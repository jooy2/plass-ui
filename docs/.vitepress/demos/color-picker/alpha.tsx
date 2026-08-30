import { useState } from 'react';
import { PlColorPicker } from 'plass-ui';

export default function ColorPickerAlpha() {
  const [color, setColor] = useState('rgba(59, 130, 246, 0.5)');

  return (
    <div className="flex flex-col items-center gap-4">
      <PlColorPicker inline alpha format="rgb" value={color} onValueChange={setColor} />
      <div className="rounded-(--plass-radius-md) p-4" style={{ backgroundColor: color }}>
        <span className="text-sm">{color}</span>
      </div>
    </div>
  );
}
