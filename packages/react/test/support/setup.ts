/**
 * Tears down every rendered tree after the test that made it.
 *
 * The whole suite runs in **one browser page** — `fileParallelism` is off, for
 * the reason `vitest.config.ts` gives — and `render` leaves its container in
 * the document. Without this, every tree from every file is still there at the
 * end of the run: a hundred-odd component pages stacked on one document, which
 * costs memory, leaves `position: fixed` elements from earlier files sitting
 * over later ones, and makes `getElementById` answer with the first of a dozen
 * copies rather than the one the test just rendered.
 *
 * A test that genuinely wants two trees at once still renders twice inside
 * itself; what goes away is the accumulation *between* tests.
 */
import { afterEach, beforeAll } from 'vitest';
import { cleanup } from 'vitest-browser-react';
import { emulateMedia } from './media';

afterEach(cleanup);

// Every file also starts with motion allowed. A page that has never been told
// otherwise answers `prefers-reduced-motion` from the runner's own system, which
// is `reduce` on some CI runners (macOS and Windows Chromium, macOS and Ubuntu
// WebKit) and not on others, so a test that reads a transition under way passed
// or failed by which file happened to run before it in its shard.
beforeAll(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});
