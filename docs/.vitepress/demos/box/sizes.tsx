import { PlBox, PlTypography } from 'plass-ui';

export default function BoxSizes() {
  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlBox key={size} size={size}>
          <PlTypography level="body">size: {size}</PlTypography>
        </PlBox>
      ))}
    </div>
  );
}
