import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

export default function TabsAlign() {
  return (
    <PlTabs orientation="vertical" align="start" defaultValue="general" className="w-full max-w-lg">
      <PlTab value="general">General</PlTab>
      <PlTab value="security">Security</PlTab>
      <PlTab value="notifications">Notifications</PlTab>

      <PlTabPanel value="general">The name of the project and who owns it.</PlTabPanel>
      <PlTabPanel value="security">Two-factor authentication and session alerts.</PlTabPanel>
      <PlTabPanel value="notifications">Which events reach you, and where.</PlTabPanel>
    </PlTabs>
  );
}
