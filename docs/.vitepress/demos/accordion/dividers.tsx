import { PlAccordion, PlAccordionItem } from 'plass-ui';

export default function AccordionDividers() {
  return (
    <div className="grid w-full gap-5 sm:grid-cols-2">
      <PlAccordion size="sm" defaultValue={['one']}>
        <PlAccordionItem value="one" title="Scored">
          The rule reaches both edges.
        </PlAccordionItem>
        <PlAccordionItem value="two" title="Second">
          One pane, two folds.
        </PlAccordionItem>
      </PlAccordion>

      <PlAccordion size="sm" dividers={false} defaultValue={['one']}>
        <PlAccordionItem value="one" title="Tiled">
          Each fold is its own tile.
        </PlAccordionItem>
        <PlAccordionItem value="two" title="Second">
          Told apart by space instead.
        </PlAccordionItem>
      </PlAccordion>
    </div>
  );
}
