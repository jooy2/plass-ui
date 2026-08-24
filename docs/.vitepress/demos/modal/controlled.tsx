import { useState } from 'react';
import { PlButton, PlModal } from 'plass-ui';

export default function ModalControlled() {
  const [open, setOpen] = useState(false);
  const [saved, setSaved] = useState(false);

  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlButton onClick={() => setOpen(true)}>Publish</PlButton>
      {saved ? (
        <span className="text-xs font-semibold text-(--plass-success-accent)">Published</span>
      ) : null}

      <PlModal
        open={open}
        onOpenChange={setOpen}
        size="sm"
        title="Publish this version?"
        description="Everyone on the team will see it."
        actions={
          <>
            <PlButton variant="ghost" color="secondary" onClick={() => setOpen(false)}>
              Not yet
            </PlButton>
            <PlButton
              onClick={() => {
                setSaved(true);
                setOpen(false);
              }}
            >
              Publish
            </PlButton>
          </>
        }
      />
    </div>
  );
}
