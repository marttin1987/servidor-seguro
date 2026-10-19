# 12 - Scripts de root fuera de /home

## Objetivo

Separar lo que ejecuta root de lo que puede editar un usuario común. Cierra el riesgo anotado en el doc 11.

## Problema

El crontab de root ejecutaba scripts que vivían en `/home/martinc`:

- `respaldar-configs.sh`
- `backups-rotatorios-atlas/src/backup.sh` y `verificar.sh`

Esas carpetas las puede modificar `martinc`. Además ATLAS carga `config/backup.conf` con `source`, así que cualquier comando escrito ahí se ejecutaría como root.

En este laboratorio `martinc` ya tiene `sudo`, por lo que el riesgo práctico es bajo. Aun así, la regla es la correcta: root solo ejecuta lo que root controla. Con otro usuario sin `sudo`, o con una sesión de `martinc` comprometida, esto sería una escalada de privilegios.

## Cambios

| Antes | Después | Permisos |
| --- | --- | --- |
| `/home/martinc/backups-rotatorios-atlas` | `/opt/atlas` | root:root, sin escritura para otros |
| `/home/martinc/respaldar-configs.sh` | `/usr/local/sbin/respaldar-configs.sh` | root:root, `750` |
| `/home/martinc/exportar-backup.sh` | `/usr/local/sbin/exportar-backup.sh` | root:root, `750` |

Procedimiento:

```bash
sudo cp -a ~/backups-rotatorios-atlas /opt/atlas
sudo chown -R root:root /opt/atlas
sudo chmod -R go-w /opt/atlas
sudo install -m 750 -o root -g root ~/respaldar-configs.sh /usr/local/sbin/respaldar-configs.sh
```

ATLAS busca su configuración relativa a la carpeta del script, por eso se pudo mover la carpeta completa sin cambiar nada.

## Crontab de root

Se guardó una copia (`crontab -l > crontab-root.bak`), se armó la versión nueva en un archivo con `sed`, se revisó y recién entonces se cargó con `sudo crontab archivo`:

```cron
0 2  * * * BACKUP_SH=/opt/atlas/src/backup.sh /usr/local/sbin/respaldar-configs.sh >> /var/log/atlas-cron.log 2>&1
30 2 * * * /opt/atlas/src/verificar.sh >> /var/log/atlas-verificacion.log 2>&1
```

## Pruebas

| Prueba | Resultado |
| --- | --- |
| `sudo BACKUP_SH=/opt/atlas/src/backup.sh /usr/local/sbin/respaldar-configs.sh` | 11 rutas preparadas, backup creado, `rc=0` |
| `sudo /opt/atlas/src/verificar.sh` | Todas las firmas en `OK`, `rc=0` |
| `sudo crontab -l \| grep -c '/home/martinc'` | `0` |

## Mantenimiento

- Para cambiar la configuración de ATLAS se edita `/opt/atlas/config/backup.conf` con `sudo`.
- Para actualizar un script se vuelve a instalar con `install`: editar la copia del repositorio no cambia lo que corre cron.
- El repositorio de ATLAS sigue siendo el original; `/opt/atlas` es una copia desplegada con la configuración de este servidor.

## Aprendizajes

- Todo lo que ejecuta root de forma automática debe estar en un lugar que solo root pueda modificar.
- Antes de tocar el crontab: copia de seguridad, versión nueva en un archivo, revisión y recién después carga.
- El `UMASK 027` volvió a aparecer: la carpeta copiada quedó cerrada para `martinc`, y se comprobó con `sudo ls`.
