import { PlMockup } from 'plass-ui';

const dawn = 'url(/samples/illustrations/layered-mountains-rising-sun.webp) center/cover';
const night = 'url(/samples/illustrations/night-train-floating-lanterns.webp) center/cover';

export default function MockupDevice() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-8">
      <PlMockup device="mobile" width={110} wallpaper={dawn} />
      <PlMockup device="tablet" width={170} wallpaper={night} />
      <PlMockup device="desktop" width={300} wallpaper={dawn} />
      <PlMockup device="desktop" hardware="laptop" os="windows" width={300} wallpaper={night} />
    </div>
  );
}
