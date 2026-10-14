# 03 — Nginx y acceso web desde Ubuntu

## Objetivo

Instalar y verificar un servidor web Nginx en Debian 13, dentro de una máquina virtual VirtualBox, y acceder desde Ubuntu mediante reenvío de puertos NAT.

## Entorno

- Sistema servidor: Debian GNU/Linux 13.
- Sistema anfitrión: Ubuntu.
- Servidor web: Nginx.
- Protocolo: HTTP sobre TCP.
- Puerto de Nginx en Debian: 80.
- Puerto de acceso local en Ubuntu: 8080.

## Configuración de red

Se configuró la siguiente regla NAT en VirtualBox:

`http,tcp,127.0.0.1,8080,,80`

Esto reenvía las conexiones dirigidas al puerto 8080 de la interfaz local de Ubuntu hacia el puerto 80 de Debian.

La regla SSH existente se conservó:

`ssh,tcp,127.0.0.1,2222,,22`

## Firewall

UFW está activo con las políticas predeterminadas de entrada denegada y salida permitida. Se habilitaron los puertos 22/TCP y 80/TCP para SSH y HTTP, respectivamente.

El reenvío HTTP de VirtualBox está vinculado a `127.0.0.1`, por lo que el acceso publicado por esa regla queda limitado al equipo anfitrión.

## Verificación

Se comprobó que Nginx respondía con HTTP `200 OK` y que la página predeterminada de bienvenida era accesible desde Firefox en Ubuntu mediante:

`http://127.0.0.1:8080`

## Resultado

El servidor web funciona y puede ser consultado desde el anfitrión a través de NAT.

## Próximos pasos

- Reemplazar la página predeterminada por una página propia.
- Revisar los registros de acceso y errores de Nginx.
- Verificar el estado del servicio y su inicio automático.
- Documentar las pruebas y conservar evidencias del laboratorio.
