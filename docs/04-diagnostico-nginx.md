# 04 — Diagnóstico de Nginx y recursos HTTP

## Objetivo

Verificar el funcionamiento del servidor web, analizar los registros y comprobar la entrega de archivos estáticos.

## Entorno

- Servidor: Debian GNU/Linux 13.
- Servidor web: Nginx.
- Cliente: Ubuntu mediante Firefox y curl.
- Acceso web: `http://127.0.0.1:8080` desde Ubuntu.
- Directorio web: `/var/www/html`.

## Recursos publicados

- `index.html`: página HTML personalizada del laboratorio.
- `favicon.ico`: archivo de ícono del sitio.
- `index.nginx-debian.html`: página predeterminada de Debian.
- `index.html.bak`: copia de seguridad de la página personalizada.

## Verificaciones realizadas

Se consultaron los registros de acceso de Nginx mediante:

`sudo tail -f /var/log/nginx/access.log`

Se identificaron los siguientes códigos HTTP:

- `200 OK`: solicitud atendida correctamente.
- `304 Not Modified`: el navegador puede reutilizar un recurso almacenado en caché.
- `404 Not Found`: recurso solicitado inexistente, observado inicialmente para `/favicon.ico`.

Se revisó el registro de errores con:

`sudo tail -n 20 /var/log/nginx/error.log`

No se observaron errores relevantes en las líneas consultadas.

## Pruebas finales

Página principal:

`curl -I http://127.0.0.1/`

Resultado: `HTTP/1.1 200 OK`.

Favicon:

`curl -I http://127.0.0.1/favicon.ico`

Resultado: `HTTP/1.1 200 OK`, con tipo de contenido `image/x-icon`.

## Conclusión

Nginx entrega correctamente la página HTML y el archivo favicon. Se practicaron comprobaciones HTTP, inspección de logs y diagnóstico básico de recursos estáticos.

## Próximos pasos

- Verificar visualmente el favicon en Firefox.
- Aprender a consultar y filtrar logs con `grep`.
- Integrar las comprobaciones en un script de monitoreo.

## 1. Verificación del firewall UFW

Comando ejecutado:

```bash
sudo ufw status verbose
```

Salida observada:

```text
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
80/tcp                     ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
80/tcp (v6)                ALLOW IN    Anywhere (v6)
```

**Resultado:** UFW está activo, bloquea por defecto las conexiones entrantes y permite las conexiones entrantes a los puertos TCP 22 (SSH) y 80 (HTTP), tanto para IPv4 como para IPv6.

## 2. Verificación de la respuesta HTTP

Comando ejecutado:

```bash
curl -I http://127.0.0.1/
```

Salida observada:

```text
HTTP/1.1 200 OK
Server: nginx
Date: Thu, 15 Oct 2026 12:37:05 GMT
Content-Type: text/html
Content-Length: 429
Last-Modified: Wed, 14 Oct 2026 21:38:58 GMT
Connection: keep-alive
ETag: "6acff672-1ad"
Accept-Ranges: bytes
```

**Resultado:** el servidor Nginx respondió con HTTP 200 OK, indicando que la solicitud fue atendida correctamente.

## 3. Estado del servicio Nginx

Comando ejecutado:

```bash
systemctl status nginx --no-pager
```

Resultado observado:

- Servicio: `nginx.service`.
- Estado: `active (running)`.
- Inicio automático: habilitado (`enabled`).
- Verificación previa de configuración: finalizó con `status=0/SUCCESS`.

**Resultado:** Nginx está en ejecución y configurado para iniciarse automáticamente con el sistema.



