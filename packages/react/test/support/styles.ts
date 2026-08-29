/**
 * `transform-origin` as the component set it, not as an engine writes it back.
 *
 * CSSOM serialises the property per engine, and the three browsers in the test
 * matrix do not agree: Firefox writes the z component out, so a component that
 * sets `center` reads back as `center center 0px` there and `center center` in
 * Chromium and WebKit. Nothing in the library sets a z offset — reading the
 * origin through this keeps these tests about which point a component turns
 * about rather than about how a browser spells it.
 */
export function transformOrigin(element: HTMLElement): string {
  return element.style.transformOrigin.replace(/ 0px$/, '');
}
