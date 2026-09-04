'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import {
  controlTextLeadingClasses,
  cx,
  hasContent,
  sheetLineClasses,
  toLength
} from '../../internal/styles.js';
import type { PlassDensity, PlassOrientation, PlassSize } from '../../types.js';

/** What a row inherits from the list around it. */
interface PlassDataListContextValue {
  orientation: PlassOrientation;
  size: PlassSize;
  density: PlassDensity;
  labelWidth: string | undefined;
  divider: boolean;
}

/**
 * Local rather than in `internal/`, because only these two components exist and
 * a row is meaningless outside its list — unlike a `PlButton`, which is a
 * component in its own right that a `PlButtonGroup` happens to contain.
 */
const DataListContext = /* @__PURE__ */ React.createContext<PlassDataListContextValue>({
  orientation: 'horizontal',
  size: 'md',
  density: 'default',
  labelWidth: undefined,
  divider: false
});

export interface PlDataListProps extends React.ComponentPropsWithoutRef<'dl'> {
  /**
   * Where the label sits.
   *
   * - `horizontal` — beside the value, in a column of its own. The default, and
   *   the shape a details panel takes.
   * - `vertical` — above it. For a narrow column, or for values long enough
   *   that a label beside them leaves the value nowhere to go.
   * @default 'horizontal'
   */
  orientation?: PlassOrientation;
  /**
   * How wide the label column is, while the labels are beside the values.
   *
   * A number is pixels; a string is any CSS length, and `'12ch'` is usually
   * the right one — a label column is measured in characters, not in pixels,
   * and no ladder of `rem` can spell that.
   * @default '10rem'
   */
  labelWidth?: number | string;
  /** Draws a hairline between the rows. @default false */
  divider?: boolean;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'default' */
  density?: PlassDensity;
  /** The `PlDataListItem`s. */
  children?: React.ReactNode;
}

export interface PlDataListItemProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'title'> {
  /** What the value is of. */
  label?: React.ReactNode;
  /** The value. `children` says the same thing and is there for a value with markup in it. */
  value?: React.ReactNode;
  /** A glyph before the label. */
  icon?: React.ReactNode;
  /** The value, when it is more than a string. */
  children?: React.ReactNode;
}

/** The space between one row and the next. */
const rowGapClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'gap-2', sm: 'gap-2.5', md: 'gap-3', lg: 'gap-3.5', xl: 'gap-4' },
  compact: { xs: 'gap-1', sm: 'gap-1.5', md: 'gap-2', lg: 'gap-2', xl: 'gap-2.5' }
};

/** The space between a label and its value, once they are stacked. */
const stackGapClasses: Record<PlassSize, string> = {
  xs: 'gap-0.5',
  sm: 'gap-0.5',
  md: 'gap-1',
  lg: 'gap-1',
  xl: 'gap-1.5'
};

/** A divided row's padding, so the hairline has something to sit between. */
const dividedPaddingClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'pt-2', sm: 'pt-2.5', md: 'pt-3', lg: 'pt-3.5', xl: 'pt-4' },
  compact: { xs: 'pt-1', sm: 'pt-1.5', md: 'pt-2', lg: 'pt-2', xl: 'pt-2.5' }
};

const DEFAULT_LABEL_WIDTH = '10rem';

/**
 * A list of labels and the values that go with them.
 *
 * The panel every detail screen ends with — a plan, an owner, a created date, a
 * status — and the whole reason it is a component is the **markup**. It is a
 * real `<dl>` with real `<dt>`s and `<dd>`s, which is what says that "Owner"
 * names "Ada Lovelace" rather than being a line of text that happens to sit
 * beside it. A screen reader reads the pair; a grid of `<div>`s reads as eight
 * loose strings, and the reader has to guess which belongs to which.
 *
 * It is not a [PlTable](./table). A table is many things with the same fields;
 * this is **one** thing and its fields. A details panel built as a two-column
 * table claims a row and column relationship that is not there, and a reader
 * navigating it by cell is told there are two columns of data when there is a
 * column of names and a column of values.
 *
 * Nor is it a [PlList](./list), which is a run of items of the same kind.
 *
 * The rows are children rather than data, unlike a `PlTable`'s columns. A
 * details panel is written out once and read in source order, and every value
 * in it is a different shape — a chip, a date, an avatar, a link — so a data
 * array would be an array of `render` functions.
 */
export const PlDataList = /* @__PURE__ */ React.forwardRef<HTMLDListElement, PlDataListProps>(
  function PlDataList(
    {
      orientation = 'horizontal',
      labelWidth,
      divider = false,
      size: sizeProp,
      density: densityProp,
      className,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const density = densityProp ?? defaults.density ?? 'default';

    const context = React.useMemo(
      () => ({
        orientation,
        size,
        density,
        labelWidth: toLength(labelWidth) ?? DEFAULT_LABEL_WIDTH,
        divider
      }),
      [orientation, size, density, labelWidth, divider]
    );

    return (
      <DataListContext.Provider value={context}>
        <dl
          ref={ref}
          className={cx(
            'm-0 flex flex-col',
            // A divided list holds its own gap: the hairline needs padding
            // either side of it rather than a gap around it, or the line sits
            // in the middle of empty space instead of between two rows.
            divider ? '' : rowGapClasses[density][size],
            controlTextLeadingClasses[size],
            className
          )}
          {...props}
        >
          {children}
        </dl>
      </DataListContext.Provider>
    );
  }
);

/**
 * One label and its value.
 *
 * Wrapped in a `<div>` inside the `<dl>`, which is what the HTML specification
 * allows and what lets a row be laid out at all: a `<dt>` and a `<dd>` that are
 * direct children of the list cannot be put side by side without giving up the
 * grouping that makes them a pair.
 */
export const PlDataListItem = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlDataListItemProps>(
  function PlDataListItem({ label, value, icon, className, children, ...props }, ref) {
    const { orientation, size, density, labelWidth, divider } = React.useContext(DataListContext);
    const horizontal = orientation === 'horizontal';

    return (
      <div
        ref={ref}
        className={cx(
          'flex min-w-0',
          horizontal ? 'flex-row gap-4' : 'flex-col',
          horizontal ? '' : stackGapClasses[size],
          divider ? `${dividedPaddingClasses[density][size]} first:pt-0` : '',
          divider ? `${sheetLineClasses} first:border-t-0` : '',
          className
        )}
        {...props}
      >
        <dt
          className="flex shrink-0 items-center gap-1.5 text-(--plass-muted-fg)"
          style={horizontal ? { width: labelWidth } : undefined}
        >
          {hasContent(icon) ? (
            <span aria-hidden="true" className="flex items-center [&_svg]:size-[1.15em]">
              {icon}
            </span>
          ) : null}
          {label}
        </dt>
        <dd className="m-0 min-w-0 flex-1 text-(--plass-fg)">{value ?? children}</dd>
      </div>
    );
  }
);
