import { PlButton, PlButtonGroup } from 'plass-ui';

export default function ButtonGroupHero() {
  return (
    <PlButtonGroup variant="glass" color="secondary">
      <PlButton>Day</PlButton>
      <PlButton>Week</PlButton>
      <PlButton>Month</PlButton>
    </PlButtonGroup>
  );
}
