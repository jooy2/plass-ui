'use client';

import * as React from 'react';
import { Collapsible as BaseUICollapsible } from '@base-ui/react/collapsible';
import { ChevronIcon } from '../../internal/icons.js';
import {
  cx,
  focusRingInsetClasses,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetRestClasses,
  sheetTitleClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassDensity, PlassElevation, PlassSize, PlassStyleProps } from '../../types.js';

export interface PlCollapsibleProps
  extends
    PlassStyleProps,
    Omit<
      React.ComponentPropsWithoutRef<'div'>,
      // `title` is the tooltip attribute on every element; here it is the
      // heading written on the trigger, and a `ReactNode` rather than a string.
      'color' | 'title' | 'onChange'
    > {
  /**
   * Drop shadow depth. `0` is the default — a fold is part of the page it is set
   * into, not a panel floating over it.
   * @default 0
   */
  elevation?: PlassElevation;
  /** Whether the panel is showing. Use with `onOpenChange` for a controlled fold. */
  open?: boolean;
  /** Where an uncontrolled fold starts. @default false */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** The heading on the trigger. */
  title?: React.ReactNode;
  /** A second line under the title, one step down the type scale and muted. */
  subtitle?: React.ReactNode;
  /** Content before the title — an icon, a status dot, a count. */
  startIcon?: React.ReactNode;
  /**
   * A control pinned to the end of the header, outside the trigger.
   *
   * Deliberately outside it: a header that both folds and holds a switch has
   * two things to press, and one of them cannot be nested inside the other —
   * the browser rewrites a `<button>` inside a `<button>` on parse. The same
   * shape `PlAccordionItem` uses.
   */
  action?: React.ReactNode;
  /**
   * Replaces the header entirely with a control of your own — a `PlButton`, a
   * `PlChip`, a line of text you made pressable.
   *
   * The element you pass *becomes* the trigger: it is handed the click handler,
   * `aria-expanded` and the `aria-controls` pointing at the panel, so nothing
   * has to be wired up. `title` and the slots around it are for the far commoner
   * case of wanting the header that is already there.
   */
  trigger?: React.ReactElement;
  /** The chevron at the end of the header, turned to report the state. @default true */
  indicator?: boolean;
  /** Unavailable. The trigger stops answering and the panel stays as it is. */
  disabled?: boolean;
  /**
   * Inner padding around the panel's content. Turn it off for something that
   * should reach the edges — a table, a picture, a list of its own.
   * @default true
   */
  padded?: boolean;
  /**
   * Keeps a closed panel in the DOM so the browser's own page search can find
   * and open it. Overrides `keepMounted`.
   * @default false
   */
  hiddenUntilFound?: boolean;
  /**
   * Keeps a closed panel in the DOM. For content that is expensive to build, or
   * that holds form state which should survive being folded away.
   * @default false
   */
  keepMounted?: boolean;
  /** The body. */
  children?: React.ReactNode;
}

/**
 * The space between the header and the body it opened.
 *
 * The header's own padding does not pay for it, which is the correction
 * `PlAccordion` already carries: an open header is a tinted band with its own
 * bottom edge, the body begins at that edge, and its first line lands against
 * it with only half a leading in between — so the title and the paragraph
 * explaining it read as one run of text broken by a colour change.
 */
const panelPaddingTopClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'pt-1.5', sm: 'pt-2', md: 'pt-3', lg: 'pt-3.5', xl: 'pt-4' },
  compact: { xs: 'pt-1', sm: 'pt-1.5', md: 'pt-2', lg: 'pt-2.5', xl: 'pt-3' }
};

/** And the space under it, on the same two tracks. */
const panelPaddingBottomClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'pb-2.5', sm: 'pb-3', md: 'pb-5', lg: 'pb-6', xl: 'pb-7' },
  compact: { xs: 'pb-2', sm: 'pb-2.5', md: 'pb-3.5', lg: 'pb-4', xl: 'pb-5' }
};

/**
 * One section that folds, standing on its own.
 *
 * A `PlAccordion` is a *set* of these and owns which one of them is open; this
 * is the same fold with nothing else beside it, so what it needs is an `open` of
 * its own rather than a place in somebody's list. Reach for it for a "Show more"
 * on a form, an optional block of settings, the details under a row.
 *
 * Base UI owns the parts that are genuinely hard: the `button` / panel pairing
 * and the `aria-controls` / `aria-expanded` wiring between them,
 * `hidden="until-found"`, and measuring the panel so it has a height to animate
 * from.
 *
 * The panel's height *is* animated, which looks like an exception to the rule
 * against moving things and is not: nothing is transformed, no text is
 * resampled, and the content does not shift relative to the panel it is in — the
 * panel is a window opening onto it. Content that appears instantly is a page
 * that jumps, which is the failure the rule exists to prevent.
 */
export const PlCollapsible = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlCollapsibleProps>(
  function PlCollapsible(
    {
      variant = 'glass',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      open,
      defaultOpen = false,
      onOpenChange,
      title,
      subtitle,
      startIcon,
      action,
      trigger,
      indicator = true,
      disabled = false,
      padded = true,
      hiddenUntilFound = false,
      keepMounted = false,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const padX = sheetPaddingXClasses[density][size];
    const padY = sheetPaddingYClasses[density][size];

    return (
      <BaseUICollapsible.Root
        ref={ref}
        open={open}
        defaultOpen={defaultOpen}
        onOpenChange={(next) => onOpenChange?.(next)}
        disabled={disabled}
        className={cx(
          // `overflow-hidden` is what makes the panel a window rather than
          // something that spills past the sheet's own corners while it moves.
          'flex flex-col overflow-hidden',
          radiusClasses[size],
          sheetRestClasses[variant],
          transitionClasses,
          className
        )}
        style={{ ...surfaceSlots(color, elevation), ...style }}
        {...props}
      >
        {trigger ? (
          <BaseUICollapsible.Trigger render={trigger} />
        ) : (
          <div className="flex w-full items-center">
            <BaseUICollapsible.Trigger
              className={cx(
                'flex min-w-0 flex-1 cursor-pointer items-center text-start',
                padX,
                padY,
                gapClasses[size],
                transitionClasses,
                iconClasses,
                // Inset rather than offset. The sheet clips its children so the
                // panel can be a window, and `overflow: hidden` clips a
                // descendant's outline along with everything else — an offset
                // ring on a trigger that fills the top of the sheet would be
                // shaved off on three sides.
                focusRingInsetClasses,
                'hover:bg-(--p-soft)',
                'data-[panel-open]:bg-(--p-soft) data-[panel-open]:text-(--p-accent)',
                'disabled:cursor-not-allowed disabled:bg-transparent disabled:opacity-50'
              )}
            >
              {hasContent(startIcon) ? (
                <span className="flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)">
                  {startIcon}
                </span>
              ) : null}

              <span className={cx('flex min-w-0 flex-1 flex-col', sheetHeaderGapClasses[size])}>
                {hasContent(title) ? (
                  <span
                    className={cx('plass-title truncate font-semibold', sheetTitleClasses[size])}
                  >
                    {title}
                  </span>
                ) : null}
                {hasContent(subtitle) ? (
                  <span className={cx('truncate text-(--plass-muted-fg)', metaTextClasses[size])}>
                    {subtitle}
                  </span>
                ) : null}
              </span>

              {/* Turned, not moved: the chevron is a glyph, so rotating it is
                  the one allowance the no-transform rule makes. It is also the
                  only thing on the header that reports the state by moving,
                  which is why the header itself only changes colour. */}
              {indicator ? (
                <span
                  className={cx(
                    'flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)',
                    '[transition:rotate_var(--plass-duration)_var(--plass-ease)]',
                    'data-[panel-open]:rotate-180'
                  )}
                >
                  <ChevronIcon />
                </span>
              ) : null}
            </BaseUICollapsible.Trigger>

            {hasContent(action) ? (
              <span className={cx('flex shrink-0 items-center', padX)}>{action}</span>
            ) : null}
          </div>
        )}

        {/*
          `height` from Base UI's measured `--collapsible-panel-height` down to
          0, plus `overflow-hidden` so the body is clipped rather than squashed
          while it moves — the same two lines the accordion panel is written
          with.
        */}
        <BaseUICollapsible.Panel
          hiddenUntilFound={hiddenUntilFound}
          keepMounted={keepMounted}
          className={cx(
            'h-(--collapsible-panel-height) overflow-hidden',
            '[transition:height_var(--plass-duration-slow)_var(--plass-ease)]',
            'data-[starting-style]:h-0 data-[ending-style]:h-0'
          )}
        >
          <div
            className={cx(
              'min-w-0 text-(--plass-muted-fg)',
              sheetBodyClasses[size],
              padded ? padX : '',
              // The default header already paid for the space above, so the
              // body only owes what goes under it — otherwise a closed
              // collapsible would look padded. A caller's own `trigger` has paid
              // for nothing, so there the panel owes both.
              padded
                ? trigger
                  ? `${panelPaddingTopClasses[density][size]} ${panelPaddingBottomClasses[density][size]}`
                  : panelPaddingBottomClasses[density][size]
                : ''
            )}
          >
            {children}
          </div>
        </BaseUICollapsible.Panel>
      </BaseUICollapsible.Root>
    );
  }
);
