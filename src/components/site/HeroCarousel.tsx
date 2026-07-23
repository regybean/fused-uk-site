import * as React from "react"
import Autoplay from "embla-carousel-autoplay"
import Fade from "embla-carousel-fade"
import {
  Carousel,
  CarouselContent,
  CarouselItem,
} from "@/components/ui/carousel"

const images = [
  { src: "/testing-pat-machine.jpg", alt: "FUSED UK PAT testing equipment in use on site" },
  { src: "/testing-office.jpg", alt: "FUSED UK engineer PAT testing in an office" },
  { src: "/testing-school.jpg", alt: "FUSED UK engineer PAT testing appliances in a school" },
  { src: "/microwave-leakage.jpg", alt: "FUSED UK microwave leakage testing" },
  { src: "/man-working.jpeg", alt: "FUSED UK engineer carrying out PAT testing" },
]

export function HeroCarousel() {
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
      className="h-full overflow-hidden"
    >
      <CarouselContent className="ml-0 h-full" viewportClassName="h-full">
        {images.map((img) => (
          <CarouselItem key={img.src} className="h-full pl-0">
            <div className="relative h-full w-full overflow-hidden bg-neutral-900">
              <img
                src={img.src}
                alt={img.alt}
                className="h-full w-full object-cover"
              />
            </div>
          </CarouselItem>
        ))}
      </CarouselContent>
    </Carousel>
  )
}
