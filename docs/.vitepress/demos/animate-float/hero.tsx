import { PlAnimateFloat } from 'plass-ui';

export default function AnimateFloatHero() {
  return (
    <PlAnimateFloat>
      <div className="flex size-24 items-center justify-center rounded-[1.75rem] [background-image:var(--plass-primary-fill)] text-3xl text-(--plass-primary-on-solid)">
        ☁
      </div>
    </PlAnimateFloat>
  );
}
