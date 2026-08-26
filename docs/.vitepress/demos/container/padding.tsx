import { PlContainer, PlTypography } from 'plass-ui';

export default function ContainerPadding() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['default', 'compact'] as const).map((density) => (
        <div key={density} className="flex flex-col gap-1">
          <PlTypography level="caption">{density}</PlTypography>
          <div className="rounded-(--plass-radius-md) bg-(--plass-glass-press)">
            <PlContainer density={density}>
              <div className="rounded-(--plass-radius-sm) bg-(--plass-glass) py-2 text-center text-sm">
                the gutter is outside this
              </div>
            </PlContainer>
          </div>
        </div>
      ))}
    </div>
  );
}
