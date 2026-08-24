import { PlHotKeys } from 'plass-ui';

export default function HotKeysOs() {
  return (
    <div className="flex flex-col gap-3 text-(--plass-fg)">
      <p className="flex items-center gap-2">
        <span className="w-20 text-xs text-(--plass-muted-fg)">auto</span>
        <PlHotKeys keys="Mod+Shift+P" />
      </p>
      <p className="flex items-center gap-2">
        <span className="w-20 text-xs text-(--plass-muted-fg)">mac</span>
        <PlHotKeys keys="Mod+Shift+P" os="mac" />
      </p>
      <p className="flex items-center gap-2">
        <span className="w-20 text-xs text-(--plass-muted-fg)">windows</span>
        <PlHotKeys keys="Mod+Shift+P" os="windows" />
      </p>
      <p className="flex items-center gap-2">
        <span className="w-20 text-xs text-(--plass-muted-fg)">linux</span>
        <PlHotKeys keys="Mod+Shift+P" os="linux" />
      </p>
    </div>
  );
}
