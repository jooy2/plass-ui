import { PlVisuallyHidden } from 'plass-ui';

export default function VisuallyHiddenHero() {
  return (
    <div className="flex flex-col items-center gap-4">
      <div className="flex gap-2">
        {[
          { glyph: '★', name: 'Add to favourites' },
          { glyph: '⌫', name: 'Delete' },
          { glyph: '✕', name: 'Close' }
        ].map((action) => (
          <button
            key={action.name}
            type="button"
            className="inline-flex size-10 items-center justify-center rounded-(--plass-radius-md) border bg-(--plass-glass) [border-color:var(--plass-border)]"
          >
            <span aria-hidden="true">{action.glyph}</span>
            <PlVisuallyHidden>{action.name}</PlVisuallyHidden>
          </button>
        ))}
      </div>

      <p className="text-center text-sm text-(--plass-muted-fg)">
        Three glyphs on the screen. Three sentences — “Add to favourites”, “Delete”, “Close” — in
        the accessibility tree.
      </p>
    </div>
  );
}
