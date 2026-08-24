import { PlAlert, PlButton } from 'plass-ui';

export default function AlertHero() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <PlAlert color="success">Your changes are live.</PlAlert>
      <PlAlert
        color="danger"
        title="The deploy failed"
        action={
          <PlButton size="xs" variant="ghost" color="danger">
            Retry
          </PlButton>
        }
      >
        Two of the health checks never came back.
      </PlAlert>
    </div>
  );
}
