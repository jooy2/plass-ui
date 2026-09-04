import { PlAppLogo } from 'plass-ui';

/**
 * Artwork with its own background and its own margin — the case `bare` exists
 * for, and the case a plate or a circle would ruin.
 */
function Wordmark() {
  return (
    <svg viewBox="0 0 108 32" aria-hidden="true">
      <rect width="108" height="32" rx="6" fill="var(--plass-info-soft)" />
      <text
        x="54"
        y="21"
        textAnchor="middle"
        fill="var(--plass-fg)"
        fontSize="13"
        letterSpacing="2"
      >
        ACME CO
      </text>
    </svg>
  );
}

export default function AppLogoShapes() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      <PlAppLogo>
        <Wordmark />
      </PlAppLogo>

      <PlAppLogo shape="plate">
        <Wordmark />
      </PlAppLogo>
    </div>
  );
}
