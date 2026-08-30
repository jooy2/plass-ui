import { PlBox, PlMenubar, PlMenubarMenu, PlMenuItem } from 'plass-ui';

export default function MenubarOrientation() {
  return (
    <PlBox size="sm" className="w-44">
      <PlMenubar orientation="vertical" size="sm">
        <PlMenubarMenu label="File">
          <PlMenuItem>New</PlMenuItem>
          <PlMenuItem>Open…</PlMenuItem>
        </PlMenubarMenu>
        <PlMenubarMenu label="Edit">
          <PlMenuItem>Undo</PlMenuItem>
        </PlMenubarMenu>
        <PlMenubarMenu label="Help">
          <PlMenuItem>About</PlMenuItem>
        </PlMenubarMenu>
      </PlMenubar>
    </PlBox>
  );
}
