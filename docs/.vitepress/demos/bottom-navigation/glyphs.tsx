/**
 * The drawings the bottom-navigation demos use.
 *
 * A demo file, not a demo: `Demo.vue` only ever mounts the default export, and
 * this one has none — every file beside it imports the four glyphs from here so
 * that four demos of the same bar are not four copies of the same four paths.
 */
export function HomeGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <path d="M4 11 12 4l8 7v8a1 1 0 0 1-1 1h-4v-6H9v6H5a1 1 0 0 1-1-1z" />
    </svg>
  );
}

export function SearchGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <circle cx="11" cy="11" r="6" />
      <path d="m15.5 15.5 4 4" />
    </svg>
  );
}

export function SavedGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <path d="M7 4h10v16l-5-4-5 4z" />
    </svg>
  );
}

export function AccountGlyph() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
      <circle cx="12" cy="9" r="3.4" />
      <path d="M5 20a7 7 0 0 1 14 0" />
    </svg>
  );
}
