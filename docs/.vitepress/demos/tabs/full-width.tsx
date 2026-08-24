import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

export default function TabsFullWidth() {
  return (
    <PlTabs fullWidth variant="solid" defaultValue="open" className="w-full max-w-lg">
      <PlTab value="open">Open</PlTab>
      <PlTab value="paid">Paid</PlTab>
      <PlTab value="void">Void</PlTab>

      <PlTabPanel value="open">Three invoices are waiting.</PlTabPanel>
      <PlTabPanel value="paid">Everything else has cleared.</PlTabPanel>
      <PlTabPanel value="void">Nothing has been voided this year.</PlTabPanel>
    </PlTabs>
  );
}
