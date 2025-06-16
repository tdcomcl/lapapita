import { Suspense } from "react"

import { listRegions } from "@lib/data/regions"
import { listCategories } from "@lib/data/categories"
import { StoreRegion } from "@medusajs/types"
import LocalizedClientLink from "@modules/common/components/localized-client-link"
import CartButton from "@modules/layout/components/cart-button"
import SideMenu from "@modules/layout/components/side-menu"
import ModernMenu from "@modules/layout/components/modern-menu"
import SearchBar from "@modules/layout/components/search-bar"

export default async function Nav() {
  const regions = await listRegions().then((regions: StoreRegion[]) => regions)
  const categories = await listCategories({
    fields: "id, name, handle, description, parent_category, category_children",
  })

  return (
    <div className="sticky top-0 inset-x-0 z-50 group">
      <header className="relative mx-auto border-b duration-200 bg-white border-ui-border-base shadow-sm">
        {/* Main Navigation */}
        <nav className="content-container flex items-center justify-between w-full h-16 gap-2 lg:gap-4">
          {/* Logo */}
          <div className="flex items-center flex-shrink-0">
            <LocalizedClientLink
              href="/"
              className="flex items-center gap-2 hover:opacity-80 transition-opacity"
              data-testid="nav-store-link"
            >
              <div className="text-2xl">🥔</div>
              <span className="font-bold text-lg lg:text-xl text-orange-600 hidden sm:block">
                La Papita
              </span>
            </LocalizedClientLink>
          </div>

          {/* Desktop Menu - Visible desde laptop */}
          <div className="hidden lg:flex flex-shrink-0">
            <ModernMenu categories={categories} />
          </div>

          {/* Right Side */}
          <div className="flex items-center gap-2 lg:gap-4 flex-shrink-0">
            {/* Search Icon - Desktop */}
            <div className="hidden md:flex">
              <SearchBar countryCode="cl" compact={true} />
            </div>

            {/* Desktop Account Link - Solo icono */}
            <div className="hidden lg:flex items-center">
              <LocalizedClientLink
                className="hover:text-orange-600 transition-colors flex items-center justify-center p-2 rounded-lg hover:bg-orange-50"
                href="/account"
                data-testid="nav-account-link"
                title="Mi Cuenta"
              >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
                </svg>
              </LocalizedClientLink>
            </div>

            {/* Cart */}
            <Suspense
              fallback={
                <LocalizedClientLink
                  className="hover:text-orange-600 transition-colors flex items-center justify-center p-2 rounded-lg hover:bg-orange-50"
                  href="/cart"
                  data-testid="nav-cart-link"
                  title="Carrito"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 10.5V6a3.75 3.75 0 10-7.5 0v4.5m11.356-1.993l1.263 12c.07.665-.45 1.243-1.119 1.243H4.25a1.125 1.125 0 01-1.12-1.243l1.264-12A1.125 1.125 0 015.513 7.5h12.974c.576 0 1.059.435 1.119.993z" />
                  </svg>
                </LocalizedClientLink>
              }
            >
              <CartButton />
            </Suspense>

            {/* Mobile Menu */}
            <div className="lg:hidden">
              <SideMenu regions={regions} categories={categories} />
            </div>
          </div>
        </nav>
        
        {/* Mobile Search Bar - Modo completo */}
        <div className="md:hidden px-4 pb-3 border-t border-gray-100">
          <SearchBar countryCode="cl" compact={false} />
        </div>
      </header>
    </div>
  )
}
