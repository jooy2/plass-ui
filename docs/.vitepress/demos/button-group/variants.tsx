import { PlButton, PlButtonGroup } from 'plass-ui';

export default function ButtonGroupVariants() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      <PlButtonGroup variant="solid">
        <PlButton>Cut</PlButton>
        <PlButton>Copy</PlButton>
        <PlButton>Paste</PlButton>
      </PlButtonGroup>

      <PlButtonGroup variant="glass" color="secondary">
        <PlButton>Cut</PlButton>
        <PlButton>Copy</PlButton>
        <PlButton>Paste</PlButton>
      </PlButtonGroup>

      <PlButtonGroup variant="ghost" color="secondary">
        <PlButton>Cut</PlButton>
        <PlButton>Copy</PlButton>
        <PlButton>Paste</PlButton>
      </PlButtonGroup>
    </div>
  );
}
