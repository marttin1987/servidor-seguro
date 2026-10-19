#!/usr/bin/env bash

# Reporte de estado del servidor con semaforo.
#
# Codigos de salida:
#   0 = todo OK
#   1 = hay avisos (conviene revisar)
#   2 = hay fallos criticos (hay que actuar)
#
# Uso: sudo ./scripts/reporte-servidor.sh
# Sin sudo se omiten las verificaciones que necesitan privilegios.

set -u
export LC_ALL=C

SEPARATOR="=========================================="
UMBRAL_DISCO_AVISO=80
UMBRAL_DISCO_CRITICO=90
UMBRAL_MEMORIA_LIBRE=10
SERVICIOS_CRITICOS="ssh nginx fail2ban ufw auditd"

AVISOS=0
FALLOS=0

if [ -t 1 ]; then
	VERDE=$'\033[32m'
	AMARILLO=$'\033[33m'
	ROJO=$'\033[31m'
	RESET=$'\033[0m'
else
	VERDE=""
	AMARILLO=""
	ROJO=""
	RESET=""
fi

ok() {
	printf '%s[  OK  ]%s %s\n' "$VERDE" "$RESET" "$1"
}

aviso() {
	printf '%s[AVISO ]%s %s\n' "$AMARILLO" "$RESET" "$1"
	AVISOS=$((AVISOS + 1))
}

fallo() {
	printf '%s[FALLO ]%s %s\n' "$ROJO" "$RESET" "$1"
	FALLOS=$((FALLOS + 1))
}

seccion() {
	echo
	echo "$SEPARATOR"
	echo "$1"
	echo "$SEPARATOR"
}

# verificar_ssh <directiva> <valor esperado> <fallo|aviso>
verificar_ssh() {
	local clave="$1" esperado="$2" severidad="$3"
	if grep -qix "$clave $esperado" <<< "$SSHD_CONF"; then
		ok "SSH $clave = $esperado"
	elif [ "$severidad" = "fallo" ]; then
		fallo "SSH $clave deberia ser '$esperado'"
	else
		aviso "SSH $clave deberia ser '$esperado'"
	fi
}

echo "$SEPARATOR"
echo "REPORTE DE ESTADO DEL SERVIDOR"
echo "$SEPARATOR"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Hostname: $(hostname)"
if [ -r /etc/os-release ]; then
	# shellcheck disable=SC1091
	. /etc/os-release
	echo "Sistema: ${PRETTY_NAME:-Desconocido}"
fi
echo "Kernel: $(uname -r)"
echo "Actividad: $(uptime -p 2>/dev/null || uptime)"

seccion "RECURSOS"
USO_DISCO=$(df --output=pcent / | tail -n 1 | tr -dc '0-9')
if [ -z "$USO_DISCO" ]; then
	aviso "No se pudo leer el uso de disco"
elif [ "$USO_DISCO" -ge "$UMBRAL_DISCO_CRITICO" ]; then
	fallo "Disco / al ${USO_DISCO}% (critico desde ${UMBRAL_DISCO_CRITICO}%)"
elif [ "$USO_DISCO" -ge "$UMBRAL_DISCO_AVISO" ]; then
	aviso "Disco / al ${USO_DISCO}% (aviso desde ${UMBRAL_DISCO_AVISO}%)"
else
	ok "Disco / al ${USO_DISCO}%"
fi

MEM_LIBRE=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if (t > 0) printf "%d", a * 100 / t}' /proc/meminfo)
if [ -z "$MEM_LIBRE" ]; then
	aviso "No se pudo leer la memoria disponible"
elif [ "$MEM_LIBRE" -lt "$UMBRAL_MEMORIA_LIBRE" ]; then
	aviso "Memoria disponible al ${MEM_LIBRE}% (aviso por debajo de ${UMBRAL_MEMORIA_LIBRE}%)"
else
	ok "Memoria disponible al ${MEM_LIBRE}%"
fi

seccion "SERVICIOS"
for servicio in $SERVICIOS_CRITICOS; do
	if systemctl is-active --quiet "$servicio" 2> /dev/null; then
		ok "Servicio $servicio activo"
	else
		fallo "Servicio $servicio inactivo o no instalado"
	fi
done

seccion "SEGURIDAD"
if [ "$(id -u)" -ne 0 ]; then
	aviso "Sin privilegios: se omiten UFW, SSH y fail2ban (ejecutar con sudo)"
else
	if ufw status 2> /dev/null | grep -q '^Status: active'; then
		ok "Firewall UFW activo"
	else
		fallo "Firewall UFW inactivo"
	fi

	SSHD_CONF=$(sshd -T 2> /dev/null)
	if [ -z "$SSHD_CONF" ]; then
		aviso "No se pudo leer la configuracion efectiva de SSH"
	else
		verificar_ssh passwordauthentication no fallo
		verificar_ssh permitrootlogin no fallo
		verificar_ssh pubkeyauthentication yes fallo
		verificar_ssh x11forwarding no aviso
		verificar_ssh maxauthtries 3 aviso
		verificar_ssh allowtcpforwarding no aviso
	fi

	BANEADOS=$(fail2ban-client status sshd 2> /dev/null | awk '/Currently banned/ {print $NF}')
	if [ -z "$BANEADOS" ]; then
		aviso "No se pudo leer el jail sshd de fail2ban"
	else
		ok "fail2ban: $BANEADOS IP bloqueadas ahora en sshd"
	fi
fi

seccion "ACTUALIZACIONES"
PENDIENTES=$(apt list --upgradable 2> /dev/null | grep -c '/')
if [ "$PENDIENTES" -gt 0 ]; then
	aviso "$PENDIENTES paquetes con actualizacion pendiente"
else
	ok "Sin paquetes pendientes de actualizar"
fi
if [ -f /var/run/reboot-required ]; then
	aviso "El sistema necesita reiniciarse"
else
	ok "No hace falta reiniciar"
fi

seccion "RESUMEN"
echo "Fallos: $FALLOS   Avisos: $AVISOS"
if [ "$FALLOS" -gt 0 ]; then
	printf '%sESTADO: CRITICO%s\n' "$ROJO" "$RESET"
	exit 2
elif [ "$AVISOS" -gt 0 ]; then
	printf '%sESTADO: CON AVISOS%s\n' "$AMARILLO" "$RESET"
	exit 1
else
	printf '%sESTADO: TODO OK%s\n' "$VERDE" "$RESET"
	exit 0
fi
