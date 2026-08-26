import { useState } from 'react';
import {
  PlButton,
  PlMenu,
  PlMenuCheckboxItem,
  PlMenuGroup,
  PlMenuRadioGroup,
  PlMenuRadioItem,
  PlMenuSeparator
} from 'plass-ui';

export default function MenuSelection() {
  const [wrap, setWrap] = useState(true);
  const [minimap, setMinimap] = useState(false);
  const [layout, setLayout] = useState<string | number>('list');

  return (
    <PlMenu trigger={<PlButton variant="glass">View</PlButton>}>
      <PlMenuGroup label="Show">
        <PlMenuCheckboxItem checked={wrap} onCheckedChange={setWrap} shortcut="⌥Z">
          Word wrap
        </PlMenuCheckboxItem>
        <PlMenuCheckboxItem checked={minimap} onCheckedChange={setMinimap}>
          Minimap
        </PlMenuCheckboxItem>
      </PlMenuGroup>
      <PlMenuSeparator />
      <PlMenuGroup label="Layout">
        <PlMenuRadioGroup value={layout} onValueChange={setLayout}>
          <PlMenuRadioItem value="list">List</PlMenuRadioItem>
          <PlMenuRadioItem value="grid">Grid</PlMenuRadioItem>
          <PlMenuRadioItem value="columns">Columns</PlMenuRadioItem>
        </PlMenuRadioGroup>
      </PlMenuGroup>
    </PlMenu>
  );
}
