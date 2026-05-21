# FUSED UK — Site Rebuild Prompt

This document is the prompt for Claude Code to build the new FUSED UK marketing site. The repo is already initialised as an Astro + shadcn + Tailwind v4 template with brand colours in `src/styles/global.css`.

---

## Hard rules

1. **No invented copy.** Use only the verbatim text in this document. Anywhere copy is missing, insert a literal placeholder `[CLIENT TO PROVIDE: <what>]`. Do not paraphrase, do not "fill in the gaps".
2. **No invented components.** Every UI primitive must be installed via shadcn CLI: `pnpm dlx shadcn@latest add <name>`. Do not hand-roll Card/Button/Carousel/Sheet/etc.
3. **No new images.** Use only the files already in `public/`. Where a client logo or extra photo is needed, use a placeholder `<div>` labelled `[CLIENT TO PROVIDE: <description>]`.
4. **Light is default. Dark mode is opt-in via toggle.**
5. **Header and footer are dark always** (white text on near-black), regardless of light/dark mode. The body switches.
6. **Container centred, text left-aligned** inside it. Only hero headline + section eyebrows centred.
7. **Default typography** — don't override Tailwind/shadcn defaults. Tweak later if needed.

---

## Tech setup

- **Framework:** Astro (already configured)
- **Styling:** Tailwind v4 + shadcn (already configured, see `src/styles/global.css`)
- **Font:** Inter Variable (already imported)
- **Dark mode:** Official shadcn-for-Astro pattern — inline `<script is:inline>` in `<head>` that reads `localStorage.theme` + system preference and sets `class="dark"` on `<html>` *before paint* (no FOUC). Toggle is a shadcn `dropdown-menu` with Light / Dark / System options. Reference: https://ui.shadcn.com/docs/dark-mode/astro
- **Forms:** No backend. Quote page uses a `mailto:` link with pre-filled subject + body template.
- **Reviews:** Hardcoded in `src/data/reviews.json`.

### shadcn components to install up-front

```bash
pnpm dlx shadcn@latest add button card carousel navigation-menu sheet accordion dropdown-menu separator badge
```

Install more as needed — never hand-roll.

---

## Routes

| Path        | Page          |
|-------------|---------------|
| `/`         | Home          |
| `/services` | Services      |
| `/why-pat`  | Why PAT Test? |
| `/about`    | About Us      |
| `/quote`    | Get a Quote   |
| `/terms`    | Terms & Conditions (footer-linked) |
| `/privacy`  | Privacy Policy (footer-linked) |

Nav (header): Home, Services, Why PAT Test, About Us, Get a Quote.

---

## Images available in `public/`

User-supplied photos:
- `blurred-workspace-with-f-uk-overlay.jpeg` — hero background
- `man-working.jpeg` — in-action shot
- `vans.jpeg` — branded van
- `fuseduk-sign.jpeg` — sign
- `3-person-team.jpg` — team

Iconographic / supporting:
- `microwave-leakage-test.jpg`
- `cable-repairs.jpg`
- `asset-certifications.jpg`
- `iet-code-of-practice.jpg`
- `landlord-legal-requirements.jpg`

Branding / accreditation:
- `fused-uk-logo.jpg` — full logo banner
- `disclosure-and-barring-service.png` — DBS logo
- `favicon.svg`

---

## Layout shell

### Header (dark always, sticky)

- **Desktop:** Left: `fused-uk-logo.jpg` (height ~40px). Centre: nav links. Right: phone number `07729 577307` as `tel:` link + **Book Now** button (primary) + theme toggle (dropdown: Light / Dark / System).
- **Mobile:** Left: logo. Right: phone icon (`tel:` link) + hamburger. Hamburger opens a shadcn `Sheet` overlay with nav links, theme toggle, and **Book Now** button at the bottom.

### Footer (dark always)

- Column 1: logo + address (`FUSED UK Electrical Ltd, 8 Nelson Court, Methley, Leeds, LS26 9LJ`) + company/VAT (`Registered in England & Wales No: 10843606; VAT No: 320977105`).
- Column 2: nav links repeated.
- Column 3: contact — `07729 577307` (tel link), `sales@fuseduk.co.uk` (mailto link).
- Column 4: social icons in their original brand colours — Facebook (#1877F2) → `https://www.facebook.com/fuseduk`, X/Twitter (black) → `https://twitter.com/Fuseduk`, Instagram (official gradient) → `https://www.instagram.com/fuseduk`.
- Bottom strip: `© FUSED UK Electrical Ltd` + links to `/terms` and `/privacy`.

### Book Now button behaviour

- **Mobile:** `href="tel:07729577307"` — direct one-tap call.
- **Desktop:** Opens a small shadcn `Dialog` showing phone number, email, and a link "Or get a quote instead →" pointing to `/quote`.
- Same `<BookNowButton />` component everywhere — variant prop controls placement, never duplicated logic.

---

## Page: `/` (Home)

### 1. Hero

- Background: `blurred-workspace-with-f-uk-overlay.jpeg` (full-bleed, slight dark overlay for legibility).
- Headline (centred): **FUSED UK PAT Testing**
- Subhead (centred): Welcome to FUSED UK. We provide specialist, UK wide, portable appliance testing (PAT testing) services that enable you to comply with health and safety, insurance and site survey regulations.
- CTA row (centred): **Book Now** (primary) + **Get a Quote** (outline).
- Phone strip below CTAs: We aim to 'beat any quote', so if you require electrical testing services, please don't hesitate to call us on **07729 577307**.

### 2. Key benefits strip (green-tick row)

Use shadcn cards or a simple grid. Each item prefixed with a green tick icon (lucide `Check` in brand green):

- Beat any quotation
- Same-day callout and flexible after-hours/weekend testing
- On-time UK-wide arrival
- DBS-checked and fully insured engineers
- Testing per IEE Code of Practice
- Itemised asset reports
- No hidden charges

### 3. Services preview

Three shadcn `Card`s:

- **Fully Inclusive PAT Testing** — Inspection and safety testing of portable appliances with the latest computerised equipment. Testing follows IEE Code of Practice standards. Minor repairs and replacement fuses/IT leads are provided at no charge. *(image: `microwave-leakage-test.jpg` — no wait, use `iet-code-of-practice.jpg`)*
- **Microwave Leakage Testing** — Radiation intensity assessments are conducted, with reports detailing mW/cm2 output levels. *(image: `microwave-leakage-test.jpg`)*
- **Emergency Light Testing** — The company provides inspection and testing for 6-monthly and annual compliance periods, typically running the full 3-hour rated duration. Services include verifying correct fixture placement and signage. *(no image)*

Below cards: **See all services →** link to `/services`.

### 4. Photo carousel (fade transition)

shadcn `Carousel` with fade plugin (`embla-carousel-fade`). Autoplay 5s. Images:

- `man-working.jpeg`
- `vans.jpeg`
- `fuseduk-sign.jpeg`
- `3-person-team.jpg`

### 5. Why PAT Test? teaser

4 callout boxes (shadcn `Card`s) using verbatim micro-extracts from the Why PAT Test page:

- **Legal requirement** — The Electricity at Work Regulations requires that employers maintain their electrical systems at work to prevent any danger to anyone. This is a legal requirement.
- **Insurance risk** — Insurers are fully entitled to reduce, delay or even refuse to pay on a claim for damage caused by a portable appliance that has not been PAT tested.
- **Prosecution risk** — Failure to comply can result in prosecution, fine and or/imprisonment.
- **Landlord duty** — The Electrical Equipment (Safety) Regulations 1994 requires that all mains electrical equipment (cookers, washing machines, kettles, etc), new or second-hand, supplied with the accommodation must be safe.

Below: **Read the full guide →** link to `/why-pat`.

### 6. Reviews carousel

shadcn `Carousel` rendering all 14 reviews from `src/data/reviews.json` (see Data section). Autoplay 6s. Show one card at a time on mobile, three at a time on desktop. **No "Read all on Google" button.**

### 7. Trust strip

Horizontal row: DBS logo (`disclosure-and-barring-service.png`) + text badge "Fully insured up to £5 million".

### 8. Final CTA band

Dark band, centred content: phone number large + **Book Now** + **Get a Quote** buttons.

---

## Page: `/services`

Heading: **Services**

Six sections, each with the existing copy verbatim and green-tick lists where natural. Each section uses an image from `public/` where one fits.

1. **Fully Inclusive PAT Testing** (image: `iet-code-of-practice.jpg`)
   > Inspection and safety testing of portable appliances with the latest computerised equipment. Testing follows IEE Code of Practice standards. Minor repairs and replacement fuses/IT leads are provided at no charge.

2. **Microwave Leakage Testing** (image: `microwave-leakage-test.jpg`)
   > Radiation intensity assessments are conducted, with reports detailing mW/cm2 output levels.

3. **Emergency Light Testing** (no image)
   > The company provides inspection and testing for 6-monthly and annual compliance periods, typically running the full 3-hour rated duration. Services include verifying correct fixture placement and signage.

4. **Cable Repairs** (image: `cable-repairs.jpg`)
   > The majority of items which fail a visual PAT testing inspection are due to damaged cable and flex. FUSED UK offers replacement services for worn equipment like vacuums and 110v site gear.

5. **Free Reminder Renewal Service**
   > Automatic contact system ensures certification renewal scheduling and prevents expiration.

6. **Asset Reports and Certification** (image: `asset-certifications.jpg`)
   > Detailed electrical testing reports list all tested assets. Deliverables include an itemised appliance register, PAT testing certificate, and passed/failed item lists—provided free in bound folders or digitally.

Closing strip with green ticks:
- No hidden charges on quotes
- DBS-checked engineers approved for schools, hospitals, and residences
- Contact: `07729 577307` or `sales@fuseduk.co.uk`

---

## Page: `/why-pat`

Heading: **Why PAT test?**

Use verbatim copy below. Use shadcn `Accordion` for the longer landlord section if it makes the page feel less wall-of-text — but copy stays verbatim.

> Portable appliance testing was introduced to enable companies and organisations to comply with the Electricity at Work regulations. "The Electricity at Work Regulations requires that employers maintain their electrical systems at work to prevent any danger to anyone. This is a legal requirement."

**Legislation.**
> The legislation of specific relevance to electrical maintenance is the Health & Safety at Work Act 1974, the Management of Health & Safety at Work Regulations 1999, the Electricity at Work Regulations 1989, the Workplace (Health, Safety and Welfare) Regulations 1992 and the Provision and Use of Work Equipment Regulations 1998.
>
> This includes the self employed.
>
> The Health & Safety at Work Act (1974) places such an obligation in the following circumstances:
> - Where appliances are used by employees.
> - Where the public may use appliances in establishments such as hospitals, schools, hotels, shops etc.
> - Where appliances are supplied or hired.
> - Where appliances are repaired or serviced.

**If you don't PAT test...**
> Portable appliance testing, or PAT testing, is a major contributor to ensuring safety at all times, and will enable your business to comply with the legal standards. Failure to implement a programme of regular appliance testing can lead to serious consequences, as well as affecting insurance policies.

**Insurance claims can be refused.**
> Most insurance companies will assume that the owners of a business are compliant with all relevant regulations. "Insurers are fully entitled to reduce, delay or even refuse to pay on a claim for damage caused by a portable appliance that has not been PAT tested."

**Prosecution.**
> It is vital to provide a safe electrical environment for your staff and visitors by PAT testing. "Failure to comply can result in prosecution, fine and or/imprisonment."

**Landlord legal requirements.** (image: `landlord-legal-requirements.jpg`)
> Anyone who lets residential accommodation (such as houses, flats and bedsits, holiday homes, caravans and boats) as a business activity is required by law to ensure the equipment they supply as part of the tenancy is safe. "The Electrical Equipment (Safety) Regulations 1994 requires that all mains electrical equipment (cookers, washing machines, kettles, etc), new or second-hand, supplied with the accommodation must be safe."
>
> The penalties for non-compliance can be severe: in certain cases, unlimited fines and imprisonment, not to mention the harm done to someone in the event of a serious electric shock, or the damage done to property in the case of a fire Landlords therefore need to regularly maintain the electrical equipment they supply to ensure it is safe.
>
> The supply of goods occurs at the time of the tenancy contract. It is, therefore, essential that property is checked prior to the tenancy to ensure that all goods supplied are in a safe condition. A record should be made of the goods supplied as part of the tenancy agreement and of checks made on those goods. The record should indicate who carried out the checks and when they did it.
>
> It is strongly advised that you have all the electrical equipment checked before the start of each let. It is also good practice to have the equipment checked at regular intervals thereafter, as well as obtaining and retaining all the test reports detailing the equipment, the tests carried out and the results.

**Get all your electrical equipment tested today.**
> If you are a landlord or business owner and would like to find out more about where your business stands with regards to electrical safety, or if you think you could benefit from having your electrical equipment PAT tested, please call us on **07729 577307** or email us via sales@fuseduk.co.uk.

End the page with **Book Now** + **Get a Quote** buttons.

---

## Page: `/about`

Mirrors the structure of the existing FUSED UK About page (team photo, DBS badge, contact section — no client logo grid).

Heading: **About FUSED UK**

Image: `3-person-team.jpg` at the top.

> The company is headed by owner Jason Bolton and his team of experienced engineers with extensive portable appliance testing industry experience. They emphasize providing prompt, professional, and reliable service with customer guidance on PAT testing obligations.

**Mission**
> FUSED UK will provide a prompt, professional service and work flexible hours to suit customers' needs with minimum disruption to the workplace within the field of electrical health and safety.

**What we offer** (green-tick list)
- Cost-effective solutions throughout the UK, particularly Leeds, Wakefield, and West Yorkshire
- Fully calibrated, up-to-date equipment
- Tailored testing regimes, safety certificates, and reports provided at no charge

**DBS-checked engineers** (DBS logo `disclosure-and-barring-service.png` inline, green-tick list)
- All engineers are DBS checked for work in private residences, schools, hospitals, and vulnerable populations
- Fully insured up to £5 million

**Who we work with**
> The company serves GP surgeries, schools, nurseries, shops, restaurants, and hairdressers.

**Service features** (green-tick list)
- Same-day callout availability
- Flexible after-hours and weekend testing
- On-time guarantee across the UK

**Contact** (three coloured icon cards, matching the existing site's blue/yellow/green icon row)
- Phone (blue): `07729 577307`
- Email (yellow): `sales@fuseduk.co.uk`
- Address (green): `8 Nelson Court, Methley, Leeds, LS26 9LJ`

---

## Page: `/quote`

Heading: **Get a Quote**

Body copy (verbatim):
> Our quotation is based on the number of tests required. We aim to beat any genuine comparable offer with no hidden charges and no VAT.

Three large action cards:

1. **Email us** — primary card. Big button with `href`:
   ```
   mailto:sales@fuseduk.co.uk?subject=PAT%20Testing%20Quote%20Request&body=Company%20name%3A%0AContact%20name%3A%0APhone%3A%0AAddress%3A%0AType%20of%20business%3A%0ATest%20due%20date%3A%0ANumber%20of%20tests%20required%3A%0AHow%20did%20you%20hear%20about%20us%3F%3A%0A
   ```
   (Opens default mail client with subject + body template pre-filled.)

2. **Call us** — `tel:07729577307`, large phone number displayed.

3. **Book Now** — same shared Book Now component.

---

## Page: `/terms`

Heading: **Terms & Conditions**

Body verbatim:
> All content and design of this website is protected by copyright, trademarks and other intellectual property rights and is the property of © FUSED UK Ltd or is issued under license from third party copyright owners.
>
> You may print or download such material in electronic form on your local hard drive for your personal and non-commercial use.
>
> You may not alter or otherwise make any changes to any material that you print or download including, without limitation, removing any copyright or proprietary notices.
>
> All other uses are prohibited including, without limitation, distributing, reproducing, modifying, copying or using for commercial purposes any of the materials or contents of this site.
>
> The license to copy also does not permit incorporation of the content or any part of the website in any other work or publication in any form whatsoever.
>
> If you have any questions regarding our Terms and Conditions, please call us on **07729 577307**.
>
> FUSED UK Electrical Ltd - Company Registration No. 10843606.

---

## Page: `/privacy`

Heading: **Privacy Policy**

Body verbatim:
> FUSED UK Ltd prioritizes privacy and confidentiality in accordance with the United Kingdom Data Protection Act 1998. The company commits to ensuring personal data is:
> - Fairly and lawfully processed
> - Processed for limited purposes
> - Adequate, relevant and not excessive
> - Accurate
> - Not kept longer than necessary
> - Processed in accordance with the data subject's rights
> - Secure
> - Not transferred to countries without adequate protection
>
> **Registration and Communications**
> When you register details on the website, information is securely retained. The organization may send correspondence by post or email. You may request removal from the mailing list at any time.
>
> **Internet Security Notice**
> "No data transmission over the internet can be guaranteed to be 100% secure, as such we will strive to protect your personal information but cannot ensure the security of any information you transmit to us and you do so at your own risk."
>
> **Data Sharing**
> The company does not share personal details with third parties.
>
> **Contact for Concerns**
> For inquiries about personal information, reach out at 07729 577307.
>
> FUSED UK Electrical Ltd - Company Registration No 10843606.

---

## Data: `src/data/reviews.json`

```json
[
  { "name": "www.partynightsdjs.co.uk", "location": "", "quote": "All our equipment has been PAT Tested by Fused UK. Good, friendly and professional service, would not hesitate to recommend." },
  { "name": "Vicky Brazendale", "location": "Eccles", "quote": "Superb service, I would not use anyone else for all my future PAT Testing requirements. Excellent service all round. Highly recommend." },
  { "name": "E. Cortes", "location": "Leeds", "quote": "Highly recommended, pat testing of our Leeds salon was completed on schedule and at a competitive rate – very happy" },
  { "name": "J. Kavanagh", "location": "Normanton", "quote": "Pat testing was carried out at our Normanton salon. The pat testing was done efficiently, promptly and with minimal disruption to our business" },
  { "name": "S. Wilson", "location": "Leeds", "quote": "FUSED UK offered a professional portable appliance testing service arrived on time and completed pat testing after hours to suit our business needs – excellent service thanks" },
  { "name": "S. Carroll", "location": "Wakefield", "quote": "We had our portable appliance testing (pat testing) done by FUSED UK at our Wakefield office we were so impressed at the pricing we have asked them to complete testing at our Huddersfield and Leeds branches!" },
  { "name": "P. Fellows", "location": "Castleford", "quote": "Having been let down by other companies it was a relief to have FUSED UK complete our pat testing...with minimal disruption and clear reports I am very happy and would recommend" },
  { "name": "J. Daniels", "location": "Castleford & Wakefield", "quote": "With an offer of \"we will beat any quote\" I decided that we would used FUSED UK for pat testing of our Castleford offices their service was professional and prompt would highly recommend" },
  { "name": "C. Calvert", "location": "Huddersfield", "quote": "They beat the price of the previous pat testing company and I received my reports and certificates via email the next day! Truly superb service!" },
  { "name": "David Lawrence", "location": "Leeds", "quote": "Reliable, flexible and friendly PAT Testing always sends certificates through quickly, good quality service. Thanks." },
  { "name": "Karen Taylor", "location": "Pudsey", "quote": "Very happy with the service I received for PAT Testing - Jason and his team very friendly and professional his quotation was also very competitive will be using again." },
  { "name": "Chris Bolton", "location": "Shipley", "quote": "I found the service and value for money second to none." },
  { "name": "Kimberley Hayes", "location": "Leeds", "quote": "Highly recommend!! Great service!! Will use again!" },
  { "name": "Mark Fisher", "location": "Leeds", "quote": "Asked Jason from FUSED UK on Thursday if he could do a job for me. Monday job done! Excellent work, already have other work for him." }
]
```

---

## Visual rules summary

- **Header & footer:** dark always (near-black background, white text). Independent of theme.
- **Body:** light by default; dark mode opt-in via toggle (persists in `localStorage`).
- **Container:** centred horizontally, max-width ~1200px. Text inside is **left-aligned** (hero headline + section eyebrows are the only centred text).
- **Buttons:** shadcn defaults. `Book Now` = primary (brand green). `Get a Quote` = outline.
- **Lists:** any bullet list in body content uses a green tick icon (lucide `Check`, brand green) instead of a disc/dot.
- **Cards / inputs / images:** shadcn default rounding — do not override.
- **Typography:** Inter Variable, default scale. Don't override.
- **Animations:** carousel fade (5s home photos, 6s reviews). Respect `prefers-reduced-motion`.
- **Social icons:** Facebook (#1877F2), X/Twitter (black/white per footer contrast), Instagram (official gradient).

---

## What is NOT in scope

- No accessibility widget / panel.
- No "Read all on Google" button on reviews.
- No live Google Places API integration.
- No backend / API routes / SSR forms.
- No custom components when a shadcn component exists.
- No copywriting — verbatim only, placeholders elsewhere.

---

## Unresolved questions for the client

None outstanding — all decisions resolved.
