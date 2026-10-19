#!/usr/bin/env bash

# Deja la ultima copia de ATLAS (y su firma SHA-256) en una carpeta
# legible por el usuario administrador, para que el anfitrion la pueda
# traer por SSH sin usar sudo.
#
# Codigos de salida: 0 = OK, 2 = error
# Uso: sudo ./scripts/exportar-backup.sh
#
# Atencion: la copia incluye las claves privadas del servidor. La carpeta
# de destino es 700 y pertenece solo al usuario administrador.

set -u

ORIGEN="${ORIGEN:-/var/backups/atlas/copias}"
DESTINO="${DESTINO:-/home/martinc/backups-export}"
USUARIO="${USUARIO_EXPORT:-martinc}"

if [ "$(id -u)" -ne 0 ]; then
	echo "ERROR: ejecutar con sudo." >&2
	exit 2
fi

ULTIMO=$(find "$ORIGEN" -maxdepth 1 -name '*.tar.gz' -printf '%T@ %p\n' 2> /dev/null | sort -n | tail -n 1 | cut -d' ' -f2-)
if [ -z "$ULTIMO" ] || [ ! -f "$ULTIMO.sha256" ]; then
	echo "ERROR: no hay una copia con su firma en $ORIGEN." >&2
	exit 2
fi

install -d -o "$USUARIO" -g "$USUARIO" -m 700 "$DESTINO"
# Deja solo la ultima copia: el historial queda en el anfitrion
find "${DESTINO:?}" -mindepth 1 -maxdepth 1 -delete
cp -p "$ULTIMO" "$ULTIMO.sha256" "$DESTINO/"
chown -R "$USUARIO:$USUARIO" "$DESTINO"

echo "Exportado: $(basename "$ULTIMO")"
