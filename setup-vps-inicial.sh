#!/bin/bash
#
# 🚀 Setup Inicial VPS - La Papita
# Para Debian 12 / Ubuntu 22.04 LTS
# 
# Uso: curl -sSL https://raw.githubusercontent.com/tdcomcl/lapapita/main/setup-vps-inicial.sh | bash
#

set -e  # Salir en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Verificar que se ejecuta como root
if [[ $EUID -ne 0 ]]; then
    error "Este script debe ejecutarse como root. Usa: sudo bash setup-vps-inicial.sh"
fi

echo -e "${BLUE}"
echo "=============================================="
echo "🚀 SETUP INICIAL VPS - LA PAPITA"
echo "=============================================="
echo "Configurando servidor desde cero..."
echo -e "${NC}"

# Obtener información del usuario
read -p "Ingresa tu dominio (ej: lapapita.com) o presiona Enter para saltar: " DOMAIN
read -p "Ingresa una contraseña para la base de datos: " -s DB_PASSWORD
echo
read -p "¿Configurar firewall automáticamente? (y/n): " SETUP_FIREWALL

log "Iniciando configuración del servidor..."

# 1. Actualizar sistema
log "Paso 1: Actualizando el sistema..."
apt update && apt upgrade -y

# 2. Instalar herramientas esenciales
log "Paso 2: Instalando herramientas esenciales..."
apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    ufw \
    net-tools

# 3. Configurar firewall (opcional)
if [[ $SETUP_FIREWALL == "y" ]]; then
    log "Paso 3: Configurando firewall..."
    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 9000/tcp  # Backend Medusa
    ufw allow 8000/tcp  # Frontend Next.js
    log "✅ Firewall configurado"
else
    log "Paso 3: Saltando configuración de firewall"
fi

# 4. Instalar Node.js 20
log "Paso 4: Instalando Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Verificar instalación
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
log "✅ Node.js instalado: $NODE_VERSION"
log "✅ NPM instalado: $NPM_VERSION"

# 5. Instalar PostgreSQL
log "Paso 5: Instalando PostgreSQL..."
apt install -y postgresql postgresql-contrib

# Iniciar y habilitar PostgreSQL
systemctl start postgresql
systemctl enable postgresql

# Configurar usuario y base de datos
sudo -u postgres psql -c "CREATE USER lapapita WITH PASSWORD '$DB_PASSWORD';" || true
sudo -u postgres psql -c "CREATE DATABASE lapapita_db OWNER lapapita;" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE lapapita_db TO lapapita;"

# Configurar acceso
PG_VERSION=$(ls /etc/postgresql/ | head -n1)
PG_HBA_FILE="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

if ! grep -q "local   all             lapapita" "$PG_HBA_FILE"; then
    echo "local   all             lapapita                                md5" >> "$PG_HBA_FILE"
fi

systemctl restart postgresql
log "✅ PostgreSQL configurado"

# 6. Instalar PM2
log "Paso 6: Instalando PM2..."
npm install -g pm2
pm2 startup systemd -u root --hp /root
PM2_VERSION=$(pm2 --version)
log "✅ PM2 instalado: $PM2_VERSION"

# 7. Instalar Nginx
log "Paso 7: Instalando Nginx..."
apt install -y nginx
systemctl start nginx
systemctl enable nginx
log "✅ Nginx instalado y configurado"

# 8. Crear usuario de aplicación
log "Paso 8: Creando usuario de aplicación..."
adduser --disabled-password --gecos "" lapapita || true
usermod -aG sudo lapapita
mkdir -p /home/lapapita/apps
chown -R lapapita:lapapita /home/lapapita/apps
log "✅ Usuario 'lapapita' creado"

# 9. Configurar swap (recomendado para VPS pequeños)
log "Paso 9: Configurando memoria swap..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    log "✅ Swap de 2GB configurado"
else
    log "✅ Swap ya existe"
fi

# 10. Optimizaciones básicas del sistema
log "Paso 10: Aplicando optimizaciones básicas..."

# Configurar timezone
timedatectl set-timezone America/Santiago

# Optimizar configuración de red
cat >> /etc/sysctl.conf << 'EOF'
# Optimizaciones para aplicaciones web
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
EOF

sysctl -p

log "✅ Optimizaciones aplicadas"

# 11. Crear script de deployment rápido
log "Paso 11: Creando script de deployment..."
cat > /home/lapapita/deploy.sh << 'EOF'
#!/bin/bash
# Script de deployment rápido para La Papita
cd /home/lapapita/apps

# Clonar o actualizar repositorio
if [ -d "lapapita" ]; then
    echo "Actualizando repositorio..."
    cd lapapita && git pull origin main
else
    echo "Clonando repositorio..."
    git clone https://github.com/tdcomcl/lapapita.git
    cd lapapita
fi

# Instalar dependencias
echo "Instalando dependencias..."
npm run install:all

# Configurar variables de entorno (debes editarlas)
echo "⚠️  RECUERDA CONFIGURAR LAS VARIABLES DE ENTORNO:"
echo "   - backend/.env"
echo "   - frontend/.env.local"
echo ""
echo "Después ejecuta:"
echo "   - npm run build (en backend y frontend)"
echo "   - pm2 start ecosystem.config.js"
EOF

chmod +x /home/lapapita/deploy.sh
chown lapapita:lapapita /home/lapapita/deploy.sh

log "✅ Script de deployment creado en /home/lapapita/deploy.sh"

# 12. Información final
echo -e "\n${GREEN}=============================================="
echo "🎉 SETUP INICIAL COMPLETADO"
echo "=============================================="
echo -e "${NC}"

info "📋 INFORMACIÓN DEL SERVIDOR:"
echo "   - SO: $(lsb_release -d | cut -f2-)"
echo "   - Node.js: $NODE_VERSION"
echo "   - PostgreSQL: $(psql --version | head -n1)"
echo "   - Usuario de app: lapapita"
echo "   - Base de datos: lapapita_db"

echo -e "\n${YELLOW}🔧 PRÓXIMOS PASOS:"
echo "1. Configura tu dominio apuntando a esta IP"
echo "2. Ejecuta como usuario 'lapapita':"
echo "   sudo su - lapapita"
echo "   ./deploy.sh"
echo "3. Configura variables de entorno"
echo "4. Ejecuta el deployment completo"
echo -e "${NC}"

if [ ! -z "$DOMAIN" ]; then
    echo -e "${BLUE}🌐 DOMINIO CONFIGURADO: $DOMAIN${NC}"
    echo "Asegúrate de que el DNS apunte a: $(curl -s ifconfig.me)"
fi

echo -e "\n${GREEN}✅ Servidor listo para deployment de La Papita!${NC}" 