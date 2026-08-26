import { PlContextMenu, PlMenuItem, PlMenuSeparator } from 'plass-ui';

export default function MenuContextDemo() {
  return (
    <PlContextMenu
      content={
        <>
          <PlMenuItem shortcut="⌘R">Rename</PlMenuItem>
          <PlMenuItem shortcut="⌘D">Duplicate</PlMenuItem>
          <PlMenuSeparator />
          <PlMenuItem color="danger">Delete</PlMenuItem>
        </>
      }
    >
      <div className="flex h-28 w-full max-w-sm items-center justify-center rounded-(--plass-radius-lg) border border-dashed border-(--plass-border) text-sm text-(--plass-muted-fg)">
        Right-click, or press and hold
      </div>
    </PlContextMenu>
  );
}
