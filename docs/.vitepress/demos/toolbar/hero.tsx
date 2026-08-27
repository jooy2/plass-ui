import { PlAvatar, PlButton, PlIconButton, PlToolbar, PlTypography } from 'plass-ui';

function SearchGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" className="size-4">
      <circle cx="11" cy="11" r="6" />
      <path d="m20 20-4.5-4.5" strokeLinecap="round" />
    </svg>
  );
}

export default function ToolbarHero() {
  return (
    <PlToolbar
      className="w-full max-w-lg"
      render={<header />}
      start={<PlTypography level="h6">Reports</PlTypography>}
      end={
        <>
          <PlIconButton variant="ghost" color="secondary" label="Search" icon={<SearchGlyph />} />
          <PlButton>New</PlButton>
          <PlAvatar size="sm" name="Ada Lovelace" />
        </>
      }
    />
  );
}
