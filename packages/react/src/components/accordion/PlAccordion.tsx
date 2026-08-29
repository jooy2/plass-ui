'use client';

import * as React from 'react';
import { Accordion as BaseUIAccordion } from '@base-ui/react/accordion';
import { ChevronIcon } from '../../internal/icons.js';
import {
  focusRingClasses,
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

/**
 * What a `PlAccordionItem` inherits from the `PlAccordion` around it.
 *
 * A fold is a fold *of* something, so `size`, `density` and whether the folds
 * are scored belong to the stack rather than to any one section in it. The
 * alternative is repeating three props on every item and having the fourth one
 * disagree.
 */
interface AccordionContextValue {
  size: PlassSize;
  density: PlassDensity;
  dividers: boolean;
}

const AccordionContext = /* @__PURE__ */ React.createContext<AccordionContextValue>({
  size: 'md',
  density: 'default',
  dividers: true
});

export interface PlAccordionProps
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * Drop shadow depth. `0` is the default — an accordion is part of the page it
   * is set into, not a panel floating over it.
   * @default 0
   */
  elevation?: PlassElevation;
  /**
   * Whether more than one section may be open at once.
   *
   * `false` by default, which is the whole reason an accordion is not just a
   * stack of collapsibles: closing the last one as the next opens is what keeps
   * the page from growing under the reader.
   * @default false
   */
  multiple?: boolean;
  /** Which sections are open. Use with `onValueChange` for a controlled accordion. */
  value?: (string | number)[];
  /** Which sections start open, for an uncontrolled one. */
  defaultValue?: (string | number)[];
  onValueChange?: (value: (string | number)[]) => void;
  /**
   * Scores the sheet between sections with a hairline instead of separating
   * them with space.
   *
   * On by default: the rule is what says the folds are parts of one pane rather
   * than a stack of unrelated tiles.
   * @default true
   */
  dividers?: boolean;
  /** Unavailable. Every section stops answering. */
  disabled?: boolean;
  /**
   * Keeps closed panels in the DOM so the browser's own page search can find
   * and open them. Overrides `keepMounted`.
   * @default false
   */
  hiddenUntilFound?: boolean;
  /**
   * Keeps closed panels in the DOM. For content that is expensive to build, or
   * that holds form state which should survive being folded away.
   * @default false
   */
  keepMounted?: boolean;
  children?: React.ReactNode;
}

export interface PlAccordionItemProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'title' | 'onChange'
> {
  /**
   * Identifies the section to `value` / `defaultValue`. Base UI generates one
   * when it is left out, which is enough for an accordion nobody drives from
   * code.
   */
  value?: string | number;
  /** The heading on the fold. */
  title?: React.ReactNode;
  /** A second line under the title, one step down the type scale and muted. */
  subtitle?: React.ReactNode;
  /** Content before the title — an icon, a status dot, a count. */
  startIcon?: React.ReactNode;
  /**
   * A control pinned to the end of the header, before the chevron.
   *
   * Deliberately outside the trigger: a header that both folds and holds a
   * switch has two things to press, and one of them cannot be nested inside the
   * other — the browser rewrites a `<button>` inside a `<button>` on parse.
   */
  action?: React.ReactNode;
  /**
   * Holds the header's title and subtitle to one line each, ellipsing whatever
   * runs past.
   *
   * **Off, and that is the reversal of what this used to do.** A fold's title is
   * a heading rather than a cell — an accordion is most often a list of
   * questions, and a question is a sentence. Ellipsing one costs the reader the
   * end of it with no tooltip and no way to see it, while wrapping costs a row
   * that is two lines tall in a component whose whole job is to change height.
   * The one place the old behaviour is right is a header carrying a name from a
   * database beside a control, and that is what this prop is for.
   * @default false
   */
  truncate?: boolean;
  /** Unavailable. This section stops folding; the rest keep working. */
  disabled?: boolean;
  /** The body. */
  children?: React.ReactNode;
}

/**
 * A section sits one step down the radius ladder from the sheet it is inside,
 * so a hovered header's corner is visibly inside the pane's own corner rather
 * than fighting it.
 */
const itemRadiusClasses: Record<PlassSize, string> = {
  xs: radiusClasses.xs,
  sm: radiusClasses.xs,
  md: radiusClasses.sm,
  lg: radiusClasses.sm,
  xl: radiusClasses.md
};

/**
 * The rule between two sections, written as `>div+div` rather than as a class
 * on each item so it holds however the caller composed them — through a
 * `.map()`, through fragments, through a component of their own that renders an
 * item.
 */
const dividerClasses = '[&>div+div]:border-t [&>div+div]:[border-color:var(--plass-divider)]';

/**
 * The space between a header and the body it opened.
 *
 * The header's own padding does **not** pay for it, which is what this used to
 * assume. An open header is a tinted band with its own bottom edge; the body
 * begins at that edge, and the first line of text lands against it with only
 * half a leading in between — the title and the paragraph explaining it read as
 * one run of text broken by a colour change. What the header's padding buys is
 * room around the *title*, and the body has to buy its own.
 *
 * It is a little under the padding below, because a paragraph's first line has
 * the leading above it and its last has nothing under, so equal numbers on the
 * two sides look bottom-heavy.
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
 * A stack of sections, one of which is open.
 *
 * Base UI owns the parts that are genuinely hard: the `button` / `region`
 * pairing and the `aria-controls` / `aria-expanded` wiring between them, the
 * open set, and measuring the panel so it has a height to animate from.
 *
 * What is here is the sheet, the ladders and the one motion decision. The
 * panel's height *is* animated, which looks like an exception to the rule
 * against moving things and is not: nothing is transformed, no text is
 * resampled, and the content does not shift relative to the panel it is in —
 * the panel is a window opening onto it. An accordion whose sections appear
 * instantly is a page that jumps, which is the failure the rule exists to
 * prevent.
 */
export const PlAccordion = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlAccordionProps>(
  function PlAccordion(
    {
      variant = 'glass',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      multiple = false,
      value,
      defaultValue,
      onValueChange,
      dividers = true,
      disabled = false,
      hiddenUntilFound = false,
      keepMounted = false,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const context = React.useMemo(() => ({ size, density, dividers }), [size, density, dividers]);

    const classNames = [
      'flex flex-col',
      radiusClasses[size],
      sheetRestClasses[variant],
      transitionClasses,
      // Scored, the rules have to reach both edges, so the sheet keeps no padding
      // of its own and the corners clip whatever runs into them. Unscored, the
      // sections are tiles and the sheet keeps a hair of padding so a hovered
      // header does not run into the edge.
      dividers ? `overflow-hidden ${dividerClasses}` : 'p-1',
      className ?? ''
    ]
      .filter(Boolean)
      .join(' ');

    return (
      <AccordionContext.Provider value={context}>
        <BaseUIAccordion.Root
          ref={ref}
          multiple={multiple}
          value={value}
          defaultValue={defaultValue}
          onValueChange={(next) => onValueChange?.(next as (string | number)[])}
          disabled={disabled}
          hiddenUntilFound={hiddenUntilFound}
          keepMounted={keepMounted}
          className={classNames}
          style={{ ...surfaceSlots(color, elevation), ...style }}
          {...props}
        >
          {children}
        </BaseUIAccordion.Root>
      </AccordionContext.Provider>
    );
  }
);

/**
 * One section.
 *
 * The header is always a row; what is inside it is a real `<button>` covering
 * the title and the chevron, with `action` sitting outside that button as a
 * control of its own.
 */
export const PlAccordionItem = /* @__PURE__ */ React.forwardRef<
  HTMLDivElement,
  PlAccordionItemProps
>(function PlAccordionItem(
  {
    value,
    title,
    subtitle,
    startIcon,
    action,
    truncate = false,
    disabled = false,
    className,
    children,
    ...props
  },
  ref
) {
  const { size, density, dividers } = React.useContext(AccordionContext);

  const padX = sheetPaddingXClasses[density][size];
  const padY = sheetPaddingYClasses[density][size];
  // `min-w-0` on the column is what lets a wrapped line break inside a flex row
  // at all, and it is already there for the ellipsis this used to draw.
  const clamp = truncate ? 'truncate' : '';

  return (
    <BaseUIAccordion.Item
      ref={ref}
      value={value}
      disabled={disabled}
      className={['flex flex-col', className ?? ''].filter(Boolean).join(' ')}
      {...props}
    >
      <BaseUIAccordion.Header className="m-0 flex w-full items-center [font:inherit]">
        <BaseUIAccordion.Trigger
          className={[
            'flex min-w-0 flex-1 cursor-pointer items-center text-start',
            padX,
            padY,
            gapClasses[size],
            transitionClasses,
            iconClasses,
            // An outline on a clipped sheet would be cut off at the first and
            // last section, so it is drawn inside the header instead. Two
            // whole classes rather than one plus an override: a variant that
            // only moves the offset resolves against the base by its position
            // in the generated stylesheet, which is not something to bet a
            // focus ring on.
            dividers ? focusRingInsetClasses : `${focusRingClasses} ${itemRadiusClasses[size]}`,
            'hover:bg-(--p-soft)',
            'data-[panel-open]:bg-(--p-soft) data-[panel-open]:text-(--p-accent)',
            'disabled:cursor-not-allowed disabled:bg-transparent disabled:opacity-50'
          ]
            .filter(Boolean)
            .join(' ')}
        >
          {hasContent(startIcon) ? (
            <span className="flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)">
              {startIcon}
            </span>
          ) : null}

          <span className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
            {hasContent(title) ? (
              <span
                className={`plass-title font-semibold ${clamp} ${sheetTitleClasses[size]}`.trim()}
              >
                {title}
              </span>
            ) : null}
            {hasContent(subtitle) ? (
              <span className={`text-(--plass-muted-fg) ${clamp} ${metaTextClasses[size]}`.trim()}>
                {subtitle}
              </span>
            ) : null}
          </span>

          {/* Turned, not moved. It is also the only thing on the header that
                reports the open state by moving, which is why the header itself
                only changes colour. */}
          <span
            className={[
              'flex h-[1lh] shrink-0 items-center text-(--plass-muted-fg)',
              '[transition:rotate_var(--plass-duration)_var(--plass-ease)]',
              'data-[panel-open]:rotate-180'
            ].join(' ')}
          >
            <ChevronIcon />
          </span>
        </BaseUIAccordion.Trigger>

        {hasContent(action) ? (
          <span className={`flex shrink-0 items-center ${padX}`}>{action}</span>
        ) : null}
      </BaseUIAccordion.Header>

      {/*
          `height` from Base UI's measured `--accordion-panel-height` down to 0,
          with `overflow-hidden` so the body is clipped rather than squashed
          while it moves.
        */}
      <BaseUIAccordion.Panel
        className={[
          'h-(--accordion-panel-height) overflow-hidden',
          '[transition:height_var(--plass-duration-slow)_var(--plass-ease)]',
          'data-[starting-style]:h-0 data-[ending-style]:h-0'
        ].join(' ')}
      >
        <div
          className={[
            'text-(--plass-muted-fg)',
            sheetBodyClasses[size],
            padX,
            panelPaddingTopClasses[density][size],
            panelPaddingBottomClasses[density][size]
          ].join(' ')}
        >
          {children}
        </div>
      </BaseUIAccordion.Panel>
    </BaseUIAccordion.Item>
  );
});
