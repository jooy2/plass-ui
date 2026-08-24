import { PlTimeline, PlTimelineItem } from 'plass-ui';

export default function TimelineStatus() {
  return (
    <PlTimeline className="w-full max-w-md" active={3}>
      <PlTimelineItem title="Cloned" bullet="1" />
      <PlTimelineItem title="Installed" bullet="2" />
      <PlTimelineItem title="Tested" bullet="✕" status="upcoming" color="danger">
        Two tests are red, so this step never finished.
      </PlTimelineItem>
      <PlTimelineItem title="Deployed" bullet="4" />
    </PlTimeline>
  );
}
