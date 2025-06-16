# 🗄️ Despliegue de Base de Datos - La Papita

## 📋 Contenido de la Base de Datos

La base de datos actual contiene:
- **7 productos** configurados
- **6 categorías** con subcategorías
- Configuración completa de Medusa Commerce
- Datos de prueba y configuración inicial

## 📦 Archivos Incluidos

- `database_backup.sql` - Backup completo de la base de datos PostgreSQL
- `restore-database.sh` - Script automatizado para restaurar la BD en el servidor

## 🚀 Instrucciones de Despliegue

### 1. En el Servidor (Debian 12)

```bash
# Clonar el repositorio
cd /var/www/lapapita
git pull origin main

# Hacer ejecutable el script
chmod +x restore-database.sh

# Ejecutar la restauración
./restore-database.sh
```

### 2. Verificación Post-Despliegue

```bash
# Verificar productos
psql -h localhost -U lapapita -d lapapita_db -c "SELECT COUNT(*) as productos FROM product;"

# Verificar categorías
psql -h localhost -U lapapita -d lapapita_db -c "SELECT COUNT(*) as categorias FROM product_category;"

# Ver productos disponibles
psql -h localhost -U lapapita -d lapapita_db -c "SELECT title, status FROM product;"

# Ver categorías
psql -h localhost -U lapapita -d lapapita_db -c "SELECT name, handle FROM product_category;"
```

### 3. Configuración de Variables de Entorno

Asegúrate de que el archivo `.env` del backend tenga:

```env
DATABASE_URL=postgresql://lapapita:tu_password@localhost:5432/lapapita_db
```

## 🔧 Comandos Útiles

### Backup Manual
```bash
# Crear backup
pg_dump -h localhost -U lapapita -d lapapita_db > backup_$(date +%Y%m%d).sql
```

### Restauración Manual
```bash
# Restaurar backup
psql -h localhost -U lapapita -d lapapita_db < database_backup.sql
```

### Reiniciar Aplicaciones
```bash
# Reiniciar backend y frontend
pm2 restart lapapita-backend lapapita-frontend

# Ver logs
pm2 logs
```

## 📊 Estructura de Datos

### Productos Incluidos
- Productos de ejemplo con imágenes
- Variantes y opciones configuradas
- Precios en CLP (pesos chilenos)

### Categorías Incluidas
- Estructura jerárquica de categorías
- Subcategorías organizadas
- Handles SEO-friendly

## 🚨 Notas Importantes

1. **Backup de Seguridad**: El script automáticamente crea un backup antes de restaurar
2. **Downtime**: Las aplicaciones se detienen durante la restauración (~2-3 minutos)
3. **Verificación**: Siempre verificar que los datos se restauraron correctamente
4. **Permisos**: El usuario `lapapita` debe tener permisos completos en la BD

## 🆘 Solución de Problemas

### Error de Conexión
```bash
# Verificar que PostgreSQL esté corriendo
sudo systemctl status postgresql

# Verificar usuario y permisos
sudo -u postgres psql -c "\du"
```

### Error de Restauración
```bash
# Ver logs detallados
psql -h localhost -U lapapita -d lapapita_db < database_backup.sql 2>&1 | tee restore.log
```

### Aplicaciones No Inician
```bash
# Ver logs de PM2
pm2 logs lapapita-backend
pm2 logs lapapita-frontend

# Verificar variables de entorno
cd /var/www/lapapita/backend && cat .env
``` 