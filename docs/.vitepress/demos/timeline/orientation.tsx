import { PlTimeline, PlTimelineItem } from 'plass-ui';

export default function TimelineOrientation() {
  return (
    <PlTimeline className="w-full max-w-lg" orientation="horizontal" active={1}>
      <PlTimelineItem title="Account" bullet="1" />
      <PlTimelineItem title="Payment" bullet="2" />
      <PlTimelineItem title="Review" bullet="3" />
      <PlTimelineItem title="Done" bullet="4" />
    </PlTimeline>
  );
}
