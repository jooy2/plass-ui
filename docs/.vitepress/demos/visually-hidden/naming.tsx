import { PlVisuallyHidden } from 'plass-ui';

export default function VisuallyHiddenNaming() {
  return (
    <div className="flex flex-col gap-4 text-sm">
      <button
        type="button"
        className="inline-flex size-10 items-center justify-center rounded-(--plass-radius-md) border [border-color:var(--plass-border)]"
      >
        <span aria-hidden="true">★</span>
        <PlVisuallyHidden>Add to favourites</PlVisuallyHidden>
      </button>

      <p className="text-(--plass-muted-fg)">
        The button’s accessible name is “Add to favourites”, and the star is marked{' '}
        <code>aria-hidden</code> so it is not read as a second name.
      </p>
    </div>
  );
}
