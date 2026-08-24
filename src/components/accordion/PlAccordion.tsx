import * as React from 'react';
import { Accordion as BaseUIAccordion } from '@base-ui/react/accordion';
import { ChevronIcon } from '../../internal/icons';
import {
  focusRingClasses,
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
} from '../../internal/styles';
import type { PlassDensity, PlassElevation, PlassSize, PlassStyleProps } from '../../types';

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

const AccordionContext = React.createContext<AccordionContextValue>({
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
const dividerClasses = '[&>div+div]:border-t [&>div+div]:[border-color:var(--plass-glass-line)]';

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
export const PlAccordion = React.forwardRef<HTMLDivElement, PlAccordionProps>(function PlAccordion(
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
});

/**
 * One section.
 *
 * The header is always a row; what is inside it is a real `<button>` covering
 * the title and the chevron, with `action` sitting outside that button as a
 * control of its own.
 */
export const PlAccordionItem = React.forwardRef<HTMLDivElement, PlAccordionItemProps>(
  function PlAccordionItem(
    { value, title, subtitle, startIcon, action, disabled = false, className, children, ...props },
    ref
  ) {
    const { size, density, dividers } = React.useContext(AccordionContext);

    const padX = sheetPaddingXClasses[density][size];
    const padY = sheetPaddingYClasses[density][size];

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
              focusRingClasses,
              // An outline on a clipped sheet would be cut off at the first and
              // last section, so it is drawn inside the header instead.
              dividers ? 'focus-visible:-outline-offset-2' : itemRadiusClasses[size],
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
                <span className={`plass-title truncate font-semibold ${sheetTitleClasses[size]}`}>
                  {title}
                </span>
              ) : null}
              {hasContent(subtitle) ? (
                <span className={`truncate text-(--plass-muted-fg) ${metaTextClasses[size]}`}>
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
              // The header already paid for the space above; the body only owes
              // the space below it, or every closed section would look padded.
              density === 'compact' ? 'pb-3' : 'pb-5'
            ].join(' ')}
          >
            {children}
          </div>
        </BaseUIAccordion.Panel>
      </BaseUIAccordion.Item>
    );
  }
);
