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
import type { PlassColor } from '../types';

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

/**
 * The arrow, drawn pointing **right**.
 *
 * One of the two marks a trail can put between its steps, and the one that says
 * "and then" out loud. It is turned back under RTL by whoever draws it rather
 * than being redrawn, the same allowance the chevron takes.
 */
export function ArrowRightIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M3 8h10m-3.5-3.5L13 8l-3.5 3.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/** Three dots: the middle of something that has been folded away. */
export function EllipsisIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="3.5" cy="8" r="1.15" fill="currentColor" />
      <circle cx="8" cy="8" r="1.15" fill="currentColor" />
      <circle cx="12.5" cy="8" r="1.15" fill="currentColor" />
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
 * The two steppers' marks.
 *
 * A pair, and they stay one: a minus drawn at a different weight from the plus
 * beside it reads as two toolkits in one control.
 */
export function MinusIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

export function PlusIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
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

/** The clock: something that has been started and has not finished. */
export function ClockIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="6.25" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="M8 4.5V8l2.4 1.6"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
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

/** The neutral note: a circled `i` without the serif problem an `i` has at 16px. */
function NoteIcon(): React.ReactElement {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="6.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="M8 7.25v4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <circle cx="8" cy="4.9" r="0.85" fill="currentColor" />
    </svg>
  );
}

/**
 * One drawing per colour family, and a piece of the design language rather than
 * a convenience.
 *
 * An alert that says "this went wrong" only in red says it only to some
 * readers, so the shape has to carry the meaning too — and that only holds if
 * every component uses the same shape for the same family.
 *
 * `primary` and `secondary` have no severity to draw, so they take the note the
 * informational one uses: three shapes for six families, because the three that
 * mean something are the three worth telling apart.
 */
export const severityIcons: Record<PlassColor, React.ReactNode> = {
  primary: <NoteIcon />,
  secondary: <NoteIcon />,
  info: <NoteIcon />,
  success: (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="6.25" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="m5.25 8.25 1.9 1.9 3.6-3.9"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  ),
  warning: (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M7.13 2.6 1.9 11.7a1 1 0 0 0 .87 1.5h10.46a1 1 0 0 0 .87-1.5L8.87 2.6a1 1 0 0 0-1.74 0Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path d="M8 6.1v3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <circle cx="8" cy="11.2" r="0.85" fill="currentColor" />
    </svg>
  ),
  danger: (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="8" cy="8" r="6.25" stroke="currentColor" strokeWidth="1.5" />
      <path
        d="m5.9 5.9 4.2 4.2m0-4.2-4.2 4.2"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  )
};
