# 09 - Usuarios y permisos

## Objetivo

Aplicar el principio de mínimo privilegio: crear un usuario que pueda leer los registros del sistema para auditar, pero que no pueda administrar el servidor, entrar por SSH ni leer secretos.

## Procedimiento

Creación del usuario `auditor` y alta en el grupo `adm`, que da lectura al registro del sistema:

```bash
sudo adduser --gecos "" auditor
sudo usermod -aG adm auditor
id auditor
```

```text
uid=1001(auditor) gid=1001(auditor) grupos=1001(auditor),4(adm),100(users)
```

El usuario no pertenece al grupo `sudo`.

## Política de contraseñas heredada

Los valores de `/etc/login.defs` aplicados en el doc 07 rigen para los usuarios nuevos. Se comprobó con `sudo chage -l auditor`:

| Parámetro | Valor |
| --- | --- |
| Mínimo entre cambios de contraseña | 1 día |
| Máximo entre cambios de contraseña | 90 días |
| Aviso antes de que caduque | 7 días |

El usuario `martinc` no se modificó, para no arriesgar el acceso de administración.

## Pruebas de límites

| Prueba | Comando | Resultado esperado | Resultado |
| --- | --- | --- | --- |
| Leer el registro del sistema | `sudo -u auditor journalctl -n 3 --no-pager` | Muestra líneas | Correcto |
| Leer una clave privada | `sudo -u auditor cat /etc/ssh/ssh_host_ed25519_key` | `Permiso denegado` | Correcto |
| Usar sudo | `sudo -u auditor sudo -n ufw status` | `a password is required` | Correcto |
| Entrar por SSH | `ssh -p 2222 auditor@127.0.0.1` | `Permission denied (publickey)` | Correcto |

El acceso por SSH queda bloqueado porque `AllowUsers martinc` (doc 06) solo admite a ese usuario. El auditor se usa desde una sesión de `martinc` con `sudo -u auditor`.

## Aprendizajes

- Los permisos de archivos protegen las claves: el auditor lee los registros por el grupo `adm`, pero no los archivos de `/etc/ssh` que son solo de root.
- Cada capa se prueba con un comando que tiene que fallar: probar lo que no se debe poder hacer es tan importante como probar lo que sí.
- Los avisos del sistema salen en el idioma del servidor, por eso un `grep` de "maximo" no encontró "máximo".

## Próximos pasos

- Agregar al reporte con semáforo una revisión de cuentas con contraseña vencida o sin contraseña.
