# 11 - Copia de backups fuera de la VM

## Objetivo

Resolver la limitación principal del doc 08: las copias estaban en el mismo disco que el servidor. Si ese disco se pierde, se pierden también los backups. Ahora la última copia se trae al anfitrión y se verifica allá.

## Diseño

Cada noche, en la VM:

| Hora | Tarea | Dónde |
| --- | --- | --- |
| 02:00 | Backup con ATLAS (doc 08) | `crontab` de root |
| 02:30 | Verificación de las firmas SHA-256 | `crontab` de root |
| 02:45 | Exportación de la última copia | `/etc/cron.d/atlas-export` |

Cuando el anfitrión lo necesita, trae la copia por SSH:

```bash
./scripts/traer-backups.sh
```

La VM no puede copiar hacia el anfitrión por su cuenta: el acceso va solo del anfitrión a la VM, con clave. Por eso el diseño es de tipo "traer" y no "enviar".

## Scripts

| Script | Dónde corre | Qué hace |
| --- | --- | --- |
| `scripts/exportar-backup.sh` | VM, como root | Copia la última copia y su firma a `/home/martinc/backups-export` (carpeta `700` de `martinc`) y deja solo esa última. |
| `scripts/traer-backups.sh` | Anfitrión | Trae esa carpeta con `scp`, verifica las firmas con `sha256sum -c` y borra copias locales de más de 30 días. |

Códigos de salida de `traer-backups.sh`: `0` correcto, `1` firma que no coincide, `2` error al copiar.

## Seguridad

- El script que corre cron se instaló en `/usr/local/sbin`, con dueño root y modo `750`. Si quedara en la carpeta de `martinc`, ese usuario podría modificarlo y lograr que root ejecute lo que él quiera.
- El archivo `/etc/cron.d/atlas-export` quedó con modo `640` por el `UMASK 027` del doc 07, y se dejó en `644`, que es lo habitual.
- La copia incluye las claves privadas del servidor. La carpeta de exportación es `700` y la de destino en el anfitrión también.

## Pruebas

1. Copia manual de la última copia a `backups-export` y descarga con `scp`: la firma dio `OK`.
2. Primer intento con `rsync`: falló porque la VM no lo tiene instalado. Se resolvió con `scp`, que ya estaba disponible.
3. Con los scripts: `exportar-backup.sh` en la VM (`Exportado: backup_atlas_...`) y `traer-backups.sh` en el anfitrión (`OK`, `rc=0`).
4. Con copias de prueba se comprobó que una copia dañada hace fallar a `traer-backups.sh` con `rc=1`.

## Limitaciones

- En este laboratorio la VM y el anfitrión comparten la misma máquina física. Un esquema real llevaría la copia a otro equipo o a un servicio externo.
- Traer la copia es manual: depende de que se ejecute `traer-backups.sh`.
- Las copias no están cifradas. Quien lea el archivo obtiene las claves del servidor.
- La primera ejecución automática de las 02:45 se confirma revisando `/var/log/atlas-export.log` al día siguiente.

## Próximos pasos

- Cifrar las copias antes de sacarlas de la VM, por ejemplo con GPG.
- Instalar también `respaldar-configs.sh` en `/usr/local/sbin`: hoy cron lo ejecuta como root desde la carpeta de `martinc`, con el mismo riesgo que se corrigió acá.
- Agregar al reporte con semáforo la revisión de `/var/log/atlas-export.log`.

## Aprendizajes

- Un script que ejecuta root con cron no debe poder ser modificado por un usuario común.
- La política de permisos que se endurece en un lugar (`UMASK`) afecta archivos nuevos en todo el sistema: conviene revisar los permisos de lo que se crea después.
- Un backup que se guarda en el mismo disco protege de un error, pero no de la pérdida del disco.
