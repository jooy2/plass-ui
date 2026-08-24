import { PlSlider } from 'plass-ui';

export default function SliderSteps() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      <PlSlider label="Continuous" defaultValue={40} showValue />
      <PlSlider label="In tens" defaultValue={40} step={10} showValue />
      <PlSlider
        label="1 to 5"
        defaultValue={3}
        min={1}
        max={5}
        step={1}
        showValue
        description="Every step is a whole number, so the thumb snaps."
      />
    </div>
  );
}
