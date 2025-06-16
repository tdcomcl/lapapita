// Script manual para crear subcategorías - ingresa tu token aquí
const axios = require('axios');
const readline = require('readline');

const BACKEND_URL = 'http://localhost:9000';
const PUBLISHABLE_KEY = 'pk_5fff5295898482c5a71702783c5d8d3d7f3799d1b8863d6ac48517cd077a9250';

// Configurar readline para input del usuario
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

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

async function testEndpointsWithToken(token, tokenType = 'Bearer') {
  const endpoints = [
    '/admin/product-categories',
    '/api/admin/product-categories',
    '/app/api/admin/product-categories'
  ];

  const headers = tokenType === 'Bearer' 
    ? {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    : {
        'Cookie': token,
        'Content-Type': 'application/json'
      };

  console.log(`\n🔍 Probando con token tipo: ${tokenType}`);
  console.log(`🔑 Token: ${token.substring(0, 50)}...`);

  for (const endpoint of endpoints) {
    try {
      console.log(`\n📡 Probando GET en: ${endpoint}`);
      
      const response = await axios.get(`${BACKEND_URL}${endpoint}`, { headers });
      
      console.log(`✅ GET exitoso en: ${endpoint}`);
      console.log(`📊 Respuesta: ${response.status} - ${JSON.stringify(response.data).substring(0, 100)}...`);
      
      // Si GET funciona, probar POST
      try {
        console.log(`📡 Probando POST en: ${endpoint}`);
        
        const postResponse = await axios.post(`${BACKEND_URL}${endpoint}`, {
          name: "Test Category",
          handle: "test-category-temp",
          description: "Categoría de prueba temporal",
          is_active: true,
          is_internal: false
        }, { headers });

        console.log(`✅ POST exitoso en: ${endpoint}`);
        
        // Eliminar la categoría de prueba
        const categoryId = postResponse.data.product_category?.id || postResponse.data.id;
        if (categoryId) {
          try {
            await axios.delete(`${BACKEND_URL}${endpoint}/${categoryId}`, { headers });
            console.log(`🗑️ Categoría de prueba eliminada`);
          } catch (deleteError) {
            console.log(`⚠️ No se pudo eliminar la categoría de prueba: ${deleteError.message}`);
          }
        }
        
        return { success: true, endpoint, headers };
        
      } catch (postError) {
        console.log(`❌ POST falló en ${endpoint}: ${postError.response?.status} - ${postError.response?.data?.message || postError.message}`);
      }
      
    } catch (getError) {
      console.log(`❌ GET falló en ${endpoint}: ${getError.response?.status} - ${getError.response?.data?.message || getError.message}`);
    }
  }
  
  return { success: false };
}

async function createCategoriesWithToken(workingEndpoint, headers) {
  console.log(`\n🌱 Creando categorías usando: ${workingEndpoint}`);
  
  for (const categoryData of newCategories) {
    try {
      console.log(`\n📁 Creando categoría: ${categoryData.name}`);
      
      const response = await axios.post(`${BACKEND_URL}${workingEndpoint}`, {
        name: categoryData.name,
        handle: categoryData.handle,
        description: categoryData.description,
        is_active: true,
        is_internal: false
      }, { headers });

      console.log(`✅ Categoría creada: ${categoryData.name}`);
      
      // Crear subcategorías
      const parentId = response.data.product_category?.id || response.data.id;
      if (parentId) {
        console.log(`📂 Creando ${categoryData.subcategories.length} subcategorías...`);
        
        for (const subCat of categoryData.subcategories) {
          try {
            console.log(`  📄 Creando: ${subCat.name}`);
            
            await axios.post(`${BACKEND_URL}${workingEndpoint}`, {
              name: subCat.name,
              handle: subCat.handle,
              description: subCat.description,
              parent_category_id: parentId,
              is_active: true,
              is_internal: false
            }, { headers });

            console.log(`  ✅ Subcategoría creada: ${subCat.name}`);
          } catch (subError) {
            console.error(`  ❌ Error con subcategoría ${subCat.name}:`, subError.response?.data?.message || subError.message);
          }
        }
      } else {
        console.log(`⚠️ No se pudo obtener ID de la categoría padre`);
      }
      
    } catch (categoryError) {
      console.error(`❌ Error con categoría ${categoryData.name}:`, categoryError.response?.data?.message || categoryError.message);
    }
  }
}

function askForToken() {
  return new Promise((resolve) => {
    console.log('\n🔑 Opciones de autenticación:');
    console.log('1. Token Bearer (Authorization: Bearer [token])');
    console.log('2. Cookie de sesión (Cookie: [cookie])');
    console.log('3. Salir');
    
    rl.question('\n¿Qué tipo de token tienes? (1/2/3): ', (choice) => {
      if (choice === '3') {
        console.log('👋 ¡Hasta luego!');
        rl.close();
        process.exit(0);
      }
      
      const tokenType = choice === '1' ? 'Bearer' : 'Cookie';
      const prompt = choice === '1' 
        ? '\n🔑 Pega tu token Bearer (sin "Bearer "): '
        : '\n🍪 Pega tu cookie completa: ';
      
      rl.question(prompt, (token) => {
        resolve({ token: token.trim(), tokenType });
      });
    });
  });
}

async function main() {
  console.log('🚀 Script manual para crear subcategorías en Medusa v2');
  console.log('\n📋 Categorías que se crearán:');
  
  newCategories.forEach(cat => {
    console.log(`📁 ${cat.name}`);
    cat.subcategories.forEach(sub => {
      console.log(`  📄 ${sub.name}`);
    });
  });

  const { token, tokenType } = await askForToken();
  
  console.log('\n🧪 Probando endpoints...');
  const result = await testEndpointsWithToken(token, tokenType);
  
  if (!result.success) {
    console.log('\n❌ No se encontró un endpoint que funcione.');
    console.log('\n💡 Verifica:');
    console.log('1. Que el token sea correcto y esté completo');
    console.log('2. Que tengas permisos de admin');
    console.log('3. Que Medusa esté ejecutándose en localhost:9000');
    rl.close();
    return;
  }
  
  console.log(`\n🎯 ¡Endpoint encontrado! Usando: ${result.endpoint}`);
  
  rl.question('\n¿Continuar con la creación de categorías? (s/n): ', async (answer) => {
    if (answer.toLowerCase() === 's' || answer.toLowerCase() === 'si') {
      await createCategoriesWithToken(result.endpoint, result.headers);
      console.log('\n🎉 ¡Proceso completado!');
      console.log('🔄 Reinicia tu frontend para ver los cambios');
    } else {
      console.log('❌ Operación cancelada');
    }
    rl.close();
  });
}

main().catch(error => {
  console.error('❌ Error:', error.message);
  rl.close();
}); 