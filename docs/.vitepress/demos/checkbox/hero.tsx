import { PlCheckbox } from 'plass-ui';

export default function CheckboxHero() {
  return (
    <div className="flex flex-col gap-3">
      <PlCheckbox label="Email me about releases" defaultChecked />
      <PlCheckbox label="Email me about outages" description="At most once a week." />
      <PlCheckbox label="Email me about everything else" disabled />
    </div>
  );
}
