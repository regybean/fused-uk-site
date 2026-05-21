import * as React from "react"
import Autoplay from "embla-carousel-autoplay"
import Fade from "embla-carousel-fade"
import {
  Carousel,
  CarouselContent,
  CarouselItem,
} from "@/components/ui/carousel"

const images = [
  { src: "/man-working.jpeg", alt: "FUSED UK engineer carrying out PAT testing on site" },
  { src: "/vans.jpeg", alt: "Branded FUSED UK service van" },
  { src: "/fuseduk-sign.jpeg", alt: "FUSED UK signage" },
  { src: "/3-person-team.jpg", alt: "The FUSED UK engineering team" },
]

export function PhotoCarousel() {
  const reduced = React.useMemo(
    () =>
      typeof window !== "undefined" &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches,
    []
  )

  const plugins = React.useMemo(() => {
    const list: any[] = []
    if (!reduced) {
      list.push(Autoplay({ delay: 5000, stopOnInteraction: false }))
      list.push(Fade())
    }
    return list
  }, [reduced])

  return (
    <Carousel
      opts={{ loop: true }}
      plugins={plugins}
      className="overflow-hidden"
    >
      <CarouselContent className="ml-0">
        {images.map((img) => (
          <CarouselItem key={img.src} className="pl-0">
            <div className="relative aspect-[16/9] w-full overflow-hidden bg-neutral-900 sm:aspect-[21/9]">
              <img
                src={img.src}
                alt={img.alt}
                loading="lazy"
                className="h-full w-full object-cover"
              />
            </div>
          </CarouselItem>
        ))}
      </CarouselContent>
    </Carousel>
  )
}
