import { Github } from "@medusajs/icons"
import { Button, Heading } from "@medusajs/ui"

// Componente SVG personalizado para WhatsApp
const WhatsApp = ({ ...props }) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width="20"
    height="20"
    viewBox="0 0 24 24"
    fill="currentColor"
    {...props}
  >
    <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.570-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.890-5.335 11.893-11.893A11.821 11.821 0 0020.525 3.488"/>
  </svg>
)

const Hero = () => {
  return (
    <div 
      className="h-[75vh] w-full border-b border-ui-border-base relative bg-ui-bg-subtle bg-cover bg-center bg-no-repeat"
      style={{
        backgroundImage: 'url(/papitas.jpg)'
      }}
    >
      {/* Overlay oscuro para mejorar legibilidad del texto */}
      <div className="absolute inset-0 bg-black bg-opacity-50"></div>
      <div className="absolute inset-0 z-10 flex flex-col justify-center items-center text-center small:p-32 gap-6">
        <div className="max-w-4xl mx-auto">
          <Heading
            level="h1"
            className="text-4xl leading-12 text-white font-bold mb-4 drop-shadow-lg"
          >
            ¡Bienvenido a La Papita! 🥔
          </Heading>
          <Heading
            level="h2"
            className="text-xl leading-8 text-gray-100 font-normal mb-6 drop-shadow-md"
          >
            El rincón más papudo de internet donde la calidad no se negocia... ¡pero los precios sí!
          </Heading>
          <div className="text-lg leading-7 text-white max-w-3xl mx-auto drop-shadow-md">
            <p className="mb-4">
              Somos como esa papita perfecta: crujiente por fuera, suave por dentro y que nunca te deja con hambre de más.
            </p>
            <p className="mb-4">
              Aquí no vendemos humo ni cuentos chinos, solo productos de calidad a precios que no te van a dejar pelado.
            </p>
            <p className="text-yellow-300 font-semibold">
              📦 ¡Todos nuestros productos se envían desde Chile! 🇨🇱
            </p>
          </div>
        </div>
        <div className="flex gap-4">
          <a
            href="https://wa.me/56939573480"
            target="_blank"
            rel="noreferrer"
          >
            <Button variant="secondary" className="bg-green-600 hover:bg-green-700 text-white border-green-600">
              ¿Preguntas? ¡Mándale un wasap al papita Nico!
              El jefe de las ofertas y rey de la buena onda
              <WhatsApp />
            </Button>
          </a>
          <a
            href="https://wa.me/56939573480"
            target="_blank"
            rel="noreferrer"
          >
            <Button variant="secondary" className="bg-green-600 hover:bg-green-700 text-white border-green-600">
            "¡Dale, escríbele al papita Cristian! 💬
            Te responde más rápido que freír papas"
              <WhatsApp />
            </Button>
          </a>
        </div>
      </div>
    </div>
  )
}

export default Hero
