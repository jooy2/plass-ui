import { PlDivider } from 'plass-ui';

export default function DividerSizes() {
  return (
    <div className="flex w-full max-w-md flex-col gap-5">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlDivider key={size} size={size}>
          {size}
        </PlDivider>
      ))}
    </div>
  );
}
