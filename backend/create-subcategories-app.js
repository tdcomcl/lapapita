// Script para crear subcategorías en Medusa v2 (/app)
const axios = require('axios');

const BACKEND_URL = 'http://localhost:9000';
const PUBLISHABLE_KEY = 'pk_5fff5295898482c5a71702783c5d8d3d7f3799d1b8863d6ac48517cd077a9250';

// Headers para Store API
const storeHeaders = {
  'x-publishable-api-key': PUBLISHABLE_KEY,
  'Content-Type': 'application/json'
};

// Headers para App API (usando cookies de sesión)
const appHeaders = {
  'Content-Type': 'application/json',
  'Cookie': 'next-auth.session-token=eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIn0..4NhAWnbCXoYWztLH.REw97l929amPjy4Lg1ayDCiDNYgGvBp7NJJ_TsBVB4RpnmnNGxh9sGNVa0DagIMF8yieVll4wMvv66f8abcgXPFRu_5pOpPb2qgH1DWsC_WMCFFquINLKsDopgKuNzt-7ABnXzw5TISRwKkyPIrjHgJ2ShNYTuyv8iVxWkgM-rgQJrkWFuKCu4lnyf7dI31VZy3-PsZoy21dHF2s2A.lnxhOG2b5vOM8p26w43GWg'
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

async function tryDifferentEndpoints(categoryData) {
  const endpoints = [
    '/app/api/admin/product-categories',
    '/admin/product-categories',
    '/api/admin/product-categories'
  ];

  for (const endpoint of endpoints) {
    try {
      console.log(`🔍 Probando endpoint: ${endpoint}`);
      
      const response = await axios.post(`${BACKEND_URL}${endpoint}`, {
        name: categoryData.name,
        handle: categoryData.handle,
        description: categoryData.description,
        is_active: true,
        is_internal: false
      }, { headers: appHeaders });

      console.log(`✅ Éxito con endpoint: ${endpoint}`);
      return { success: true, endpoint, data: response.data };
      
    } catch (error) {
      console.log(`❌ Falló ${endpoint}: ${error.response?.status} - ${error.response?.data?.message || error.message}`);
    }
  }
  
  return { success: false };
}

async function createCategoriesWithApp() {
  try {
    console.log('\n🌱 Intentando crear categorías...');
    
    // Probar con la primera categoría para encontrar el endpoint correcto
    const testCategory = newCategories[0];
    console.log(`🧪 Probando con categoría: ${testCategory.name}`);
    
    const result = await tryDifferentEndpoints(testCategory);
    
    if (!result.success) {
      console.log('\n❌ No se pudo encontrar un endpoint que funcione.');
      console.log('💡 Opciones:');
      console.log('1. Crear categorías manualmente en http://localhost:9000/app/categories');
      console.log('2. Obtener token Bearer del DevTools Network tab');
      console.log('3. Verificar permisos de usuario admin');
      return;
    }

    const workingEndpoint = result.endpoint;
    console.log(`\n🎯 Usando endpoint: ${workingEndpoint}`);
    
    // Crear el resto de categorías
    for (let i = 1; i < newCategories.length; i++) {
      const categoryData = newCategories[i];
      try {
        console.log(`📁 Creando: ${categoryData.name}`);
        
        const response = await axios.post(`${BACKEND_URL}${workingEndpoint}`, {
          name: categoryData.name,
          handle: categoryData.handle,
          description: categoryData.description,
          is_active: true,
          is_internal: false
        }, { headers: appHeaders });

        console.log(`✅ Creada: ${categoryData.name}`);
        
        // Crear subcategorías
        const parentId = response.data.product_category?.id || response.data.id;
        if (parentId) {
          for (const subCat of categoryData.subcategories) {
            try {
              console.log(`  📄 Creando subcategoría: ${subCat.name}`);
              
              await axios.post(`${BACKEND_URL}${workingEndpoint}`, {
                name: subCat.name,
                handle: subCat.handle,
                description: subCat.description,
                parent_category_id: parentId,
                is_active: true,
                is_internal: false
              }, { headers: appHeaders });

              console.log(`  ✅ Subcategoría creada: ${subCat.name}`);
            } catch (subError) {
              console.error(`  ❌ Error con subcategoría ${subCat.name}:`, subError.response?.data?.message || subError.message);
            }
          }
        }
        
      } catch (categoryError) {
        console.error(`❌ Error con categoría ${categoryData.name}:`, categoryError.response?.data?.message || categoryError.message);
      }
    }

    // También crear subcategorías para la primera categoría (que usamos para probar)
    if (result.data) {
      const parentId = result.data.product_category?.id || result.data.id;
      if (parentId) {
        console.log(`📁 Creando subcategorías para: ${testCategory.name}`);
        for (const subCat of testCategory.subcategories) {
          try {
            console.log(`  📄 Creando subcategoría: ${subCat.name}`);
            
            await axios.post(`${BACKEND_URL}${workingEndpoint}`, {
              name: subCat.name,
              handle: subCat.handle,
              description: subCat.description,
              parent_category_id: parentId,
              is_active: true,
              is_internal: false
            }, { headers: appHeaders });

            console.log(`  ✅ Subcategoría creada: ${subCat.name}`);
          } catch (subError) {
            console.error(`  ❌ Error con subcategoría ${subCat.name}:`, subError.response?.data?.message || subError.message);
          }
        }
      }
    }

    console.log('\n🎉 ¡Proceso completado!');
    console.log('🔄 Reinicia tu frontend para ver los cambios');
    
  } catch (error) {
    console.error('❌ Error general:', error.message);
  }
}

async function main() {
  console.log('🚀 Iniciando creación de subcategorías en Medusa v2...\n');
  
  // Mostrar categorías actuales
  await checkCurrentCategories();
  
  // Intentar crear nuevas categorías
  await createCategoriesWithApp();
}

main(); 