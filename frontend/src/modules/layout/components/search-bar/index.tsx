"use client"

import { useState, useEffect, useRef } from "react"
import { useRouter } from "next/navigation"
import { HttpTypes } from "@medusajs/types"
import LocalizedClientLink from "@modules/common/components/localized-client-link"
import { listProducts } from "@lib/data/products"

interface SearchBarProps {
  countryCode: string
  compact?: boolean // Para mostrar solo el icono
}

const SearchBar = ({ countryCode, compact = false }: SearchBarProps) => {
  const [query, setQuery] = useState("")
  const [results, setResults] = useState<HttpTypes.StoreProduct[]>([])
  const [isOpen, setIsOpen] = useState(false)
  const [isExpanded, setIsExpanded] = useState(!compact) // Para el modo compacto
  const [isLoading, setIsLoading] = useState(false)
  const router = useRouter()
  const searchRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)

  // Cerrar dropdown cuando se hace clic fuera
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setIsOpen(false)
        if (compact && !query) {
          setIsExpanded(false)
        }
      }
    }

    document.addEventListener("mousedown", handleClickOutside)
    return () => document.removeEventListener("mousedown", handleClickOutside)
  }, [compact, query])

  // Enfocar input cuando se expande
  useEffect(() => {
    if (isExpanded && inputRef.current) {
      inputRef.current.focus()
    }
  }, [isExpanded])

  // Buscar productos
  const searchProducts = async (searchQuery: string) => {
    if (searchQuery.length < 2) {
      setResults([])
      setIsOpen(false)
      return
    }

    setIsLoading(true)
    try {
      const { response } = await listProducts({
        queryParams: {
          q: searchQuery,
          limit: 6,
        },
        countryCode,
      })
      setResults(response.products)
      setIsOpen(true)
    } catch (error) {
      console.error("Error searching products:", error)
      setResults([])
    } finally {
      setIsLoading(false)
    }
  }

  // Debounce search
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      searchProducts(query)
    }, 300)

    return () => clearTimeout(timeoutId)
  }, [query])

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (query.trim()) {
      router.push(`/store?q=${encodeURIComponent(query.trim())}`)
      setIsOpen(false)
      setQuery("")
      if (compact) {
        setIsExpanded(false)
      }
    }
  }

  const handleSearchClick = () => {
    if (compact && !isExpanded) {
      setIsExpanded(true)
    }
  }

  const handleClose = () => {
    setQuery("")
    setIsOpen(false)
    if (compact) {
      setIsExpanded(false)
    }
  }

  const formatPrice = (product: HttpTypes.StoreProduct) => {
    const variant = product.variants?.[0]
    if (!variant?.calculated_price?.calculated_amount) return ""
    
    const amount = variant.calculated_price.calculated_amount
    const currency = variant.calculated_price.currency_code
    
    return new Intl.NumberFormat('es-CL', {
      style: 'currency',
      currency: currency || 'CLP',
    }).format(amount / 100)
  }

  // Modo compacto - solo icono
  if (compact && !isExpanded) {
    return (
      <div className="relative">
        <button
          onClick={handleSearchClick}
          className="hover:text-orange-600 transition-colors flex items-center justify-center p-2 rounded-lg hover:bg-orange-50"
          title="Buscar productos"
        >
          <svg 
            xmlns="http://www.w3.org/2000/svg" 
            fill="none" 
            viewBox="0 0 24 24" 
            strokeWidth={1.5} 
            stroke="currentColor" 
            className="w-5 h-5"
          >
            <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
          </svg>
        </button>
      </div>
    )
  }

  return (
    <div ref={searchRef} className={`relative ${compact ? 'w-auto' : 'w-full'}`}>
      {/* Overlay para modo compacto */}
      {compact && isExpanded && (
        <div className="fixed inset-0 bg-black bg-opacity-25 z-40" onClick={handleClose}></div>
      )}
      
      <form onSubmit={handleSubmit} className="relative z-50">
        <div className={`relative ${compact ? 'w-80' : 'w-full'}`}>
          <input
            ref={inputRef}
            type="text"
            placeholder="Buscar productos..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="w-full pl-10 pr-10 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors bg-white shadow-lg"
          />
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            {isLoading ? (
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-orange-500"></div>
            ) : (
              <svg 
                xmlns="http://www.w3.org/2000/svg" 
                fill="none" 
                viewBox="0 0 24 24" 
                strokeWidth={1.5} 
                stroke="currentColor" 
                className="w-4 h-4 text-gray-400"
              >
                <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
              </svg>
            )}
          </div>
          {/* Botón cerrar para modo compacto */}
          {compact && (
            <button
              type="button"
              onClick={handleClose}
              className="absolute inset-y-0 right-0 pr-3 flex items-center hover:text-gray-600"
            >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-4 h-4 text-gray-400">
                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          )}
        </div>
      </form>

      {/* Dropdown de resultados */}
      {isOpen && (
        <div className={`absolute top-full left-0 mt-1 bg-white rounded-lg shadow-lg border border-gray-200 z-50 max-h-96 overflow-y-auto ${compact ? 'w-80' : 'right-0'}`}>
          {results.length > 0 ? (
            <>
              <div className="p-3 border-b border-gray-100">
                <p className="text-sm text-gray-600">
                  {results.length} resultado{results.length > 1 ? 's' : ''} para "{query}"
                </p>
              </div>
              <div className="py-2">
                {results.map((product) => (
                  <LocalizedClientLink
                    key={product.id}
                    href={`/products/${product.handle}`}
                    className="flex items-center px-4 py-3 hover:bg-gray-50 transition-colors"
                    onClick={() => {
                      setIsOpen(false)
                      setQuery("")
                      if (compact) {
                        setIsExpanded(false)
                      }
                    }}
                  >
                    {product.thumbnail && (
                      <img
                        src={product.thumbnail}
                        alt={product.title}
                        className="w-10 h-10 rounded object-cover mr-3 flex-shrink-0"
                      />
                    )}
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        {product.title}
                      </p>
                      <p className="text-sm text-orange-600 font-semibold">
                        {formatPrice(product)}
                      </p>
                    </div>
                  </LocalizedClientLink>
                ))}
              </div>
              <div className="p-3 border-t border-gray-100">
                <button
                  onClick={handleSubmit}
                  className="w-full text-center text-sm text-orange-600 hover:text-orange-700 font-medium"
                >
                  Ver todos los resultados →
                </button>
              </div>
            </>
          ) : query.length >= 2 ? (
            <div className="p-4 text-center text-gray-500">
              <p className="text-sm">No se encontraron productos para "{query}"</p>
              <button
                onClick={handleSubmit}
                className="mt-2 text-sm text-orange-600 hover:text-orange-700"
              >
                Buscar en toda la tienda →
              </button>
            </div>
          ) : null}
        </div>
      )}
    </div>
  )
}

export default SearchBar 