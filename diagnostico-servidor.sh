#!/bin/bash
#
# 🔍 Script de Diagnóstico - La Papita
# Detecta problemas comunes en el deployment
#

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 DIAGNÓSTICO DEL SERVIDOR - LA PAPITA${NC}"
echo "=============================================="

# Función para verificar comandos
check_command() {
    if command -v $1 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $1 está instalado${NC}"
        if [ "$1" = "node" ]; then
            echo "   Versión: $(node --version)"
        elif [ "$1" = "npm" ]; then
            echo "   Versión: $(npm --version)"
        elif [ "$1" = "psql" ]; then
            echo "   Versión: $(psql --version | head -n1)"
        elif [ "$1" = "pm2" ]; then
            echo "   Versión: $(pm2 --version)"
        elif [ "$1" = "nginx" ]; then
            echo "   Versión: $(nginx -v 2>&1)"
        fi
    else
        echo -e "${RED}❌ $1 NO está instalado${NC}"
    fi
}

# Función para verificar servicios
check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "${GREEN}✅ $1 está corriendo${NC}"
    else
        echo -e "${RED}❌ $1 NO está corriendo${NC}"
    fi
}

# Función para verificar puertos
check_port() {
    if netstat -tlnp | grep -q ":$1 "; then
        echo -e "${GREEN}✅ Puerto $1 está en uso${NC}"
        echo "   $(netstat -tlnp | grep ":$1 " | head -n1)"
    else
        echo -e "${YELLOW}⚠️  Puerto $1 está libre${NC}"
    fi
}

echo -e "\n${BLUE}📋 INFORMACIÓN DEL SISTEMA${NC}"
echo "Sistema: $(uname -a)"
echo "Distribución: $(lsb_release -d 2>/dev/null | cut -f2- || echo 'No disponible')"
echo "Usuario actual: $(whoami)"
echo "Directorio actual: $(pwd)"

echo -e "\n${BLUE}🔧 VERIFICANDO DEPENDENCIAS${NC}"
check_command "node"
check_command "npm"
check_command "psql"
check_command "pm2"
check_command "nginx"
check_command "git"

echo -e "\n${BLUE}🔄 VERIFICANDO SERVICIOS${NC}"
check_service "postgresql"
check_service "nginx"

echo -e "\n${BLUE}🌐 VERIFICANDO PUERTOS${NC}"
check_port "80"
check_port "443"
check_port "9000"
check_port "8000"
check_port "5432"

echo -e "\n${BLUE}📁 VERIFICANDO ESTRUCTURA DEL PROYECTO${NC}"
if [ -d "/home/lapapita/apps/lapapita" ]; then
    echo -e "${GREEN}✅ Directorio del proyecto existe${NC}"
    echo "   Ubicación: /home/lapapita/apps/lapapita"
    
    if [ -f "/home/lapapita/apps/lapapita/package.json" ]; then
        echo -e "${GREEN}✅ package.json principal encontrado${NC}"
    else
        echo -e "${RED}❌ package.json principal NO encontrado${NC}"
    fi
    
    if [ -f "/home/lapapita/apps/lapapita/backend/package.json" ]; then
        echo -e "${GREEN}✅ Backend configurado${NC}"
    else
        echo -e "${RED}❌ Backend NO configurado${NC}"
    fi
    
    if [ -f "/home/lapapita/apps/lapapita/frontend/package.json" ]; then
        echo -e "${GREEN}✅ Frontend configurado${NC}"
    else
        echo -e "${RED}❌ Frontend NO configurado${NC}"
    fi
    
    if [ -f "/home/lapapita/apps/lapapita/backend/.env" ]; then
        echo -e "${GREEN}✅ Variables de entorno del backend configuradas${NC}"
    else
        echo -e "${RED}❌ Variables de entorno del backend NO configuradas${NC}"
    fi
    
    if [ -f "/home/lapapita/apps/lapapita/frontend/.env.local" ]; then
        echo -e "${GREEN}✅ Variables de entorno del frontend configuradas${NC}"
    else
        echo -e "${RED}❌ Variables de entorno del frontend NO configuradas${NC}"
    fi
else
    echo -e "${RED}❌ Directorio del proyecto NO existe${NC}"
fi

echo -e "\n${BLUE}🗄️ VERIFICANDO BASE DE DATOS${NC}"
if command -v psql >/dev/null 2>&1; then
    echo "Intentando conectar a la base de datos..."
    # Nota: Esto pedirá contraseña
    if psql -h localhost -U lapapita -d lapapita_db -c "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Conexión a la base de datos exitosa${NC}"
        
        # Verificar tablas
        table_count=$(psql -h localhost -U lapapita -d lapapita_db -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | xargs)
        if [ "$table_count" -gt 0 ]; then
            echo -e "${GREEN}✅ Base de datos tiene $table_count tablas${NC}"
        else
            echo -e "${YELLOW}⚠️  Base de datos existe pero está vacía${NC}"
        fi
    else
        echo -e "${RED}❌ NO se puede conectar a la base de datos${NC}"
        echo "   Verifica credenciales y que PostgreSQL esté corriendo"
    fi
else
    echo -e "${RED}❌ PostgreSQL no está instalado${NC}"
fi

echo -e "\n${BLUE}📊 ESTADO DE PM2${NC}"
if command -v pm2 >/dev/null 2>&1; then
    pm2_status=$(pm2 list 2>/dev/null | grep -c "lapapita")
    if [ "$pm2_status" -gt 0 ]; then
        echo -e "${GREEN}✅ PM2 tiene $pm2_status procesos de La Papita${NC}"
        pm2 list | grep lapapita
    else
        echo -e "${YELLOW}⚠️  No hay procesos de La Papita corriendo en PM2${NC}"
    fi
else
    echo -e "${RED}❌ PM2 no está instalado${NC}"
fi

echo -e "\n${BLUE}🔥 VERIFICANDO LOGS RECIENTES${NC}"
if [ -d "/home/lapapita/apps/lapapita" ]; then
    echo "Últimos logs de PM2:"
    pm2 logs --lines 5 2>/dev/null || echo "No hay logs de PM2 disponibles"
    
    echo -e "\nLogs de Nginx:"
    sudo tail -n 5 /var/log/nginx/error.log 2>/dev/null || echo "No hay logs de Nginx disponibles"
    
    echo -e "\nLogs de PostgreSQL:"
    sudo tail -n 5 /var/log/postgresql/postgresql-*-main.log 2>/dev/null || echo "No hay logs de PostgreSQL disponibles"
fi

echo -e "\n${BLUE}💾 ESPACIO EN DISCO${NC}"
df -h | head -n 1
df -h | grep -E '^/dev'

echo -e "\n${BLUE}🧠 MEMORIA${NC}"
free -h

echo -e "\n${YELLOW}=============================================="
echo "🔍 DIAGNÓSTICO COMPLETADO"
echo "=============================================="
echo -e "Si necesitas ayuda, comparte esta información.${NC}" 