import { PhoneIcon, MailIcon, ArrowRightIcon } from "lucide-react"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { PHONE, TEL, EMAIL, MAILTO } from "@/lib/contact"

export function BookNowCardTrigger() {
  const icon = (
    <svg
      width="22"
      height="22"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <rect x="3" y="4" width="18" height="18" rx="2" />
      <line x1="16" y1="2" x2="16" y2="6" />
      <line x1="8" y1="2" x2="8" y2="6" />
      <line x1="3" y1="10" x2="21" y2="10" />
    </svg>
  )

  return (
    <Dialog>
      <DialogTrigger asChild>
        <button
          type="button"
          className="bg-primary text-primary-foreground hover:bg-primary/80 inline-flex size-12 cursor-pointer items-center justify-center rounded-none transition-colors"
        >
          {icon}
        </button>
      </DialogTrigger>
      <div className="text-muted-foreground text-xs font-semibold tracking-widest uppercase">
        Book today
      </div>
      <DialogTrigger asChild>
        <button
          type="button"
          className="hover:text-primary cursor-pointer text-left text-2xl font-semibold tracking-tight"
        >
          Same-day callout
        </button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Book your PAT test</DialogTitle>
          <DialogDescription>
            We aim to beat any genuine quote — call or email and we&apos;ll come
            back to you fast.
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
