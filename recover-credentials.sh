#!/bin/bash
#
# 🔍 RECUPERAR CREDENCIALES - LA PAPITA
# Ejecutar como: sudo bash recover-credentials.sh
#

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}"
echo "🔍 RECUPERANDO CREDENCIALES - LA PAPITA"
echo "======================================"
echo -e "${NC}"

APP_DIR="/home/lapapita/lapapita"

# Verificar si la aplicación existe
if [ ! -d "$APP_DIR" ]; then
    echo -e "${RED}❌ No se encontró la aplicación en $APP_DIR${NC}"
    echo -e "${YELLOW}Parece que el deployment no se completó correctamente${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Aplicación encontrada en: $APP_DIR${NC}"

# Leer variables de entorno del backend
if [ -f "$APP_DIR/backend/.env" ]; then
    echo -e "${GREEN}✅ Archivo .env encontrado${NC}"
    
    # Extraer información
    DB_URL=$(grep "DATABASE_URL" "$APP_DIR/backend/.env" | cut -d'=' -f2)
    JWT_SECRET=$(grep "JWT_SECRET" "$APP_DIR/backend/.env" | cut -d'=' -f2)
    COOKIE_SECRET=$(grep "COOKIE_SECRET" "$APP_DIR/backend/.env" | cut -d'=' -f2)
    
    # Extraer credenciales de la URL de base de datos
    if [ ! -z "$DB_URL" ]; then
        DB_USER=$(echo $DB_URL | sed 's/.*:\/\/\([^:]*\):.*/\1/')
        DB_PASSWORD=$(echo $DB_URL | sed 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/')
        DB_NAME=$(echo $DB_URL | sed 's/.*\/\([^?]*\).*/\1/')
    fi
else
    echo -e "${RED}❌ No se encontró el archivo .env${NC}"
    DB_USER="lapapita"
    DB_NAME="lapapita_db"
    DB_PASSWORD="NO_ENCONTRADA"
fi

# Verificar PM2
PM2_STATUS=$(sudo -u lapapita pm2 status 2>/dev/null | grep -c "online" || echo "0")

# Verificar servicios
PG_STATUS=$(systemctl is-active postgresql 2>/dev/null || echo "inactive")
NGINX_STATUS=$(systemctl is-active nginx 2>/dev/null || echo "inactive")

# Crear archivo de credenciales recuperadas
sudo -u lapapita cat > $APP_DIR/CREDENCIALES_RECUPERADAS.txt << EOF
🔍 LA PAPITA - CREDENCIALES RECUPERADAS
======================================
Fecha de recuperación: $(date)

🌐 DOMINIO: lapapita.cl
📧 Admin Panel: https://lapapita.cl/admin
🏪 Tienda: https://lapapita.cl

🗄️ BASE DE DATOS POSTGRESQL:
• Host: localhost:5432
• Usuario: $DB_USER
• Contraseña: $DB_PASSWORD
• Base de datos: $DB_NAME
• Conexión: postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME

🔐 SECRETS:
• JWT_SECRET: $JWT_SECRET
• COOKIE_SECRET: $COOKIE_SECRET

📊 ESTADO DE SERVICIOS:
• PostgreSQL: $PG_STATUS
• Nginx: $NGINX_STATUS
• PM2 Apps online: $PM2_STATUS

📁 DIRECTORIOS:
• Aplicación: $APP_DIR
• Usuario del sistema: lapapita

🛠️ COMANDOS ÚTILES:
• sudo -u lapapita pm2 status
• sudo -u lapapita pm2 logs
• sudo -u lapapita pm2 restart all
• sudo systemctl status postgresql
• sudo systemctl status nginx

⚠️ NOTA: Este archivo fue generado por el script de recuperación.
EOF

echo -e "${GREEN}"
echo "📋 CREDENCIALES RECUPERADAS"
echo "=========================="
echo -e "${NC}"
echo -e "${BLUE}🌐 Dominio: lapapita.cl${NC}"
echo -e "${BLUE}📧 Admin: https://lapapita.cl/admin${NC}"
echo
echo -e "${YELLOW}🗄️ Base de Datos:${NC}"
echo -e "${BLUE}• Usuario: $DB_USER${NC}"
echo -e "${BLUE}• Contraseña: $DB_PASSWORD${NC}"
echo -e "${BLUE}• Base de datos: $DB_NAME${NC}"
echo
echo -e "${YELLOW}📊 Estado:${NC}"
echo -e "${BLUE}• PostgreSQL: $PG_STATUS${NC}"
echo -e "${BLUE}• Nginx: $NGINX_STATUS${NC}"
echo -e "${BLUE}• PM2 Apps: $PM2_STATUS online${NC}"
echo
echo -e "${GREEN}💾 Credenciales guardadas en: $APP_DIR/CREDENCIALES_RECUPERADAS.txt${NC}"

# Verificar conectividad
echo -e "${YELLOW}🔍 Verificando conectividad...${NC}"

# Test PostgreSQL
if PGPASSWORD=$DB_PASSWORD psql -h localhost -U $DB_USER -d $DB_NAME -c "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Conexión a PostgreSQL: OK${NC}"
else
    echo -e "${RED}❌ Conexión a PostgreSQL: ERROR${NC}"
fi

# Test puertos
if netstat -tlnp 2>/dev/null | grep -q ":8000"; then
    echo -e "${GREEN}✅ Frontend (puerto 8000): OK${NC}"
else
    echo -e "${RED}❌ Frontend (puerto 8000): NO RESPONDE${NC}"
fi

if netstat -tlnp 2>/dev/null | grep -q ":9000"; then
    echo -e "${GREEN}✅ Backend (puerto 9000): OK${NC}"
else
    echo -e "${RED}❌ Backend (puerto 9000): NO RESPONDE${NC}"
fi

echo -e "${GREEN}🔍 Recuperación completada${NC}" 