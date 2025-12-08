# 3) Configuración de red del server TPServer

Para este punto del TP nos basamos en el modulo 4 donde se indica como configurar una interfaz de red en Linux Debian.

[Documentacion Intefaz de red](./docs/0306_APU_Redes_251Q_V3.pdf)


## 1) Configurar la interfaz de red con una IP estática en el archivo de configuración. La IP debe pertenecer al mismo rango red de la máquina física.

## 2) El archivo de configuración debe incluir los campos ADDRESS, NETMASK y GATEWAY.


Ambos puntos se solucionan juntos para este caso. Para que el servidor TPServer sea accesible dentro de la red local en forma estatica, es necesario asignarle una dirección IP fija. Si dependiéramos del DHCP del router, la dirección podría cambiar con cada reinicio.

En este trabajo práctico configuraremos manualmente la IP del servidor editando el archivo /etc/network/interfaces, que es uno de los métodos clásicos de configuración de red en sistemas basados en Debian y el explicado en la docuentación del modulo 4. A través de este archivo vamos definir parámetros como la dirección IP, máscara de red, puerta de enlace y DNS.


1. Abrir la terminal del server TPServer

2. Obtener permisos de administrador (si no iniciamos sesion como root):

```bash
root@TPServer:~# su -
```

3. Editar el archivo de configuración:

```bash
root@TPServer:~# vi /etc/network/interfaces
```

4. Agregar o modificar la sección de tu interfaz de red (ejemplo con enp0s8):

```bash
# The primary network interface
auto enp0s8
#allow-hotplug enp0s8
iface enp0s8 inet static
	address 192.168.0.200
	netmask 255.255.255.0
	gateway 192.168.0.1
```

5. Apagamos IPV6 si aparece comentando la linea (ejemplo con enp0s8):

```bash
# This is an autoconfigured IPv6 interface
#iface enp0s8 inet6 auto
```

6. Verificamos o cambiamos el archivo /etc/hosts:
Cambiamos la línea localhost por la sigiente, 127.0.0.1	localhost

```bash
root@TPServer:~# vi /etc/hosts
```

Debe quedar de la sigiente forma:
```bash
root@TPServer:~# cat /etc/hosts
127.0.0.1	localhost
127.0.1.1	TPServer

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
root@TPServer:~# 
```

7. Reiniciar el servicio de red para aplicar los cambios:
```bash
root@TPServer:~# systemctl restart networking
```

8. Verificar la configuración:
```bash
root@TPServer:~# ifconfig 
enp0s8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.200  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::a00:27ff:fef4:540b  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:f4:54:0b  txqueuelen 1000  (Ethernet)
        RX packets 28450  bytes 28474594 (27.1 MiB)
        RX errors 0  dropped 99  overruns 0  frame 0
        TX packets 3890  bytes 544981 (532.2 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@TPServer:~# 
```

En este caso a la intefaz enp0s8 se le asignó la IP 192.168.0.200 lo cual es correcto.

