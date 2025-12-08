# 5) Backup de información disponible en TPServer

El script debe cumple con todas estas premisas:

1) Desarrollar un script de backup denominado “backup_full.sh”, y guardarlo en /opt/scripts.
2) El script debe backupear los directorios indicados con nombres que incluyan la fecha en formato ANSI (YYYMMDD). Por ejemplo, para /var/log, el archivo generado debería llamarse “log_bkp_20240302.tar.gz”.
3) Los backups generados deben almacenarse en la partición que tiene montado el directorio /backup_dir.
4) El script debe aceptar argumentos como origen (lo que se va a backupear) y destino (dónde se va a backupear).
5) El script debe incluir una opción de ayuda (-help), para guiar al usuario en el uso del script.
6) El script debe validar que los sistemas de archivos de origen y destino estén disponibles antes de ejecutar el backup.


### Para iniciar con el proceso primero crearemos la carpeta y luego construiremos el script.

1. Abrir la terminal del server TPServer
2. Obtener permisos de administrador (si no iniciamos sesion como root):

```bash
root@TPServer:~# su -
```

3. Creamos la carpeta /opt/scripts donde se dejará el script que realizará el backup.
```bash
root@TPServer:/opt# mkdir -p /opt/scripts
root@TPServer:/opt# l
total 16
drwxr-xr-x  3 root root 4096 Dec  8 11:54 .
drwxr-xr-x 20 root root 4096 Dec  8 10:34 ..
-rw-r--r--  1 root root  355 Dec  8 11:21 particion
drwxr-xr-x  2 root root 4096 Dec  8 11:54 scripts
root@TPServer:/opt# vi scripts/backup_full.sh
root@TPServer:/opt# chmod 754 scripts/backup_full.sh 
root@TPServer:/opt# l scripts/
total 12
drwxr-xr-x 2 root root 4096 Dec  8 11:59 .
drwxr-xr-x 3 root root 4096 Dec  8 11:54 ..
-rwxr-xr-- 1 root root 2607 Dec  8 11:59 backup_full.sh
```

El [script](./docs/backup_full.sh) estará en la carpeta /opt/scripts e intentará cumplir con los premisas solicitadas. El mismo tendrá permisos de ejecución para el owner y el grupo, y solo lectora por el resto.

4. Pruebas basicas de ejecución para validar si funcionamiento sin parametros o pidiendo ayuda
```bash
root@TPServer:/opt/scripts# l
total 12
drwxr-xr-x 2 root root 4096 Dec  8 12:10 .
drwxr-xr-x 3 root root 4096 Dec  8 11:54 ..
-rwxr-xr-- 1 root root 2988 Dec  8 12:10 backup_full.sh

root@TPServer:/opt/scripts# ./backup_full.sh 
Error: Debes indicar el origen (archivo o directorio).
Ejemplo: ./backup_full.sh /var/log /backup_dir

root@TPServer:/opt/scripts# ./backup_full.sh --help
==============================================
Uso: sudo ./backup_full.sh <origen> [destino]
Ejemplo: sudo ./backup_full.sh /var/log /backup_dir
Genera backup comprimido .tar.gz en el destino indicado.
Nota: Si no se indica destino, se usará /backup_dir por defecto.
==============================================
root@TPServer:/opt/scripts#
```

Realizamos la ejecuión para realizar el backup de /var/log, luego la volvemos a ejecutaar para que nos asigne un nuevo primer secuencial ya que el archivo para esta fecha existe.

```bash
root@TPServer:/opt/scripts# l /backup_dir/
total 24
drwxr-xr-x  3 root root  4096 Dec  8 12:28 .
drwxr-xr-x 20 root root  4096 Dec  8 10:34 ..
drwx------  2 root root 16384 Dec  8 10:01 lost+found
root@TPServer:/opt/scripts# ./backup_full.sh /var/log/
No se especificó destino, usando por defecto: /backup_dir
Creando backup de: /var/log/
Guardando en: /backup_dir/log_bkp_20251208.tar.gz
Backup completado con éxito.
Archivo generado: /backup_dir/log_bkp_20251208.tar.gz
root@TPServer:/opt/scripts# l /backup_dir/
total 6792
drwxr-xr-x  3 root root    4096 Dec  8 12:29 .
drwxr-xr-x 20 root root    4096 Dec  8 10:34 ..
-rw-r--r--  1 root root 6927791 Dec  8 12:29 log_bkp_20251208.tar.gz
drwx------  2 root root   16384 Dec  8 10:01 lost+found
root@TPServer:/opt/scripts# 
```

```bash
root@TPServer:/opt/scripts# ./backup_full.sh /var/log/
No se especificó destino, usando por defecto: /backup_dir
Atención: ya existe un backup con el mismo nombre.
   Se generará una copia incremental.
Creando backup de: /var/log/
Guardando en: /backup_dir/log_bkp_20251208_1.tar.gz
Backup completado con éxito.
Archivo generado: /backup_dir/log_bkp_20251208_1.tar.gz
root@TPServer:/opt/scripts# l /backup_dir/
total 13560
drwxr-xr-x  3 root root    4096 Dec  8 12:30 .
drwxr-xr-x 20 root root    4096 Dec  8 10:34 ..
-rw-r--r--  1 root root 6927791 Dec  8 12:30 log_bkp_20251208_1.tar.gz
-rw-r--r--  1 root root 6927791 Dec  8 12:29 log_bkp_20251208.tar.gz
drwx------  2 root root   16384 Dec  8 10:01 lost+found
root@TPServer:/opt/scripts# 
```

Realizamos la ejecuión para realizar el backup de /var/log pero le forzamos una directorio de salida, que es el parametro opcional para verificar que el resultado quede en otro destino diferente a /backup_dir/

```bash
root@TPServer:/opt/scripts# ./backup_full.sh /var/log/ /opt/scripts/
Creando backup de: /var/log/
Guardando en: /opt/scripts//log_bkp_20251208.tar.gz
Backup completado con éxito.
Archivo generado: /opt/scripts//log_bkp_20251208.tar.gz
root@TPServer:/opt/scripts# l
total 6780
drwxr-xr-x 2 root root    4096 Dec  8 12:31 .
drwxr-xr-x 3 root root    4096 Dec  8 11:54 ..
-rwxr-xr-- 1 root root    3092 Dec  8 12:28 backup_full.sh
-rw-r--r-- 1 root root 6927791 Dec  8 12:31 log_bkp_20251208.tar.gz
root@TPServer:/opt/scripts# 
```

Realizamos la ejecuión para realizar el backup validando que controle que existan el origen y destino del backup.

### Valida origen:

```bash
root@TPServer:/opt/scripts# ./backup_full.sh /var/logos
No se especificó destino, usando por defecto: /backup_dir
Error: El origen no existe -> /var/logos
root@TPServer:/opt/scripts# 
```

### Valida destino:
```bash
root@TPServer:/opt/scripts# ./backup_full.sh /var/log/ /opt/dir_backup/
Error: El directorio destino no existe -> /opt/dir_backup/
root@TPServer:/opt/scripts# 
```

----

## 7) El script debe ser incluido en un calendario de tareas para correr automáticamente

* TODOS LOS DÍAS a las 00:00 hs: Backupear “/var/log”
* LUNES, MIÉRCOLES, VIERNES a las 23:00 hs: Backupear “/www_dir”


Para agendar las teras se realiza con el crontab.

### Sintaxis de cron

```bash
# ┌──────────── minuto (0-59)
# │ ┌────────── hora (0-23)
# │ │ ┌──────── día del mes (1-31)
# │ │ │ ┌────── mes (1-12)
# │ │ │ │ ┌──── día de la semana (0-7) (domingo=0 o 7)
# │ │ │ │ │
# │ │ │ │ │
# * * * * * comando a ejecutar
```

### Configuración de tus tareas

Tarea 1: /var/log todos los días a las 00:00
* 0 0 * * * = minuto 0, hora 0, todos los días, todos los meses, todos los días de la semana
* /opt/scripts/backup_full.sh /var/log → ejecuta tu script con el directorio de origen /var/log

Tarea 2: /www_dir lunes, miércoles y viernes a las 23:00
* 0 23 * * 1,3,5 → minuto 0, hora 23, días lunes(1), miércoles(3), viernes(5)
* /opt/scripts/backup_full.sh /www_dir → ejecuta tu script con /www_dir


Ejecutar crontab y agregar las configuraciones de abajo:
```bash
root@TPServer:/opt/scripts# crontab -e
no crontab for root - using an empty one

Select an editor.  To change later, run 'select-editor'.
  1. /bin/nano        <---- easiest
  2. /usr/bin/vim.tiny

Choose 1-2 [1]: 1

crontab: installing new crontab
```

```bash
0 0 * * * /opt/scripts/backup_full.sh /var/log
0 23 * * 1,3,5 /opt/scripts/backup_full.sh /www_dir
```

###  Verificar las tareas

```bash
root@TPServer:/opt/scripts# crontab -l

0 0 * * * /opt/scripts/backup_full.sh /var/log
0 23 * * 1,3,5 /opt/scripts/backup_full.sh /www_dir
```

