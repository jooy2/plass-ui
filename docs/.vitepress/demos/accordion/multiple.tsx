import { PlAccordion, PlAccordionItem } from 'plass-ui';

export default function AccordionMultiple() {
  return (
    <PlAccordion multiple defaultValue={['cpu', 'memory']} className="w-full max-w-lg">
      <PlAccordionItem value="cpu" title="CPU">
        8 cores, 3.4 GHz.
      </PlAccordionItem>
      <PlAccordionItem value="memory" title="Memory">
        32 GB, 6000 MT/s.
      </PlAccordionItem>
      <PlAccordionItem value="storage" title="Storage">
        1 TB NVMe.
      </PlAccordionItem>
    </PlAccordion>
  );
}
