#!/bin/bash

# ==============================================
#  Script: backup_full.sh
#  Ubicación sugerida: /opt/scripts/backup_full.sh
# ==============================================

FECHA=$(date +%Y%m%d)

# ----- Opción de ayuda -----
if [[ "$1" == "-help" || "$1" == "--help" ]]; then
    echo "=============================================="
    echo "Uso: sudo ./backup_full.sh <origen> [destino]"
    echo "Ejemplo: sudo ./backup_full.sh /var/log /backup_dir"
    echo "Genera backup comprimido .tar.gz en el destino indicado."
    echo "Nota: Si no se indica destino, se usará /backup_dir por defecto."
    echo "=============================================="
    exit 0
fi

# ---- Validación: debe ejecutarse como root ----
if [[ "$EUID" -ne 0 ]]; then
    echo "Permiso denegado: Este script debe ejecutarse como root o con sudo."
    exit 1
fi

# ----- Validar argumento 1 (Origen) -----
if [[ -z "$1" ]]; then
    echo "Error: Debes indicar el origen (archivo o directorio)."
    echo "Ejemplo: ./backup_full.sh /var/log /backup_dir"
    exit 1
fi

ORIGEN="$1"

# ----- Validar argumento 2 (Destino) -----
# Si $2 existe lo usa, si no, usa /backup_dir por defecto (para cumplir req 3 y 4 a la vez)
if [[ -z "$2" ]]; then
    DESTINO="/backup_dir"
    echo "No se especificó destino, usando por defecto: $DESTINO"
else
    DESTINO="$2"
fi

# Validar existencia del origen ya sea como archivo o como directorio
#   -e acepta archivos como o(/etc/hosts) y carpetas como (/var/log).
if [[ ! -e "$ORIGEN" ]]; then
    echo "Error: El origen no existe -> $ORIGEN"
    exit 1
fi

# Validar si el destino es un directorio válido
#   -d "$DESTINO"   Verifica si existe un directorio con la ruta $DESTINO.
#   ! -d "$DESTINO" El ! niega la condición, es decir verdadero si el directorio NO existe
if [[ ! -d "$DESTINO" ]]; then
    echo "Error: El directorio destino no existe -> $DESTINO"
    exit 1
fi

# Obtener nombre base del origen
NOMBRE=$(basename "$ORIGEN")
ARCHIVO="${NOMBRE}_bkp_${FECHA}.tar.gz"
RUTA_FINAL="$DESTINO/$ARCHIVO"

# ----- Control incremental si existe -----
CONTADOR=1

# 1. Preguntamos una sola vez si el archivo base existe para dar el aviso
if [[ -f "$RUTA_FINAL" ]]; then
    echo "Atención: ya existe un backup con el mismo nombre."
    echo "   Se generará una copia incremental."
fi

# 2. El bucle se encarga de calcular el nombre libre
while [[ -f "$RUTA_FINAL" ]]; do
    RUTA_FINAL="${DESTINO}/${NOMBRE}_bkp_${FECHA}_${CONTADOR}.tar.gz"
    CONTADOR=$((CONTADOR+1))
done

# ----- Ejecutar backup -----
echo "Creando backup de: $ORIGEN"
echo "Guardando en: $RUTA_FINAL"

# Compresión de los datos para backup
#   -c crear un archivo tar
#   -z comprimir con gzip
#   -P mantener rutas absolutas
#   -f indica el nombre del archivo final
#  si $ORIGEN es un directorio, tar hace backup recursivo automáticamente.
tar -czPf "$RUTA_FINAL" "$ORIGEN"

if [[ $? -eq 0 ]]; then
    echo "Backup completado con éxito."
    echo "Archivo generado: $RUTA_FINAL"
else
    echo "Ocurrió un error durante el proceso de backup."
    exit 1
fi

exit 0
