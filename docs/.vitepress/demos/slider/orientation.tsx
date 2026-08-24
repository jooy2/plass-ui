import { PlSlider } from 'plass-ui';

export default function SliderOrientation() {
  return (
    <div className="flex items-end gap-8">
      <PlSlider orientation="vertical" defaultValue={30} aria-label="Bass" />
      <PlSlider orientation="vertical" defaultValue={65} aria-label="Mid" />
      <PlSlider orientation="vertical" defaultValue={48} aria-label="Treble" />
    </div>
  );
}
