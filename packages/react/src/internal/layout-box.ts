/**
 * An element's length along one axis as it is laid out, which is not always
 * the length it is drawn at.
 *
 * The two differ under a `transform` on an ancestor, a component inside a
 * scaled `PlMockup` for one. `getBoundingClientRect` measures the box on the
 * screen, which is the drawn size there, while a `width`, a `flex-basis`
 * percentage and a `scrollLeft` are all counted in the element's own pixels.
 * So the laid-out size is read off the computed style, which a transform does
 * not reach, and the box on the screen is kept for what is measured on the
 * screen: a pointer's movement, and the distance between two boxes.
 */
export interface LayoutBox {
  /**
   * The used `width` or `height`, which is the border box or the content box
   * as `box-sizing` says: the length a declaration of either sets.
   */
  size: number;
  /**
   * The content box, inside the padding and the border: what a child's
   * percentage is a percentage of.
   */
  content: number;
  /**
   * How many of the element's own pixels one pixel on the screen is. `1`
   * unless an ancestor scales it.
   */
  perPixel: number;
}

/**
 * Measures `element` across when `horizontal` and down otherwise. An element
 * that is not laid out, inside a closed `PlAccordion` for example, measures
 * nothing.
 */
export function layoutBox(element: HTMLElement, horizontal: boolean): LayoutBox {
  const rect = element.getBoundingClientRect();
  const drawn = horizontal ? rect.width : rect.height;

  if (!(drawn > 0)) {
    return { size: 0, content: 0, perPixel: 1 };
  }

  const style = getComputedStyle(element);
  const edges = (
    horizontal
      ? [
          style.paddingInlineStart,
          style.paddingInlineEnd,
          style.borderInlineStartWidth,
          style.borderInlineEndWidth
        ]
      : [
          style.paddingBlockStart,
          style.paddingBlockEnd,
          style.borderBlockStartWidth,
          style.borderBlockEndWidth
        ]
  ).reduce((total, edge) => total + (parseFloat(edge) || 0), 0);
  const size = parseFloat(horizontal ? style.width : style.height) || 0;
  const border = style.boxSizing === 'border-box' ? size : size + edges;

  return { size, content: border - edges, perPixel: border > 0 ? border / drawn : 1 };
}
