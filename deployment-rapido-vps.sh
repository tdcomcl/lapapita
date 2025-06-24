#!/bin/bash
#
# 🚀 Deployment Rápido VPS - La Papita
# Para usar después del setup inicial
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
echo "🚀 DEPLOYMENT RÁPIDO - LA PAPITA"
echo "=============================================="
echo -e "${NC}"

# Verificar que estamos como usuario lapapita
if [ "$USER" != "lapapita" ]; then
    error "Este script debe ejecutarse como usuario 'lapapita'. Usa: sudo su - lapapita"
fi

# Ir al directorio de apps
cd /home/lapapita/apps

log "Paso 1: Clonando/Actualizando repositorio..."

if [ -d "lapapita" ]; then
    log "Actualizando repositorio existente..."
    cd lapapita
    git pull origin main
else
    log "Clonando repositorio desde GitHub..."
    git clone https://github.com/tdcomcl/lapapita.git
    cd lapapita
fi

log "Paso 2: Instalando dependencias..."
npm run install:all

log "Paso 3: Configurando variables de entorno..."

# Verificar si existen los archivos .env
if [ ! -f "backend/.env" ]; then
    warning "Creando archivo backend/.env - DEBES EDITARLO!"
    cat > backend/.env << 'EOF'
# EDITA ESTAS VARIABLES ANTES DE CONTINUAR
DATABASE_URL=postgresql://lapapita:TU_PASSWORD_BD@localhost:5432/lapapita_db
JWT_SECRET=tu_jwt_secret_de_64_caracteres_minimo_aqui_generalo_con_openssl_rand_hex_32
COOKIE_SECRET=tu_cookie_secret_de_64_caracteres_minimo_aqui_generalo_con_openssl_rand_hex_32
STORE_CORS=http://localhost:8000,http://tu-dominio.com
ADMIN_CORS=http://localhost:9000,http://tu-dominio.com:9000
AUTH_CORS=http://localhost:9000,http://tu-dominio.com:9000
NODE_ENV=production
EOF
    echo -e "${RED}⚠️  IMPORTANTE: Edita backend/.env con tus valores reales!${NC}"
fi

if [ ! -f "frontend/.env.local" ]; then
    warning "Creando archivo frontend/.env.local - DEBES EDITARLO!"
    cat > frontend/.env.local << 'EOF'
# EDITA ESTAS VARIABLES ANTES DE CONTINUAR
MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_tu_publishable_key_aqui
NODE_ENV=production
EOF
    echo -e "${RED}⚠️  IMPORTANTE: Edita frontend/.env.local con tus valores reales!${NC}"
fi

log "Paso 4: Restaurando base de datos..."
if [ -f "database_backup.sql" ]; then
    info "Restaurando datos desde backup..."
    PGPASSWORD="$(grep 'DATABASE_URL' backend/.env | cut -d':' -f3 | cut -d'@' -f1)" psql -h localhost -U lapapita -d lapapita_db < database_backup.sql
    log "✅ Base de datos restaurada"
else
    warning "No se encontró database_backup.sql, usando seed..."
    cd backend && npm run seed
    cd ..
fi

log "Paso 5: Construyendo aplicaciones..."
cd backend && npm run build
cd ../frontend && npm run build
cd ..

log "Paso 6: Configurando PM2..."

# Crear archivo ecosystem.config.js si no existe
if [ ! -f "ecosystem.config.js" ]; then
    info "Creando configuración PM2..."
    cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'lapapita-backend',
      cwd: './backend',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
        PORT: 9000
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      log_file: '/home/lapapita/logs/backend.log',
      error_file: '/home/lapapita/logs/backend-error.log',
      out_file: '/home/lapapita/logs/backend-out.log'
    },
    {
      name: 'lapapita-frontend',
      cwd: './frontend',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
        PORT: 8000
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      log_file: '/home/lapapita/logs/frontend.log',
      error_file: '/home/lapapita/logs/frontend-error.log',
      out_file: '/home/lapapita/logs/frontend-out.log'
    }
  ]
}
EOF
fi

# Crear directorio de logs
mkdir -p /home/lapapita/logs

log "Paso 7: Iniciando aplicaciones con PM2..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save

log "Paso 8: Configurando Nginx..."
sudo tee /etc/nginx/sites-available/lapapita > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;  # Cambia por tu dominio

    # Frontend (Next.js)
    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_buffering off;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Backend API (Medusa)
    location /admin {
        proxy_pass http://localhost:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # API Store
    location /store {
        proxy_pass http://localhost:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Habilitar sitio
sudo ln -sf /etc/nginx/sites-available/lapapita /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

echo -e "\n${GREEN}=============================================="
echo "🎉 DEPLOYMENT COMPLETADO!"
echo "=============================================="
echo -e "${NC}"

info "📋 ESTADO ACTUAL:"
echo "   - Repositorio: Actualizado desde GitHub"
echo "   - Dependencias: Instaladas"
echo "   - Base de datos: Restaurada"
echo "   - Backend: Construido y corriendo en puerto 9000"
echo "   - Frontend: Construido y corriendo en puerto 8000"
echo "   - Nginx: Configurado como proxy"

echo -e "\n${BLUE}🌐 ACCESO A LA APLICACIÓN:${NC}"
echo "   - Tienda: http://$(curl -s ifconfig.me)/"
echo "   - Admin: http://$(curl -s ifconfig.me)/admin"

echo -e "\n${YELLOW}🔧 COMANDOS ÚTILES:${NC}"
echo "   - Ver logs: pm2 logs"
echo "   - Reiniciar: pm2 restart all"
echo "   - Estado: pm2 status"
echo "   - Logs Nginx: sudo tail -f /var/log/nginx/error.log"

echo -e "\n${YELLOW}⚠️  RECUERDA:${NC}"
echo "   1. Editar backend/.env con tus credenciales reales"
echo "   2. Editar frontend/.env.local con tu publishable key"
echo "   3. Configurar tu dominio en Nginx (/etc/nginx/sites-available/lapapita)"
echo "   4. Configurar SSL con Let's Encrypt (opcional)"

echo -e "\n${GREEN}✅ ¡La Papita está lista en tu VPS!${NC}" 