'use client';

import * as React from 'react';
import { CloseIcon, severityIcon } from '../../internal/icons.js';
import {
  controlSlots,
  focusRingClasses,
  glassClasses,
  hasContent,
  iconClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassElevation, PlassStyleProps, PlassVariant } from '../../types.js';

export interface PlAlertProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title'> {
  /**
   * Drop shadow depth. `0` is the default — an alert belongs to the flow of the
   * page it interrupts. The one that floats above it is a dialog.
   * @default 0
   */
  elevation?: PlassElevation;
  /**
   * The heading line. With it the alert is two-part — a headline and the detail
   * under it; without it the whole thing is one line.
   */
  title?: React.ReactNode;
  /**
   * The glyph at the start. Defaults to the one that goes with `color`; pass
   * `false` to drop it, or a node to replace it. A node is sized in `em`, so it
   * tracks whichever line it sits on.
   */
  icon?: React.ReactNode | false;
  /**
   * Content pinned to the end of the row — a "Retry" button, a link. Kept out
   * of `children` so it stays on the first line while the message wraps.
   */
  action?: React.ReactNode;
  /** Passing it is what makes the dismiss button appear. */
  onClose?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  /**
   * Accessible name of the dismiss button. Never drawn.
   * @default 'Dismiss'
   */
  closeLabel?: string;
  /** The message. */
  children?: React.ReactNode;
}

/**
 * An alert **is** the thing being coloured — it is a notice about a severity,
 * not a container holding someone else's content — so unlike a PlCard its sheet
 * takes the tint. The same three materials they mean everywhere.
 *
 * `solid` carries no gloss line, exactly as a filled PlButton does not: the
 * gradient is the form, and a white edge over the top of it reads as lacquer.
 */
const restClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'text-(--p-on-solid) [background-image:var(--p-fill)]',
    '[box-shadow:var(--p-elev),var(--p-lift)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'border text-(--plass-fg) bg-(--plass-glass)',
    '[border-color:var(--p-line)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  // No sheet and no edge, only the tint. For an alert set among form fields,
  // where a second bordered rectangle is one rectangle too many.
  ghost: 'text-(--plass-fg) bg-(--p-soft)'
};

/**
 * On `solid` the surface already carries the family, so the glyph and the title
 * ride on it as one ink. On the other two the surface is only faintly tinted:
 * the message has to stay ordinary reading text, and the accent is spent on the
 * two things that say which kind of alert this is.
 */
const accentClasses: Record<PlassVariant, string> = {
  solid: '',
  glass: 'text-(--p-accent)',
  ghost: 'text-(--p-accent)'
};

/**
 * The detail line under a title.
 *
 * On a tinted surface it drops to the muted ink, the same step a field's
 * description takes. On a filled one there is no muted ink to drop to — the
 * page's grey is invisible on a gradient — so the ink stays and the title does
 * the separating with its weight.
 */
const detailClasses: Record<PlassVariant, string> = {
  solid: '',
  glass: 'text-(--plass-muted-fg)',
  ghost: 'text-(--plass-muted-fg)'
};

/**
 * Which live region an alert belongs in.
 *
 * `alert` interrupts whatever a screen reader is in the middle of saying;
 * `status` waits for a pause. "This failed" is worth interrupting for and
 * "saved" is not, so the severity decides — and a caller who knows better still
 * wins, because their props spread after this.
 */
const rolesFor: Record<PlassColor, 'alert' | 'status'> = {
  primary: 'status',
  secondary: 'status',
  info: 'status',
  success: 'status',
  warning: 'alert',
  danger: 'alert'
};

/**
 * A message about something that happened, set into the page it is about.
 *
 * The three shapes people mean by "an alert" are one component with different
 * slots filled rather than three components: a bare line
 * (`<PlAlert icon={false}>`), a line with a glyph (the default), and a glyph
 * with a headline and the detail under it (`title` plus `children`). Nothing
 * about the surface changes between them — only how much of it is used.
 *
 * There is no Base UI primitive under this, and there should not be: an alert
 * has no interaction to delegate. It is a live region with a layout, and the
 * only interactive parts it can grow — the action and the dismiss button — are
 * real buttons that the caller either passes in or gets by passing `onClose`.
 */
export const PlAlert = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlAlertProps>(
  function PlAlert(
    {
      variant = 'glass',
      size = 'md',
      // An alert with no severity named is an informational one. This is the one
      // place `primary` would be a lie: it is not the primary anything, it is a
      // note, and the palette already has the word for that.
      color = 'info',
      density = 'default',
      elevation = 0,
      title,
      icon,
      action,
      onClose,
      closeLabel = 'Dismiss',
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const glyph = icon === undefined ? severityIcon(color) : icon;
    const accent = accentClasses[variant];
    const titled = hasContent(title);

    return (
      <div
        ref={ref}
        role={rolesFor[color]}
        className={[
          'flex w-full items-start',
          sheetPaddingXClasses[density][size],
          sheetPaddingYClasses[density][size],
          radiusClasses[size],
          sheetSectionGapClasses[size],
          sheetBodyClasses[size],
          transitionClasses,
          restClasses[variant],
          iconClasses,
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        style={{ ...controlSlots(color, elevation, variant), ...style }}
        {...props}
      >
        {hasContent(glyph) ? (
          // `h-[1lh]` rather than a margin: the glyph centres on the first line of
          // text whatever the type scale turns out to be, so a one-line alert
          // looks centred and a three-line one still has its glyph at the top.
          <span className={`flex h-[1lh] shrink-0 items-center ${accent}`}>{glyph}</span>
        ) : null}

        <div className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
          {titled ? (
            <div className={`plass-title font-semibold ${sheetTitleClasses[size]} ${accent}`}>
              {title}
            </div>
          ) : null}
          {hasContent(children) ? (
            // Under a title the message is supporting detail and steps back to the
            // muted ink. On its own it *is* the alert, and stays reading text.
            <div className={titled ? detailClasses[variant] : undefined}>{children}</div>
          ) : null}
        </div>

        {hasContent(action) ? (
          <div className="flex h-[1lh] shrink-0 items-center">{action}</div>
        ) : null}

        {onClose ? (
          <span className="flex h-[1lh] shrink-0 items-center">
            <button
              type="button"
              aria-label={closeLabel}
              onClick={onClose}
              className={[
                'inline-flex size-[1.15em] cursor-pointer items-center justify-center rounded-full',
                'opacity-70 [transition:opacity_var(--plass-duration)_var(--plass-ease)]',
                'hover:opacity-100 focus-visible:opacity-100',
                focusRingClasses
              ].join(' ')}
            >
              <CloseIcon />
            </button>
          </span>
        ) : null}
      </div>
    );
  }
);
