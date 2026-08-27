import { PlProgressBox } from 'plass-ui';

export default function ProgressBoxCount() {
  return (
    <div className="flex flex-col items-start gap-6">
      <PlProgressBox label="Four plates, 30%" value={30} showValue />
      <PlProgressBox label="Five steps, on the third" value={3} max={5} count={5} showValue />
      <PlProgressBox label="Twelve plates" value={30} count={12} showValue />
    </div>
  );
}
