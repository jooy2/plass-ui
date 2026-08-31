import { PlVisuallyHidden } from 'plass-ui';

export default function VisuallyHiddenFocusable() {
  return (
    <div className="relative flex w-full flex-col gap-4 py-2">
      <PlVisuallyHidden focusable className="top-0 left-0">
        <a
          href="#demo-main"
          className="inline-block rounded-(--plass-radius-md) bg-(--plass-glass-press) px-3 py-1.5 text-sm font-medium"
        >
          Skip to content
        </a>
      </PlVisuallyHidden>

      <p id="demo-main" className="text-sm text-(--plass-muted-fg)">
        Press <kbd>Tab</kbd> with the focus just before this box: the skip link appears in the top
        corner, and disappears again the moment the focus moves on.
      </p>
    </div>
  );
}
