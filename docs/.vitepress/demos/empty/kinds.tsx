import { PlButton, PlCard, PlEmpty } from 'plass-ui';

export default function EmptyKinds() {
  return (
    <div className="grid w-full gap-4 md:grid-cols-3">
      <PlCard>
        <PlEmpty
          size="sm"
          icon={<span>🔍</span>}
          title="No results"
          description="Try fewer words."
        />
      </PlCard>

      <PlCard>
        <PlEmpty
          size="sm"
          color="danger"
          icon={<span>⚠️</span>}
          title="Could not load"
          description="The server did not answer."
          actions={
            <PlButton size="sm" color="danger" variant="glass">
              Try again
            </PlButton>
          }
        />
      </PlCard>

      <PlCard>
        <PlEmpty
          size="sm"
          color="success"
          icon={<span>✅</span>}
          title="All done"
          description="Your order is on its way."
        />
      </PlCard>
    </div>
  );
}
