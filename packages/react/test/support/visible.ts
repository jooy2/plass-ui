/**
 * Resolves once a `visible` trigger watching `target` has had its report on
 * whatever has just moved it or the view: a scroll, or a frame its own
 * animation was sent to.
 *
 * An observer made here with the steps the trigger's own observers use reports
 * in the same delivery as theirs, and a task later every callback of that
 * delivery has run. Only the reports are waited for: whatever they start is
 * rendered on React's schedule, which the test waits for on its own.
 */
export async function reported(target: Element): Promise<void> {
  await new Promise<void>((resolve) => {
    const observer = new IntersectionObserver(
      () => {
        observer.disconnect();
        resolve();
      },
      { threshold: Array.from({ length: 21 }, (_, step) => step / 20) }
    );

    observer.observe(target);
  });
  await new Promise((resolve) => setTimeout(resolve, 0));
}

/**
 * Scrolls `scroller` to `top`, and resolves once a `visible` trigger watching
 * `target` has had its report on what that did.
 */
export async function scrollAndReport(
  scroller: HTMLElement,
  top: number,
  target: Element
): Promise<void> {
  scroller.scrollTop = top;

  await reported(target);
}
