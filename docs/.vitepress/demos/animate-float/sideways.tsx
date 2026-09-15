import { PlAnimateFloat } from 'plass-ui';

export default function AnimateFloatSideways() {
  return (
    <PlAnimateFloat orientation="horizontal" distance={16} duration={5000}>
      <div className="flex size-24 items-center justify-center rounded-[1.75rem] [background-image:var(--plass-secondary-fill)] text-3xl text-(--plass-secondary-on-solid)">
        ☁
      </div>
    </PlAnimateFloat>
  );
}
