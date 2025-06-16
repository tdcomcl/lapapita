#!/bin/bash

# Script para restaurar la base de datos de La Papita en el servidor
# Uso: ./restore-database.sh

echo "🗄️  Restaurando base de datos de La Papita..."

# Configuración
DB_NAME="lapapita_db"
DB_USER="lapapita"
BACKUP_FILE="database_backup.sql"

# Verificar que existe el archivo de backup
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: No se encontró el archivo $BACKUP_FILE"
    exit 1
fi

echo "📋 Configuración:"
echo "   Base de datos: $DB_NAME"
echo "   Usuario: $DB_USER"
echo "   Archivo backup: $BACKUP_FILE"
echo ""

# Confirmar antes de proceder
read -p "¿Continuar con la restauración? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Restauración cancelada"
    exit 1
fi

# Detener aplicaciones PM2
echo "🛑 Deteniendo aplicaciones..."
pm2 stop lapapita-backend lapapita-frontend

# Hacer backup de la base de datos actual (por seguridad)
echo "💾 Creando backup de seguridad..."
pg_dump -h localhost -U $DB_USER -d $DB_NAME > backup_before_restore_$(date +%Y%m%d_%H%M%S).sql

# Eliminar y recrear la base de datos
echo "🗑️  Eliminando base de datos actual..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

# Restaurar desde el backup
echo "📥 Restaurando desde backup..."
psql -h localhost -U $DB_USER -d $DB_NAME < $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✅ Base de datos restaurada exitosamente"
    
    # Reiniciar aplicaciones
    echo "🚀 Reiniciando aplicaciones..."
    pm2 start lapapita-backend lapapita-frontend
    
    echo "🎉 ¡Restauración completada!"
    echo ""
    echo "📊 Verificar datos:"
    echo "   psql -h localhost -U $DB_USER -d $DB_NAME -c \"SELECT COUNT(*) as productos FROM product;\""
    echo "   psql -h localhost -U $DB_USER -d $DB_NAME -c \"SELECT COUNT(*) as categorias FROM product_category;\""
else
    echo "❌ Error durante la restauración"
    exit 1
fi 