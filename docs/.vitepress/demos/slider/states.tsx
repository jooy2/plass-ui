import { PlSlider } from 'plass-ui';

export default function SliderStates() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      <PlSlider label="Default" defaultValue={45} showValue />
      <PlSlider label="Disabled" defaultValue={45} showValue disabled />
    </div>
  );
}
