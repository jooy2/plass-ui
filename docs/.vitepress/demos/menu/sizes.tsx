import { PlButton, PlMenu, PlMenuItem } from 'plass-ui';

export default function MenuSizes() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {(['sm', 'md', 'lg'] as const).map((size) => (
        <PlMenu
          key={size}
          size={size}
          trigger={
            <PlButton size={size} variant="glass">
              {size}
            </PlButton>
          }
        >
          <PlMenuItem shortcut="⌘X">Cut</PlMenuItem>
          <PlMenuItem shortcut="⌘C">Copy</PlMenuItem>
        </PlMenu>
      ))}
    </div>
  );
}
