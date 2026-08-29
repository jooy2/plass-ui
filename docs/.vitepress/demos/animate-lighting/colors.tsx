import { PlAnimateLighting, PlBox } from 'plass-ui';

const colors = ['primary', 'success', 'warning', 'danger'] as const;

export default function AnimateLightingColors() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-5">
      {colors.map((color) => (
        <PlAnimateLighting key={color} size="sm" color={color} duration={2400}>
          <PlBox size="sm">{color}</PlBox>
        </PlAnimateLighting>
      ))}
    </div>
  );
}
