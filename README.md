# Trabajo Práctico Integrador Grupal

## Contexto del Proyecto

Este Trabajo Práctico (TP) se realiza para la materia **Computación Aplicada**. Las definiciones del exactas del TP están definidas en el [documento](./docs/0306_TPIntegaror_252Q_V3.pdf)


**Profesores del Curso:**
*   CRISTIAN DAMIANO
*   ALBERTO DELUCA

## Participantes del Grupo

*   RODRIGO FLORES
*   ROBERTO IANNI

## Descripción y Alcance del TP

Este trabajo práctico consiste en la **configuración integral de un entorno de servidor** utilizando una máquina virtual con el sistema operativo **GNU/Linux Debian**. El objetivo principal es establecer y asegurar un servidor que aloje una aplicación web y una base de datos, implementando además servicios esenciales de red y una política de almacenamiento y respaldo.

El trabajo es un ejercicio de integración de conocimientos, partiendo de la configuración inicial del entornohasta la implementación de tareas automáticas de backup.

## Resumen de Tareas Realizadas

El Trabajo Práctico abarca las siguientes áreas principales, tal como se detallan en las consignas del documento:

### 1. [Configuración del Entorno](./1.%20config/configuracion.md)
Se realizó la configuración inicial de la máquina virtual, incluyendo el blanqueo y cambio de la clave de *root* a "palermo", y el establecimiento del nombre de *hostname* como `TPServer`.

### 2. [Servicios](./2.%20servicios/servicios.md)
Se instalaron y configuraron servicios clave en el servidor:
*   **SSH:** Se configuró el acceso seguro para el usuario *root* utilizando un par de claves privada/pública.
*   **WEB:** Se instaló y configuró el servidor **Apache** con soporte para **PHP** (versión 7.3 o superior) para servir archivos como `index.php` y `logo.png`.
*   **Base de datos:** Se instaló y configuró **MariaDB**, cargando el *script* SQL (`db.sql`) para inicializar la base de datos necesaria.

### 3. [Configuración de Red](./3.%20red/red.md)
Se configuró la interfaz de red con una **dirección IP estática**, asegurando que el archivo de configuración incluya los campos `ADDRESS`, `NETMASK` y `GATEWAY`.

### 4. [Almacenamiento](./4.%20almacenamiento/almacenamiento.md)
Se agregó un disco adicional de 10 GB a la máquina virtual y se crearon dos particiones estándar (tipo 83):
*   Una partición de 3 GB para **`/www_dir`**.
*   Una partición de 6 GB para **`/backup_dir`**.
*   Se configuró Apache para que sirviera contenido desde la nueva ubicación `/www_dir`.
*   Ambos directorios se configuraron para que se **montaran automáticamente** al iniciar el sistema operativo mediante el archivo `fstab`.

### 5. [Backup](./5.%20backup/backup.md)
Se desarrolló un *script* de *backup* denominado `backup_full.sh` y se guardó en `/opt/scripts`. Este *script* está diseñado para aceptar argumentos de origen y destino, validar la disponibilidad de los sistemas de archivos y almacenar los *backups* en el directorio `/backup_dir`. Finalmente, el *script* fue incluido en un **calendario de tareas (crontab)** para ejecutarse automáticamente, respaldando `/var/log` diariamente y `/www_dir` los lunes, miércoles y viernes.


## 6. [Entregables del Trabajo Práctico](./6.%20entregables/entregables.md)

El trabajo requiere la entrega de los siguientes elementos, los cuales deben ser alojados en el **repositorio de GitHub** creado.

#### 6.1 Repositorio y Documentación

Se debe crear un repositorio en GitHub y redactar el archivo **`README.md`** conteniendo los nombres de los participantes del grupo.

#### 6.2 Archivos y Directorios Comprimidos

Es obligatorio subir al repositorio varios directorios del servidor, cumpliendo con los siguientes formatos de compresión:

1.  Los siguientes directorios deben ser comprimidos **individualmente en formato `.tar.gz`** y subidos:
    *   `/root`
    *   `/etc`
    *   `/opt`
    *   `/www_dir`
    *   `/backup_dir`
2.  El directorio `/var` debe ser **dividido (*spliteado*) en partes pequeñas** para que pueda ser cargado al repositorio.

#### 6.3 Diagrama Topológico

Finalmente, se debe realizar y entregar un **diagrama topológico** que represente la infraestructura armada durante el desarrollo del TP.

