/**
 * Emulates a media feature, and resolves once the page's own media query lists
 * have caught up with it.
 *
 * `commands.emulateMedia` resolves once the browser holds the new value, but
 * WebKit hands that value to a `MediaQueryList` that already exists only on its
 * next frame: straight after the call, a list made before it still reports the
 * old `matches` while a list made after it reports the new one. The library
 * keeps one list per query and reads it while rendering, so a component rendered
 * straight after the call reads the old answer, and a `PlAnimateMarquee` became
 * a tab stop for a frame after reduced motion was switched off. Chromium and
 * Firefox update every list at once, so there this resolves as soon as the call
 * does.
 *
 * A list for each query the library asks is made before the call, and this
 * waits until every one of them agrees with a list made afterwards. It waits on
 * timers rather than on animation frames, because a test may be holding the
 * frame clock.
 */
import { cdp, commands } from 'vitest/browser';

type Features = Parameters<typeof commands.emulateMedia>[0];

/** The queries the library reads through `matchMedia`, and forced colours. */
const watched = [
  '(prefers-reduced-motion: reduce)',
  '(prefers-color-scheme: dark)',
  '(forced-colors: active)'
];

/** Long enough for a slow runner's next frame, short enough to name the failure. */
const patience = 2000;

export async function emulateMedia(features: Features): Promise<void> {
  const lists = watched.map((query) => window.matchMedia(query));
  const caughtUp = () =>
    lists.every((list) => list.matches === window.matchMedia(list.media).matches);

  await commands.emulateMedia(features);

  const deadline = performance.now() + patience;

  while (!caughtUp()) {
    if (performance.now() > deadline) {
      throw new Error(`The media query lists did not catch up with ${JSON.stringify(features)}.`);
    }

    await new Promise((resolve) => setTimeout(resolve, 10));
  }
}

/**
 * Emulates `prefers-reduced-transparency`, and resolves once the page answers
 * to it. `null` puts the browser's own answer back.
 *
 * Playwright has no option for this feature, so it goes through the DevTools
 * protocol, which only Chromium speaks. Chromium is also the only engine that
 * reads it: Firefox keeps it behind a preference that is off, and WebKit does
 * not know it, so in both of those a query for either value matches nothing.
 * A test of it runs in Chromium, and the rule it tests is plain CSS that every
 * other engine skips.
 *
 * The override belongs to a DevTools session of its own, so the colour scheme
 * and the motion `emulateMedia` sets through Playwright's session sit beside it
 * rather than replacing it.
 */
export async function emulateReducedTransparency(
  value: 'reduce' | 'no-preference' | null
): Promise<void> {
  await cdp().send('Emulation.setEmulatedMedia', {
    features: [{ name: 'prefers-reduced-transparency', value: value ?? '' }]
  });

  const reduce = window.matchMedia('(prefers-reduced-transparency: reduce)');
  const deadline = performance.now() + patience;

  while (reduce.matches !== (value === 'reduce')) {
    if (performance.now() > deadline) {
      throw new Error(`The page did not take prefers-reduced-transparency: ${value}.`);
    }

    await new Promise((resolve) => setTimeout(resolve, 10));
  }
}
