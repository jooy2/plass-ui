import { PlButton, PlSegment, PlSegmentedButton, PlToolbar, PlTypography } from 'plass-ui';

export default function ToolbarSlots() {
  return (
    <PlToolbar
      className="w-full max-w-lg"
      divider
      start={<PlTypography level="h6">Invoices</PlTypography>}
      end={<PlButton size="sm">Export</PlButton>}
    >
      <PlSegmentedButton size="sm" defaultValue="all">
        <PlSegment value="all">All</PlSegment>
        <PlSegment value="open">Open</PlSegment>
        <PlSegment value="paid">Paid</PlSegment>
      </PlSegmentedButton>
    </PlToolbar>
  );
}
