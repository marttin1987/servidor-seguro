# Etapa 2 — Firewall y acceso SSH

## Objetivo

Configurar un firewall básico en Debian 13 y verificar que la administración remota mediante SSH continúe funcionando.

## Entorno

- Sistema: Debian GNU/Linux 13 (Trixie).
- Máquina virtual: `servidor-seguro`.
- Usuario administrativo: `martinc`.
- Red: NAT de VirtualBox.
- Acceso SSH desde Ubuntu: `127.0.0.1:2222` hacia el puerto `22` de Debian.

## Configuración aplicada

Se instalaron y configuraron reglas de UFW:

- Política predeterminada de entrada: `deny`.
- Política predeterminada de salida: `allow`.
- Puerto TCP 22: permitido para SSH.
- Registro del firewall: activado en nivel bajo.

## Verificación

El comando `sudo ufw status verbose` confirmó:

- Firewall activo.
- Entradas bloqueadas por defecto.
- Salidas permitidas por defecto.
- Puerto 22 permitido para IPv4 e IPv6.

Se probó una conexión SSH desde Ubuntu mediante la clave pública. La conexión fue exitosa después de activar el firewall.

## Observaciones

La prueba de `sudo -n true` indicó que sudo requiere autenticación interactiva en esa ejecución. Esto no afecta la autenticación SSH por clave pública.

## Próximos pasos

- Revisar la configuración efectiva de SSH.
- Evaluar la desactivación de autenticación SSH por contraseña después de validar el acceso por clave.
- Instalar Nginx y comprobar su funcionamiento.
- Integrar pruebas de servicios con el proyecto de monitoreo ATLAS.

# Ocho parametros de Hardening
- Maxauthtries 3
- Permitrootlogin no
- Pubkeyauthentication yes
- Passwordauthentication no
- Kbdinteractiveauthentication no
- Allowusers martinc
- X11Forwarding no
- LoginGraceTime 30

## Protección SSH con Fail2ban

### Instalación y configuración

Se instaló Fail2ban en Debian GNU/Linux 13 y se configuró una cárcel específica para SSH en `/etc/fail2ban/jail.d/sshd.local`.

Parámetros configurados:

- **Servicio protegido:** SSH (`sshd`).
- **Puerto:** 22.
- **Máximo de intentos fallidos:** 5.
- **Ventana de detección:** 10 minutos.
- **Duración del bloqueo:** 15 minutos.
- **Backend:** systemd.

### Verificación

Se comprobó el estado del servicio mediante `systemctl status fail2ban` y la cárcel mediante `fail2ban-client status sshd`.

Resultado observado:

- Intentos fallidos actuales: 0.
- Intentos fallidos acumulados: 0.
- Direcciones IP bloqueadas actualmente: 0.

Estos valores indican que, al momento de la comprobación, no se habían registrado fallos ni bloqueos en esa cárcel.

### Objetivo de seguridad

Fail2ban agrega una capa de protección frente a intentos repetidos de autenticación. Complementa, pero no reemplaza, el endurecimiento de SSH ni las reglas del firewall.
