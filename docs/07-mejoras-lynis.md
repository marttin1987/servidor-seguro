# 07 - Mejoras a partir de la auditoría Lynis

## Objetivo

Aplicar las sugerencias de la primera auditoría Lynis (doc 05) que tienen sentido en este servidor, verificar cada cambio y volver a medir.

## Resultado

| Medida | Antes | Después |
| --- | --- | --- |
| Hardening index | 68 | 78 |
| Sugerencias de Lynis | 54 | 32 |

Comandos usados para medir (dentro de la VM):

```bash
sudo lynis audit system
sudo grep hardening_index /var/log/lynis-report.dat
sudo grep -c 'suggestion\[\]' /var/log/lynis-report.dat
```

## Cambios aplicados

Antes de empezar se tomó la instantánea de VirtualBox `04-antes-mejoras-lynis`.

| Lynis | Cambio | Cómo se verificó |
| --- | --- | --- |
| `PKGS-7392` | Sistema actualizado con `apt update` y `apt upgrade` | Sin paquetes pendientes |
| `PKGS-7420` | Instalado `unattended-upgrades` | `systemctl is-active unattended-upgrades` |
| `DEB-0831` | Instalado `needrestart` | Paquete instalado |
| `PKGS-7370` | Instalado `debsums` | Paquete instalado |
| `PKGS-7394` | Instalado `apt-show-versions` | Paquete instalado |
| `DEB-0280` | Instalado `libpam-tmpdir` | Paquete instalado |
| `ACCT-9628` | Instalado y activado `auditd` | `systemctl is-active auditd` |
| `SSH-7408` | Siete directivas más en `10-hardening.conf` (ver abajo) | `sshd -t` y `sshd -T` |
| `BANN-7126`, `BANN-7130` | Aviso legal en `/etc/issue` y `/etc/issue.net` | `cat /etc/issue.net` |
| `AUTH-9328`, `AUTH-9286` | `UMASK 027`, `PASS_MAX_DAYS 90`, `PASS_MIN_DAYS 1` en `/etc/login.defs` | `grep` sobre el archivo |
| `NETW-3200` | `dccp`, `sctp`, `rds` y `tipc` desactivados con `install ... /bin/false` | `modprobe -n -v dccp` |
| `USB-1000`, `STRG-1846` | `usb-storage` y FireWire desactivados | `modprobe -n -v usb-storage` |
| `KRNL-6000` | Archivos de `configs/sysctl/` aplicados | `sudo sysctl` devuelve `0`, `2`, `1`, `0` |

Los valores de `/etc/login.defs` valen solo para usuarios nuevos. El usuario `martinc` no se tocó, para no arriesgar el acceso.

## SSH: segunda ronda

Se agregaron al final de `/etc/ssh/sshd_config.d/10-hardening.conf`:

| Directiva | Valor | Motivo |
| --- | --- | --- |
| `AllowTcpForwarding` | `no` | El servidor no se usa como túnel. |
| `AllowAgentForwarding` | `no` | Evita reenviar el agente de claves. |
| `ClientAliveInterval` | `300` | Comprueba cada 5 minutos que el cliente siga ahí. |
| `ClientAliveCountMax` | `2` | Cierra la sesión tras dos comprobaciones sin respuesta. |
| `LogLevel` | `VERBOSE` | Registra la huella de la clave con la que se entra. |
| `MaxSessions` | `2` | Limita las sesiones por conexión. |
| `TCPKeepAlive` | `no` | Deja el control de sesiones inactivas a las dos directivas anteriores. |

Procedimiento: copia de respaldo del archivo, `sudo sshd -t`, `sudo systemctl reload ssh`, y prueba de una conexión nueva con otra sesión abierta como vía de escape.

## Descartado a propósito

| Sugerencia | Motivo |
| --- | --- |
| Cambiar el puerto SSH (`Port`) | Con red NAT no aporta protección real. |
| Contraseña de GRUB | Poco sentido en una VM de laboratorio sin acceso físico. |
| `mod_evasive` y `modsecurity` de Apache | El servidor web es Nginx. |

## Pendiente

Entre las 32 sugerencias que quedan está HTTPS en Nginx (`HTTP-6710`), que se aborda en un documento aparte.

## Aprendizajes

- El índice mide de forma gruesa: las rondas de SSH no movieron el número hasta que se sumaron los demás cambios.
- `sysctl` vive en `/usr/sbin`: un usuario normal necesita `sudo` para ejecutarlo en Debian.
- Cada cambio se verificó con un comando antes de darlo por hecho.
