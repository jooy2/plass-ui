import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

export default function TabsHero() {
  return (
    <PlTabs defaultValue="account" className="w-full max-w-lg">
      <PlTab value="account">Account</PlTab>
      <PlTab value="billing">Billing</PlTab>
      <PlTab value="team" endIcon={<span className="tabular-nums">4</span>}>
        Team
      </PlTab>

      <PlTabPanel value="account">Your name, your avatar and the language you read in.</PlTabPanel>
      <PlTabPanel value="billing">Cards, invoices and the plan you are on.</PlTabPanel>
      <PlTabPanel value="team">Four people, and what each of them can do.</PlTabPanel>
    </PlTabs>
  );
}
