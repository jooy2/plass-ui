/**
 * The glyphs more than one component draws.
 *
 * A component that needs a shape nobody else needs draws it in its own file.
 * What lands here is what two components would otherwise each have a copy of —
 * and the reason that matters is not the duplication, it is that two copies
 * drift: a spinner in a PlButton and a spinner in a PlTextField have to be the same
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

/**
 * The disclosure chevron, drawn pointing **down**.
 *
 * One drawing for every direction: a PlAccordion's header, a PlSelect's
 * trigger, a PlPagination's stepper all want the same wedge turned a different
 * way. Turning it is the one allowance the no-transform rule makes — the rule
 * is about a control resampling its own label under the pointer, and a glyph
 * has no text in it to resample.
 */
export function ChevronIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m4.5 6.5 3.5 3.5 3.5-3.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/** The tick: a chosen option, a ticked menu item, a checked box. */
export function CheckIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m3.5 8.5 3 3 6-6"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * The ×.
 *
 * One drawing for every dismissal in the library — a file's remove button, an
 * alert's close, a modal's. Two copies of an × drift by half a pixel of stroke
 * weight, and then a page has two kinds of "close" on it.
 */
export function CloseIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m4.5 4.5 7 7m0-7-7 7"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
      />
    </svg>
  );
}

/** The chain: a link that stays on this page. */
export function LinkIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M6.5 9.5a2.75 2.75 0 0 0 4 .25l1.75-1.75a2.75 2.75 0 0 0-3.9-3.9L7.75 5.2"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M9.5 6.5a2.75 2.75 0 0 0-4-.25L3.75 8a2.75 2.75 0 0 0 3.9 3.9l.6-.6"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

/** The arrow leaving its box: a link that takes over a new tab. */
export function ExternalLinkIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M12.75 9.25v2.5a1.5 1.5 0 0 1-1.5 1.5h-7a1.5 1.5 0 0 1-1.5-1.5v-7a1.5 1.5 0 0 1 1.5-1.5h2.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M9.5 2.75h3.75V6.5M7.25 8.75l5.75-5.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
