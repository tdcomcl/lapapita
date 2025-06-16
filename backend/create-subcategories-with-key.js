// Script para crear subcategorías usando publishable key
const axios = require('axios');

const BACKEND_URL = 'http://localhost:9000';
const PUBLISHABLE_KEY = 'pk_5fff5295898482c5a71702783c5d8d3d7f3799d1b8863d6ac48517cd077a9250';

// Headers para Store API (solo lectura)
const storeHeaders = {
  'x-publishable-api-key': PUBLISHABLE_KEY,
  'Content-Type': 'application/json'
};

// Para Admin API necesitamos token de sesión
let adminToken = 'YOUR_ADMIN_TOKEN_HERE'; // Reemplazar con token del navegador

const adminHeaders = {
  'Authorization': `Bearer ${adminToken}`,
  'Content-Type': 'application/json'
};

const newCategories = [
  {
    name: "Electrónicos",
    handle: "electronicos", 
    description: "Productos electrónicos y tecnología",
    subcategories: [
      { name: "Smartphones", handle: "smartphones", description: "Teléfonos inteligentes" },
      { name: "Laptops", handle: "laptops", description: "Computadoras portátiles" },
      { name: "Audífonos", handle: "audifonos", description: "Audífonos y auriculares" }
    ]
  },
  {
    name: "Ropa",
    handle: "ropa",
    description: "Vestimenta y accesorios", 
    subcategories: [
      { name: "Camisetas", handle: "camisetas", description: "Camisetas y polos" },
      { name: "Jeans", handle: "jeans", description: "Pantalones de mezclilla" },
      { name: "Zapatos", handle: "zapatos", description: "Calzado deportivo y casual" }
    ]
  }
];

async function checkCurrentCategories() {
  try {
    console.log('📋 Categorías actuales:');
    const response = await axios.get(`${BACKEND_URL}/store/product-categories`, {
      headers: storeHeaders
    });
    
    response.data.product_categories.forEach(cat => {
      console.log(`📁 ${cat.name} (${cat.handle})`);
      if (cat.category_children && cat.category_children.length > 0) {
        cat.category_children.forEach(child => {
          console.log(`  📄 ${child.name} (${child.handle})`);
        });
      }
    });
    
    return response.data.product_categories;
  } catch (error) {
    console.error('❌ Error obteniendo categorías:', error.message);
    return [];
  }
}

async function createCategoriesWithAdmin() {
  if (adminToken === 'YOUR_ADMIN_TOKEN_HERE') {
    console.log('\n❌ Necesitas configurar el token de admin:');
    console.log('1. Ve a http://localhost:9000/app e inicia sesión');
    console.log('2. Abre DevTools (F12) → Network');
    console.log('3. Ve a Categories y busca petición a /admin/');
    console.log('4. Copia el header "Authorization: Bearer TOKEN"');
    console.log('5. Reemplaza YOUR_ADMIN_TOKEN_HERE en este archivo');
    console.log('6. Ejecuta: node create-subcategories-with-key.js');
    return;
  }

  try {
    console.log('\n🌱 Creando nuevas categorías...');
    
    for (const categoryData of newCategories) {
      try {
        // Verificar si ya existe
        const existing = await axios.get(
          `${BACKEND_URL}/admin/product-categories?handle=${categoryData.handle}`,
          { headers: adminHeaders }
        );

        let parentCategory;
        
        if (existing.data.product_categories.length === 0) {
          // Crear categoría principal
          console.log(`📁 Creando: ${categoryData.name}`);
          const parentResponse = await axios.post(
            `${BACKEND_URL}/admin/product-categories`,
            {
              name: categoryData.name,
              handle: categoryData.handle,
              description: categoryData.description,
              is_active: true,
              is_internal: false
            },
            { headers: adminHeaders }
          );
          parentCategory = parentResponse.data.product_category;
          console.log(`✅ Creada: ${categoryData.name}`);
        } else {
          parentCategory = existing.data.product_categories[0];
          console.log(`📁 Ya existe: ${categoryData.name}`);
        }

        // Crear subcategorías
        for (const subCat of categoryData.subcategories) {
          try {
            const existingSub = await axios.get(
              `${BACKEND_URL}/admin/product-categories?handle=${subCat.handle}`,
              { headers: adminHeaders }
            );

            if (existingSub.data.product_categories.length === 0) {
              console.log(`  📄 Creando subcategoría: ${subCat.name}`);
              await axios.post(
                `${BACKEND_URL}/admin/product-categories`,
                {
                  name: subCat.name,
                  handle: subCat.handle,
                  description: subCat.description,
                  parent_category_id: parentCategory.id,
                  is_active: true,
                  is_internal: false
                },
                { headers: adminHeaders }
              );
              console.log(`  ✅ Subcategoría creada: ${subCat.name}`);
            } else {
              console.log(`  📄 Subcategoría existente: ${subCat.name}`);
            }
          } catch (subError) {
            console.error(`  ❌ Error con subcategoría ${subCat.name}:`, subError.response?.data?.message || subError.message);
          }
        }
      } catch (categoryError) {
        console.error(`❌ Error con categoría ${categoryData.name}:`, categoryError.response?.data?.message || categoryError.message);
      }
    }

    console.log('\n🎉 ¡Proceso completado!');
    console.log('🔄 Reinicia tu frontend para ver los cambios');
    
  } catch (error) {
    console.error('❌ Error general:', error.response?.data?.message || error.message);
  }
}

async function main() {
  console.log('🚀 Iniciando gestión de categorías...\n');
  
  // Mostrar categorías actuales
  await checkCurrentCategories();
  
  // Crear nuevas categorías (si hay token admin)
  await createCategoriesWithAdmin();
}

main(); 