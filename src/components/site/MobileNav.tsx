import * as React from "react"
import { MenuIcon } from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
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
      <SheetContent side="right" className="flex w-72 flex-col bg-neutral-950 text-white">
        <SheetHeader>
          <SheetTitle className="text-white">Menu</SheetTitle>
        </SheetHeader>
        <nav className="mt-2 flex flex-col">
          {links.map((l) => (
            <SheetClose asChild key={l.href}>
              <a
                href={l.href}
                className="border-b border-white/10 py-3 text-base font-medium tracking-tight hover:text-primary"
              >
                {l.label}
              </a>
            </SheetClose>
          ))}
        </nav>
        <div className="mt-auto flex flex-col gap-3 pb-4">
          <div className="flex items-center justify-between text-sm text-white/70">
            <span>Theme</span>
            <ThemeToggle />
          </div>
          <BookNowButton size="lg" className="w-full" />
        </div>
      </SheetContent>
    </Sheet>
  )
}
