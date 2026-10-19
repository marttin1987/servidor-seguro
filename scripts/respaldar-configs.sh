#!/usr/bin/env bash

# Respalda las configuraciones criticas del servidor con ATLAS.
#
# Copia las rutas de RUTAS en una carpeta de preparacion y ejecuta
# backup.sh (proyecto backups-rotatorios-atlas) sobre ella.
#
# Codigos de salida: 0 = OK, 2 = error critico (o el codigo de backup.sh)
# Uso: sudo ./scripts/respaldar-configs.sh
#
# Atencion: la copia incluye las claves privadas del servidor (/etc/ssh).
# La carpeta de destino debe ser legible solo por root.

set -u

PREPARACION="/var/backups/atlas/origen/config-servidor"
RUTAS="/etc/ssh /etc/nginx /etc/fail2ban /etc/ufw /etc/sysctl.d /etc/modprobe.d /etc/login.defs /etc/issue /etc/issue.net /etc/ssl/certs/servidor-seguro.crt /etc/ssl/private/servidor-seguro.key"

if [ "$(id -u)" -ne 0 ]; then
	echo "ERROR: ejecutar con sudo." >&2
	exit 2
fi

# Por defecto busca backup.sh en la carpeta del usuario que llamo a sudo
USUARIO="${SUDO_USER:-root}"
HOME_USUARIO=$(getent passwd "$USUARIO" | cut -d: -f6)
BACKUP_SH="${BACKUP_SH:-$HOME_USUARIO/backups-rotatorios-atlas/src/backup.sh}"

if [ ! -x "$BACKUP_SH" ]; then
	echo "ERROR: no se encuentra '$BACKUP_SH' (definir BACKUP_SH o dar permisos de ejecucion)." >&2
	exit 2
fi

mkdir -p "$PREPARACION"
chmod 700 "$PREPARACION"
# Borra la preparacion anterior para no arrastrar archivos que ya no existen
find "${PREPARACION:?}" -mindepth 1 -delete

COPIADAS=0
for ruta in $RUTAS; do
	if [ -e "$ruta" ]; then
		cp -a --parents "$ruta" "$PREPARACION"
		COPIADAS=$((COPIADAS + 1))
	else
		echo "AVISO: no existe $ruta, se omite."
	fi
done

if [ "$COPIADAS" -eq 0 ]; then
	echo "ERROR: no se copio ninguna ruta." >&2
	exit 2
fi

echo "Rutas preparadas: $COPIADAS"
"$BACKUP_SH"
