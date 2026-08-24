import { PlTimeline, PlTimelineItem } from 'plass-ui';

export default function TimelineConnectors() {
  return (
    <PlTimeline className="w-full max-w-md" density="compact" active={4}>
      <PlTimelineItem title="solid" connector="solid" />
      <PlTimelineItem title="dashed" connector="dashed" />
      <PlTimelineItem title="dotted" connector="dotted" />
      <PlTimelineItem title="none" connector="none" />
      <PlTimelineItem title="The last line is never drawn" />
    </PlTimeline>
  );
}
