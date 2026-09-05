import { PlAppLogo } from 'plass-ui';

/** A stand-in for a product's own artwork: a bare glyph, the case a plate exists for. */
function Glyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <path d="M4 20 12 4l8 16" stroke="currentColor" strokeWidth="2.4" strokeLinejoin="round" />
    </svg>
  );
}

export default function AppLogoHero() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      <PlAppLogo shape="plate" name="Acme">
        <Glyph />
      </PlAppLogo>

      <PlAppLogo shape="circle" variant="glass" name="Acme" description="Staging">
        <Glyph />
      </PlAppLogo>

      {/* Finished artwork — its own colours, its own margin — so it is left bare. */}
      <PlAppLogo name="Acme" src="/samples/marks/lantern.webp" />
    </div>
  );
}
