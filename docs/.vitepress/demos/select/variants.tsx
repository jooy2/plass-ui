import { PlSelect } from 'plass-ui';

const plans = [
  { value: 'starter', label: 'Starter' },
  { value: 'team', label: 'Team' },
  { value: 'enterprise', label: 'Enterprise' }
];

export default function SelectVariants() {
  return (
    <div className="flex flex-wrap items-start gap-3">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlSelect key={variant} variant={variant} items={plans} defaultValue="team" />
      ))}
    </div>
  );
}
