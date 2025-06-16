"use client"

import { Popover, PopoverPanel, Transition } from "@headlessui/react"
import { XMark } from "@medusajs/icons"
import { Text } from "@medusajs/ui"
import { Fragment } from "react"

import LocalizedClientLink from "@modules/common/components/localized-client-link"
import SearchBar from "@modules/layout/components/search-bar"
import { HttpTypes } from "@medusajs/types"

const SideMenuItems = [
  { name: "Inicio", href: "/" },
  { name: "Tienda", href: "/store" },
  { name: "Mi Cuenta", href: "/account" },
  { name: "Carrito", href: "/cart" },
]

interface SideMenuProps {
  regions: HttpTypes.StoreRegion[] | null
  categories?: HttpTypes.StoreProductCategory[]
}

const SideMenu = ({ regions, categories }: SideMenuProps) => {
  const mainCategories = categories?.filter(category => !category.parent_category)?.slice(0, 6) || []

  return (
    <div className="h-full">
      <div className="flex items-center h-full">
        <Popover className="h-full flex">
          {({ open, close }) => (
            <>
              <div className="relative flex h-full">
                <Popover.Button
                  data-testid="nav-menu-button"
                  className="relative h-full flex items-center transition-all ease-out duration-200 focus:outline-none hover:text-orange-600 p-2"
                >
                  {/* Hamburger Icon */}
                  <div className="flex flex-col w-6 h-6 justify-center space-y-1">
                    <div className={`h-0.5 bg-current transition-all duration-300 ${open ? 'rotate-45 translate-y-1.5 w-6' : 'w-6'}`}></div>
                    <div className={`h-0.5 bg-current transition-all duration-300 ${open ? 'opacity-0' : 'w-5'}`}></div>
                    <div className={`h-0.5 bg-current transition-all duration-300 ${open ? '-rotate-45 -translate-y-1.5 w-6' : 'w-4'}`}></div>
                  </div>
                </Popover.Button>
              </div>

              <Transition
                show={open}
                as={Fragment}
                enter="transition ease-out duration-300"
                enterFrom="opacity-0 scale-95"
                enterTo="opacity-100 scale-100"
                leave="transition ease-in duration-200"
                leaveFrom="opacity-100 scale-100"
                leaveTo="opacity-0 scale-95"
              >
                <PopoverPanel className="fixed inset-0 z-50 lg:hidden">
                  <div className="fixed inset-0 bg-black bg-opacity-50" onClick={close}></div>
                  <div className="fixed right-0 top-0 h-full w-full max-w-sm bg-white shadow-xl">
                    <div className="flex flex-col h-full">
                      {/* Header */}
                      <div className="p-4 border-b border-gray-200">
                        {/* Logo y botón cerrar */}
                        <div className="flex items-center justify-between mb-4">
                          <div className="flex items-center gap-2">
                            <div className="text-2xl">🥔</div>
                            <span className="font-bold text-xl text-orange-600">La Papita</span>
                          </div>
                          <button 
                            onClick={close}
                            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                            data-testid="close-menu-button"
                          >
                            <XMark className="w-6 h-6" />
                          </button>
                        </div>
                        
                        {/* Search Bar móvil */}
                        <div className="w-full">
                          <SearchBar countryCode="cl" />
                        </div>
                      </div>

                      {/* Menu Content */}
                      <div className="flex-1 overflow-y-auto">
                        {/* Main Navigation */}
                        <div className="p-4">
                          <h3 className="font-semibold text-gray-800 mb-3">Navegación</h3>
                          <ul className="space-y-2">
                            {SideMenuItems.map((item) => (
                              <li key={item.name}>
                                <LocalizedClientLink
                                  href={item.href}
                                  className="flex items-center px-3 py-2 text-gray-700 hover:text-orange-600 hover:bg-orange-50 rounded-lg transition-colors"
                                  onClick={close}
                                  data-testid={`${item.name.toLowerCase().replace(/\s+/g, '-')}-link`}
                                >
                                  {item.name}
                                </LocalizedClientLink>
                              </li>
                            ))}
                          </ul>
                        </div>

                        {/* Categories */}
                        {mainCategories.length > 0 && (
                          <div className="p-4 border-t border-gray-200">
                            <h3 className="font-semibold text-gray-800 mb-3">Categorías</h3>
                            <ul className="space-y-2">
                              {mainCategories.map((category) => (
                                <li key={category.id}>
                                  <LocalizedClientLink
                                    href={`/categories/${category.handle}`}
                                    className="flex items-center px-3 py-2 text-gray-700 hover:text-orange-600 hover:bg-orange-50 rounded-lg transition-colors"
                                    onClick={close}
                                  >
                                    {category.name}
                                  </LocalizedClientLink>
                                </li>
                              ))}
                            </ul>
                          </div>
                        )}
                      </div>

                      {/* Footer */}
                      <div className="p-4 border-t border-gray-200">
                        <Text className="text-xs text-gray-500 text-center">
                          © {new Date().getFullYear()} La Papita. Todos los derechos reservados.
                        </Text>
                      </div>
                    </div>
                  </div>
                </PopoverPanel>
              </Transition>
            </>
          )}
        </Popover>
      </div>
    </div>
  )
}

export default SideMenu
