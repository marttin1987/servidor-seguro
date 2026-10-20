# 13 - Regla de sudoers de mínimo privilegio

## Objetivo

Permitir que el usuario `auditor` vea el estado del servidor ejecutando un único comando con `sudo`, sin darle acceso completo de administración. Completa el doc 09.

## Diseño

- El comando permitido es `reporte-servidor.sh`, que solo lee el estado del sistema y no modifica nada.
- El script está instalado en `/usr/local/sbin`, con dueño root y modo `750` (mismo criterio del doc 12): root lo ejecuta, pero ningún usuario común puede cambiarlo.
- La regla vive en un archivo propio, `/etc/sudoers.d/auditor-reporte`, y no en `/etc/sudoers`. Para quitar el permiso alcanza con borrar ese archivo.

```text
auditor ALL=(root) NOPASSWD: /usr/local/sbin/reporte-servidor.sh
```

Se usa `NOPASSWD` porque el comando es fijo, de solo lectura y está en una ruta que el usuario no puede modificar.

## Procedimiento

Un error en `sudoers` puede dejar sin `sudo` a todos los usuarios, así que la regla se valida antes de activarla:

```bash
sudo install -m 750 -o root -g root ~/reporte-servidor.sh /usr/local/sbin/reporte-servidor.sh
echo 'auditor ALL=(root) NOPASSWD: /usr/local/sbin/reporte-servidor.sh' > ~/auditor-reporte.tmp
sudo visudo -cf ~/auditor-reporte.tmp
sudo install -m 440 -o root -g root ~/auditor-reporte.tmp /etc/sudoers.d/auditor-reporte
rm ~/auditor-reporte.tmp
sudo visudo -c
```

`visudo -cf` revisa el archivo temporal. `sudo` exige modo `440` en los archivos de `sudoers.d`. El último `visudo -c` comprueba todo el conjunto de reglas: `parsed OK` en cada archivo.

## Pruebas

| Comando | Resultado esperado | Resultado |
| --- | --- | --- |
| `sudo -u auditor sudo -n /usr/local/sbin/reporte-servidor.sh` | Reporte con `ESTADO: TODO OK` | Correcto |
| `sudo -u auditor sudo -n ufw status` | `sudo: a password is required` | Correcto |
| `sudo -u auditor sudo -n -l` | Solo `reporte-servidor.sh` | Correcto |

## Limitaciones

- La regla no restringe los argumentos. Hoy el script los ignora, pero si algún día los usara habría que revisar la regla.
- El reporte muestra la configuración efectiva de SSH y del firewall: es información de seguridad, aunque no incluye secretos.

## Próximos pasos

- Agregar al reporte con semáforo una revisión de cuentas con contraseña vencida o sin contraseña.

## Aprendizajes

- Los permisos de `sudo` se dan por comando, no por usuario: conviene empezar por ninguno y sumar solo lo necesario.
- Una regla de `sudo` sobre un script solo es segura si el usuario no puede modificar ese script.
- Validar con `visudo -cf` antes de activar evita quedarse sin acceso de administración.
