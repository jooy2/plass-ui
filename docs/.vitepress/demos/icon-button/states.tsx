import { PlIconButton } from 'plass-ui';

const Save = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M5 4h11l3 3v13H5zM8 4v6h8V4M8 20v-6h8v6" />
  </svg>
);

export default function IconButtonStates() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlIconButton icon={<Save />} label="Save" />
      <PlIconButton icon={<Save />} label="Saving" loading />
      <PlIconButton icon={<Save />} label="Saved" readOnly />
      <PlIconButton icon={<Save />} label="Unavailable" disabled />
    </div>
  );
}
