/**
 * The rail a sequence is drawn on, shared by `PlTimeline` and `PlStepper`.
 *
 * The two components are not the same thing — a timeline **reports** a sequence
 * that happened and a stepper **is** one the reader is moving through, which is
 * why one is an `<ol>` of text and the other is an `<ol>` of buttons with a
 * panel under it — but they are the same *drawing*, and a reader who has learned
 * what a haloed bullet means on one must not find it meaning something else on
 * the other.
 *
 * So the marks live here and the behaviour lives in the components. This is the
 * arrangement `internal/button-group.ts` and `internal/progress.ts` already
 * make, and it is here for the reason `internal/icons.tsx` gives: two copies of
 * twelve lines are not expensive, they are two copies that drift.
 */

import type { PlassColor, PlassSize } from '../types.js';

/**
 * How far along one step is.
 *
 * Three states rather than two, because "the one you are on" is not the same
 * claim as "done", and a sequence that cannot say which step is current is a
 * list. Each gets its own axis — a filled bullet, a filled bullet with a halo
 * around it, an empty one — rather than three shades of the same thing.
 */
export type PlassStepStatus = 'complete' | 'current' | 'upcoming';

/** How the line between two steps is drawn. `none` leaves the gap open. */
export type PlassStepConnector = 'solid' | 'dashed' | 'dotted' | 'none';

/**
 * The bullet.
 *
 * Its own ladder rather than a step off `controlHeightClasses`, for the reason
 * `tickSizeClasses` has one: a bullet is not a control you can put a label
 * inside. It is a mark beside one, sized against the title next to it — which is
 * why the steps are close to the tick ladder and not to the control ladder.
 *
 * It is written as a custom property rather than as a class because the
 * connector has to know it: the line is centred on the bullet, and centring is
 * arithmetic on this number.
 */
export const bulletSizeValues: Record<PlassSize, string> = {
  xs: '0.875rem',
  sm: '1rem',
  md: '1.25rem',
  lg: '1.5rem',
  xl: '1.875rem'
};

/** Between the bullet column and the content beside it. */
export const bulletGapClasses: Record<PlassSize, string> = {
  xs: 'gap-2',
  sm: 'gap-2.5',
  md: 'gap-3',
  lg: 'gap-3.5',
  xl: 'gap-4'
};

/**
 * The bullet at each of the three states.
 *
 * Every one of them is a different axis, never a different opacity: `complete`
 * is the family's gradient, `current` is that gradient with a halo of the soft
 * tint around it, and `upcoming` is a hairline ring on the page's own surface. A
 * reader who cannot tell the colours apart still has a filled shape, a haloed
 * shape and an empty one.
 *
 * There is no gloss line on the two filled ones, for the reason a filled
 * `PlButton` has none — the gradient is the form. The `upcoming` ring is drawn
 * in the neutral hairline rather than the sheet's white one, the same call a
 * checkbox's edge makes: a bullet is small enough that its edge *is* the object,
 * and white light on a translucent pane disappears on a light card.
 */
export const bulletStatusClasses: Record<PlassStepStatus, string> = {
  complete: '[background-image:var(--p-fill)] text-(--p-on-solid)',
  current:
    '[background-image:var(--p-fill)] text-(--p-on-solid) [box-shadow:0_0_0_0.25rem_var(--p-soft)]',
  upcoming:
    'border-2 bg-(--plass-surface) text-(--plass-muted-fg) [border-color:var(--plass-border)]'
};

/**
 * The line *after* a step, which is what makes it the step's own property: a
 * connector is coloured by whether the step it leaves has been reached, not by
 * where it arrives.
 */
export const connectorColorClasses: Record<PlassStepStatus, string> = {
  complete: '[border-color:var(--p-line-hover)]',
  current: '[border-color:var(--plass-border)]',
  upcoming: '[border-color:var(--plass-border)]'
};

export const connectorStyleClasses: Record<PlassStepConnector, string> = {
  solid: 'border-solid',
  dashed: 'border-dashed',
  dotted: 'border-dotted',
  none: ''
};

export const titleStatusClasses: Record<PlassStepStatus, string> = {
  complete: 'text-(--plass-fg)',
  current: 'text-(--p-accent)',
  upcoming: 'text-(--plass-muted-fg)'
};

/**
 * Which of the three a step is, from where the sequence has got to.
 *
 * `active` is an **index**, not a value, because neither a timeline nor a
 * stepper has a selection: everything before it is `complete`, the step at it is
 * `current`, everything after it is `upcoming`.
 */
export function statusAt(index: number, active: number | null): PlassStepStatus {
  if (active === null) {
    return 'upcoming';
  }

  if (index < active) {
    return 'complete';
  }

  return index === active ? 'current' : 'upcoming';
}

/** The slot family a step draws in, so the two components dye a rail alike. */
export type StepFamily = PlassColor;
