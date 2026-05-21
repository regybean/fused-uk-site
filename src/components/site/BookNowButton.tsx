import * as React from "react"
import { PhoneIcon, MailIcon, ArrowRightIcon } from "lucide-react"
import { Button, type buttonVariants } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import type { VariantProps } from "class-variance-authority"
import { PHONE, TEL, EMAIL, MAILTO } from "@/lib/contact"

type BookNowProps = {
  variant?: VariantProps<typeof buttonVariants>["variant"]
  size?: VariantProps<typeof buttonVariants>["size"]
  className?: string
  label?: string
}

export function BookNowButton({
  variant = "default",
  size = "default",
  className,
  label = "Book Now",
}: BookNowProps) {
  const [isMobile, setIsMobile] = React.useState(false)

  React.useEffect(() => {
    const mq = window.matchMedia("(max-width: 767px)")
    const update = () => setIsMobile(mq.matches)
    update()
    mq.addEventListener("change", update)
    return () => mq.removeEventListener("change", update)
  }, [])

  if (isMobile) {
    return (
      <Button asChild variant={variant} size={size} className={className}>
        <a href={TEL}>{label}</a>
      </Button>
    )
  }

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant={variant} size={size} className={className}>
          {label}
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Book your PAT test</DialogTitle>
          <DialogDescription>
            We aim to beat any genuine quote — call or email and we&apos;ll come back to you fast.
          </DialogDescription>
        </DialogHeader>
        <div className="mt-2 flex flex-col gap-3">
          <a
            href={TEL}
            className="hover:bg-muted flex items-center gap-3 border p-4 transition-colors"
          >
            <PhoneIcon className="text-primary size-5" />
            <div>
              <div className="text-muted-foreground text-xs">Call us</div>
              <div className="font-medium">{PHONE}</div>
            </div>
          </a>
          <a
            href={MAILTO}
            className="hover:bg-muted flex items-center gap-3 border p-4 transition-colors"
          >
            <MailIcon className="text-primary size-5" />
            <div>
              <div className="text-muted-foreground text-xs">Email us</div>
              <div className="font-medium">{EMAIL}</div>
            </div>
          </a>
          <a
            href="/quote"
            className="text-primary hover:text-primary/80 mt-1 inline-flex items-center gap-1 text-sm font-medium"
          >
            Or get a quote instead <ArrowRightIcon className="size-3.5" />
          </a>
        </div>
      </DialogContent>
    </Dialog>
  )
}
