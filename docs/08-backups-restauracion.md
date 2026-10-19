# 08 - Backups y prueba de restauración

## Objetivo

Tener copias automáticas y verificables de las configuraciones críticas del servidor, y comprobar que se pueden restaurar. Se reutiliza el proyecto `backups-rotatorios-atlas` (compresión atómica, firma SHA-256 y rotación por antigüedad).

## Qué se respalda

| Ruta | Contenido |
| --- | --- |
| `/etc/ssh` | Configuración de SSH y claves del servidor |
| `/etc/nginx` | Configuración del servidor web |
| `/etc/fail2ban` | Reglas de bloqueo |
| `/etc/ufw` | Reglas del firewall |
| `/etc/sysctl.d` | Parámetros del kernel |
| `/etc/modprobe.d` | Módulos desactivados |
| `/etc/login.defs` | Política de cuentas |
| `/etc/issue`, `/etc/issue.net` | Aviso legal |
| `/etc/ssl/certs/servidor-seguro.crt` y `/etc/ssl/private/servidor-seguro.key` | Certificado y clave de HTTPS (doc 10) |

## Diseño

`backup.sh` respalda una sola carpeta, y estas configuraciones están repartidas por `/etc`. El script `scripts/respaldar-configs.sh` copia las rutas a una carpeta de preparación (`/var/backups/atlas/origen/config-servidor`), conservando permisos y estructura con `cp -a --parents`, y después llama a `backup.sh` sobre esa carpeta.

- La carpeta de preparación se vacía en cada corrida, para no arrastrar archivos que ya no existen.
- Si una ruta no existe, el script avisa y sigue. Si no se copia ninguna, termina con error.
- Exige `sudo`: sin privilegios no se pueden leer todos los archivos.
- Los backups se guardan en `/var/backups/atlas/copias`, con permisos `700` (solo root).

La copia incluye las claves privadas del servidor. Por eso la carpeta es solo de root y los archivos temporales de las pruebas se borran.

## Configuración en el servidor

En `config/backup.conf` de la copia de ATLAS en la VM:

```bash
DIR_ORIGEN="/var/backups/atlas/origen/config-servidor"
DIR_DESTINO="/var/backups/atlas/copias"
LOG_FILE="/var/log/atlas-backup.log"
DIAS_RETENCION=7
UMBRAL_DISCO_MAX=90
```

Estas rutas son específicas de este servidor, por eso el cambio no se sube al repositorio de ATLAS.

## Pruebas

Primer backup:

```bash
sudo ~/respaldar-configs.sh; echo "rc=$?"
```

Resultado: 9 rutas preparadas (11 al sumar el certificado y la clave de HTTPS), backup creado, `rc=0`.

Verificación de la firma:

```bash
sudo ~/backups-rotatorios-atlas/src/verificar.sh; echo "rc=$?"
```

Resultado: la firma SHA-256 coincide (`OK`) y `rc=0`.

### Restauración

Se extrajo la copia más reciente en una carpeta temporal y se comparó con lo que hay en el servidor:

```bash
sudo mkdir -p /tmp/restauracion
sudo bash -c 'tar -xzf "$(ls -t /var/backups/atlas/copias/*.tar.gz | head -1)" -C /tmp/restauracion'
sudo diff -r /etc/ssh /tmp/restauracion/config-servidor/etc/ssh && echo "SSH IGUAL"
sudo diff -r /etc/nginx /tmp/restauracion/config-servidor/etc/nginx && echo "NGINX IGUAL"
sudo rm -rf /tmp/restauracion
```

Resultado: `diff -r` no encontró diferencias en `/etc/ssh` ni en `/etc/nginx`. La copia de prueba se borró al terminar.

## Automatización

Tareas en el `crontab` de root:

```cron
0 2 * * *  BACKUP_SH=/home/martinc/backups-rotatorios-atlas/src/backup.sh /home/martinc/respaldar-configs.sh >> /var/log/atlas-cron.log 2>&1
30 2 * * * /home/martinc/backups-rotatorios-atlas/src/verificar.sh >> /var/log/atlas-verificacion.log 2>&1
```

El backup corre a las 02:00 y la verificación a las 02:30. La variable `BACKUP_SH` es necesaria porque `cron` no define `SUDO_USER` y el script no sabría en qué carpeta buscar `backup.sh`.

Antes de dejar el horario definitivo, se probó con una ejecución cada 3 minutos y se comprobó en `/var/log/atlas-cron.log` que el backup terminaba bien.

## Limitaciones

- Las copias están en el mismo disco que el servidor. Si el disco se pierde, se pierden también. Se atiende en el doc 11, que trae la última copia al anfitrión.
- Solo se respaldan configuraciones, no el contenido web ni datos de usuarios.
- La primera ejecución programada se confirma revisando `/var/log/atlas-cron.log` al día siguiente.

## Próximos pasos

- Cifrar las copias y llevarlas a otra máquina (ver doc 11).
- Agregar el estado del último backup al reporte con semáforo.
