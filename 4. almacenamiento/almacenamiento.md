# 4) Configuración de almacenamiento del server TPServer


## 1) Agregar un nuevo disco de 10 GB adicional a la máquina virtual.

Para este punto del TP nos basamos en el modulo 7 donde se indica agregar un nuevo disco a la maquina virtual. [Documentacion FileSystem](./docs/0306_APU_IntroFilesystem(1ra.parteM7)_251Q_V2.pdf)

Antes de comenzar verificaremos las configuraciones de discos que tenemos en el server TPServer.

1. Abrir la terminal del server TPServer
2. Obtener permisos de administrador (si no iniciamos sesion como root):

```bash
root@TPServer:~# su -
```

3. Verificamos los discos con el fdisk.

```bash
root@TPServer:~# fdisk -l | grep "Disk /dev/"
Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
root@TPServer:~# 
```

En este caso podemos verificar que tenemos un solo disco de 20Gb en /dev/sda

4. Realiazamos los pasos para [agregar un nuevo disco](./docs/0306_APU_IntroFilesystem(1ra.parteM7)_251Q_V2.pdf) en nuestra maquina virtual.

5. Luego de agregar el disco, volvemos a verificar los discos con el fdisk.

```bash
root@TPServer:~# fdisk -l | grep "Disk /dev/"
Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk /dev/sdb: 10 GiB, 10737418240 bytes, 20971520 sectors
root@TPServer:~# 
```

Podemos verficar que se agregó un nuevo disco en /dev/sdb, ahora vamos a verificar si tiene particiones:

```bash
root@TPServer:~# fdisk /dev/sdb -l
Disk /dev/sdb: 10 GiB, 10737418240 bytes, 20971520 sectors
Disk model: HARDDISK        
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

No tiene particiones creadas, es solo un disco vinculado al server.

----

## 2) Crear dos particiones estándar (tipo 83), con las siguientes capacidades:
* /www_dir: 3 GB
* /backup_dir: 6 GB

Para hacer esto tenemos dos formas, con el comando fdisk que es interactivo, por lo cual los pasos para nevegar en el menu de fdisk son los siguentes:

Crear partición 1 (3GB)
```bash
n
p
1
<Enter>
+3G
t
1
83
```


Crear partición 2 (6GB) y salir de fdisk
```bash
n
p
2
<Enter>
+6G
t
2
83
w
```

Se debería ver así la interacción con fdisk.

```bash
root@TPServer:~# fdisk /dev/sdb

Welcome to fdisk (util-linux 2.36.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x9b488082.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-20971519, default 2048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-20971519, default 20971519): +3G

Created a new partition 1 of type 'Linux' and of size 3 GiB.

Command (m for help): t
Selected partition 1
Hex code or alias (type L to list all): 83
Changed type of partition 'Linux' to 'Linux'.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 2
First sector (6293504-20971519, default 6293504): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (6293504-20971519, default 20971519): +6G

Created a new partition 2 of type 'Linux' and of size 6 GiB.

Command (m for help): t
Partition number (1,2, default 2): 2
Hex code or alias (type L to list all): 83

Changed type of partition 'Linux' to 'Linux'.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

Luego de haber creado las particiones, hay que darles formato y en nuestor caso utilizaremos ext4.

```bash
root@TPServer:~# mkfs.ext4 /dev/sdb1
mke2fs 1.46.2 (28-Feb-2021)
Creating filesystem with 786432 4k blocks and 196608 inodes
Filesystem UUID: b1a9d024-4e05-4b5f-adf7-820ce7ad9fd4
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

root@TPServer:~# mkfs.ext4 /dev/sdb2
mke2fs 1.46.2 (28-Feb-2021)
Creating filesystem with 1572864 4k blocks and 393216 inodes
Filesystem UUID: 63c457c9-d877-4aaa-8373-b0a68bb11282
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

root@TPServer:~# 
```

Crear los puntos de montaje. En Debian se define que las unidades temporales (como CD-ROMs o pendrives) deben montarse en el directorio /media y los discos rígidos o unidades no temporales (de uso prolongado) pueden montarse en el directorio /mnt. Este directorio se utiliza para montar discos de un uso más prolongado, como discos externos que es nuestro caso, pero para este ejercicio se solicita dejar los archivos en el /.


```bash
root@TPServer:/# mkdir /www_dir
root@TPServer:/# mkdir /backup_dir
```

Ahora vamos a montar los discos en forma temporal.

```bash
root@TPServer:/mnt# mount /dev/sdb1 /www_dir
root@TPServer:/mnt# mount /dev/sdb2 /backup_dir
```
----

## 3) Configurar el directorio /www_dir para alojar el archivo index.php y logo.png. Actualizar el archivo de configuración de Apache para que éste apunte a la nueva ubicación (ver archivos 000-default.conf y apache2).

Este punto es una modificación a lo que se hizo en el ejercicio numero 2, donde habia que levantar el servidor apache y servir los programas desde /var/www/html. Hay que tener presente que con estos cambios y partir de ahora /var/www/html dejará de ser el directorio principal del sitio y pasará a serlo /www_dir

### Mover los archivos (index.php y logo.png)

```bash
root@TPServer:/# mv /var/www/html/index.php /www_dir/
root@TPServer:/# mv /var/www/html/logo.png /www_dir/
root@TPServer:/# l www_dir/
total 32
drwxr-xr-x  3 root     root      4096 Dec  8 10:38 .
drwxr-xr-x 20 root     root      4096 Dec  8 10:34 ..
-rw-r--r--  1 www-data www-data  2325 Dec  7 23:34 index.php
-rw-r--r--  1 www-data www-data  1719 Dec  7 23:34 logo.png
drwx------  2 root     root     16384 Dec  8 10:01 lost+found
root@TPServer:/# 
```

### Modificar Apache para que apunte a /www_dir
Editar el archivo 000-default.conf de apache y modicar la linea "DocumentRoot /var/www/html" lo siguente:

```bash
DocumentRoot /www_dir
<Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
</Directory>
```


```bash
root@TPServer:/# vi /etc/apache2/sites-available/000-default.conf
root@TPServer:/# grep -i DocumentRoot /etc/apache2/sites-available/000-default.conf
	DocumentRoot /www_dir
```

El comando grep debería mostrar "DocumentRoot /www_dir". Acá lo que hicimos es cambiar el DocumentoRoot pero además definimos un directorio que antes no estaba, y eso se debe a que /var/www/ ya está definido en la configuración global de Apache (/etc/apache2/apache2.conf) como directorio autorizado, mientras que /www_dir no lo está, sino lo agregamos al dorectorio, Apache lo bloqueará. Otra opción es apache2.conf y definirlo ahi como autorizado.

Apache necesita una serie de permisos sobre los archivos y directorios donde se ejecuta, así que vamos a cambiar los permisos para no tener problemas de accesos a los mismos.

```bash
root@TPServer:/# chown -R www-data:www-data /www_dir
root@TPServer:/# chmod -R 755 /www_dir
```

## Reiniciar Apache y verificar que siga funcionando.

```bash
root@TPServer:/# systemctl restart apache2
```

Como hicimos en el punto 2, desde el navegador de la Mac apuntamos a la IP del server TPDebian y verificamos que index.php responda correctame conectandose a la base MariaDB, en nuestro caso la url es http://192.168.0.200/index.php


----

## 4) Configurar el directorio /www_dir para que se monte automáticamente al iniciar el sistema operativo.
## 5) Configurar el directorio /backup_dir para que se monte automáticamente al iniciar el sistema operativo.

Estos dos puntos se resuelven en el mismo lugar, en el archivo fstab. Si, no se realiza esta configuración cada vez que se inicia el sistema se debería montar los disco en forma manual como se hizo al final del punto 2 con el comando mount.

### Para que se monten automáticamente en cada reinicio:

```bash
root@TPServer:/mnt# vi /etc/fstab
```

### Agregar estas lineas al final:
```bash
/dev/sdb1   /www_dir     ext4   defaults   0 2
/dev/sdb2   /backup_dir  ext4   defaults   0 2
```

## 6) se debe crear un archivo en /opt llamado "particion", y redirigir el contenido del archivo "partitions" ubicado en /proc (el archivo original es efímero y se pierde al apagar la máquina).

Se debe copiar/guardar el contenido del archivo efímero /proc/partitions hacia un archivo persistente /opt/particion para que no se pierda cuando la máquina se apague. /proc/partitions no es un archivo real, sino una vista del kernel que se genera automáticamente en cada arranque. Por eso se aclara que es efímero.

```bash
root@TPServer:/# cat /proc/partitions > /opt/particion
root@TPServer:/# l /opt/particion
-rw-r--r-- 1 root root 355 Dec  8 11:21 /opt/particion
root@TPServer:/# cat /opt/particion
major minor  #blocks  name

   8        0   20971520 sda
   8        1     524288 sda1
   8        2    4222976 sda2
   8        3    1732608 sda3
   8        4    1000448 sda4
   8        5     375808 sda5
   8        6   13113344 sda6
  11        0    1048575 sr0
   8       16   10485760 sdb
   8       17    3145728 sdb1
   8       18    6291456 sdb2
root@TPServer:/# 
```
