#!/bin/bash
#
# 🔧 Fix Rollup Dependencies - La Papita
# Soluciona el problema con @rollup/rollup-linux-x64-gnu
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
echo "🔧 SOLUCIONANDO PROBLEMA ROLLUP - LA PAPITA"
echo "=============================================="
echo -e "${NC}"

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    error "No se encontró package.json. Ejecuta este script desde el directorio del proyecto"
fi

# Verificar que estamos como usuario lapapita
if [ "$USER" != "lapapita" ]; then
    error "Este script debe ejecutarse como usuario 'lapapita'"
fi

log "Paso 1: Limpiando dependencias corruptas..."

# Limpiar cache de npm
npm cache clean --force

# Eliminar node_modules y package-lock.json del backend
if [ -d "backend/node_modules" ]; then
    rm -rf backend/node_modules
    log "✅ backend/node_modules eliminado"
fi

if [ -f "backend/package-lock.json" ]; then
    rm -f backend/package-lock.json
    log "✅ backend/package-lock.json eliminado"
fi

# Limpiar frontend también por si acaso
if [ -d "frontend/node_modules" ]; then
    rm -rf frontend/node_modules
    log "✅ frontend/node_modules eliminado"
fi

if [ -f "frontend/package-lock.json" ]; then
    rm -f frontend/package-lock.json
    log "✅ frontend/package-lock.json eliminado"
fi

# Limpiar node_modules del root
if [ -d "node_modules" ]; then
    rm -rf node_modules
    log "✅ node_modules del root eliminado"
fi

if [ -f "package-lock.json" ]; then
    rm -f package-lock.json
    log "✅ package-lock.json del root eliminado"
fi

log "Paso 2: Reinstalando dependencias..."

# Instalar dependencias usando el comando del proyecto
npm run install:all

log "Paso 3: Instalando dependencias específicas de Rollup..."

# Instalar explícitamente las dependencias de rollup para Linux
cd backend
npm install @rollup/rollup-linux-x64-gnu --save-optional

log "Paso 4: Verificando instalación..."

# Verificar que rollup funciona
if npx rollup --version >/dev/null 2>&1; then
    log "✅ Rollup instalado correctamente"
else
    warning "Rollup aún tiene problemas, intentando instalación alternativa..."
    npm install rollup@latest --save-dev
fi

log "Paso 5: Intentando build del backend..."

# Intentar build
if npm run build; then
    log "✅ Build del backend exitoso"
else
    warning "Build falló, intentando con alternativa..."
    
    # Intentar con yarn si está disponible
    if command -v yarn >/dev/null 2>&1; then
        log "Probando con yarn..."
        yarn install
        yarn build
    else
        # Instalar dependencias una por una
        log "Instalando dependencias críticas..."
        npm install @medusajs/medusa@latest
        npm install @medusajs/framework@latest
        npm run build
    fi
fi

cd ..

log "Paso 6: Build del frontend..."

cd frontend
npm run build
cd ..

echo -e "\n${GREEN}=============================================="
echo "🎉 PROBLEMA ROLLUP SOLUCIONADO!"
echo "=============================================="
echo -e "${NC}"

info "📋 RESUMEN:"
echo "   - Dependencias limpiadas y reinstaladas"
echo "   - Rollup configurado correctamente"
echo "   - Backend construido exitosamente"
echo "   - Frontend construido exitosamente"

echo -e "\n${BLUE}🚀 SIGUIENTES PASOS:${NC}"
echo "   1. Iniciar aplicaciones: pm2 start ecosystem.config.js"
echo "   2. Ver estado: pm2 status"
echo "   3. Ver logs: pm2 logs"

echo -e "\n${GREEN}✅ ¡Builds completados correctamente!${NC}" 