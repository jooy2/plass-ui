import * as React from 'react';
import { PlButton } from '../button/PlButton.js';
import {
  cx,
  hasContent,
  metaTextClasses,
  radiusClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetRestClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassColor,
  PlassDensity,
  PlassElevation,
  PlassSize,
  PlassVariant
} from '../../types.js';

export interface PlSpoilerProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'onChange'
> {
  /** Whether the content is uncovered. Use with `onRevealedChange` for a controlled one. */
  revealed?: boolean;
  /** Where an uncontrolled spoiler starts. @default false */
  defaultRevealed?: boolean;
  onRevealedChange?: (revealed: boolean) => void;
  /** The reveal button's label. @default 'Reveal' */
  label?: React.ReactNode;
  /** The hide button's label, when `reversible` is on. @default 'Hide' */
  hideLabel?: React.ReactNode;
  /**
   * The line above the button, saying why the content is covered. Pass `false`
   * for a cover with nothing written on it.
   * @default 'This may contain spoilers'
   */
  description?: React.ReactNode | false;
  /**
   * Replaces the default reveal button entirely.
   *
   * The replacement is yours to wire up: pass `revealed` and `onRevealedChange`
   * and drive it from your own control. `label` is the prop for the far
   * commoner case of wanting different words on the button that is already
   * there.
   */
  action?: React.ReactNode;
  /**
   * Keeps the content coverable: once revealed, a hide button appears under it.
   * @default false
   */
  reversible?: boolean;
  /**
   * Clamps the covered box to this height — a CSS length, or a number in pixels.
   * Revealing releases it and the content takes whatever height it needs.
   *
   * Left out, the box is exactly as tall as what it holds, which is the right
   * default for a paragraph or a picture. Set it for something long enough that
   * a page of blurred content would be a page of nothing.
   */
  maxHeight?: number | string;
  /** How hard the content is blurred, in pixels. @default 10 */
  blur?: number;
  /**
   * Inner padding around the content, on the sheet's `size` / `density` scale.
   * Turn it off for something that should reach the edges — a picture, a video.
   * @default true
   */
  padded?: boolean;
  /**
   * What the sheet is made of. `ghost` draws no box at all, which is what a
   * spoiler sitting inside running prose usually wants.
   * @default 'glass'
   */
  variant?: PlassVariant;
  /** The sheet's radius, and the size of the button on it. @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** Padding around the cover's own text and button. @default 'default' */
  density?: PlassDensity;
  /** Drop shadow depth. `0` is the default and it is flat. @default 0 */
  elevation?: PlassElevation;
  /** What is being covered. */
  children?: React.ReactNode;
}

/**
 * The wash between the blurred content and the words on top of it.
 *
 * Blur alone is not cover. It takes a paragraph apart but leaves its colour and
 * its rhythm — a photograph blurred at 10px is still recognisably a photograph
 * of a face — and it leaves the button standing on whatever happened to be
 * underneath it. Mixing the page's own surface over the top settles both: the
 * content goes to a wash of its own colours, and the button gets something to
 * stand on.
 */
const scrimClasses = '[background-color:color-mix(in_oklab,var(--plass-surface)_55%,transparent)]';

/**
 * Content that is covered until somebody asks for it.
 *
 * The cover is a **blur** rather than a `display: none`, which is the whole
 * point: a reader can see that there is something there, roughly how much of it
 * there is, and — with `maxHeight` — that it has been clamped. What they cannot
 * do is read it by accident, which is the one thing a spoiler is for.
 *
 * While it is covered the content is `inert`, so it is not tabbable, not
 * readable by a screen reader and not selectable by a drag across the page. A
 * spoiler that could be defeated by <kbd>Ctrl</kbd>+<kbd>A</kbd> is not a
 * spoiler.
 *
 * The sheet is never dyed, exactly as on a `PlCard`: what a spoiler holds is a
 * photograph, a paragraph, a plot twist, and it arrives with its own colours.
 * The family shows up on the button and in the hairline and stops there.
 */
export const PlSpoiler = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlSpoilerProps>(
  function PlSpoiler(
    {
      revealed,
      defaultRevealed = false,
      onRevealedChange,
      label = 'Reveal',
      hideLabel = 'Hide',
      description = 'This may contain spoilers',
      action,
      reversible = false,
      maxHeight,
      blur = 10,
      padded = true,
      variant = 'glass',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const contentId = React.useId();

    const [uncontrolled, setUncontrolled] = React.useState(defaultRevealed);
    const open = revealed ?? uncontrolled;

    const change = (next: boolean) => {
      if (revealed === undefined) {
        setUncontrolled(next);
      }

      onRevealedChange?.(next);
    };

    const insetX = sheetPaddingXClasses[density][size];
    const insetY = sheetPaddingYClasses[density][size];
    const notice = description === false ? null : description;

    return (
      <div
        ref={ref}
        className={cx(
          // A grid rather than a box with an absolutely positioned cover on it,
          // and the difference is what happens to a *short* spoiler: an
          // absolute cover is laid out against a box the content alone decided
          // the height of, so a one-line spoiler clips its own Reveal button.
          // Both children are put in the same cell instead, so the row is as
          // tall as whichever of them needs more and they stretch to match.
          'isolate grid overflow-hidden',
          radiusClasses[size],
          sheetRestClasses[variant],
          transitionClasses,
          className
        )}
        style={{ ...surfaceSlots(color, elevation), ...style }}
        {...props}
      >
        <div
          id={contentId}
          className={cx(
            'min-w-0 [grid-area:1/1]',
            padded ? `${insetX} ${insetY}` : '',
            '[transition:filter_var(--plass-duration-slow)_var(--plass-ease)]',
            'motion-reduce:[transition-duration:0ms]',
            open ? '' : 'select-none'
          )}
          style={{
            filter: open ? undefined : `blur(${blur}px)`,
            // The clamp is only ever on the covered state: revealing something
            // and leaving it in a box with a scrollbar is answering the wrong
            // question.
            maxHeight: open ? undefined : maxHeight,
            overflow: open ? undefined : 'hidden'
          }}
          // `inert` rather than `aria-hidden`: it takes the content out of the
          // tab order, off the accessibility tree and out of the selection in
          // one attribute — and `aria-hidden` alone would leave a keyboard
          // reader tabbing into a link their screen reader has been told is not
          // there.
          inert={!open}
        >
          {children}
        </div>

        {open ? null : (
          <div
            className={cx(
              'z-10 flex flex-col items-center justify-center gap-2 text-center [grid-area:1/1]',
              insetX,
              insetY,
              scrimClasses
            )}
          >
            {hasContent(notice) ? (
              <p className={cx('m-0 text-(--plass-muted-fg)', metaTextClasses[size])}>{notice}</p>
            ) : null}

            {action ?? (
              <PlButton
                size={size}
                color={color}
                density={density}
                onClick={() => change(true)}
                aria-expanded={false}
                aria-controls={contentId}
              >
                {label}
              </PlButton>
            )}
          </div>
        )}

        {open && reversible ? (
          <div
            className={cx(
              'flex justify-end',
              insetX,
              // The row takes the sheet's padding on both axes and then gives
              // the top back: `padded` content already ends with a full gap, and
              // two of them stacked is a hole between the text and the way back
              // out. `pt-0` beating `py-*` is Tailwind's own
              // longhand-after-shorthand ordering rather than an accident of how
              // these are concatenated.
              insetY,
              'pt-0'
            )}
          >
            <PlButton
              variant="ghost"
              size={size}
              color={color}
              density={density}
              onClick={() => change(false)}
              aria-expanded
              aria-controls={contentId}
            >
              {hideLabel}
            </PlButton>
          </div>
        ) : null}
      </div>
    );
  }
);
