# Laboratorio de Servidor Linux Seguro

## Descripción

Proyecto práctico de administración de sistemas Linux orientado a la configuración, protección, monitorización y mantenimiento de un servidor Debian.

## Entorno

- Anfitrión: Ubuntu
- Virtualización: VirtualBox
- Servidor: Debian
- Administración remota: autenticacion mediante clave publica configurada; endurecimiento adicional pendiente.
- Red inicial: NAT con redirección de puertos

## Objetivos de aprendizaje

- Administrar usuarios, grupos y permisos.
- Configurar y verificar el acceso SSH.
- Gestionar servicios y conectividad de red.
- Implementar un firewall.
- Desplegar un servidor web.
- Auditar la configuración de seguridad.
- Automatizar verificaciones mediante Bash.
- Realizar backups y comprobar su restauración.

## Progreso

- [x] Conexión SSH desde el anfitrión al servidor.
- [x] Autenticación mediante clave pública.
- [x] Inventario inicial de red.
- [ ] Administración de usuarios y permisos.
- [x] Endurecimiento de SSH.
- [x] Firewall y servidor web.
- [x] Monitorización y auditoría.
- [ ] Reporte automatizado.
- [ ] Backups y prueba de restauración.

## Documentación

- [Instalación y resolución de problemas](docs/00-instalacion.md)
- [Inventario inicial](docs/01-inventario.md)
- [Firewall y SSH](docs/02-firewall-ssh.md)
- [Despliegue y acceso web con Nginx](docs/03-nginx-acceso-web.md)
- [Diagnóstico de Nginx y recursos HTTP](docs/04-diagnostico-nginx.md)
- [Auditoria Lynis](docs/05-auditoria-lynis.md)
- [Endurecimiento de SSH](docs/06-hardening-ssh.md)
- [Mejoras a partir de Lynis](docs/07-mejoras-lynis.md)

## Principios de trabajo

Cada etapa incluye explicación técnica, configuración, pruebas y documentación de los resultados reales. No se publican claves privadas, contraseñas ni otros secretos.
