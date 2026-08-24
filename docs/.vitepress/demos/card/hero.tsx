import { PlButton, PlCard } from 'plass-ui';

export default function CardHero() {
  return (
    <PlCard
      className="w-full max-w-sm"
      title="Team plan"
      subtitle="Billed yearly"
      headerAction={
        <span className="text-xs font-semibold text-(--plass-primary-accent)">Current</span>
      }
      footer={
        <>
          <PlButton size="sm">Upgrade</PlButton>
          <PlButton size="sm" variant="ghost" color="secondary">
            Compare plans
          </PlButton>
        </>
      }
    >
      Everything in Pro, plus shared projects, audit logs and a seat for anyone you invite.
    </PlCard>
  );
}
