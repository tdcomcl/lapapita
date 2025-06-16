import { HttpTypes } from "@medusajs/types"
import LocalizedClientLink from "@modules/common/components/localized-client-link"

interface CategoryBannersProps {
  categories: HttpTypes.StoreProductCategory[]
}

const CategoryBanners = ({ categories }: CategoryBannersProps) => {
  // Tomamos solo las categorías principales (sin padre)
  const mainCategories = categories.filter(category => !category.parent_category).slice(0, 4)

  return (
    <div className="py-8 bg-gray-50">
      <div className="content-container">
        <h2 className="text-2xl font-bold text-center mb-8 text-gray-800">
          Explora Nuestras Categorías
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {mainCategories.map((category) => (
            <LocalizedClientLink
              key={category.id}
              href={`/categories/${category.handle}`}
              className="group"
            >
              <div className="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300 overflow-hidden">
                <div className="h-32 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
                  <div className="text-white text-center">
                    <div className="text-3xl mb-2">
                      {getCategoryIcon(category.name)}
                    </div>
                    <h3 className="font-semibold text-lg">
                      {category.name}
                    </h3>
                  </div>
                </div>
                <div className="p-4">
                  <p className="text-gray-600 text-sm text-center">
                    {category.description || `Descubre productos de ${category.name.toLowerCase()}`}
                  </p>
                  <div className="mt-3 text-center">
                    <span className="text-orange-600 font-medium text-sm group-hover:underline">
                      Ver productos →
                    </span>
                  </div>
                </div>
              </div>
            </LocalizedClientLink>
          ))}
        </div>
      </div>
    </div>
  )
}

// Función para asignar iconos según el nombre de la categoría
const getCategoryIcon = (categoryName: string): string => {
  const name = categoryName.toLowerCase()
  
  if (name.includes('electrón') || name.includes('tech')) return '📱'
  if (name.includes('ropa') || name.includes('fashion')) return '👕'
  if (name.includes('hogar') || name.includes('casa')) return '🏠'
  if (name.includes('deportes') || name.includes('sport')) return '⚽'
  if (name.includes('libros') || name.includes('book')) return '📚'
  if (name.includes('salud') || name.includes('health')) return '💊'
  if (name.includes('belleza') || name.includes('beauty')) return '💄'
  if (name.includes('juguetes') || name.includes('toy')) return '🧸'
  if (name.includes('automóvil') || name.includes('auto')) return '🚗'
  if (name.includes('música') || name.includes('music')) return '🎵'
  
  return '🛒' // Icono por defecto
}

export default CategoryBanners 