import { PlButtonGroup, PlButton } from 'plass-ui';

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function ButtonGroupSizes() {
  return (
    <div className="flex flex-col items-start gap-3">
      {sizes.map((size) => (
        <PlButtonGroup key={size} size={size} variant="glass" color="secondary">
          <PlButton>Back</PlButton>
          <PlButton>Forward</PlButton>
        </PlButtonGroup>
      ))}
    </div>
  );
}
