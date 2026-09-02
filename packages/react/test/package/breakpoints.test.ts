/**
 * That the breakpoint ladder is written down **once**.
 *
 * Like `tokens.test.ts` this is a test of the package rather than of a
 * component, and it exists because the failure it guards is invisible: a page
 * whose `md:` utilities change at one width and whose `PlGrid` changes at
 * another still renders, still passes every component test, and is simply wrong
 * on a laptop.
 *
 * The arrangement it holds in place is in `src/styles.css` under "The
 * breakpoint ladder". A media query's *condition* cannot read a custom
 * property, so the CSS half resolves Tailwind's theme at build time through
 * `@variant` — and the moment somebody writes `@media (width >= 48rem)` out by
 * hand instead, that block stops following the theme while everything around it
 * keeps doing so. Measured: `@theme { --breakpoint-md: 50rem }` moves a
 * `@variant md` block to 50rem and leaves a hand-written one at 48.
 */
import { describe, expect, it } from 'vitest';
import styles from '../../src/styles.css?raw';
import breakpoints from '../../src/internal/breakpoints.ts?raw';

/** The four widths Tailwind's own theme starts at. */
const widths = ['40rem', '48rem', '64rem', '80rem'];

describe('the breakpoint ladder', () => {
  it('leaves every width to the Tailwind theme rather than writing one out', () => {
    const hardcoded = widths.filter((width) =>
      new RegExp(`@media[^{]*${width.replace('.', '\\.')}`).test(styles)
    );

    expect(hardcoded).toEqual([]);
  });

  it('changes shape at a breakpoint through `@variant`, so the theme decides', () => {
    for (const rung of ['sm', 'md', 'lg', 'xl']) {
      expect(styles).toContain(`@variant ${rung} {`);
    }
  });

  it('publishes each width as a token, for the half that reads a value', () => {
    // The JavaScript half asks `matchMedia`, where a breakpoint is a value
    // rather than a condition — so it can read the same answer off the
    // document, which is what keeps the two halves from drifting.
    for (const rung of ['sm', 'md', 'lg', 'xl']) {
      expect(styles).toContain(`--plass-breakpoint-${rung}: var(--breakpoint-${rung},`);
    }
  });

  it('keeps a fallback that matches the theme it is falling back from', () => {
    // Read before the stylesheet has resolved anything — every server render,
    // and the first client render of a page whose CSS has not arrived.
    for (const [rung, width] of [
      ['sm', '40rem'],
      ['md', '48rem'],
      ['lg', '64rem'],
      ['xl', '80rem']
    ]) {
      expect(styles).toContain(`--plass-breakpoint-${rung}: var(--breakpoint-${rung}, ${width})`);
      expect(breakpoints).toContain(`${rung}: '${width}'`);
    }
  });
});
