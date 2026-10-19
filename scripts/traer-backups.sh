#!/usr/bin/env bash

# Trae al anfitrion la ultima copia exportada por la VM y verifica su
# firma SHA-256. Borra las copias locales con mas de RETENCION_DIAS dias.
#
# Codigos de salida: 0 = OK, 1 = firma no coincide, 2 = error
# Uso: ./scripts/traer-backups.sh   (en el anfitrion, con la VM encendida)

set -u

SERVIDOR="${SERVIDOR:-servidor-seguro}"
DESTINO="${DESTINO:-$HOME/backups-servidor-seguro}"
RETENCION_DIAS=30

mkdir -p "$DESTINO"
chmod 700 "$DESTINO"

if ! scp -p "$SERVIDOR:backups-export/*" "$DESTINO/"; then
	echo "ERROR: no se pudo copiar desde $SERVIDOR (VM encendida? se corrio exportar-backup.sh?)." >&2
	exit 2
fi

cd "$DESTINO" || exit 2

if ! sha256sum -c --quiet ./*.sha256; then
	echo "ERROR: alguna firma SHA-256 no coincide." >&2
	exit 1
fi

find "$DESTINO" -maxdepth 1 -type f -name 'backup_atlas_*' -mtime +"$RETENCION_DIAS" -delete

echo "OK: $(find "$DESTINO" -maxdepth 1 -name '*.tar.gz' | wc -l) copias verificadas en $DESTINO"
