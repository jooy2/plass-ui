import { PlToggle, PlToggleGroup } from 'plass-ui';

function BoldGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M7 5h6a3.5 3.5 0 0 1 0 7H7zM7 12h7a3.5 3.5 0 0 1 0 7H7z" />
    </svg>
  );
}

function ItalicGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M14 5h-4M14 19h-4M15 5l-6 14" strokeLinecap="round" />
    </svg>
  );
}

function UnderlineGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M7 4v7a5 5 0 0 0 10 0V4M6 20h12" strokeLinecap="round" />
    </svg>
  );
}

export default function ToggleIcons() {
  return (
    <PlToggleGroup multiple variant="ghost" defaultValue={['bold']}>
      <PlToggle value="bold" aria-label="Bold" startIcon={<BoldGlyph />} />
      <PlToggle value="italic" aria-label="Italic" startIcon={<ItalicGlyph />} />
      <PlToggle value="underline" aria-label="Underline" startIcon={<UnderlineGlyph />} />
    </PlToggleGroup>
  );
}
