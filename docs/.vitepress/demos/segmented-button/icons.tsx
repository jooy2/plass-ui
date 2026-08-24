import { PlSegment, PlSegmentedButton } from 'plass-ui';

function GridIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" aria-hidden="true">
      <rect x="2.5" y="2.5" width="4.5" height="4.5" rx="1" />
      <rect x="9" y="2.5" width="4.5" height="4.5" rx="1" />
      <rect x="2.5" y="9" width="4.5" height="4.5" rx="1" />
      <rect x="9" y="9" width="4.5" height="4.5" rx="1" />
    </svg>
  );
}

function ListIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" aria-hidden="true">
      <path d="M5 4h9M5 8h9M5 12h9M2.5 4h.01M2.5 8h.01M2.5 12h.01" strokeLinecap="round" />
    </svg>
  );
}

export default function SegmentedButtonIcons() {
  return (
    <PlSegmentedButton aria-label="Layout" defaultValue="grid">
      <PlSegment value="grid" startIcon={<GridIcon />}>
        Grid
      </PlSegment>
      <PlSegment value="list" startIcon={<ListIcon />} endIcon={<span>12</span>}>
        List
      </PlSegment>
    </PlSegmentedButton>
  );
}
