import { PlButton, PlCard } from 'plass-ui';

export default function CardSlots() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-2">
      <PlCard title="Title only">The body sits under it.</PlCard>

      <PlCard title="With a subtitle" subtitle="One step down, and muted">
        The two are one block of text, so the gap between them is tight.
      </PlCard>

      <PlCard
        title="With a header action"
        headerAction={
          <PlButton size="xs" variant="ghost" color="secondary" aria-label="More">
            •••
          </PlButton>
        }
      >
        The action stays on the title's line while the title wraps beside it.
      </PlCard>

      <PlCard
        title="With a footer"
        footer={
          <>
            <PlButton size="sm">Save</PlButton>
            <PlButton size="sm" variant="ghost" color="secondary">
              Cancel
            </PlButton>
          </>
        }
      >
        A wrapping row, so a pair of buttons needs no wrapper of its own.
      </PlCard>
    </div>
  );
}
