#!/bin/bash
#
# 🚀 DEPLOYMENT RÁPIDO - LA PAPITA
# Para Ubuntu 22.04 LTS
# Ejecutar como: curl -s https://raw.githubusercontent.com/tdcomcl/lapapita/main/quick-deploy.sh | sudo bash
#

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}"
echo "🚀 DEPLOYMENT RÁPIDO - LA PAPITA"
echo "================================="
echo -e "${NC}"

# Verificar Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}❌ Este script solo funciona en Ubuntu 22.04 LTS${NC}"
    exit 1
fi

# Configuración automática - Sin input del usuario
DOMAIN="lapapita.cl"
DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
DB_USER="lapapita"
DB_NAME="lapapita_db"
APP_DIR="/home/lapapita/lapapita"

echo -e "${BLUE}Configuración automática:${NC}"
echo -e "${GREEN}🌐 Dominio: $DOMAIN${NC}"
echo -e "${GREEN}🔐 Contraseña DB generada automáticamente${NC}"
echo -e "${YELLOW}⚡ Iniciando deployment automático...${NC}"

# Función de log
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }

# 1. Actualizar sistema e instalar todo de una vez
log "📦 Instalando dependencias del sistema..."
apt update && apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs postgresql postgresql-contrib nginx ufw git curl wget

# 2. Configurar firewall rápido
log "🔥 Configurando firewall..."
ufw --force enable
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp

# 3. Configurar PostgreSQL rápido
log "🐘 Configurando PostgreSQL..."
systemctl start postgresql
systemctl enable postgresql
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# 4. Instalar PM2
log "⚙️ Instalando PM2..."
npm install -g pm2

# 5. Crear usuario y clonar repo
log "👤 Creando usuario y clonando código..."
adduser --disabled-password --gecos "" lapapita 2>/dev/null || true
sudo -u lapapita mkdir -p /home/lapapita
sudo -u lapapita git clone https://github.com/tdcomcl/lapapita.git $APP_DIR 2>/dev/null || (
    cd $APP_DIR && sudo -u lapapita git pull origin main
)

# 6. Generar secrets
JWT_SECRET=$(openssl rand -hex 32)
COOKIE_SECRET=$(openssl rand -hex 32)

# 7. Configurar variables de entorno
log "🔧 Configurando variables de entorno..."
sudo -u lapapita cat > $APP_DIR/backend/.env << EOF
NODE_ENV=production
PORT=9000
DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME
MEDUSA_ADMIN_ONBOARDING_TYPE=nextjs
MEDUSA_ADMIN_ONBOARDING_NEXTJS_DIRECTORY=../frontend
JWT_SECRET=$JWT_SECRET
COOKIE_SECRET=$COOKIE_SECRET
ADMIN_CORS=http://localhost:8000,https://$DOMAIN
STORE_CORS=http://localhost:8000,https://$DOMAIN
EOF

sudo -u lapapita cat > $APP_DIR/frontend/.env.local << EOF
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_BASE_URL=https://$DOMAIN
NEXT_PUBLIC_SEARCH_ENDPOINT=http://localhost:9000
NEXT_PUBLIC_SEARCH_API_KEY=
NEXT_PUBLIC_INDEX_NAME=products
EOF

# 8. Instalar dependencias y build
log "📥 Instalando dependencias..."
sudo -u lapapita bash -c "cd $APP_DIR/backend && npm install"
sudo -u lapapita bash -c "cd $APP_DIR/frontend && npm install"

# 9. Configurar base de datos
log "🗄️ Configurando base de datos..."
if [ -f "$APP_DIR/database_backup.sql" ]; then
    sudo -u lapapita PGPASSWORD=$DB_PASSWORD psql -h localhost -U $DB_USER -d $DB_NAME < $APP_DIR/database_backup.sql
fi

# Generar publishable key
PUBLISHABLE_KEY=$(sudo -u lapapita PGPASSWORD=$DB_PASSWORD psql -h localhost -U $DB_USER -d $DB_NAME -t -c "
INSERT INTO publishable_api_key (id, created_at, updated_at, created_by, revoked_by, revoked_at, title) 
VALUES ('pk_01' || upper(replace(gen_random_uuid()::text, '-', '')), NOW(), NOW(), NULL, NULL, NULL, 'La Papita Store Key') 
RETURNING id;" | tr -d ' ' | tr -d '\n' 2>/dev/null || echo "pk_test_key")

if [ ! -z "$PUBLISHABLE_KEY" ]; then
    echo "NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=$PUBLISHABLE_KEY" >> $APP_DIR/frontend/.env.local
fi

# 10. Build del frontend
log "🏗️ Construyendo aplicación..."
sudo -u lapapita bash -c "cd $APP_DIR/backend && timeout 30 npm run start &"
sleep 15
sudo -u lapapita bash -c "cd $APP_DIR/frontend && npm run build" 2>/dev/null || true
pkill -f "medusa start" 2>/dev/null || true

# 11. Configurar PM2
log "🚀 Configurando PM2..."
sudo -u lapapita cat > $APP_DIR/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'lapapita-backend',
      script: 'npm',
      args: 'run start',
      cwd: '/home/lapapita/lapapita/backend',
      env: { NODE_ENV: 'production', PORT: 9000 }
    },
    {
      name: 'lapapita-frontend',
      script: 'npm',
      args: 'run start',
      cwd: '/home/lapapita/lapapita/frontend',
      env: { NODE_ENV: 'production', PORT: 8000 }
    }
  ]
};
EOF

sudo -u lapapita bash -c "cd $APP_DIR && pm2 start ecosystem.config.js"
sudo -u lapapita pm2 save
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u lapapita --hp /home/lapapita

# 12. Configurar Nginx
log "🌐 Configurando Nginx..."
cat > /etc/nginx/sites-available/lapapita << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /admin {
        proxy_pass http://localhost:9000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /store {
        proxy_pass http://localhost:9000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/lapapita /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# Verificar servicios
log "✅ Verificando servicios..."
systemctl enable postgresql nginx

# Guardar credenciales en archivo
log "💾 Guardando credenciales..."
sudo -u lapapita cat > $APP_DIR/CREDENCIALES.txt << EOF
🚀 LA PAPITA - CREDENCIALES DEL SISTEMA
=======================================
Fecha de instalación: $(date)

🌐 DOMINIO: $DOMAIN
📧 Admin Panel: https://$DOMAIN/admin

🗄️ BASE DE DATOS POSTGRESQL:
• Host: localhost:5432
• Usuario: $DB_USER
• Contraseña: $DB_PASSWORD
• Base de datos: $DB_NAME
• Conexión: postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME

🔐 SECRETS:
• JWT_SECRET: $JWT_SECRET
• COOKIE_SECRET: $COOKIE_SECRET

📁 DIRECTORIOS:
• Aplicación: $APP_DIR
• Usuario del sistema: lapapita

🛠️ COMANDOS ÚTILES:
• sudo -u lapapita pm2 status
• sudo -u lapapita pm2 logs
• sudo -u lapapita pm2 restart all
• sudo -u lapapita pm2 stop all
• sudo systemctl status postgresql
• sudo systemctl status nginx

⚠️ IMPORTANTE: Guarda este archivo en lugar seguro y elimínalo del servidor después.
EOF

sleep 5

echo -e "${GREEN}"
echo "🎉 ¡DEPLOYMENT COMPLETADO!"
echo "========================="
echo -e "${NC}"
echo -e "${BLUE}🌐 Tu sitio: http://$DOMAIN${NC}"
echo -e "${BLUE}⚙️ Admin: http://$DOMAIN/admin${NC}"
echo -e "${YELLOW}⚠️ Para SSL: certbot --nginx -d $DOMAIN${NC}"
echo
echo -e "${GREEN}📋 Información de la Base de Datos:${NC}"
echo -e "${BLUE}• Usuario: $DB_USER${NC}"
echo -e "${BLUE}• Contraseña: $DB_PASSWORD${NC}"
echo -e "${BLUE}• Base de datos: $DB_NAME${NC}"
echo -e "${BLUE}• Host: localhost:5432${NC}"
echo
echo -e "${YELLOW}💾 Credenciales guardadas en: $APP_DIR/CREDENCIALES.txt${NC}"
echo -e "${RED}⚠️ Descarga y elimina este archivo después de leerlo${NC}"
echo
echo -e "${GREEN}Comandos útiles:${NC}"
echo "• sudo -u lapapita pm2 status"
echo "• sudo -u lapapita pm2 logs"
echo "• sudo -u lapapita pm2 restart all"
echo "• cat $APP_DIR/CREDENCIALES.txt"

# Instalar SSL automáticamente si es posible
if command -v certbot >/dev/null 2>&1; then
    log "🔒 Instalando SSL..."
    apt install -y certbot python3-certbot-nginx
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN 2>/dev/null || true
fi

log "🚀 ¡La Papita está lista para usar!" 