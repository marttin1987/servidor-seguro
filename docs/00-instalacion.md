# 00 - Instalación y resolución de problemas

## Objetivo

Construir un laboratorio de administración de sistemas Linux para practicar instalación, conectividad, acceso remoto, seguridad básica y publicación de servicios web.

## Entorno final

- **Sistema anfitrión:** Ubuntu.
- **Virtualización:** VirtualBox.
- **Sistema invitado:** Debian GNU/Linux 13.
- **Acceso remoto:** SSH.
- **Servidor web:** Nginx.
- **Firewall:** UFW.

## Problemas encontrados y soluciones

### 1. Problemas de rendimiento con Ubuntu Server

Durante las primeras pruebas, Ubuntu Server presentó problemas de funcionamiento en la máquina virtual.

**Decisión:** revisar los recursos disponibles y simplificar el entorno para poder continuar con las prácticas.

**Aprendizaje:** la elección del sistema operativo invitado debe considerar los recursos del equipo anfitrión y los requisitos del laboratorio.

### 2. Cambio a Debian por limitaciones de memoria

Se decidió utilizar Debian GNU/Linux 13 como sistema invitado para continuar el laboratorio con un entorno más adecuado a los recursos disponibles.

**Resultado:** se pudo avanzar con la configuración del acceso remoto, el firewall y el servidor web.

### 3. Configuración de SSH dentro de la máquina virtual

Se configuró el acceso remoto mediante SSH y se preparó la autenticación por clave pública.

Para conectar desde Ubuntu se utilizó el reenvío de puertos de VirtualBox, exponiendo el puerto SSH de la VM en el puerto 2222 de la máquina anfitriona.

Comando de conexión:

`ssh -i ~/.ssh/id_lab -p 2222 martinc@127.0.0.1`

La clave privada permanece fuera del repositorio.

**Pendiente:** verificar y endurecer la configuración de autenticación de SSH antes de considerar finalizada la configuración de seguridad.

### 4. Instantánea de seguridad

Se utilizó una instantánea de VirtualBox como punto de recuperación del entorno.

**Objetivo:** disponer de una referencia a la que regresar si una modificación posterior deja el sistema en un estado incorrecto.

Una instantánea facilita la recuperación, pero no sustituye a una copia de seguridad independiente.

## Estado final comprobado

- Debian 13 operativo dentro de VirtualBox.
- Acceso SSH configurado.
- UFW activo con reglas para SSH y HTTP.
- Nginx en funcionamiento.
- Página web de prueba accesible desde Ubuntu mediante el puerto reenviado 8080.

## Próximos pasos

- Revisar y endurecer la configuración de SSH.
- Incorporar salidas reales de los comandos de verificación.
- Evaluar las reglas del firewall y documentar las decisiones.
- Mejorar las evidencias y los procedimientos de diagnóstico.
