import { PlAccordion, PlAccordionItem } from 'plass-ui';

export default function AccordionVariants() {
  return (
    <div className="grid w-full gap-5 sm:grid-cols-3">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlAccordion key={variant} variant={variant} size="sm" defaultValue={['one']}>
          <PlAccordionItem value="one" title={variant}>
            The sheet is {variant}.
          </PlAccordionItem>
          <PlAccordionItem value="two" title="Second">
            And a second fold under it.
          </PlAccordionItem>
        </PlAccordion>
      ))}
    </div>
  );
}
