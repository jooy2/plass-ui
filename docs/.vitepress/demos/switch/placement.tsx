import { PlSwitch } from 'plass-ui';

const rows = [
  { label: 'Two-factor authentication', description: 'Required for owners.' },
  { label: 'Session alerts', description: 'Email me about new sign-ins.' },
  { label: 'Public profile', description: 'Anyone with the link can see it.' }
];

export default function SwitchPlacement() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      {rows.map((row) => (
        <PlSwitch
          key={row.label}
          className="w-full"
          labelPlacement="start"
          label={row.label}
          description={row.description}
          defaultChecked={row.label !== 'Public profile'}
        />
      ))}
    </div>
  );
}
