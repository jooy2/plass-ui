import { PlFieldset, PlTextField } from 'plass-ui';

export default function FieldsetHero() {
  return (
    <PlFieldset
      className="w-full max-w-sm"
      legend="Billing address"
      description="Where the invoice goes."
    >
      <PlTextField label="Street" fullWidth />
      <PlTextField label="City" fullWidth />
      <PlTextField label="Postcode" fullWidth />
    </PlFieldset>
  );
}
