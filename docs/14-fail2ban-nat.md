# 14 - fail2ban y la red NAT

## Objetivo

Documentar cómo protege fail2ban el acceso SSH, por qué hubo que excluir una dirección por la red NAT de VirtualBox, y comprobar que el bloqueo funciona. La instalación está en el doc 02.

## Configuración

La cárcel de SSH está en `/etc/fail2ban/jail.d/sshd.local`:

```ini
[sshd]
enabled = true
port = 22
backend = systemd
maxretry = 5
findtime = 10m
bantime = 15m
```

Cinco intentos fallidos en 10 minutos bloquean la dirección durante 15 minutos. Con `backend = systemd` lee los intentos del registro de systemd.

La lista de exclusión está en `/etc/fail2ban/jail.local`:

```ini
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1 10.0.2.2
```

Valores efectivos, comprobados con `sudo fail2ban-client get sshd <parámetro>`:

| Parámetro | Valor |
| --- | --- |
| `ignoreip` | `127.0.0.0/8`, `10.0.2.2`, `::1` |
| `maxretry` | `5` |
| `findtime` | `600` segundos |
| `bantime` | `900` segundos |

## Por qué se excluye 10.0.2.2

Con la red NAT de VirtualBox, todas las conexiones del anfitrión llegan al servidor desde la misma dirección: `10.0.2.2`. Si fail2ban la bloqueara por unos intentos fallidos, quedaría sin acceso todo el anfitrión, incluido el administrador. Por eso se la excluye.

## Prueba del bloqueo

Como la dirección del anfitrión está excluida, no sirve para probar. Se bloqueó a mano una dirección reservada para documentación (`203.0.113.5`), que no pertenece a nadie:

```bash
sudo fail2ban-client set sshd banip 203.0.113.5
sudo fail2ban-client status sshd | grep -E 'Currently banned|Banned IP'
sudo nft list ruleset 2>/dev/null | grep -c '203.0.113.5'
sudo fail2ban-client set sshd unbanip 203.0.113.5
sudo fail2ban-client status sshd | grep 'Currently banned'
```

| Paso | Resultado |
| --- | --- |
| Bloqueo | `Currently banned: 1` y la dirección en la lista |
| Regla en el firewall | `1` coincidencia en `nftables` |
| Desbloqueo | `Currently banned: 0` |

Así se comprobó que fail2ban crea la regla de bloqueo en el firewall y que la quita al desbloquear.

## Recuperar el acceso

Si una dirección legítima quedara bloqueada, desde la consola de VirtualBox:

```bash
sudo fail2ban-client set sshd unbanip <dirección>
```

## Limitaciones

- No se probó la detección con intentos fallidos reales, porque la única dirección que llega al servidor está excluida.
- Con la exclusión de `10.0.2.2`, un ataque que entrara por el reenvío del anfitrión no sería bloqueado. En el laboratorio no hay otro origen posible.
- Aunque nadie pudiera bloquearse, la autenticación por contraseña está desactivada (doc 06): la fuerza bruta no puede tener éxito.

## Próximos pasos

- Cuando la red deje de ser NAT, quitar `10.0.2.2` de `ignoreip` y probar la detección con intentos fallidos desde otra máquina.

## Aprendizajes

- Una herramienta que bloquea direcciones puede bloquearte a vos: conviene saber de qué dirección llegás antes de activarla.
- Una prueba tiene que usar un origen que no afecte al acceso: por eso se usó una dirección de documentación.
- Un bloqueo se comprueba en dos lugares: en el estado de fail2ban y en las reglas del firewall.
