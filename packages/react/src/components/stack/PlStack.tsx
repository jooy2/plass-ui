'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { cx, toLength } from '../../internal/styles.js';
import { useResponsiveValue } from '../../internal/responsive.js';
import type { PlassResponsive, PlassSize } from '../../types.js';

/** Which way the pile grows. */
export type PlStackDirection = 'horizontal' | 'vertical' | 'diagonal';

/** Which end of the list is on top. */
export type PlStackFront = 'first' | 'last';

export interface PlStackProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which way the pile grows.
   *
   * `diagonal` is a **fan** rather than a true 45°, and it cannot be anything
   * else: the horizontal advance is `item width − overlap`, and a component that
   * takes arbitrary children does not know how wide they are. `drop` is the
   * vertical step, stated separately, and the two are independent on purpose.
   * @default 'horizontal'
   */
  direction?: PlassResponsive<PlStackDirection>;
  /**
   * How far each item sits under the one before it, along the axis the pile
   * flows on — a number of pixels or any CSS length.
   *
   * Left out it is a fraction of `size`, which keeps the overlap looking the
   * same at every step.
   */
  overlap?: number | string;
  /**
   * The step on the *other* axis, for `direction="diagonal"` only. Defaults to
   * whatever `overlap` resolved to, which is a 45° fan for square items and a
   * shallower one for anything wider than it is tall.
   */
  drop?: number | string;
  /**
   * Which rung of the ladder the default `overlap` comes off.
   *
   * It decides **nothing else**. A stack draws no surface of its own and has no
   * type in it, so there is no height to set and no ink to colour — the items
   * are whatever they already were.
   * @default 'md'
   */
  size?: PlassSize;
  /** How many items are drawn. Left out, every one of them is. */
  max?: number;
  /**
   * How many there are altogether, when the stack was handed only the first few.
   * Without it the count is worked out from the children, which is right only
   * when all of them were passed.
   */
  total?: number;
  /**
   * Draws a last item standing for the ones that did not fit, given how many
   * that is: `(n) => <PlAvatar initials={`+${n}`} />`.
   *
   * A function rather than a node, because the number **is** the item — a node
   * would have to be given a count it has no way to work out, and would then be
   * wrong every time the list changed.
   */
  overflow?: (hidden: number) => React.ReactNode;
  /**
   * Which end of the list is on top.
   *
   * `last` is what the DOM does on its own and what a row of faces wants — the
   * newest arrival in front. `first` is what a deck of cards is: the top card is
   * the one you read first.
   * @default 'last'
   */
  front?: PlStackFront;
  /**
   * What each item further back is multiplied by, compounding. `0.94` takes four
   * steps down to about 78%.
   *
   * On the standalone `scale` property rather than inside a `transform`, so a
   * caller's own transform on the same item survives.
   * @default 1
   */
  scaleStep?: number;
  /** The same, for opacity. @default 1 */
  opacityStep?: number;
  /**
   * Draws a hairline of the page's own surface colour around each item, which
   * is the *hole* the near item is cut out of rather than an edge on it.
   *
   * Two shapes of similar tone laid over each other have no boundary between
   * them at all and the pile reads as one smeared shape. A translucent line
   * would not help, because what is behind it is the other item.
   *
   * It lands on **the element you passed**, so it takes that element's shape.
   * Wrap an avatar in something square and the ring is square; there is no way
   * for a component that accepts arbitrary children to know better.
   * @default false
   */
  ring?: boolean;
  /** The things in the pile. */
  children?: React.ReactNode;
}

/**
 * How far one item sits under the last, per rung.
 *
 * Roughly a third of a control at every size: enough that the pile reads as a
 * pile, and not so much that what is behind is hidden by what is in front.
 */
const overlapSizes: Record<PlassSize, string> = {
  xs: '0.5rem',
  sm: '0.625rem',
  md: '0.875rem',
  lg: '1rem',
  xl: '1.25rem'
};

/**
 * The flow, per direction — and the whole of why this is a layout rather than
 * an offset.
 *
 * **The overlap is a negative margin, never a `translate`.** A translated pile
 * is laid out as one item wide: it draws outside its own box, and everything
 * after it on the page is placed against a width that is not what the reader
 * sees. A negative margin makes the box measure exactly what it draws, so a
 * stack can sit in a sentence, in a table cell, or in a flex row beside a label
 * without any of them being told a lie about its size.
 *
 * `diagonal` flows on the **horizontal** axis for the same reason `horizontal`
 * does, and takes its vertical step per item instead. That last part is not
 * interchangeable: a flow only overlaps on the axis it flows along, so one fixed
 * `margin-block-start` in a row would put every item at the same height. The
 * other axis has to be multiplied by the item's own index, which is what the
 * inline style below does.
 */
const flowClasses: Record<PlStackDirection, string> = {
  horizontal: /* @__PURE__ */ [
    'flex-row',
    '[&>*:not(:first-child)]:[margin-inline-start:calc(var(--p-overlap)*-1)]'
  ].join(' '),
  vertical: /* @__PURE__ */ [
    'flex-col',
    '[&>*:not(:first-child)]:[margin-block-start:calc(var(--p-overlap)*-1)]'
  ].join(' '),
  diagonal: /* @__PURE__ */ [
    'flex-row',
    '[&>*:not(:first-child)]:[margin-inline-start:calc(var(--p-overlap)*-1)]'
  ].join(' ')
};

/**
 * The hairline, at the one depth it can be written at.
 *
 * Three levels down is the item the caller passed: the stack's own offset
 * wrapper, the box holding the depth, and then their element. A fixed depth is
 * ugly and it is the honest answer — the alternative is copying a class onto the
 * children with `cloneElement`, which stops working the moment one of them is a
 * `PlTooltip`, a fragment, or the output of somebody else's `.map()`. That is
 * the same reason `PlAvatar` reads its group's axes from a context rather than
 * being cloned.
 */
const ringClasses = '[&>*>*>*]:ring-2 [&>*>*>*]:ring-(--plass-surface)';

/**
 * Things piled up, overlapping.
 *
 * A row of faces is one arrangement of this and not a component of its own: a
 * deck of cards, a pile of documents, a fan of thumbnails and a stack of avatars
 * differ in what is in them, not in how they are laid out. So this takes
 * whatever it is given and never looks inside.
 *
 * Which is also what it gives up. It cannot set an axis on its items the way a
 * `PlAvatarGroup` used to, because it does not know what they are — put a
 * `PlassProvider` around it for `size` and `color`, and write anything narrower
 * on the items themselves.
 *
 * Two boxes are drawn per item rather than one, and the second is not spare. The
 * outer one carries the offset and the stacking order; the inner one carries the
 * depth, on the standalone `scale` and `opacity` properties. Kept on one box,
 * an entrance animation that writes `scale` — every keyframe in this library
 * that grows or zooms does — would overwrite the depth on its first frame.
 */
export const PlStack = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlStackProps>(
  function PlStack(
    {
      direction: directionProp,
      overlap,
      drop,
      size: sizeProp,
      max,
      total,
      overflow,
      front = 'last',
      scaleStep = 1,
      opacityStep = 1,
      ring = false,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    // Resolved here rather than in CSS: the direction decides which margin
    // axis each item takes and which one the drop is multiplied on, and those
    // are different declarations rather than one value. A bare direction
    // subscribes to nothing.
    const direction = useResponsiveValue(directionProp, 'horizontal');

    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';

    const step = overlap === undefined ? overlapSizes[size] : (toLength(overlap) as string);
    const fall = drop === undefined ? step : (toLength(drop) as string);

    const items = React.Children.toArray(children);
    const shown = max === undefined ? items : items.slice(0, Math.max(0, max));
    const counted = total ?? items.length;
    const hidden = Math.max(0, counted - shown.length);

    const piled: React.ReactNode[] =
      overflow && hidden > 0 ? [...shown, overflow(hidden)] : [...shown];

    return (
      <div
        ref={ref}
        className={cx(
          // `isolate` so the first item's ring is painted against the page
          // rather than against whatever is behind the stack.
          'isolate inline-flex items-start',
          flowClasses[direction],
          ring ? ringClasses : '',
          className
        )}
        style={{ '--p-overlap': step, ...style } as React.CSSProperties}
        {...props}
      >
        {piled.map((item, index) => {
          // DOM order paints later children on top, which is the answer for
          // exactly one of the two readings. Stated rather than inherited, so
          // the other one is available and neither depends on the browser.
          const depth = front === 'first' ? index : piled.length - 1 - index;

          return (
            <span
              key={index}
              className="flex shrink-0"
              style={{
                zIndex: front === 'first' ? piled.length - index : index + 1,
                ...(direction === 'diagonal' && index > 0
                  ? { marginBlockStart: `calc(${fall} * ${index})` }
                  : null)
              }}
            >
              <span
                className="flex"
                style={{
                  ...(scaleStep === 1 ? null : { scale: String(scaleStep ** depth) }),
                  ...(opacityStep === 1 ? null : { opacity: opacityStep ** depth })
                }}
              >
                {item}
              </span>
            </span>
          );
        })}
      </div>
    );
  }
);
