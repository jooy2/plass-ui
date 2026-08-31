/**
 * Pressing a key at an element, the way a component actually hears one.
 *
 * A real DOM `keydown` that **bubbles**, because React listens at the root of
 * the tree rather than on the element: an event dispatched without `bubbles`
 * reaches no handler at all, and the test passes for the wrong reason by
 * failing to fire anything. `cancelable`, because half of what these tests
 * assert is that the component consumed the key.
 *
 * There is deliberately nothing about platforms in here. `Mod` is ⌘ on a Mac
 * and Ctrl everywhere else and the matrix runs on all three, so a test that
 * pressed "the Mod key" would be a test about its runner. The `hotKeys` tests
 * press ⌘ and Ctrl in turn and assert that **exactly one** of them counted,
 * which is the real invariant and is true on every platform.
 */
export function press(element: Element, key: string, modifiers: KeyboardEventInit = {}): void {
  element.dispatchEvent(
    new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true, ...modifiers })
  );
}
