import { PlAccordion, PlAccordionItem } from 'plass-ui';

export default function AccordionSizes() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {(['sm', 'md', 'lg'] as const).map((size) => (
        <PlAccordion key={size} size={size} defaultValue={['one']}>
          <PlAccordionItem value="one" title={`size="${size}"`} subtitle="Title, subtitle, body">
            The three ladders move together: the title, the body under it and the padding around
            both.
          </PlAccordionItem>
        </PlAccordion>
      ))}
    </div>
  );
}
