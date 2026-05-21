import * as React from "react"
import Autoplay from "embla-carousel-autoplay"
import Fade from "embla-carousel-fade"
import {
  Carousel,
  CarouselContent,
  CarouselItem,
} from "@/components/ui/carousel"

const images = [
  { src: "/fused-uk-pat-testing-slide-1.jpg", alt: "FUSED UK PAT testing slide 1" },
  { src: "/fused-uk-pat-testing-slide-2.jpg", alt: "FUSED UK PAT testing slide 2" },
  { src: "/fused-uk-pat-testing-slide-3.jpg", alt: "FUSED UK PAT testing slide 3" },
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
      className="overflow-hidden"
    >
      <CarouselContent className="ml-0">
        {images.map((img) => (
          <CarouselItem key={img.src} className="pl-0">
            <div className="relative aspect-[16/9] w-full overflow-hidden bg-neutral-900 sm:aspect-[21/9]">
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
