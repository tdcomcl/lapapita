# 📂 Cómo Agregar Subcategorías en Backend Medusa

## 🎯 **3 Formas de Crear Subcategorías**

### **1. Admin Dashboard (Más Fácil) ⭐**

```bash
# Iniciar backend
npm run dev

# Ir a: http://localhost:9000/app/categories
```

**Pasos:**
1. **Login** con tus credenciales
2. **Categories** → **New Category**
3. **Crear categoría padre:**
   - Name: "Electrónicos"
   - Handle: "electronicos" (auto-generado)
   - Description: "Productos electrónicos"
   - ✅ **Save**
4. **Crear subcategoría:**
   - Name: "Smartphones"
   - Handle: "smartphones"
   - **Parent Category**: ⚠️ **Seleccionar "Electrónicos"**
   - ✅ **Save**

### **2. Script Automático (Recomendado)**

```bash
# 1. Instalar dependencias
npm install axios dotenv

# 2. Configurar credenciales en .env
echo "ADMIN_EMAIL=admin@medusa-test.com" >> .env
echo "ADMIN_PASSWORD=supersecret" >> .env
echo "MEDUSA_BACKEND_URL=http://localhost:9000" >> .env

# 3. Ejecutar seed (con backend corriendo)
npm run seed:categories
```

**Esto creará automáticamente:**
```
📁 Electrónicos → 📱 Smartphones, 💻 Laptops, 🎧 Audífonos, 📱 Tablets
📁 Ropa → 👕 Camisetas, 👖 Pantalones, 👟 Zapatos, 🎒 Accesorios  
📁 Hogar → 🛋️ Muebles, 🍽️ Cocina, 🛏️ Dormitorio, 🚿 Baño
📁 Deportes → 🏋️ Fitness, ⚽ Fútbol, 🏃 Running, 🏊 Natación
```

### **3. API REST Manual**

```bash
# 1. Autenticar
curl -X POST http://localhost:9000/admin/auth \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@medusa-test.com","password":"supersecret"}'

# 2. Crear categoría padre
curl -X POST http://localhost:9000/admin/product-categories \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Electrónicos",
    "handle": "electronicos",
    "description": "Productos electrónicos",
    "is_active": true
  }'

# 3. Crear subcategoría
curl -X POST http://localhost:9000/admin/product-categories \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Smartphones",
    "handle": "smartphones",
    "parent_category_id": "PARENT_CATEGORY_ID",
    "is_active": true
  }'
```

## 🔧 **Verificar Resultados**

### **En Backend:**
```bash
# Ver todas las categorías
curl http://localhost:9000/store/product-categories

# Ver categoría específica con subcategorías
curl "http://localhost:9000/store/product-categories?fields=*category_children"
```

### **En Frontend:**
```bash
# Reiniciar frontend
cd ../frontend
npm run dev

# Las subcategorías aparecerán en:
# - Menú desktop (dropdown)
# - Menú móvil (lista)
# - CategoryBanners (solo principales)
```

## 📋 **Estructura de Base de Datos**

```sql
-- Tabla: product_category
id                  | parent_category_id | name         | handle
--------------------|-------------------|--------------|-------------
cat_electronics     | null              | Electrónicos | electronicos
cat_smartphones     | cat_electronics   | Smartphones  | smartphones
cat_laptops         | cat_electronics   | Laptops      | laptops
```

## 🚀 **Próximos Pasos**

1. **Crear productos** y asignarlos a subcategorías
2. **Configurar imágenes** para categorías
3. **Personalizar SEO** (meta titles, descriptions)
4. **Agregar más niveles** de subcategorías si necesitas

## 🐛 **Troubleshooting**

**❌ Error de autenticación:**
- Verifica email/password en `.env`
- Asegúrate de que el admin user existe

**❌ No aparecen subcategorías:**
- Reinicia el frontend después de crear
- Verifica que `is_active: true`
- Revisa la consola del navegador

**❌ Error en script:**
- Asegúrate de que el backend esté corriendo
- Instala dependencias: `npm install axios dotenv`

## 📚 **Recursos Adicionales**

- [Medusa Categories Docs](https://docs.medusajs.com/modules/products/categories)
- [Admin API Reference](https://docs.medusajs.com/api/admin#product-categories)
- [Store API Reference](https://docs.medusajs.com/api/store#product-categories) 