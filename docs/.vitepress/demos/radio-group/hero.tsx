import { PlRadio, PlRadioGroup } from 'plass-ui';

export default function RadioGroupHero() {
  return (
    <PlRadioGroup label="Plan" defaultValue="team" description="Change it whenever you like.">
      <PlRadio value="starter" label="Starter" description="One project, one seat." />
      <PlRadio value="team" label="Team" description="Shared projects and audit logs." />
      <PlRadio value="enterprise" label="Enterprise" description="SSO and a contract." />
    </PlRadioGroup>
  );
}
