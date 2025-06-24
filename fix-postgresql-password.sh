#!/bin/bash
#
# 🔧 Fix PostgreSQL Password - La Papita
# Soluciona problemas de autenticación con PostgreSQL
#

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

echo -e "${BLUE}"
echo "=============================================="
echo "🔧 SOLUCIONANDO PROBLEMA POSTGRESQL - LA PAPITA"
echo "=============================================="
echo -e "${NC}"

# Verificar que se ejecuta como root
if [[ $EUID -ne 0 ]]; then
    error "Este script debe ejecutarse como root. Usa: sudo bash fix-postgresql-password.sh"
fi

# Obtener nueva contraseña
echo -e "${YELLOW}Vamos a reconfigurar la contraseña de PostgreSQL${NC}"
read -p "Ingresa una nueva contraseña para el usuario 'lapapita': " -s NEW_PASSWORD
echo
read -p "Confirma la contraseña: " -s CONFIRM_PASSWORD
echo

if [ "$NEW_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
    error "Las contraseñas no coinciden"
fi

if [ ${#NEW_PASSWORD} -lt 8 ]; then
    error "La contraseña debe tener al menos 8 caracteres"
fi

log "Paso 1: Reconfigurando usuario PostgreSQL..."

# Cambiar contraseña del usuario lapapita
sudo -u postgres psql -c "ALTER USER lapapita WITH PASSWORD '$NEW_PASSWORD';"

log "✅ Contraseña de PostgreSQL actualizada"

log "Paso 2: Verificando conexión..."

# Probar conexión
export PGPASSWORD="$NEW_PASSWORD"
if psql -h localhost -U lapapita -d lapapita_db -c "SELECT 1;" >/dev/null 2>&1; then
    log "✅ Conexión a PostgreSQL exitosa"
else
    error "❌ Aún hay problemas de conexión. Verificando configuración..."
fi

log "Paso 3: Actualizando variables de entorno..."

# Actualizar archivo .env del backend
if [ -f "/home/lapapita/apps/lapapita/backend/.env" ]; then
    # Hacer backup
    cp /home/lapapita/apps/lapapita/backend/.env /home/lapapita/apps/lapapita/backend/.env.backup
    
    # Actualizar DATABASE_URL
    sed -i "s|DATABASE_URL=.*|DATABASE_URL=postgresql://lapapita:$NEW_PASSWORD@localhost:5432/lapapita_db|g" /home/lapapita/apps/lapapita/backend/.env
    
    log "✅ Variables de entorno actualizadas"
    
    # Mostrar el archivo actualizado (sin mostrar la contraseña completa)
    info "Archivo .env actualizado:"
    sed 's/:[^:@]*@/:***@/g' /home/lapapita/apps/lapapita/backend/.env
else
    warning "Archivo .env no encontrado. Creando uno nuevo..."
    
    # Generar secrets si no existen
    JWT_SECRET=$(openssl rand -hex 32)
    COOKIE_SECRET=$(openssl rand -hex 32)
    
    cat > /home/lapapita/apps/lapapita/backend/.env << EOF
DATABASE_URL=postgresql://lapapita:$NEW_PASSWORD@localhost:5432/lapapita_db
JWT_SECRET=$JWT_SECRET
COOKIE_SECRET=$COOKIE_SECRET
STORE_CORS=http://localhost:8000,http://45.225.92.98
ADMIN_CORS=http://localhost:9000,http://45.225.92.98:9000
AUTH_CORS=http://localhost:9000,http://45.225.92.98:9000
NODE_ENV=production
EOF
    
    chown lapapita:lapapita /home/lapapita/apps/lapapita/backend/.env
    log "✅ Archivo .env creado con credenciales correctas"
fi

log "Paso 4: Restaurando base de datos..."

# Restaurar base de datos con la nueva contraseña
cd /home/lapapita/apps/lapapita
export PGPASSWORD="$NEW_PASSWORD"

if [ -f "database_backup.sql" ]; then
    log "Restaurando datos desde backup..."
    psql -h localhost -U lapapita -d lapapita_db < database_backup.sql
    log "✅ Base de datos restaurada exitosamente"
else
    warning "Archivo database_backup.sql no encontrado. Ejecutando seed..."
    cd backend
    sudo -u lapapita npm run seed
    cd ..
    log "✅ Datos iniciales creados con seed"
fi

log "Paso 5: Reiniciando servicios..."

# Reiniciar aplicaciones si están corriendo
if command -v pm2 >/dev/null 2>&1; then
    sudo -u lapapita pm2 restart all 2>/dev/null || true
    log "✅ Aplicaciones reiniciadas"
fi

echo -e "\n${GREEN}=============================================="
echo "🎉 PROBLEMA SOLUCIONADO!"
echo "=============================================="
echo -e "${NC}"

info "📋 RESUMEN:"
echo "   - Contraseña de PostgreSQL actualizada"
echo "   - Variables de entorno corregidas"
echo "   - Base de datos restaurada"
echo "   - Aplicaciones reiniciadas"

echo -e "\n${BLUE}🧪 COMANDOS DE VERIFICACIÓN:${NC}"
echo "   # Probar conexión BD:"
echo "   PGPASSWORD='$NEW_PASSWORD' psql -h localhost -U lapapita -d lapapita_db -c 'SELECT COUNT(*) FROM product;'"
echo ""
echo "   # Ver estado de aplicaciones:"
echo "   sudo -u lapapita pm2 status"
echo ""
echo "   # Ver logs:"
echo "   sudo -u lapapita pm2 logs"

echo -e "\n${GREEN}✅ ¡PostgreSQL configurado correctamente!${NC}"

# Guardar credenciales para referencia
echo "Contraseña PostgreSQL: $NEW_PASSWORD" > /root/.lapapita-credentials
chmod 600 /root/.lapapita-credentials
info "💾 Credenciales guardadas en /root/.lapapita-credentials" 