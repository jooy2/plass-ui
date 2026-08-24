import { PlTimeline, PlTimelineItem } from 'plass-ui';

export default function TimelineHero() {
  return (
    <PlTimeline className="w-full max-w-md" active={2}>
      <PlTimelineItem title="Ordered" meta="Mon 09:12" bullet="1">
        Payment cleared and the warehouse was notified.
      </PlTimelineItem>
      <PlTimelineItem title="Packed" meta="Mon 14:40" bullet="2">
        Two boxes, 3.1kg.
      </PlTimelineItem>
      <PlTimelineItem title="Shipped" meta="Tue 07:05" bullet="3">
        In transit with the carrier.
      </PlTimelineItem>
      <PlTimelineItem title="Delivered" meta="Expected Wed" bullet="4" />
    </PlTimeline>
  );
}
