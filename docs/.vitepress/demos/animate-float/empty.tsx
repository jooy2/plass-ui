import { PlAnimateFloat, PlButton, PlCard, PlEmpty } from 'plass-ui';

export default function AnimateFloatEmpty() {
  return (
    <PlCard className="w-full max-w-md">
      <PlEmpty
        icon={
          <PlAnimateFloat>
            <span>🗂️</span>
          </PlAnimateFloat>
        }
        title="No projects yet"
        description="Start one and it will show up here, with everyone you invite to it."
        actions={<PlButton>New project</PlButton>}
      />
    </PlCard>
  );
}
