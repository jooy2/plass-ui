/**
 * What a keyboard can reach, as one selector.
 *
 * Written out rather than worked out from `tabIndex`, which reads `0` on things
 * a browser will not actually focus and `-1` on a plain `div`.
 */
const FOCUSABLE =
  'a[href], button:not([disabled]), input:not([disabled]):not([type="hidden"]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])';

/**
 * Every element under `root` that the Tab key could land on, in document order.
 *
 * Anything inside an `inert` subtree is left out: it matches the selector and
 * a browser still refuses to focus it, so handing the focus to one is handing
 * it to the top of the document.
 */
export function focusablesIn(root: ParentNode): HTMLElement[] {
  return Array.from(root.querySelectorAll<HTMLElement>(FOCUSABLE)).filter(
    (element) => !element.closest('[inert]')
  );
}

/**
 * Whether a press on `target`, inside a field's `shell`, is one the browser
 * should be left to answer: a press on the field's own `control`, where it
 * places the caret or starts a selection, or on something in the shell that
 * takes a press of its own, a button or a link in an adornment.
 *
 * Anything else in the shell, its padding or a drawn adornment, is part of the
 * field, and a press there keeps the focus in the control.
 */
export function ownsPress(
  target: EventTarget | null,
  shell: Element,
  control: Element | null
): boolean {
  if (!(target instanceof Element)) {
    return true;
  }

  if (control !== null && control.contains(target)) {
    return true;
  }

  const owner = target.closest(
    'a[href], button, input, select, textarea, [tabindex], [role="button"]'
  );

  // Looked for inside the shell only: a shell inside something focusable is
  // still the field's.
  return owner !== null && owner !== shell && shell.contains(owner);
}
