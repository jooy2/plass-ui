import { useState } from 'react';
import { PlAnimateFade, PlBox, PlSwitch } from 'plass-ui';

export default function AnimateFadeTriggers() {
  const [play, setPlay] = useState(false);

  return (
    <div className="flex flex-col items-center gap-4">
      <div className="flex flex-wrap items-center justify-center gap-4">
        <PlAnimateFade trigger="hover" duration={400}>
          <PlBox size="sm">Hover me</PlBox>
        </PlAnimateFade>

        <PlAnimateFade trigger="visible" duration={600}>
          <PlBox size="sm">On scrolling into view</PlBox>
        </PlAnimateFade>
      </div>

      <PlSwitch size="sm" checked={play} onCheckedChange={setPlay} label="Play the manual one" />

      <PlAnimateFade trigger="manual" play={play} duration={500}>
        <PlBox size="sm">Driven by the switch</PlBox>
      </PlAnimateFade>
    </div>
  );
}
