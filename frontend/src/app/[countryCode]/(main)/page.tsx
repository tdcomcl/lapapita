import { Metadata } from "next"

import FeaturedProducts from "@modules/home/components/featured-products"
import Hero from "@modules/home/components/hero"
import CategoryBanners from "@modules/home/components/category-banners"
import { listCollections } from "@lib/data/collections"
import { listCategories } from "@lib/data/categories"
import { getRegion } from "@lib/data/regions"

export const metadata: Metadata = {
  title: "La Papita - Tu tienda online favorita",
  description:
    "El rincón más papudo de internet donde la calidad no se negocia... ¡pero los precios sí!",
}

export default async function Home(props: {
  params: Promise<{ countryCode: string }>
}) {
  const params = await props.params

  const { countryCode } = params

  const region = await getRegion(countryCode)

  const { collections } = await listCollections({
    fields: "id, handle, title",
  })

  const categories = await listCategories({
    fields: "id, name, handle, description, parent_category",
  })

  if (!collections || !region) {
    return null
  }

  return (
    <>
      <Hero />
      {categories && categories.length > 0 && (
        <CategoryBanners categories={categories} />
      )}
      <div className="py-12">
        <ul className="flex flex-col gap-x-6">
          <FeaturedProducts collections={collections} region={region} />
        </ul>
      </div>
    </>
  )
}
