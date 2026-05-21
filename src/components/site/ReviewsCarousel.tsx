import * as React from "react"
import Autoplay from "embla-carousel-autoplay"
import { QuoteIcon, StarIcon } from "lucide-react"
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@/components/ui/carousel"
import { Card, CardContent } from "@/components/ui/card"
import reviews from "@/data/reviews.json"

export function ReviewsCarousel() {
  const reduced = React.useMemo(
    () =>
      typeof window !== "undefined" &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches,
    []
  )

  const plugins = React.useMemo(() => {
    if (reduced) return []
    return [Autoplay({ delay: 6000, stopOnInteraction: false })]
  }, [reduced])

  return (
    <div className="relative px-2 sm:px-12">
      <Carousel opts={{ loop: true, align: "start" }} plugins={plugins}>
        <CarouselContent>
          {reviews.map((r, i) => (
            <CarouselItem
              key={i}
              className="basis-full md:basis-1/2 lg:basis-1/3"
            >
              <Card className="h-full">
                <CardContent className="flex h-full flex-col gap-4 p-6">
                  <div className="flex items-center justify-between">
                    <div className="text-accent-foreground flex gap-0.5">
                      {Array.from({ length: 5 }).map((_, i) => (
                        <StarIcon
                          key={i}
                          className="size-4 fill-current text-yellow-500"
                        />
                      ))}
                    </div>
                    <QuoteIcon className="text-primary/30 size-6" />
                  </div>
                  <p className="text-sm leading-relaxed text-foreground">
                    “{r.quote}”
                  </p>
                  <div className="mt-auto border-t pt-3">
                    <div className="text-sm font-medium">{r.name}</div>
                    {r.location ? (
                      <div className="text-muted-foreground text-xs">
                        {r.location}
                      </div>
                    ) : null}
                  </div>
                </CardContent>
              </Card>
            </CarouselItem>
          ))}
        </CarouselContent>
        <CarouselPrevious className="hidden sm:flex" />
        <CarouselNext className="hidden sm:flex" />
      </Carousel>
    </div>
  )
}
