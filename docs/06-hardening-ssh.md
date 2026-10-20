# 06 - Endurecimiento de SSH

## Objetivo

Reducir la superficie de ataque del servicio SSH del servidor Debian: desactivar la autenticación por contraseña, impedir el acceso directo de `root` y limitar los intentos y los usuarios permitidos.

## Entorno

- Servidor: Debian GNU/Linux 13 (`servidor-seguro`), en VirtualBox con red NAT.
- Acceso desde el anfitrión Ubuntu: `127.0.0.1:2222` hacia el puerto 22 de la VM.
- Autenticación: clave pública Ed25519 (la clave privada permanece fuera del repositorio).
- Punto de recuperación previo: instantánea de VirtualBox `02-antes-hardening-ssh`.

## Procedimiento

La configuración se escribió en un archivo aparte, sin modificar `/etc/ssh/sshd_config`, para poder deshacerla borrando un solo archivo:

```bash
printf '%s\n' \
  'PasswordAuthentication no' \
  'KbdInteractiveAuthentication no' \
  'PermitRootLogin no' \
  'PubkeyAuthentication yes' \
  'MaxAuthTries 3' \
  'LoginGraceTime 30' \
  'X11Forwarding no' \
  'AllowUsers martinc' \
  | sudo tee /etc/ssh/sshd_config.d/10-hardening.conf
```

Antes de aplicar el cambio se validó la sintaxis y se mantuvo una sesión SSH abierta como vía de recuperación:

```bash
sudo sshd -t && echo "config OK"
sudo systemctl reload ssh
```

## Directivas aplicadas

| Directiva | Valor | Motivo |
| --- | --- | --- |
| `PasswordAuthentication` | `no` | Elimina los ataques de fuerza bruta contra contraseñas. |
| `KbdInteractiveAuthentication` | `no` | Evita que la contraseña se pida por otro método interactivo. |
| `PermitRootLogin` | `no` | Obliga a entrar con un usuario normal y elevar con `sudo`. |
| `PubkeyAuthentication` | `yes` | Deja la clave pública como único método de entrada. |
| `MaxAuthTries` | `3` | Limita los intentos de autenticación por conexión. |
| `LoginGraceTime` | `30` | Corta las conexiones que no se autentican en 30 segundos. |
| `X11Forwarding` | `no` | Desactiva una función que el servidor no necesita. |
| `AllowUsers` | `martinc` | Solo ese usuario puede iniciar sesión por SSH. |

## Verificación

Configuración efectiva informada por el servidor:

```bash
sudo sshd -T | grep -Ei "passwordauthentication|kbdinteractive|permitrootlogin|maxauthtries|logingracetime|x11forwarding|allowusers"
```

Resultado: las ocho directivas coinciden con los valores de la tabla.

Prueba de rechazo de contraseña, desde el anfitrión:

```bash
ssh -o PubkeyAuthentication=no -p 2222 martinc@127.0.0.1
```

```text
martinc@127.0.0.1: Permission denied (publickey).
```

**Resultado:** el servidor ya no ofrece autenticación por contraseña.

Prueba de acceso con clave, después de aplicar el cambio:

```bash
ssh -i ~/.ssh/id_lab -p 2222 martinc@127.0.0.1
```

**Resultado:** el acceso con clave funciona después de aplicar el cambio.

## Problemas encontrados y cómo se resolvieron

### 1. Archivo de configuración mal escrito

Al crear el archivo con `printf '%s\' ...` faltó la `n` de `\n`. Las ocho directivas quedaron pegadas en una sola línea y `sshd -t` falló con `unsupported option`. La validación previa evitó aplicar un cambio roto. Se reescribió el archivo con `printf '%s\n' ...` y `sshd -t` devolvió `config OK`.

**Aprendizaje:** validar siempre con `sshd -t` antes de recargar. Un archivo inválido puede impedir que el servicio arranque en el siguiente reinicio.

### 2. `Connection refused` desde el anfitrión

La conexión a `127.0.0.1:2222` era rechazada aunque la VM estaba encendida, la regla figuraba en `showvminfo` y `sshd` estaba activo. Se descartó que fail2ban hubiera bloqueado la dirección. Se resolvió borrando y recreando la regla de reenvío:

```bash
VBoxManage controlvm servidor-seguro natpf1 delete ssh
VBoxManage controlvm servidor-seguro natpf1 "ssh,tcp,127.0.0.1,2222,,22"
```

**Aprendizaje:** que una regla aparezca listada no garantiza que esté activa.

### 3. Diagnóstico que ocultaba la salida

Un comando de diagnóstico con `| tail` retenía la salida hasta que terminaba la sesión interactiva, y parecía un cuelgue. Sin el pipe se vio que la conexión funcionaba.

**Aprendizaje:** no encadenar con `tail` un comando interactivo.

## Consideración con fail2ban y NAT

Con la red NAT de VirtualBox, todas las conexiones del anfitrión llegan al servidor desde la misma dirección (`10.0.2.2`). Si fail2ban la bloquea, queda bloqueado todo el acceso. En un laboratorio con NAT conviene agregar la dirección a la lista de exclusión (`ignoreip`) de la configuración de fail2ban (ver doc 14).

## Reversión

Si el cambio impide el acceso, desde una sesión abierta o desde la consola de VirtualBox:

```bash
sudo rm /etc/ssh/sshd_config.d/10-hardening.conf
sudo systemctl reload ssh
```

## Próximos pasos

- Volver a ejecutar Lynis y comparar con el índice inicial de 68.
- Incorporar la verificación de estas directivas al script de reporte.
- Evaluar cambiar el puerto o restringir el acceso por origen cuando la red deje de ser NAT.
