import { PlButton, PlCard } from 'plass-ui';

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
          // What the link's `::after` is stretched over.
          className="relative"
          title={
            <a
              href="#interactive"
              className="text-inherit no-underline after:absolute after:inset-0 after:rounded-(--plass-radius-sm) focus-visible:outline-none focus-visible:after:[outline:2px_solid_var(--p-ring)]"
            >
              {plan.name}
            </a>
          }
          footer={
            // Above the link's cover, so it takes its own press.
            <PlButton size="xs" variant="ghost" className="relative z-10">
              Compare
            </PlButton>
          }
        >
          {plan.blurb}
        </PlCard>
      ))}
    </div>
  );
}
