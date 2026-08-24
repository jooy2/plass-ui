import { useState } from 'react';
import { PlSlider } from 'plass-ui';

export default function SliderHero() {
  const [volume, setVolume] = useState(62);

  return (
    <PlSlider
      className="max-w-sm"
      label="Volume"
      showValue={(formatted) => `${formatted[0]}%`}
      value={volume}
      onValueChange={(next) => setVolume(next as number)}
    />
  );
}
