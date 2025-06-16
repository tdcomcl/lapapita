"use client"

import { useState } from "react"
import { HttpTypes } from "@medusajs/types"
import LocalizedClientLink from "@modules/common/components/localized-client-link"

interface ModernMenuProps {
  categories: HttpTypes.StoreProductCategory[]
}

interface MenuItem {
  name: string
  href: string
  children?: HttpTypes.StoreProductCategory[]
}

const ModernMenu = ({ categories }: ModernMenuProps) => {
  const [hoveredCategory, setHoveredCategory] = useState<string | null>(null)

  // Filtrar solo categorías principales
  const mainCategories = categories?.filter(category => !category.parent_category)?.slice(0, 6) || []

  const menuItems: MenuItem[] = [
    { name: "Inicio", href: "/" },
    { name: "Tienda", href: "/store" },
    ...mainCategories.map(category => ({
      name: category.name,
      href: `/categories/${category.handle}`,
      children: category.category_children || []
    }))
  ]

  return (
    <div className="flex items-center space-x-8">
      {menuItems.map((item, index) => (
        <div 
          key={index}
          className="relative group"
          onMouseEnter={() => setHoveredCategory(item.name)}
          onMouseLeave={() => setHoveredCategory(null)}
        >
          <LocalizedClientLink
            href={item.href}
            className="flex items-center space-x-1 px-3 py-2 text-gray-700 hover:text-orange-600 transition-colors font-medium"
          >
            <span>{item.name}</span>
            {item.children && item.children.length > 0 && (
              <svg 
                className={`w-4 h-4 transition-transform ${hoveredCategory === item.name ? 'rotate-180' : ''}`} 
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
              </svg>
            )}
          </LocalizedClientLink>

          {/* Dropdown */}
          {item.children && item.children.length > 0 && (
            <div className={`absolute top-full left-0 mt-1 w-64 bg-white rounded-lg shadow-lg border border-gray-100 z-50 transition-all duration-200 ${
              hoveredCategory === item.name ? 'opacity-100 visible translate-y-0' : 'opacity-0 invisible -translate-y-2'
            }`}>
              <div className="py-3">
                <div className="px-4 py-2 border-b border-gray-100">
                  <p className="font-semibold text-gray-800 text-sm">{item.name}</p>
                </div>
                <div className="py-2">
                  {item.children.slice(0, 8).map((child: HttpTypes.StoreProductCategory) => (
                    <LocalizedClientLink
                      key={child.id}
                      href={`/categories/${child.handle}`}
                      className="block px-4 py-2 text-sm text-gray-600 hover:text-orange-600 hover:bg-orange-50 transition-colors"
                    >
                      {child.name}
                    </LocalizedClientLink>
                  ))}
                  {item.children.length > 8 && (
                    <LocalizedClientLink
                      href={item.href}
                      className="block px-4 py-2 text-sm text-orange-600 font-medium hover:bg-orange-50 transition-colors border-t border-gray-100 mt-2 pt-3"
                    >
                      Ver todas en {item.name} →
                    </LocalizedClientLink>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>
      ))}
    </div>
  )
}

export default ModernMenu 