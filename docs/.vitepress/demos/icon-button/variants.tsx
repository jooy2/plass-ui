import { PlIconButton } from 'plass-ui';

const Plus = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M12 5v14M5 12h14" />
  </svg>
);

export default function IconButtonVariants() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlIconButton key={variant} variant={variant} icon={<Plus />} label={`Add (${variant})`} />
      ))}
    </div>
  );
}
