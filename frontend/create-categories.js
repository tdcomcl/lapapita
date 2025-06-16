// Script para crear categorías de ejemplo
// Ejecutar con: node create-categories.js

const axios = require('axios');

const MEDUSA_BACKEND_URL = 'http://localhost:9000';
const ADMIN_EMAIL = 'admin@medusa-test.com'; // Cambia por tu email de admin
const ADMIN_PASSWORD = 'supersecret'; // Cambia por tu password

async function createCategories() {
  try {
    // 1. Autenticarse como admin
    console.log('🔐 Autenticando...');
    const authResponse = await axios.post(`${MEDUSA_BACKEND_URL}/admin/auth`, {
      email: ADMIN_EMAIL,
      password: ADMIN_PASSWORD
    });
    
    const token = authResponse.data.user.api_token;
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };

    // 2. Crear categorías principales
    console.log('📁 Creando categorías principales...');
    
    const mainCategories = [
      {
        name: 'Electrónicos',
        handle: 'electronicos',
        description: 'Productos electrónicos y tecnología',
        subcategories: [
          { name: 'Smartphones', handle: 'smartphones', description: 'Teléfonos inteligentes' },
          { name: 'Laptops', handle: 'laptops', description: 'Computadoras portátiles' },
          { name: 'Audífonos', handle: 'audifonos', description: 'Audífonos y auriculares' }
        ]
      },
      {
        name: 'Ropa',
        handle: 'ropa',
        description: 'Vestimenta y accesorios',
        subcategories: [
          { name: 'Camisetas', handle: 'camisetas', description: 'Camisetas y polos' },
          { name: 'Pantalones', handle: 'pantalones', description: 'Pantalones y jeans' },
          { name: 'Zapatos', handle: 'zapatos', description: 'Calzado deportivo y casual' }
        ]
      },
      {
        name: 'Hogar',
        handle: 'hogar',
        description: 'Productos para el hogar',
        subcategories: [
          { name: 'Muebles', handle: 'muebles', description: 'Muebles y decoración' },
          { name: 'Cocina', handle: 'cocina', description: 'Utensilios de cocina' },
          { name: 'Dormitorio', handle: 'dormitorio', description: 'Productos para el dormitorio' }
        ]
      },
      {
        name: 'Deportes',
        handle: 'deportes',
        description: 'Artículos deportivos',
        subcategories: [
          { name: 'Fitness', handle: 'fitness', description: 'Equipos de ejercicio' },
          { name: 'Fútbol', handle: 'futbol', description: 'Artículos de fútbol' },
          { name: 'Running', handle: 'running', description: 'Productos para correr' }
        ]
      }
    ];

    for (const mainCat of mainCategories) {
      // Crear categoría principal
      console.log(`📂 Creando: ${mainCat.name}`);
      const parentResponse = await axios.post(
        `${MEDUSA_BACKEND_URL}/admin/product-categories`,
        {
          name: mainCat.name,
          handle: mainCat.handle,
          description: mainCat.description,
          is_active: true,
          is_internal: false
        },
        { headers }
      );

      const parentId = parentResponse.data.product_category.id;
      console.log(`✅ Creada categoría principal: ${mainCat.name} (${parentId})`);

      // Crear subcategorías
      for (const subCat of mainCat.subcategories) {
        console.log(`  📄 Creando subcategoría: ${subCat.name}`);
        await axios.post(
          `${MEDUSA_BACKEND_URL}/admin/product-categories`,
          {
            name: subCat.name,
            handle: subCat.handle,
            description: subCat.description,
            parent_category_id: parentId,
            is_active: true,
            is_internal: false
          },
          { headers }
        );
        console.log(`  ✅ Creada subcategoría: ${subCat.name}`);
      }
    }

    console.log('🎉 ¡Todas las categorías han sido creadas exitosamente!');
    console.log('🔄 Reinicia tu frontend para ver los cambios');

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

createCategories(); 