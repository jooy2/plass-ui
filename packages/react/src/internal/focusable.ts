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
