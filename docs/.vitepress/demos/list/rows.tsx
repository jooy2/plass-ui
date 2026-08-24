import { PlButton, PlList, PlListItem } from 'plass-ui';

function BellIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <path d="M18 8a6 6 0 1 0-12 0c0 6-2 7-2 7h16s-2-1-2-7" strokeLinejoin="round" />
      <path d="M13.7 20a2 2 0 0 1-3.4 0" strokeLinecap="round" />
    </svg>
  );
}

export default function ListRows() {
  return (
    <PlList className="w-full max-w-md" dividers>
      <PlListItem>Not pressable</PlListItem>
      <PlListItem onClick={() => {}}>A real button</PlListItem>
      <PlListItem href="#list">A real link</PlListItem>
      <PlListItem selected href="#list">
        The chosen one
      </PlListItem>
      <PlListItem disabled onClick={() => {}}>
        Unavailable
      </PlListItem>
      <PlListItem
        startIcon={<BellIcon />}
        description="Outside the pressable area, on purpose"
        onClick={() => {}}
        action={
          <PlButton size="xs" variant="ghost" color="secondary">
            Mute
          </PlButton>
        }
      >
        With an action
      </PlListItem>
    </PlList>
  );
}
