'use client';

import * as React from 'react';
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
  focusRingClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetTitleClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import { useLabels } from '../../internal/labels.js';
import { useResponsiveValue } from '../../internal/responsive.js';
import type {
  PlassColor,
  PlassDensity,
  PlassOrientation,
  PlassResponsive,
  PlassSize
} from '../../types.js';

/** The same three a `PlTimeline` draws, and the same marks. */
export type PlStepStatus = PlassStepStatus;

/** How the line between two steps is drawn. `none` leaves the gap open. */
export type PlStepConnector = PlassStepConnector;

interface StepperContextValue {
  size: PlassSize;
  density: PlassDensity;
  orientation: PlassOrientation;
  color: PlassColor;
  active: number;
  linear: boolean;
  connector: PlStepConnector;
  keepMounted: boolean;
  baseId: string;
  onSelect: (index: number) => void;
  /** The ref for the panel of the step at `index`, the same one every render. */
  panelRef: (index: number) => React.RefCallback<HTMLDivElement>;
  /** The ref for the button of the step at `index`, the same one every render. */
  stepRef: (index: number) => React.RefCallback<HTMLButtonElement>;
}

interface StepContextValue {
  index: number;
  last: boolean;
}

const StepperContext = /* @__PURE__ */ React.createContext<StepperContextValue | null>(null);
const StepContext = /* @__PURE__ */ React.createContext<StepContextValue>({
  index: 0,
  last: false
});

export interface PlStepperProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /** Which step the reader is on. Use with `onActiveChange` for a controlled stepper. */
  active?: number;
  /** Which step it starts on, for an uncontrolled one. @default 0 */
  defaultActive?: number;
  onActiveChange?: (active: number) => void;
  /**
   * Whether a step ahead of the current one can be jumped to.
   *
   * On by default, because that is what makes it a process rather than a set of
   * tabs: the third step of a sign-up cannot be filled in before the second.
   * Turn it off for a review screen, where every step has already been answered
   * and the reader is going back to check one.
   * @default true
   */
  linear?: boolean;
  /** @default 'horizontal' */
  orientation?: PlassResponsive<PlassOrientation>;
  /** How the line between two steps is drawn. @default 'solid' */
  connector?: PlStepConnector;
  /**
   * Keeps every step's panel in the document, hidden while `active` is on
   * another step, rather than only the panel of the step it is on.
   *
   * For panels a search engine should read: the others are otherwise not in
   * the HTML a server sends. A kept panel is `hidden`, so it is out of the
   * layout, the focus order and the accessibility tree, and what it holds
   * survives the reader stepping away from it. Off by default.
   * @default false
   */
  keepMounted?: boolean;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** @default 'default' */
  density?: PlassDensity;
  children?: React.ReactNode;
}

export interface PlStepProps extends Omit<React.ComponentPropsWithoutRef<'li'>, 'color'> {
  /** What the step is called. */
  label?: React.ReactNode;
  /** A second line under it — what the step asks for. */
  description?: React.ReactNode;
  /**
   * What is drawn in the bullet. The step's own number by default, and a tick
   * once it is complete.
   */
  bullet?: React.ReactNode;
  /**
   * Overrides where the sequence says this step is. For the one that failed
   * validation while the reader was three steps further on.
   */
  status?: PlStepStatus;
  /**
   * Marks the step as skippable. `true` draws the word "Optional"; a node draws
   * that node instead, which is how the word is translated.
   */
  optional?: boolean | React.ReactNode;
  /** Cannot be reached, whatever `linear` says. */
  disabled?: boolean;
  /** Overrides the stepper's family for this one step. */
  color?: PlassColor;
  /** The panel this step shows while the stepper's `active` is on it, whatever `status` says. */
  children?: React.ReactNode;
}

/**
 * A tick, for a step that is behind the reader.
 *
 * Its own drawing rather than `CheckIcon`, because it sits inside a bullet that
 * is already the right size — the shared glyph tracks its label's font size,
 * and inside a bullet there is no label.
 */
function StepTick() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true" className="size-[0.7em]">
      <path
        d="m3.5 8.5 3 3 6-7"
        stroke="currentColor"
        strokeWidth="2.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/**
 * Sends the focus after the reader into the next step's panel, when it was in
 * the panel they left.
 *
 * Moving on from a button inside a panel takes that panel away, or hides it
 * when it is kept, and a browser drops the focus of something gone or hidden to
 * the top of the document, so the next Tab would start the page over. The panel
 * that arrives takes it instead, and is announced by its step's name. A step
 * with no panel takes it on its own button, which is where a reader would Tab
 * to for that step. The focus anywhere else, on a step for example, stays where
 * it is.
 *
 * A panel that is taken away is asked on its way out, since its ref is let go
 * before it leaves the document. A kept panel is still there, hidden and still
 * holding the focus, when the layout effect that calls `settle` runs.
 */
function followPanelFocus() {
  const panels = new Map<number, HTMLDivElement>();
  const buttons = new Map<number, HTMLButtonElement>();
  // One callback per step, the same one every render, so a panel's ref is let
  // go only when the panel goes.
  const refs = new Map<number, React.RefCallback<HTMLDivElement>>();
  const buttonRefs = new Map<number, React.RefCallback<HTMLButtonElement>>();
  let leftHoldingFocus = false;
  let shown: number | null = null;

  const holdsFocus = (panel: HTMLDivElement | undefined) =>
    Boolean(panel?.contains(panel.ownerDocument.activeElement));

  return {
    /** The ref for a step's button, which a step out of reach does not have. */
    step(index: number): React.RefCallback<HTMLButtonElement> {
      let callback = buttonRefs.get(index);

      if (!callback) {
        callback = (node: HTMLButtonElement | null) => {
          if (node) {
            buttons.set(index, node);
          } else {
            buttons.delete(index);
          }
        };
        buttonRefs.set(index, callback);
      }

      return callback;
    },

    ref(index: number): React.RefCallback<HTMLDivElement> {
      let callback = refs.get(index);

      if (!callback) {
        callback = (node: HTMLDivElement | null) => {
          if (node) {
            panels.set(index, node);
            return;
          }

          leftHoldingFocus ||= holdsFocus(panels.get(index));
          panels.delete(index);
        };
        refs.set(index, callback);
      }

      return callback;
    },

    /** Called after every commit with the step the stepper is now on. */
    settle(active: number) {
      const from = shown;
      const heldFocus = leftHoldingFocus || (from !== null && holdsFocus(panels.get(from)));

      shown = active;
      leftHoldingFocus = false;

      if (from !== null && from !== active && heldFocus) {
        (panels.get(active) ?? buttons.get(active))?.focus();
      }
    }
  };
}

/**
 * A process the reader is moving through, and where they are in it.
 *
 * It draws the same rail a [`PlTimeline`](../display/timeline) does — the same
 * three bullet states, the same connector — and the difference is what the two
 * are *for*, which is also the whole of when to reach for which. A timeline
 * **reports**: it is an `<ol>` of text about a sequence that already happened,
 * and nothing on it can be pressed. A stepper **is** the sequence: its steps are
 * buttons, the current one owns a panel, and pressing one moves the reader.
 *
 * `active` is an index rather than a value, exactly as a timeline's is, because
 * a stepper has no selection: everything before it is done, the step at it is
 * where you are, everything after it is ahead.
 */
export const PlStepper = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlStepperProps>(
  function PlStepper(
    {
      active: activeProp,
      defaultActive = 0,
      onActiveChange,
      linear = true,
      orientation: orientationProp,
      connector = 'solid',
      keepMounted = false,
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    // Resolved here rather than in CSS, and it has to be: an orientation
    // changes which DOM this builds, which ARIA it claims and which way its
    // arrow keys go. The cost is the one every JavaScript answer about width
    // pays — a server renders the `xs` entry — and a bare value subscribes to
    // nothing at all.
    const orientation = useResponsiveValue(orientationProp, 'horizontal');

    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    const [uncontrolled, setUncontrolled] = React.useState(defaultActive);
    const active = activeProp ?? uncontrolled;
    const baseId = React.useId();

    const onSelect = React.useCallback(
      (index: number) => {
        if (activeProp === undefined) {
          setUncontrolled(index);
        }

        onActiveChange?.(index);
      },
      [activeProp, onActiveChange]
    );

    const [panelFocus] = React.useState(followPanelFocus);

    // After every commit rather than only when `active` moves, so a panel that
    // left for another reason, its content emptied, does not leave its answer
    // standing for the next move.
    React.useLayoutEffect(() => {
      panelFocus.settle(active);
    });

    // `Children.toArray` rather than the raw children, for the reason a timeline
    // walks its own: a conditional step that rendered nothing must not shift the
    // numbering of the ones after it.
    const steps = React.Children.toArray(children);
    const count = steps.length;

    const context = React.useMemo<StepperContextValue>(
      () => ({
        size,
        density,
        orientation,
        color,
        active,
        linear,
        connector,
        keepMounted,
        baseId,
        onSelect,
        panelRef: panelFocus.ref,
        stepRef: panelFocus.step
      }),
      [
        size,
        density,
        orientation,
        color,
        active,
        linear,
        connector,
        keepMounted,
        baseId,
        onSelect,
        panelFocus
      ]
    );

    const horizontal = orientation === 'horizontal';

    /** The panel of the step at `index`, under the rail, or nothing when it has none. */
    const panelAt = (index: number, key?: React.Key) => {
      const content = (steps[index] as React.ReactElement<PlStepProps> | undefined)?.props
        ?.children;

      return hasContent(content) ? (
        <div
          key={key}
          ref={panelFocus.ref(index)}
          // A group named by the step it belongs to, so a screen reader that
          // lands in the panel is told which step it is the panel for. A
          // name on an element with no role is never read, and a tab panel
          // or a region would claim more than a stepper is.
          role="group"
          aria-labelledby={`${baseId}-${index}`}
          // A kept panel of another step: in the HTML, and out of the layout,
          // the focus order and the accessibility tree.
          hidden={index !== active}
          // Reachable by script and never by Tab, for the focus that follows
          // the reader in from the last step. No ring: it marks no control.
          tabIndex={-1}
          className={cx('mt-4 outline-none', sheetBodyClasses[size])}
        >
          {content}
        </div>
      ) : null;
    };

    return (
      <StepperContext.Provider value={context}>
        <div
          ref={ref}
          className={cx('flex w-full flex-col', className)}
          style={{ ...surfaceSlots(color, 0), ...style }}
          {...props}
        >
          <ol
            // Tailwind's reset takes the markers off every `<ol>`, and Safari
            // takes the list semantics off with them. Saying it out loud is the
            // one-line fix, and it costs nothing when the reset is not there.
            role="list"
            className={cx('m-0 flex w-full list-none p-0', horizontal ? 'flex-row' : 'flex-col')}
          >
            {steps.map((step, index) => (
              <StepContext.Provider key={index} value={{ index, last: index === count - 1 }}>
                {step}
              </StepContext.Provider>
            ))}
          </ol>

          {/* Every step's panel when they are kept, and otherwise the one
              `active` is on. Each under its own step's key either way: what a
              kept panel holds stays with it, and moving on builds the next
              step's panel afresh rather than handing it the last one's
              element, which would carry a field's value from one step into
              the field at the same place in the next. */}
          {horizontal
            ? keepMounted
              ? steps.map((_, index) => panelAt(index, index))
              : panelAt(active, active)
            : null}
        </div>
      </StepperContext.Provider>
    );
  }
);

/**
 * One step.
 *
 * Its index is not a prop and cannot be: a step that had to be told where it
 * was would be one every caller could put in the wrong place, and `active={2}`
 * would stop meaning anything. The stepper numbers its children as it walks
 * them and hands each one its index through a context.
 */
export const PlStep = /* @__PURE__ */ React.forwardRef<HTMLLIElement, PlStepProps>(function PlStep(
  {
    label,
    description,
    bullet,
    status,
    optional,
    disabled = false,
    color,
    className,
    // Destructured rather than left in `...props`, or it would be spread onto
    // the `<li>` as well as drawn in the panel below — the same content twice.
    children,
    ...props
  },
  ref
) {
  const stepper = React.useContext(StepperContext);
  const { index, last } = React.useContext(StepContext);
  const labels = useLabels();

  // A bare step outside a stepper still renders — it is one step with nothing
  // before or after it. The defaults are the stepper's own.
  const size = stepper?.size ?? 'md';
  const orientation = stepper?.orientation ?? 'horizontal';
  const family = color ?? stepper?.color ?? 'primary';
  const active = stepper?.active ?? null;
  const connector = stepper?.connector ?? 'solid';
  const keepMounted = stepper?.keepMounted ?? false;

  const resolved: PlStepStatus = status ?? statusAt(index, active);
  const horizontal = orientation === 'horizontal';

  // A step ahead of the reader is out of reach while the stepper is linear, and
  // a step *behind* them never is: going back to correct an answer is the whole
  // reason a stepper is not a wizard with one door.
  const reachable = !disabled && stepper !== null && (!stepper.linear || index <= stepper.active);

  const drawsConnector = connector !== 'none' && !last;

  const bulletBox = (
    <span
      aria-hidden="true"
      className={cx(
        'relative z-10 flex shrink-0 items-center justify-center rounded-full',
        // The label inside the bullet is sized off the bullet rather than off
        // the page's own text, so a number in an `xs` bullet is not the same
        // 8px it would be in an `xl` one.
        'size-(--p-bullet) text-[calc(var(--p-bullet)*0.5)] leading-none font-semibold tabular-nums',
        bulletStatusClasses[resolved],
        transitionClasses,
        iconClasses
      )}
    >
      {bullet ?? (resolved === 'complete' ? <StepTick /> : index + 1)}
    </span>
  );

  const text = (
    <span className={cx('flex min-w-0 flex-col', horizontal ? 'items-center text-center' : '')}>
      <span
        id={stepper ? `${stepper.baseId}-${index}` : undefined}
        className={cx(
          'font-semibold',
          sheetTitleClasses[size],
          titleStatusClasses[resolved],
          transitionClasses
        )}
      >
        {label}
      </span>

      {hasContent(description) ? (
        <span className={cx('text-(--plass-muted-fg)', metaTextClasses[size])}>{description}</span>
      ) : null}

      {optional ? (
        <span className={cx('text-(--plass-muted-fg) italic', metaTextClasses[size])}>
          {optional === true ? labels.optional : optional}
        </span>
      ) : null}
    </span>
  );

  const marker = (
    <span
      className={cx(
        'flex items-center',
        horizontal ? 'flex-col' : 'flex-row',
        bulletGapClasses[size]
      )}
    >
      {bulletBox}
      {horizontal ? text : null}
    </span>
  );

  const inner = reachable ? (
    <button
      ref={stepper?.stepRef(index)}
      type="button"
      // `aria-current="step"` and never `aria-selected`: a stepper is not a tab
      // list, and claiming a role without its keyboard behaviour is worse than
      // never claiming it.
      aria-current={resolved === 'current' ? 'step' : undefined}
      onClick={() => stepper?.onSelect(index)}
      className={cx(
        'flex cursor-pointer items-center bg-transparent p-1',
        horizontal ? 'flex-col' : 'flex-row',
        bulletGapClasses[size],
        radiusClasses[size],
        focusRingClasses,
        transitionClasses,
        'hover:bg-(--p-soft)'
      )}
    >
      {horizontal ? marker : bulletBox}
      {horizontal ? null : text}
    </button>
  ) : (
    <span
      aria-current={resolved === 'current' ? 'step' : undefined}
      className={cx(
        'flex items-center p-1',
        horizontal ? 'flex-col' : 'flex-row',
        bulletGapClasses[size],
        disabled ? 'opacity-50' : ''
      )}
    >
      {horizontal ? marker : bulletBox}
      {horizontal ? null : text}
    </span>
  );

  return (
    <li
      ref={ref}
      className={cx(
        'relative flex min-w-0',
        horizontal ? 'flex-1 flex-col items-center' : 'flex-col',
        className
      )}
      // The step's own family, so one step in a sequence can be marked out —
      // the one that failed validation, in `danger`, while the rest stay the
      // stepper's colour.
      style={
        {
          '--p-bullet': bulletSizeValues[size],
          ...surfaceSlots(family, 0),
          // A container's slots leave the sheet undyed, which is right for the
          // ground a bullet sits on — but a bullet *is* the thing being
          // coloured, so the two fills it needs are put back.
          '--p-fill': `var(--plass-${family}-fill)`,
          '--p-on-solid': `var(--plass-${family}-on-solid)`
        } as React.CSSProperties
      }
      {...props}
    >
      <span className={cx('flex w-full', horizontal ? 'flex-row items-start' : 'flex-col')}>
        {inner}

        {drawsConnector ? (
          <span
            aria-hidden="true"
            className={cx(
              horizontal
                ? // Centred on the bullet, which is why the bullet's size is a
                  // custom property rather than a class.
                  'mt-[calc(var(--p-bullet)/2+0.25rem)] h-0 flex-1 border-t'
                : 'ms-[calc(var(--p-bullet)/2+0.25rem)] w-0 flex-1 self-stretch border-s',
              connectorStyleClasses[connector],
              connectorColorClasses[resolved],
              transitionClasses
            )}
          />
        ) : null}
      </span>

      {/* A vertical stepper puts the panel inside the step it belongs to, which
          is the whole reason to lay one out vertically: the answer sits under
          the question rather than under the whole rail. It follows `active`
          rather than `status`, as the horizontal panel does, so a step marked
          `current` again behind the reader does not open a second one. With
          `keepMounted` every step keeps its panel, hidden until `active`
          reaches it. */}
      {!horizontal && (index === active || keepMounted) && hasContent(children) ? (
        <div
          ref={stepper?.panelRef(index)}
          // Named by the step it sits in, as the horizontal panel is named by
          // the step it belongs to.
          role="group"
          aria-labelledby={stepper ? `${stepper.baseId}-${index}` : undefined}
          hidden={index !== active}
          // Where the focus lands when it follows the reader in, as on the
          // horizontal panel.
          tabIndex={-1}
          className={cx(
            'ms-[calc(var(--p-bullet)+0.75rem)] pt-2 pb-4 outline-none',
            sheetBodyClasses[size]
          )}
        >
          {children}
        </div>
      ) : null}
    </li>
  );
});
