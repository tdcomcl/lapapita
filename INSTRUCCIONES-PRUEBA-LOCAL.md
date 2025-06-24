# 🍟 La Papita - Instrucciones para Prueba Local

## 📋 Requisitos Previos

- **Node.js 20+** (recomendado usar nvm)
- **PostgreSQL** instalado y corriendo
- **Git** instalado

## 🚀 Pasos para Probar Localmente

### 1. Instalar Node.js 20 (si no lo tienes)
```bash
# Con nvm (recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20

# O instalar directamente desde nodejs.org
```

### 2. Instalar PostgreSQL
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# macOS
brew install postgresql
brew services start postgresql

# Windows
# Descargar desde https://www.postgresql.org/download/windows/
```

### 3. Configurar Base de Datos
```bash
# Crear usuario y base de datos
sudo -u postgres psql
CREATE USER lapapita WITH PASSWORD 'tu_password_aqui';
CREATE DATABASE lapapita_db OWNER lapapita;
GRANT ALL PRIVILEGES ON DATABASE lapapita_db TO lapapita;
\q
```

### 4. Clonar y Configurar el Proyecto
```bash
# Ya tienes el proyecto, pero asegúrate de estar en la raíz
cd lapapita

# Instalar dependencias de ambos proyectos
npm run install:all
```

### 5. Configurar Variables de Entorno

#### Backend (.env en /backend/)
```bash
cd backend
# Crear archivo .env
cat > .env << 'EOF'
DATABASE_URL=postgresql://lapapita:tu_password_aqui@localhost:5432/lapapita_db
JWT_SECRET=tu_jwt_secret_de_64_caracteres_o_mas_aqui_muy_importante
COOKIE_SECRET=tu_cookie_secret_de_64_caracteres_o_mas_aqui_tambien
STORE_CORS=http://localhost:8000,http://localhost:3000
ADMIN_CORS=http://localhost:9000,http://localhost:9001
AUTH_CORS=http://localhost:9000,http://localhost:9001
NODE_ENV=development
EOF
```

#### Frontend (.env.local en /frontend/)
```bash
cd ../frontend
# Crear archivo .env.local
cat > .env.local << 'EOF'
MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=tu_publishable_key_aqui
NODE_ENV=development
EOF
```

### 6. Restaurar Base de Datos con Datos
```bash
# Desde la raíz del proyecto
cd lapapita
psql -h localhost -U lapapita -d lapapita_db < database_backup.sql
```

### 7. Ejecutar el Proyecto

#### Opción 1: Todo junto (recomendado)
```bash
# Desde la raíz del proyecto
npm run dev
```

#### Opción 2: Por separado
```bash
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Frontend  
cd frontend
npm run dev
```

### 8. Acceder a la Aplicación

- **Tienda (Frontend)**: http://localhost:8000
- **Admin Panel**: http://localhost:9000/app
- **API Backend**: http://localhost:9000

## 🔧 Comandos Útiles

### Semilla de Datos (si no usas el backup)
```bash
cd backend
npm run seed
```

### Crear Categorías Manualmente
```bash
cd backend
npm run seed:categories
```

### Logs y Debugging
```bash
# Ver logs del backend
cd backend && npm run dev

# Ver logs del frontend
cd frontend && npm run dev
```

## 🛍️ Funcionalidades Disponibles

- ✅ Catálogo de productos
- ✅ Carrito de compras
- ✅ Proceso de checkout
- ✅ Categorías y subcategorías
- ✅ Panel de administración
- ✅ Gestión de inventario
- ✅ Múltiples métodos de pago

## 🗃️ Datos Incluidos

La base de datos incluye:
- **7 productos** de ejemplo
- **6 categorías** organizadas
- Configuración completa de Medusa
- Datos de prueba listos para usar

## 🆘 Solución de Problemas

### Error de Conexión a BD
```bash
# Verificar que PostgreSQL esté corriendo
sudo systemctl status postgresql  # Linux
brew services list | grep postgres  # macOS

# Verificar credenciales
psql -h localhost -U lapapita -d lapapita_db -c "SELECT 1;"
```

### Error de Dependencias
```bash
# Limpiar e reinstalar
rm -rf node_modules package-lock.json
rm -rf backend/node_modules backend/package-lock.json  
rm -rf frontend/node_modules frontend/package-lock.json
npm run install:all
```

### Puerto Ocupado
```bash
# Ver qué está usando el puerto
lsof -i :9000  # Backend
lsof -i :8000  # Frontend

# Cambiar puertos en package.json si es necesario
```

---

🎉 **¡Listo!** Ahora puedes explorar **La Papita** localmente y ver todas sus funcionalidades. 