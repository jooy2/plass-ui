import { PlContainer, PlTypography } from 'plass-ui';

export default function ContainerCentered() {
  return (
    <div className="flex w-full flex-col gap-4">
      {[true, false].map((centered) => (
        <div key={String(centered)} className="flex flex-col gap-1">
          <PlTypography level="caption">centered={String(centered)}</PlTypography>
          <div className="rounded-(--plass-radius-md) bg-(--plass-glass-press) py-2">
            <PlContainer maxWidth="xs" centered={centered}>
              <div className="rounded-(--plass-radius-sm) bg-(--plass-glass) py-2 text-center text-sm">
                30rem of content
              </div>
            </PlContainer>
          </div>
        </div>
      ))}
    </div>
  );
}
