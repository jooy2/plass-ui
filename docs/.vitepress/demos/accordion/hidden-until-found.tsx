import { PlAccordion, PlAccordionItem } from 'plass-ui';

export default function AccordionHiddenUntilFound() {
  return (
    <PlAccordion hiddenUntilFound className="w-full max-w-lg">
      <PlAccordionItem value="delivery" title="How long does delivery take?">
        Three to five working days at home, and seven to ten abroad.
      </PlAccordionItem>
      <PlAccordionItem value="returns" title="Can I return an opened item?">
        Yes, within thirty days, as long as it comes back with everything it shipped with.
      </PlAccordionItem>
      <PlAccordionItem value="duties" title="Who pays import charges?">
        The country an order arrives in may charge customs duties, and they are paid on delivery.
      </PlAccordionItem>
    </PlAccordion>
  );
}
