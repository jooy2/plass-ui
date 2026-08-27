import { PlProgressBox } from 'plass-ui';

export default function ProgressBoxHero() {
  return (
    <div className="flex flex-col items-start gap-6">
      <PlProgressBox label="Step 3 of 5" value={3} max={5} count={5} showValue />
      <PlProgressBox label="Compiling" />
    </div>
  );
}
