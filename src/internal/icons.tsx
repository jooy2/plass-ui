/**
 * The glyphs more than one component draws.
 *
 * A component that needs a shape nobody else needs draws it in its own file.
 * What lands here is what two components would otherwise each have a copy of —
 * and the reason that matters is not the duplication, it is that two copies
 * drift: a spinner in a Button and a spinner in a TextField have to be the same
 * object in motion, or a form that is saving looks like two things loading.
 */

import * as React from 'react';

/**
 * The one thing in the library that moves on its own, and the only place that
 * is allowed: an indeterminate indicator that does not move is a decoration.
 *
 * Sized in `em` by `iconClasses`, like every other glyph inside a control, so
 * it tracks the label rather than carrying a size of its own.
 */
export function Spinner(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true" className="animate-spin">
      <circle cx="8" cy="8" r="6.5" stroke="currentColor" strokeOpacity="0.25" strokeWidth="2" />
      <path
        d="M14.5 8A6.5 6.5 0 0 0 8 1.5"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  );
}
