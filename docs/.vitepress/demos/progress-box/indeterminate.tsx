import { PlProgressBox } from 'plass-ui';

export default function ProgressBoxIndeterminate() {
  return (
    <div className="flex flex-col items-start gap-6">
      <PlProgressBox label="Known" value={45} showValue />
      <PlProgressBox label="Unknown" />
    </div>
  );
}
