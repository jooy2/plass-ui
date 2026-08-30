import { useState } from 'react';
import { PlColorPicker } from 'plass-ui';

export default function ColorPickerHero() {
  const [color, setColor] = useState('#1a58d1');

  return (
    <div className="flex flex-col items-center gap-4">
      <PlColorPicker label="Project colour" value={color} onValueChange={setColor} clearable />
      <div
        className="h-10 w-40 rounded-(--plass-radius-md)"
        style={{ backgroundColor: color || 'transparent' }}
      />
    </div>
  );
}
