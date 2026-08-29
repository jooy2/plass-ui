import { PlAnimateMarquee, PlBox } from 'plass-ui';

const lines = ['Deployed api-gateway', 'Rotated a key', 'Invited Ada', 'Archived a project'];

export default function AnimateMarqueeOrientation() {
  return (
    <div className="flex flex-wrap items-start justify-center gap-6">
      <PlAnimateMarquee className="h-40 w-56" orientation="vertical" gap="0.75rem" speed={30}>
        {lines.map((line) => (
          <PlBox key={line} size="sm">
            {line}
          </PlBox>
        ))}
      </PlAnimateMarquee>

      <PlAnimateMarquee
        className="h-40 w-56"
        orientation="vertical"
        reverse
        gap="0.75rem"
        speed={30}
      >
        {lines.map((line) => (
          <PlBox key={line} size="sm">
            {line}
          </PlBox>
        ))}
      </PlAnimateMarquee>
    </div>
  );
}
