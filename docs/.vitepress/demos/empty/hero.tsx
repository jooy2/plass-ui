import { PlButton, PlCard, PlEmpty } from 'plass-ui';

export default function EmptyHero() {
  return (
    <PlCard className="w-full max-w-md">
      <PlEmpty
        icon={
          <img
            src="/samples/illustrations/fox-reading-under-tree.webp"
            alt=""
            className="size-32 rounded-(--plass-radius-lg)"
          />
        }
        title="No projects yet"
        description="Start one and it will show up here, with everyone you invite to it."
        actions={<PlButton>New project</PlButton>}
      />
    </PlCard>
  );
}
