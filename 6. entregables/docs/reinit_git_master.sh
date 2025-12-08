# 1. Vamos a una carpeta temporal limpia
cd /tmp
rm -rf repo_borrar
mkdir repo_borrar
cd repo_borrar

# 2. Inicializamos un git vacío
git init
echo "# Repo Reiniciado" > README.md

# 3. Preparamos la subida
git add .
git commit -m "Limpieza total - Reset"

# 4. Conectamos y forzamos (Reemplaza TU_TOKEN con el real)
# IMPORTANTE: Esto borrará todo en tu GitHub y pondrá solo este README
git remote add origin https://rcianni:TOKEN@github.com/rcianni/tp-infraestructura-server.git
git push --force origin master
