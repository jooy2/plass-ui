import { PlAspectRatio } from 'plass-ui';

const RATIOS = ['1 / 1', '4 / 3', '16 / 9', '21 / 9'];

export default function AspectRatioRatios() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 gap-4 sm:grid-cols-4">
      {RATIOS.map((ratio) => (
        <div key={ratio} className="flex flex-col gap-2">
          <PlAspectRatio ratio={ratio} rounded>
            <div className="flex size-full items-center justify-center bg-(--plass-glass-press) text-xs">
              {ratio}
            </div>
          </PlAspectRatio>
        </div>
      ))}
    </div>
  );
}
