'use client';

import { usePrefersReducedMotion } from '../internal/media.js';

/**
 * Whether the reader has asked their platform for less movement.
 *
 * `prefers-reduced-motion: reduce`, read as a boolean that re-renders when it
 * changes. The library answers it on its own behalf everywhere it moves — every
 * keyframe in the stylesheet is switched off at once, a typewriter simply
 * arrives finished — and this is the same answer, for the motion an application
 * writes itself.
 *
 * **"Reduced" is not "none", and the library's own components disagree with
 * each other on purpose.** An entrance is dropped entirely, because an
 * animation that never played has still delivered everything it was carrying. A
 * loading indicator is *slowed* rather than stopped, because a spinner that
 * stopped would be lying about whether anything is still happening. Which of
 * those two an effect is, is the question to answer before reaching for this.
 *
 * The server's answer is `false` — it has no reader and so no preference — and
 * so is the first answer in a browser. See `usePlMediaQuery` for why, and note
 * that it is the safe direction here: the reader gets their preference in the
 * render after hydration, before any of this has had a frame to run in.
 */
export function usePlReducedMotion(): boolean {
  return usePrefersReducedMotion();
}
