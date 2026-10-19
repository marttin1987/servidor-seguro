# 10 - HTTPS en Nginx

## Objetivo

Cifrar el tráfico web del servidor con HTTPS y redirigir el HTTP plano hacia HTTPS. Atiende la sugerencia `HTTP-6710` de Lynis (doc 07).

## Certificado

Se generó un certificado autofirmado, válido para un laboratorio. Datos comprobados con:

```bash
sudo openssl x509 -in /etc/ssl/certs/servidor-seguro.crt -noout -subject -dates
```

| Campo | Valor |
| --- | --- |
| Sujeto | `CN=servidor-seguro` |
| Válido desde | 19 oct 2026 05:06 GMT |
| Válido hasta | 19 oct 2027 05:06 GMT |
| Certificado | `/etc/ssl/certs/servidor-seguro.crt` |
| Clave privada | `/etc/ssl/private/servidor-seguro.key` |

La clave privada nunca se sube al repositorio y queda legible solo por root.

## Configuración de Nginx

Archivo `/etc/nginx/sites-available/servidor-seguro`, activado con un enlace simbólico en `sites-enabled`. El sitio `default` original se quitó de `sites-enabled` (para volver atrás, se vuelve a enlazar `sites-available/default`).

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 301 https://$host:8443$request_uri;
}

server {
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    server_name _;

    ssl_certificate     /etc/ssl/certs/servidor-seguro.crt;
    ssl_certificate_key /etc/ssl/private/servidor-seguro.key;
    ssl_protocols       TLSv1.2 TLSv1.3;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

- Solo se aceptan TLS 1.2 y 1.3.
- La redirección apunta al puerto `8443` porque en este laboratorio la VM está detrás de NAT de VirtualBox (host `8443` -> VM `443`). En un servidor real iría sin puerto.

## Firewall y red

```bash
sudo ufw allow 443/tcp
sudo ufw status
```

Reglas de reenvío de puertos de VirtualBox (persistentes): `http 8080 -> 80`, `https 8443 -> 443`, `ssh 2222 -> 22`.

## Pruebas

Antes de recargar, se valida la sintaxis:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

Desde el anfitrión:

```bash
curl -sk -o /dev/null -w '%{http_code}\n' https://127.0.0.1:8443
curl -sI http://127.0.0.1:8080 | head -3
```

| Prueba | Resultado esperado |
| --- | --- |
| HTTPS en `8443` | `200` |
| HTTP en `8080` | `301` con `Location: https://...:8443/` |

El `-k` de `curl` es necesario porque el certificado es autofirmado. También se comprobó que todo sigue funcionando después de reiniciar la VM.

## Resultado en Lynis

| Medida | Antes (doc 07) | Después |
| --- | --- | --- |
| Hardening index | 78 | 79 |
| Sugerencias | 32 | 31 |

`HTTP-6710` sigue apareciendo, pero cambió de sentido: ya no pide activar HTTPS sino ajustar su configuración.

## Backups

El certificado y la clave se agregaron a `RUTAS` en `scripts/respaldar-configs.sh`, así que entran en el backup diario. Como la copia incluye una clave privada, la carpeta de copias es solo de root (doc 08).

## Limitaciones

- Un certificado autofirmado hace que el navegador muestre una advertencia: cifra, pero no prueba identidad. En producción se usaría una autoridad reconocida, por ejemplo Let's Encrypt.
- La redirección a `8443` depende del NAT del laboratorio.

## Próximos pasos

- Ajustar el TLS para cerrar `HTTP-6710`: `ssl_prefer_server_ciphers`, `ssl_session_tickets off`, cabecera HSTS y `server_tokens off`.
- Revisar la nota exacta de Lynis en `/var/log/lynis.log` antes de cambiar nada.

## Aprendizajes

- Se valida con `nginx -t` antes de cada recarga, para no cortar el servicio por un error de sintaxis.
- Una sugerencia de Lynis puede cambiar de sentido al resolverla a medias: conviene leer su texto, no solo el código.
