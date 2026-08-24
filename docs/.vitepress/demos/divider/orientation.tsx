import { PlDivider } from 'plass-ui';

export default function DividerOrientation() {
  return (
    <div className="flex w-full max-w-md flex-col gap-6">
      <PlDivider />

      <div className="flex items-center gap-4 text-sm text-(--plass-fg)">
        <span>Cut</span>
        <PlDivider orientation="vertical" />
        <span>Copy</span>
        <PlDivider orientation="vertical" />
        <span>Paste</span>
      </div>
    </div>
  );
}
