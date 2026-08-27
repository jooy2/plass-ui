import { PlBox, PlTypography } from 'plass-ui';

export default function BoxPadded() {
  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      <PlBox>
        <PlTypography level="body">padded — the default</PlTypography>
      </PlBox>

      <PlBox padded={false} className="overflow-hidden">
        <div className="bg-(--plass-primary-soft) px-5 py-6 text-center text-sm">
          padded={'{false}'} — the content reaches the edges
        </div>
      </PlBox>
    </div>
  );
}
