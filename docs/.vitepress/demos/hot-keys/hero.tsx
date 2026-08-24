import { PlHotKeys } from 'plass-ui';

export default function HotKeysHero() {
  return (
    <div className="flex flex-col gap-3 text-(--plass-fg)">
      <p className="flex items-center gap-2">
        Open the palette with <PlHotKeys keys="Mod+K" />
      </p>
      <p className="flex items-center gap-2">
        Save with <PlHotKeys keys="Mod+S" /> and undo with <PlHotKeys keys="Mod+Z" />
      </p>
    </div>
  );
}
