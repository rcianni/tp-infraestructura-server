#!/bin/bash

# ==============================================
#  Script: github_push_auto.sh
#  Función: Backup automático con control de errores (Fail Fast)
# ==============================================

# 1. CONTROL DE ERRORES ROBUSTO
# set -e: Detiene el script si cualquier comando falla.
# set -o pipefail: Detecta fallos incluso dentro de tuberías (como tar | split).
set -e
set -o pipefail

# Función para imprimir errores y salir limpiamente
error_exit() {
    echo "ERROR CRÍTICO EN LA LÍNEA $1: $2"
    echo "El script se ha detenido para evitar daños."
    exit 1
}

# Atrapa errores en cualquier parte del script
trap 'error_exit $LINENO "$BASH_COMMAND"' ERR

# --- CONFIGURACIÓN ---
GITHUB_USER="rcianni"
GITHUB_EMAIL="ianni.roberto@gmail.com"
REPO_NAME="tp-infraestructura-server"
GITHUB_TOKEN="TOKEN"

# Rutas (Usamos backup_dir porque /tmp no tiene espacio)
REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"
TEMP_GIT="/gitaux"
TEMP_DIR="${TEMP_GIT}/github_staging"
REPO_LOCAL_DIR="${TEMP_GIT}/${REPO_NAME}"
SCRIPT_BACKUP="/opt/scripts/backup_full.sh"

# --- VALIDACIONES INICIALES ---

# Validar ROOT
if [[ "$EUID" -ne 0 ]]; then
    echo "Error: Este script debe ejecutarse como root."
    exit 1
fi

# Validar Token
if [[ "$GITHUB_TOKEN" == "PON_TU_TOKEN_NUEVO_AQUI" || -z "$GITHUB_TOKEN" ]]; then
    echo "Error: Configura tu GITHUB_TOKEN en el script antes de continuar."
    exit 1
fi

echo "=============================================="
echo " Iniciando proceso de Backup y Sincronización"
echo "=============================================="

# --- PASO 1: BACKUPS LOCALES ---
echo "🔄 [1/8] Ejecutando backups locales..."

# Verificamos que el script exista antes de llamarlo
if [[ ! -x "$SCRIPT_BACKUP" ]]; then
    echo "Error: No se encuentra $SCRIPT_BACKUP o no es ejecutable."
    exit 1
fi

# El '||' permite personalizar el mensaje si falla, aunque 'set -e' lo detendría igual.
$SCRIPT_BACKUP /var/log || error_exit $LINENO "Falló el backup de /var/log"
$SCRIPT_BACKUP /www_dir || error_exit $LINENO "Falló el backup de /www_dir"


# --- PASO 2: LIMPIEZA ---
echo "🧹 [2/8] Preparando directorio temporal en $TEMP_GIT..."
rm -rf "$TEMP_DIR"
rm -rf "$REPO_LOCAL_DIR"
mkdir -p "$TEMP_DIR"


# --- PASO 3: COMPRESIÓN ESTÁNDAR ---
echo "📦 [3/8] Comprimiendo directorios del sistema..."
# Si alguno de estos falla, el script se detiene automáticamente por 'set -e'
tar -czPf "$TEMP_DIR/root.tar.gz" /root
tar -czPf "$TEMP_DIR/etc.tar.gz" /etc
tar -czPf "$TEMP_DIR/opt.tar.gz" /opt
tar -czPf "$TEMP_DIR/www_dir.tar.gz" /www_dir
tar -czPf "$TEMP_DIR/backup_dir.tar.gz" /backup_dir


# --- PASO 4: SPLIT DE /VAR ---
echo "📦 [4/8] Procesando /var (Split 45MB)..."
# Gracias a 'set -o pipefail', si tar falla o split falla, se detiene.
tar -czPf - /var | split -b 45M -d - "$TEMP_DIR/var_part.tar.gz."


# --- PASO 5: CLONADO GIT ---
echo "octocat [5/8] Clonando repositorio..."

# Configuración de identidad
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USER"

# Vamos al directorio de trabajo grande
cd "$TEMP_GIT"

# Intentamos clonar. Si falla (token invalido, sin red), se detiene aquí.
if ! git clone "$REPO_URL"; then
    echo "Error: Falló git clone. Verifica tu conexión a internet o la validez del Token."
    exit 1
fi

# Entrar al repo y mover archivos
cd "$REPO_LOCAL_DIR"
mv "$TEMP_DIR"/* .


# --- PASO 6: DOCUMENTACIÓN ---
echo "📄 [6/8] Integrando documentación..."

if [[ -d "/root/documentacion" ]]; then
    cp -r /root/documentacion/* .
else
    echo "Advertencia: No existe /root/documentacion (El script continúa)."
fi

echo "[7/8] Configurando .gitignore..."
echo ".DS_Store" > .gitignore
echo "__MACOSX" >> .gitignore

# --- PASO 7: SUBIDA (COMMIT & PUSH) ---
echo "☁ [8/8] Subiendo cambios a GitHub..."

# Agregamos todo
git add .

# Hacemos commit.
# Nota: Si no hay cambios, git commit devuelve error (1).
# Usamos '|| true' para permitir que el script siga si no hubo cambios nuevos,
# o puedes dejar que falle si prefieres saber que no hubo cambios.
git commit -m "Auto-update: Backups del sistema $(date '+%Y-%m-%d %H:%M:%S')" || echo "⚠ Nada nuevo para commitear."

# El Push es crítico.
echo "   -> Enviando datos a la nube..."
git push origin master

echo "=============================================="
echo "  ¡ÉXITO! Proceso finalizado correctamente."
echo "=============================================="

# Limpieza final
rm -rf "$TEMP_DIR" "$REPO_LOCAL_DIR"

exit 0
