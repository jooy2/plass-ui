import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

export default function TabsOrientation() {
  return (
    <PlTabs orientation="vertical" defaultValue="general" className="w-full max-w-lg">
      <PlTab value="general">General</PlTab>
      <PlTab value="security">Security</PlTab>
      <PlTab value="webhooks">Webhooks</PlTab>

      <PlTabPanel value="general">The name of the project and who owns it.</PlTabPanel>
      <PlTabPanel value="security">Two-factor authentication and session alerts.</PlTabPanel>
      <PlTabPanel value="webhooks">Point a URL at an event and we will POST to it.</PlTabPanel>
    </PlTabs>
  );
}
