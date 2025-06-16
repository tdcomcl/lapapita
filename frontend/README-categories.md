# 📂 Guía para Crear Subcategorías en Medusa

## 🎯 Opciones para Crear Subcategorías

### **Opción 1: Admin Dashboard (Recomendado)**

1. **Inicia el backend de Medusa:**
   ```bash
   cd ../backend
   npm run dev
   ```

2. **Accede al admin:**
   ```
   http://localhost:9000/app/categories
   ```

3. **Crear categorías:**
   - Clic en "New Category"
   - Completa: Name, Handle, Description
   - Para subcategorías: selecciona "Parent Category"

### **Opción 2: Script Automático**

1. **Instala axios (si no lo tienes):**
   ```bash
   npm install axios
   ```

2. **Edita las credenciales en `create-categories.js`:**
   ```javascript
   const ADMIN_EMAIL = 'tu-email@ejemplo.com';
   const ADMIN_PASSWORD = 'tu-password';
   ```

3. **Ejecuta el script:**
   ```bash
   node create-categories.js
   ```

4. **Reinicia el frontend:**
   ```bash
   npm run dev
   ```

## 📋 Estructura de Categorías Creadas

```
📁 Electrónicos
  ├── 📱 Smartphones
  ├── 💻 Laptops
  └── 🎧 Audífonos

📁 Ropa
  ├── 👕 Camisetas
  ├── 👖 Pantalones
  └── 👟 Zapatos

📁 Hogar
  ├── 🛋️ Muebles
  ├── 🍽️ Cocina
  └── 🛏️ Dormitorio

📁 Deportes
  ├── 🏋️ Fitness
  ├── ⚽ Fútbol
  └── 🏃 Running
```

## 🔧 Verificar Implementación

Tu frontend ya está configurado para mostrar subcategorías:

- ✅ **ModernMenu**: Dropdown con subcategorías
- ✅ **CategoryBanners**: Solo categorías principales
- ✅ **Footer**: Categorías con subcategorías
- ✅ **CategoryTemplate**: Breadcrumbs y navegación

## 🚀 Próximos Pasos

1. **Crear productos** y asignarlos a subcategorías
2. **Personalizar iconos** en CategoryBanners
3. **Agregar imágenes** a las categorías
4. **Configurar SEO** para cada categoría

## 🐛 Troubleshooting

**Si no ves las subcategorías:**
1. Verifica que el backend esté corriendo
2. Revisa la consola del navegador por errores
3. Asegúrate de que las categorías tengan `is_active: true`
4. Reinicia el frontend después de crear categorías

**URLs de las categorías:**
- Categoría principal: `/categories/electronicos`
- Subcategoría: `/categories/smartphones` 