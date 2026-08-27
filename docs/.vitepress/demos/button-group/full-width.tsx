import { PlButton, PlButtonGroup } from 'plass-ui';

export default function ButtonGroupFullWidth() {
  return (
    <PlButtonGroup fullWidth variant="glass" color="secondary" className="max-w-sm">
      <PlButton>Deny</PlButton>
      <PlButton>Ask</PlButton>
      <PlButton>Allow</PlButton>
    </PlButtonGroup>
  );
}
