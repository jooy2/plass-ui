import { PlMenubar, PlMenubarMenu, PlMenuItem, PlMenuSeparator, PlToolbar } from 'plass-ui';

export default function MenubarHero() {
  return (
    <PlToolbar className="w-full" size="sm" density="compact">
      <PlMenubar>
        <PlMenubarMenu label="File">
          <PlMenuItem shortcut="Mod+N">New</PlMenuItem>
          <PlMenuItem shortcut="Mod+O">Open…</PlMenuItem>
          <PlMenuSeparator />
          <PlMenuItem shortcut="Mod+S">Save</PlMenuItem>
        </PlMenubarMenu>

        <PlMenubarMenu label="Edit">
          <PlMenuItem shortcut="Mod+Z">Undo</PlMenuItem>
          <PlMenuItem shortcut="Mod+Shift+Z">Redo</PlMenuItem>
          <PlMenuSeparator />
          <PlMenuItem shortcut="Mod+X">Cut</PlMenuItem>
          <PlMenuItem shortcut="Mod+C">Copy</PlMenuItem>
        </PlMenubarMenu>

        <PlMenubarMenu label="View">
          <PlMenuItem>Zoom in</PlMenuItem>
          <PlMenuItem>Zoom out</PlMenuItem>
          <PlMenuItem disabled>Enter full screen</PlMenuItem>
        </PlMenubarMenu>
      </PlMenubar>
    </PlToolbar>
  );
}
