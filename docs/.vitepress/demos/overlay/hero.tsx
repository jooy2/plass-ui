import { useState } from 'react';
import { PlButton, PlOverlay, PlTypography } from 'plass-ui';

function Spinner() {
  return (
    <svg viewBox="0 0 16 16" fill="none" className="size-8 animate-spin" aria-hidden="true">
      <circle cx="8" cy="8" r="6.5" stroke="currentColor" strokeOpacity="0.25" strokeWidth="2" />
      <path
        d="M14.5 8A6.5 6.5 0 0 0 8 1.5"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  );
}

export default function OverlayHero() {
  const [open, setOpen] = useState(false);

  function save() {
    setOpen(true);
    window.setTimeout(() => setOpen(false), 1800);
  }

  return (
    <>
      <PlButton onClick={save}>Save and wait</PlButton>

      <PlOverlay open={open} label="Saving your changes">
        <div className="flex flex-col items-center gap-3 text-(--p-accent)">
          <Spinner />
          <PlTypography color="primary" weight="medium">
            Saving your changes…
          </PlTypography>
        </div>
      </PlOverlay>
    </>
  );
}
