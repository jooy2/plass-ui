import { PlTimeline, PlTimelineItem } from 'plass-ui';

export default function TimelineSizes() {
  return (
    <div className="flex w-full max-w-lg flex-wrap gap-8">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlTimeline key={size} size={size} density="compact" active={1}>
          <PlTimelineItem title={size} bullet="1" />
          <PlTimelineItem title="Next" bullet="2" />
        </PlTimeline>
      ))}
    </div>
  );
}
