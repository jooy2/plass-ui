import { PlHotKeys } from 'plass-ui';

export default function HotKeysSizes() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlHotKeys key={size} size={size} keys="Mod+K" />
      ))}
    </div>
  );
}
