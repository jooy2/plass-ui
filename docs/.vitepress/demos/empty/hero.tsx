import { PlButton, PlCard, PlEmpty } from 'plass-ui';

export default function EmptyHero() {
  return (
    <PlCard className="w-full max-w-md">
      <PlEmpty
        icon={<InboxIcon />}
        title="No projects yet"
        description="Start one and it will show up here, with everyone you invite to it."
        actions={<PlButton>New project</PlButton>}
      />
    </PlCard>
  );
}

function InboxIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
      <path
        d="M3 13h4l1.5 3h7L17 13h4M3 13l2-7h14l2 7v5a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-5Z"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
