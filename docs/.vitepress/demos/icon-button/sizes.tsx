import { PlButton, PlIconButton } from 'plass-ui';

const Plus = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M12 5v14M5 12h14" />
  </svg>
);

export default function IconButtonSizes() {
  return (
    <div className="flex flex-col gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <div key={size} className="flex items-center gap-3">
          <PlIconButton size={size} icon={<Plus />} label={`Add (${size})`} />
          <PlButton size={size} variant="glass">
            {size}
          </PlButton>
        </div>
      ))}
    </div>
  );
}
