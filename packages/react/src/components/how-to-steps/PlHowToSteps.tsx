'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { useDefaults } from '../../internal/defaults.js';
import {
  bulletGapClasses,
  bulletSizeValues,
  bulletStatusClasses,
  connectorColorClasses,
  connectorStyleClasses,
  statusAt,
  titleStatusClasses,
  type PlassStepConnector,
  type PlassStepStatus
} from '../../internal/steps.js';
import {
  cx,
  hasContent,
  iconClasses,
  sheetBodyClasses,
  sheetTitleClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type { PlassColor, PlassDensity, PlassSize } from '../../types.js';

/** How far along one step is. The same three a `PlStepper` and a `PlTimeline` draw. */
export type PlHowToStepStatus = PlassStepStatus;

/** How the line between two steps is drawn. `none` leaves the gap open. */
export type PlHowToStepsConnector = PlassStepConnector;

interface HowToContextValue {
  size: PlassSize;
  density: PlassDensity;
  color: PlassColor;
  active: number | null;
  numbered: boolean;
  connector: PlassStepConnector;
}

interface HowToStepContextValue {
  index: number;
  last: boolean;
}

const HowToContext = /* @__PURE__ */ React.createContext<HowToContextValue | null>(null);
const HowToStepContext = /* @__PURE__ */ React.createContext<HowToStepContextValue>({
  index: 0,
  last: false
});

export interface PlHowToStepsProps extends Omit<React.ComponentPropsWithoutRef<'ol'>, 'color'> {
  /**
   * Which step is being worked on now, as an index.
   *
   * Optional, and left out for the ordinary case: a set of instructions is
   * something a reader works through at their own pace, and a guide that
   * claimed to know where they had got to would be guessing. Pass it for a
   * guide that genuinely knows — a setup wizard reporting what it has already
   * done for them.
   */
  active?: number;
  /**
   * Numbers the steps.
   *
   * On by default, because that is what instructions are: "do this, then this"
   * is an order and the number is how a reader finds their place again after
   * looking away. Turn it off for a set of things to do in any order, which is
   * a checklist rather than a how-to.
   * @default true
   */
  numbered?: boolean;
  /**
   * The line between one step and the next.
   * @default 'solid'
   */
  connector?: PlHowToStepsConnector;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** The space between steps. Never the type scale, never the bullet. */
  density?: PlassDensity;
  /** Renders something other than an `<ol>` — Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  /** The `PlHowToStep`s. */
  children?: React.ReactNode;
}

export interface PlHowToStepProps extends Omit<React.ComponentPropsWithoutRef<'li'>, 'title'> {
  /** What the step is. The line the reader scans for. */
  title?: React.ReactNode;
  /**
   * A glyph in place of the number. The step keeps its place in the order
   * either way — what changes is only what is drawn in the disc.
   */
  icon?: React.ReactNode;
  /** Overrides what the guide worked out from `active`. */
  status?: PlHowToStepStatus;
  /** What to do. */
  children?: React.ReactNode;
}

/** The space between one step and the next. */
const stepGapClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'gap-4', sm: 'gap-5', md: 'gap-6', lg: 'gap-7', xl: 'gap-8' },
  compact: { xs: 'gap-2.5', sm: 'gap-3', md: 'gap-4', lg: 'gap-4', xl: 'gap-5' }
};

/**
 * Instructions, numbered, with what to do under each one.
 *
 * Three components put things in order and they answer different questions.
 * A [PlStepper](../navigation/stepper) and a [PlTimeline](../display/timeline)
 * both say **where you are** — one in a process the reader is moving through
 * now, the other in a sequence that has already happened. This one says **what
 * to do**, and that is the difference the shape follows from: every step's body
 * is open at once, because somebody following instructions reads ahead, goes
 * back a step, and works at their own pace.
 *
 * Which is also why `active` is optional here and not on the other two. A guide
 * that claimed to know how far a reader had got would be guessing. Pass it only
 * for the guide that genuinely knows.
 *
 * It is a real `<ol>` of `<li>`s, and the numbers a reader sees are the same
 * ones the list carries. A screen reader announces "list, five items, item
 * two" on its own — the position a heading per step would only approximate —
 * which is what a reader who has looked away and come back is asking for.
 */
export const PlHowToSteps = /* @__PURE__ */ React.forwardRef<HTMLOListElement, PlHowToStepsProps>(
  function PlHowToSteps(
    {
      active,
      numbered = true,
      connector = 'solid',
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    // `Children.toArray` rather than `Children.count`, so a step that was
    // conditional and rendered nothing does not take a number with it.
    const steps = React.Children.toArray(children).filter(React.isValidElement);

    const context = React.useMemo<HowToContextValue>(
      () => ({
        size,
        density,
        color,
        active: active ?? null,
        numbered,
        connector
      }),
      [size, density, color, active, numbered, connector]
    );

    return (
      <HowToContext.Provider value={context}>
        {useRender({
          render: render ?? <ol />,
          ref,
          props: {
            className: cx(
              'm-0 flex list-none flex-col p-0',
              stepGapClasses[density][size],
              sheetBodyClasses[size],
              className
            ),
            style: { ...surfaceSlots(color, 0), ...style },
            children: steps.map((step, index) => (
              <HowToStepContext.Provider
                key={step.key ?? index}
                value={{ index, last: index === steps.length - 1 }}
              >
                {step}
              </HowToStepContext.Provider>
            )),
            ...props
          }
        })}
      </HowToContext.Provider>
    );
  }
);

/**
 * One instruction.
 *
 * The number is the guide's, not the step's: a step never takes an index, and
 * the list numbers its children as it walks them — so inserting one in the
 * middle renumbers the rest without anything being edited.
 */
export const PlHowToStep = /* @__PURE__ */ React.forwardRef<HTMLLIElement, PlHowToStepProps>(
  function PlHowToStep({ title, icon, status: statusProp, className, children, ...props }, ref) {
    const guide = React.useContext(HowToContext);
    const { index, last } = React.useContext(HowToStepContext);

    if (!guide) {
      throw new Error('PlHowToStep has to be inside a PlHowToSteps.');
    }

    const { size, color, active, numbered, connector } = guide;
    const status = statusProp ?? statusAt(index, active);
    const bullet = bulletSizeValues[size];

    return (
      <li
        ref={ref}
        aria-current={status === 'current' ? 'step' : undefined}
        className={cx('relative flex', bulletGapClasses[size], className)}
        style={surfaceSlots(color, 0)}
        {...props}
      >
        <div className="flex flex-col items-center self-stretch">
          <span
            aria-hidden="true"
            className={cx(
              'flex shrink-0 items-center justify-center rounded-full font-semibold',
              'text-[0.7em] leading-none',
              iconClasses,
              bulletStatusClasses[status]
            )}
            style={{ width: bullet, height: bullet }}
          >
            {hasContent(icon) ? icon : numbered ? index + 1 : null}
          </span>

          {/* The line belongs to the step it *leaves*, so its colour says
              whether that step has been reached. The last one has nothing to
              leave for. */}
          {!last && connector !== 'none' ? (
            <span
              aria-hidden="true"
              className={cx(
                'mt-1 w-0 flex-1 border-s-2',
                connectorStyleClasses[connector],
                connectorColorClasses[status]
              )}
            />
          ) : null}
        </div>

        <div className="min-w-0 flex-1 pb-0.5">
          {hasContent(title) ? (
            <div
              className={cx('font-semibold', sheetTitleClasses[size], titleStatusClasses[status])}
            >
              {title}
            </div>
          ) : null}

          {hasContent(children) ? (
            <div className={cx(hasContent(title) ? 'mt-1' : '', 'text-(--plass-muted-fg)')}>
              {children}
            </div>
          ) : null}
        </div>
      </li>
    );
  }
);
