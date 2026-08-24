import { PlHotKeys } from 'plass-ui';

export default function HotKeysVariants() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlHotKeys key={variant} variant={variant} keys="Mod+K" />
      ))}
    </div>
  );
}
