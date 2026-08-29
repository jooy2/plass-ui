import { PlAnimateLighting, PlBox } from 'plass-ui';

const shapes = [
  { label: 'a spark', arc: 18, blur: 6, spread: 3 },
  { label: 'the default', arc: 50, blur: 5, spread: 3 },
  { label: 'a sweep', arc: 140, blur: 10, spread: 5 }
];

export default function AnimateLightingShape() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-6">
      {shapes.map((shape) => (
        <PlAnimateLighting
          key={shape.label}
          size="md"
          arc={shape.arc}
          blur={shape.blur}
          spread={shape.spread}
        >
          <PlBox size="md">{shape.label}</PlBox>
        </PlAnimateLighting>
      ))}
    </div>
  );
}
