import * as React from "react"
import { MenuIcon, ArrowUpRightIcon } from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  Sheet,
  SheetContent,
  SheetTrigger,
  SheetClose,
} from "@/components/ui/sheet"
import { ThemeToggle } from "./ThemeToggle"
import { BookNowButton } from "./BookNowButton"

const links = [
  { href: "/", label: "Home" },
  { href: "/services", label: "Services" },
  { href: "/why-pat", label: "Why PAT Test" },
  { href: "/about", label: "About Us" },
  { href: "/quote", label: "Get a Quote" },
]

export function MobileNav() {
  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button
          variant="ghost"
          size="icon-sm"
          aria-label="Open menu"
          className="text-white hover:bg-white/10 hover:text-white"
        >
          <MenuIcon className="size-5" />
        </Button>
      </SheetTrigger>
      <SheetContent
        side="right"
        showCloseButton={false}
        className="flex w-80 flex-col gap-0 border-l border-white/10 bg-neutral-950 p-0 text-white"
      >
        <div className="relative flex items-center justify-between border-b border-white/10 px-6 pt-5 pb-4">
          <span className="text-[10px] font-medium tracking-[0.28em] text-white/40 uppercase">
            Navigation
          </span>
          <SheetClose asChild>
            <button
              aria-label="Close menu"
              className="group flex items-center gap-2 text-[11px] font-medium tracking-[0.18em] text-white/60 uppercase transition-colors hover:text-white"
            >
              Close
              <span className="flex size-6 items-center justify-center border border-white/20 transition-colors group-hover:border-primary group-hover:text-primary">
                <span aria-hidden className="text-base leading-none">×</span>
              </span>
            </button>
          </SheetClose>
        </div>

        <nav className="relative flex flex-1 flex-col px-6 pt-6">
          {links.map((l, i) => (
            <SheetClose asChild key={l.href}>
              <a
                href={l.href}
                className="group flex items-baseline gap-4 border-b border-white/5 py-4 transition-colors last:border-b-0 hover:text-primary"
              >
                <span className="text-[10px] font-medium tracking-widest text-white/30 tabular-nums group-hover:text-primary/70">
                  0{i + 1}
                </span>
                <span className="font-heading flex-1 text-lg font-medium tracking-tight">
                  {l.label}
                </span>
                <ArrowUpRightIcon className="size-4 -translate-x-1 opacity-0 transition-all group-hover:translate-x-0 group-hover:opacity-100" />
              </a>
            </SheetClose>
          ))}
        </nav>

        <div className="relative border-t border-white/10 bg-white/2 px-6 pt-5 pb-6">
          <div
            aria-hidden
            className="absolute inset-x-6 top-0 h-px bg-linear-to-r from-transparent via-primary/50 to-transparent"
          />
          <div className="flex items-center justify-between pb-5">
            <span className="text-[10px] font-medium tracking-[0.24em] text-white/40 uppercase">
              Appearance
            </span>
            <ThemeToggle />
          </div>
          <div className="flex justify-center">
            <BookNowButton size="lg" className="px-10 text-sm tracking-wide" />
          </div>
        </div>
      </SheetContent>
    </Sheet>
  )
}
