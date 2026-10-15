# 05 - Auditoría de seguridad con Lynis

## Objetivo

Realizar una auditoría inicial de seguridad del servidor Debian GNU/Linux 13 mediante Lynis.

## Herramienta

- **Herramienta:** Lynis.
- **Versión instalada:** 3.1.4.
- **Origen:** repositorio configurado de Debian.
- **Índice inicial de hardening:** 68.

## Resultado de la auditoría

La primera ejecución de `sudo lynis audit system` generó los archivos:

- Registro: `/var/log/lynis.log`.
- Reporte: `/var/log/lynis-report.dat`.

Se identificó una sugerencia indicando que la versión instalada de Lynis tiene más de cuatro meses de antigüedad. El repositorio configurado ofrece la versión 3.1.4, por lo que no se realizó una actualización externa.

## Próximos pasos

- Revisar las advertencias y sugerencias completas de Lynis.
- Evaluar las recomendaciones de seguridad antes de aplicar cambios.
- Ejecutar una nueva auditoría después de las mejoras y comparar los resultados.

## Consideraciones

El índice de hardening es una métrica propia de Lynis. No representa directamente un porcentaje de seguridad ni sustituye una revisión de las configuraciones y los riesgos del sistema.
