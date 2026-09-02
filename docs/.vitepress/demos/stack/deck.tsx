import { PlCard, PlStack } from 'plass-ui';

export default function StackDeck() {
  return (
    <PlStack
      direction="diagonal"
      front="first"
      overlap={200}
      drop={14}
      scaleStep={0.96}
      opacityStep={0.85}
    >
      {['Invoice 1041', 'Invoice 1040', 'Invoice 1039'].map((title) => (
        <PlCard key={title} size="sm" title={title} className="w-56">
          Due at the end of the month.
        </PlCard>
      ))}
    </PlStack>
  );
}
