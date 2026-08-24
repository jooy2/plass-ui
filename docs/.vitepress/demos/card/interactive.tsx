import { PlCard } from 'plass-ui';

const plans = [
  { name: 'Starter', blurb: 'One project, one seat.' },
  { name: 'Team', blurb: 'Shared projects and audit logs.' }
];

export default function CardInteractive() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-2">
      {plans.map((plan) => (
        <PlCard
          key={plan.name}
          interactive
          size="sm"
          title={plan.name}
          render={<a href="#interactive" />}
        >
          {plan.blurb}
        </PlCard>
      ))}
    </div>
  );
}
