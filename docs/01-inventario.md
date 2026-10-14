01 — Inventario de infraestructura

Objetivo

Documentar el entorno inicial del laboratorio antes de aplicar configuraciones de seguridad.

Equipo anfitrión

- Hostname: kingtero

- Sistema operativo: Ubuntu

- Conectividad principal: Wi-Fi

-Interfaz activa: wlp3s0

- Dirección IPv4: 192.168.0.18/24

- Puerta de enlace: 192.168.0.1

Servidor virtual

- Nombre de la VM: servidor-seguro

- Sistema operativo: Debian

- Red VirtualBox: NAT

- Interfaz de red: enp0s3

- Dirección IPv4: 10.0.2.15/24

- Puerta de enlace: 10.0.2.2

Acceso administrativo

- Protocolo: SSH

- Dirección de conexión desde el anfitrión: 127.0.0.1

- Puerto del anfitrión: 2222

- Puerto del servidor: 22

- Método de autenticación: clave pública SSH

- Resultado: conexión verificada

Estado inicial

La máquina virtual utiliza NAT. VirtualBox redirige el puerto TCP 2222 del anfitrión al puerto TCP 22 del servidor virtual.

La conexión SSH funciona con la clave configurada.

Próximos objetivos

Documentar usuarios y permisos.

Verificar la configuración SSH.

Implementar controles de seguridad.

Instalar y comprobar los servicios del laboratorio.

Automatizar las verificaciones y documentar los resultados
