import axios from 'axios'
import dotenv from 'dotenv'

// Cargar variables de entorno
dotenv.config()

const BACKEND_URL = process.env.MEDUSA_BACKEND_URL || 'http://localhost:9000'
const ADMIN_EMAIL = process.env.ADMIN_EMAIL || 'admin@medusa-test.com'
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'supersecret'

interface CategoryData {
  name: string
  handle: string
  description: string
  subcategories: {
    name: string
    handle: string
    description: string
  }[]
}

const categoriesData: CategoryData[] = [
  {
    name: "Electrónicos",
    handle: "electronicos",
    description: "Productos electrónicos y tecnología",
    subcategories: [
      { name: "Smartphones", handle: "smartphones", description: "Teléfonos inteligentes" },
      { name: "Laptops", handle: "laptops", description: "Computadoras portátiles" },
      { name: "Audífonos", handle: "audifonos", description: "Audífonos y auriculares" },
      { name: "Tablets", handle: "tablets", description: "Tabletas y iPads" }
    ]
  },
  {
    name: "Ropa",
    handle: "ropa",
    description: "Vestimenta y accesorios",
    subcategories: [
      { name: "Camisetas", handle: "camisetas", description: "Camisetas y polos" },
      { name: "Pantalones", handle: "pantalones", description: "Pantalones y jeans" },
      { name: "Zapatos", handle: "zapatos", description: "Calzado deportivo y casual" },
      { name: "Accesorios", handle: "accesorios", description: "Cinturones, gorros, etc." }
    ]
  },
  {
    name: "Hogar",
    handle: "hogar",
    description: "Productos para el hogar",
    subcategories: [
      { name: "Muebles", handle: "muebles", description: "Muebles y decoración" },
      { name: "Cocina", handle: "cocina", description: "Utensilios de cocina" },
      { name: "Dormitorio", handle: "dormitorio", description: "Productos para el dormitorio" },
      { name: "Baño", handle: "bano", description: "Productos para el baño" }
    ]
  },
  {
    name: "Deportes",
    handle: "deportes",
    description: "Artículos deportivos y fitness",
    subcategories: [
      { name: "Fitness", handle: "fitness", description: "Equipos de ejercicio" },
      { name: "Fútbol", handle: "futbol", description: "Artículos de fútbol" },
      { name: "Running", handle: "running", description: "Productos para correr" },
      { name: "Natación", handle: "natacion", description: "Productos para natación" }
    ]
  }
]

async function seedCategories() {
  try {
    console.log("🔐 Autenticando admin...")
    
    // Autenticar como admin
    const authResponse = await axios.post(`${BACKEND_URL}/admin/auth`, {
      email: ADMIN_EMAIL,
      password: ADMIN_PASSWORD
    })
    
    const token = authResponse.data.user.api_token
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }

    console.log("✅ Autenticación exitosa")
    console.log("🌱 Creando categorías...")

    for (const categoryData of categoriesData) {
      try {
        // Verificar si la categoría ya existe
        const existingResponse = await axios.get(
          `${BACKEND_URL}/admin/product-categories?handle=${categoryData.handle}`,
          { headers }
        )

        let parentCategory
        
        if (existingResponse.data.product_categories.length === 0) {
          // Crear categoría principal
          console.log(`📁 Creando categoría: ${categoryData.name}`)
          const parentResponse = await axios.post(
            `${BACKEND_URL}/admin/product-categories`,
            {
              name: categoryData.name,
              handle: categoryData.handle,
              description: categoryData.description,
              is_active: true,
              is_internal: false
            },
            { headers }
          )
          parentCategory = parentResponse.data.product_category
          console.log(`✅ Categoría creada: ${categoryData.name}`)
        } else {
          parentCategory = existingResponse.data.product_categories[0]
          console.log(`📁 Categoría existente: ${categoryData.name}`)
        }

        // Crear subcategorías
        for (const subCat of categoryData.subcategories) {
          try {
            // Verificar si la subcategoría ya existe
            const existingSubResponse = await axios.get(
              `${BACKEND_URL}/admin/product-categories?handle=${subCat.handle}`,
              { headers }
            )

            if (existingSubResponse.data.product_categories.length === 0) {
              console.log(`  📄 Creando subcategoría: ${subCat.name}`)
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
                { headers }
              )
              console.log(`  ✅ Subcategoría creada: ${subCat.name}`)
            } else {
              console.log(`  📄 Subcategoría existente: ${subCat.name}`)
            }
          } catch (subError) {
            console.error(`  ❌ Error creando subcategoría ${subCat.name}:`, subError.response?.data || subError.message)
          }
        }
      } catch (categoryError) {
        console.error(`❌ Error procesando categoría ${categoryData.name}:`, categoryError.response?.data || categoryError.message)
      }
    }

    console.log("🎉 ¡Seed de categorías completado!")
    console.log("🔄 Reinicia tu frontend para ver los cambios")
    
  } catch (error) {
    console.error("❌ Error en seed:", error.response?.data || error.message)
    process.exit(1)
  }
}

// Ejecutar seed
seedCategories() 