#!/usr/bin/env bash

# Reporte basico de estado del servidor Linux

set -u

SEPARATOR="=========================================="

echo "$SEPARATOR"
echo "REPORTE DE ESTADO DEL SERVIDOR"
echo "$SEPARATOR"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Hostname: $(hostname)"
echo

echo "$SEPARATOR"
echo "SISTEMA OPERATIVO"
echo "$SEPARATOR"
if [ -r /etc/os-release ]; then
	. /etc/os-release
	echo "Sistema: ${PRETTY_NAME:-Desconocido}"
fi
echo "Kernel: $(uname -r)"
echo

echo "$SEPARATOR"
echo "TIEMPO DE ACTIVIDAD"
echo "$SEPARATOR"
uptime
echo

echo "$SEPARATOR"
echo "MEMORIA"
echo "$SEPARATOR"
free -h
echo

echo "$SEPARATOR"
echo "ESPACIO EN DISCO"
echo "$SEPARATOR"
df -h /
echo

echo "$SEPARATOR"
echo "ESTADO DE SERVICIOS"
echo "$SEPARATOR"
for service in ssh nginx fail2ban; do
	if systemctl is-active --quiet "$service"; then
		echo "$service: ACTIVO"
	else
		echo "$service: INACTIVO O NO INSTALADO"
	fi
done
echo

echo "$SEPARATOR"
echo "FIREWALL UFW"
echo "$SEPARATOR"
if command -v ufw > /dev/null 2>&1; then
	sudo ufw status verbose
else
	echo "UFW no esta instalado."
fi
echo

echo "$SEPARATOR"
echo "FIN DEL REPORTE"
echo "$SEPARATOR"


