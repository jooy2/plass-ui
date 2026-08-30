import { useState } from 'react';
import { PlToggle } from 'plass-ui';

export default function ToggleHero() {
  const [bold, setBold] = useState(true);
  const [italic, setItalic] = useState(false);

  return (
    <div className="flex flex-col items-center gap-4">
      <div className="flex gap-2">
        <PlToggle pressed={bold} onPressedChange={setBold}>
          Bold
        </PlToggle>
        <PlToggle pressed={italic} onPressedChange={setItalic}>
          Italic
        </PlToggle>
      </div>
      <p
        className="text-sm"
        style={{
          fontWeight: bold ? 700 : 400,
          fontStyle: italic ? 'italic' : 'normal'
        }}
      >
        The toggle changes the state of the thing beside it.
      </p>
    </div>
  );
}
