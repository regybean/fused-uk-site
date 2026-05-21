import * as React from "react"
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion"

const items = [
  {
    value: "l1",
    title: "Who is affected",
    body: (
      <>
        Anyone who lets residential accommodation (such as houses, flats and
        bedsits, holiday homes, caravans and boats) as a business activity is
        required by law to ensure the equipment they supply as part of the
        tenancy is safe.{" "}
        <span className="text-foreground font-semibold">
          “The Electrical Equipment (Safety) Regulations 1994 requires that all
          mains electrical equipment (cookers, washing machines, kettles, etc),
          new or second-hand, supplied with the accommodation must be safe.”
        </span>
      </>
    ),
  },
  {
    value: "l2",
    title: "Penalties for non-compliance",
    body: (
      <>
        The penalties for non-compliance can be severe: in certain cases,
        unlimited fines and imprisonment, not to mention the harm done to
        someone in the event of a serious electric shock, or the damage done to
        property in the case of a fire Landlords therefore need to regularly
        maintain the electrical equipment they supply to ensure it is safe.
      </>
    ),
  },
  {
    value: "l3",
    title: "Records and timing",
    body: (
      <>
        The supply of goods occurs at the time of the tenancy contract. It is,
        therefore, essential that property is checked prior to the tenancy to
        ensure that all goods supplied are in a safe condition. A record should
        be made of the goods supplied as part of the tenancy agreement and of
        checks made on those goods. The record should indicate who carried out
        the checks and when they did it.
      </>
    ),
  },
  {
    value: "l4",
    title: "Best practice for landlords",
    body: (
      <>
        It is strongly advised that you have all the electrical equipment
        checked before the start of each let. It is also good practice to have
        the equipment checked at regular intervals thereafter, as well as
        obtaining and retaining all the test reports detailing the equipment,
        the tests carried out and the results.
      </>
    ),
  },
]

export function LandlordAccordion() {
  return (
    <Accordion type="single" collapsible className="mt-6" defaultValue="l1">
      {items.map((it) => (
        <AccordionItem key={it.value} value={it.value}>
          <AccordionTrigger className="text-left">{it.title}</AccordionTrigger>
          <AccordionContent>
            <p className="text-muted-foreground leading-relaxed">{it.body}</p>
          </AccordionContent>
        </AccordionItem>
      ))}
    </Accordion>
  )
}
