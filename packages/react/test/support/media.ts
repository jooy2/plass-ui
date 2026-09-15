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
import { commands } from 'vitest/browser';

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
