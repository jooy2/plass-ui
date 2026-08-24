import { PlAccordion, PlAccordionItem } from 'plass-ui';

export default function AccordionHero() {
  return (
    <PlAccordion defaultValue={['shipping']} className="w-full max-w-lg">
      <PlAccordionItem value="shipping" title="Shipping" subtitle="Where it goes and how fast">
        Standard delivery arrives in three to five working days. Express is next-day for orders
        placed before 4pm.
      </PlAccordionItem>
      <PlAccordionItem value="returns" title="Returns" subtitle="Thirty days, no questions">
        Send anything back within thirty days of delivery. Refunds land on the original payment
        method within a week of the parcel arriving with us.
      </PlAccordionItem>
      <PlAccordionItem value="warranty" title="Warranty" subtitle="Two years on every part">
        Manufacturing faults are covered for two years. Wear from ordinary use is not.
      </PlAccordionItem>
    </PlAccordion>
  );
}
