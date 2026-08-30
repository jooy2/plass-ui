import { useState } from 'react';
import {
  PlMenubar,
  PlMenubarMenu,
  PlMenuCheckboxItem,
  PlMenuItem,
  PlMenuSeparator,
  PlMenuSubmenu
} from 'plass-ui';

export default function MenubarRows() {
  const [grid, setGrid] = useState(true);
  const [rulers, setRulers] = useState(false);

  return (
    <PlMenubar>
      <PlMenubarMenu label="View">
        <PlMenuCheckboxItem checked={grid} onCheckedChange={setGrid}>
          Grid
        </PlMenuCheckboxItem>
        <PlMenuCheckboxItem checked={rulers} onCheckedChange={setRulers}>
          Rulers
        </PlMenuCheckboxItem>
        <PlMenuSeparator />
        <PlMenuSubmenu label="Appearance">
          <PlMenuItem>Light</PlMenuItem>
          <PlMenuItem>Dark</PlMenuItem>
          <PlMenuItem>System</PlMenuItem>
        </PlMenuSubmenu>
      </PlMenubarMenu>

      <PlMenubarMenu label="Help">
        <PlMenuItem href="#">Documentation</PlMenuItem>
        <PlMenuItem>About</PlMenuItem>
      </PlMenubarMenu>
    </PlMenubar>
  );
}
