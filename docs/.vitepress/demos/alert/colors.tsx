import { PlAlert } from 'plass-ui';

const lines = {
  info: 'Maintenance is scheduled for Sunday.',
  success: 'The invoice was paid.',
  warning: 'Your card expires next month.',
  danger: 'The webhook has failed 12 times.'
} as const;

export default function AlertColors() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      {(Object.keys(lines) as (keyof typeof lines)[]).map((color) => (
        <PlAlert key={color} color={color}>
          {lines[color]}
        </PlAlert>
      ))}
    </div>
  );
}
