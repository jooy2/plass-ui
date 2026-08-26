import { PlContainer, PlTypography } from 'plass-ui';

const WIDTHS = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function ContainerWidths() {
  return (
    <div className="flex w-full flex-col gap-3">
      {WIDTHS.map((width) => (
        <PlContainer key={width} maxWidth={width} padded={false}>
          <div className="rounded-(--plass-radius-sm) bg-(--plass-glass-press) px-3 py-2">
            <PlTypography level="caption">{width}</PlTypography>
          </div>
        </PlContainer>
      ))}
    </div>
  );
}
