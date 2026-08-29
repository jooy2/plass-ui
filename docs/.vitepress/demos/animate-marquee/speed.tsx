import { PlAnimateMarquee, PlChip } from 'plass-ui';

const words = ['one', 'two', 'three', 'four', 'five', 'six'];

export default function AnimateMarqueeSpeed() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      {[30, 90].map((speed) => (
        <PlAnimateMarquee key={speed} speed={speed} gap="1rem">
          {words.map((word) => (
            <PlChip key={word}>
              {word} — {speed}px/s
            </PlChip>
          ))}
        </PlAnimateMarquee>
      ))}
    </div>
  );
}
