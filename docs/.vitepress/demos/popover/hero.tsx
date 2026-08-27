import { PlButton, PlPopover, PlTextLink } from 'plass-ui';

export default function PopoverHero() {
  return (
    <PlPopover
      trigger={<PlButton variant="glass">How is this worked out?</PlButton>}
      title="Effective rate"
      description="Updated hourly"
    >
      Your rate is the base rate plus whatever your plan adds to it.{' '}
      <PlTextLink href="#">The full breakdown</PlTextLink> is on the billing page.
    </PlPopover>
  );
}
