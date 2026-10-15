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
