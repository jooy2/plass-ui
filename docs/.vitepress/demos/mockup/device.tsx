import { PlMockup } from 'plass-ui';

export default function MockupDevice() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-8">
      <PlMockup device="mobile" width={110} />
      <PlMockup device="tablet" width={170} />
      <PlMockup device="desktop" width={300} />
      <PlMockup device="desktop" hardware="laptop" os="windows" width={300} />
    </div>
  );
}
