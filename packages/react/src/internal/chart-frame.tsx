'use client';

/**
 * Everything a chart draws that is not its marks.
 *
 * The split this file makes is the one the whole `internal/` folder is about:
 * a PlLineChart, an PlAreaChart and a PlBarChart differ in about forty lines each —
 * a path, a band, a rounded end — and agree on everything else. The axes, the
 * grid, the legend, the crosshair, the tooltip, the empty state, the hidden
 * table a screen reader reads instead of the picture, and the measurement that
 * turns a percentage width into the pixels an SVG needs are all the same
 * problem five times over.
 *
 * So `CartesianChart` is the chart, and a component hands it a function that
 * draws the marks. What is left in `PlLineChart.tsx` is the line.
 *
 * `internal/chart.ts` is the arithmetic under this; nothing in there knows what an
 * element is, and nothing in here does arithmetic that is not layout.
 */

import * as React from 'react';
import { PlBox, type PlBoxProps } from '../components/box/PlBox.js';
import {
  bandScale,
  categoryAt,
  categoryCount,
  categoryExtent,
  chartFontSizes,
  compactNumber,
  extentOf,
  fitsLast,
  formatCategory,
  markerRadii,
  plotHeights,
  seriesColor,
  showsTick,
  textWidth,
  tickStride,
  toValues,
  truncate,
  valueScale,
  type BandScale,
  type ChartValue,
  type PlotBox,
  type ValueScale
} from './chart.js';
import { useDefaults } from './defaults.js';
import { numberFormatter } from './format.js';
import { usePlElementSize } from '../hooks/usePlElementSize.js';
import { useLabels } from './labels.js';
import { cx, hasContent, metaTextClasses, srOnlyClasses, transitionClasses } from './styles.js';
import type {
  PlassChartAxis,
  PlassChartCategory,
  PlassChartLegend,
  PlassChartSeries,
  PlassChartTooltip,
  PlassSize
} from '../types.js';

/* ---------------------------------------------------------------------------
 * Measurement
 * ------------------------------------------------------------------------- */

/** One array rather than a fresh `[]` per render, for the charts with no marks. */
const noMarks: readonly ChartMark[] = [];

/**
 * How wide the chart actually is, in pixels.
 *
 * An SVG cannot lay a chart out from a percentage: every tick position, every
 * bar width and the decision about how many category labels fit are arithmetic
 * on a number, and `100%` is not one. So the host element is measured and the
 * drawing waits for the answer.
 *
 * The wait is one frame and not one paint — `useLayoutEffect` runs before the
 * browser draws, so the empty state never reaches the screen. What does reach
 * it on a server-rendered page is a box of the right height with nothing in it,
 * which is why the height is a prop and not something measured too: a reserve
 * that is dropped when the content arrives is the same jump twice.
 */
function useMeasuredWidth(ref: React.RefObject<HTMLElement | null>): number {
  // `usePlElementSize` is the library's own `ResizeObserver`, and it reads the
  // element in a layout effect as well as from the observer — which is what
  // keeps a chart from laying itself out at zero for the one frame before the
  // observer's first callback arrives.
  return usePlElementSize(ref)?.width ?? 0;
}

/* ---------------------------------------------------------------------------
 * Shared props
 * ------------------------------------------------------------------------- */

/**
 * What every chart takes, and the reason it is one interface: a dashboard is
 * built by copying a tile and changing the component in it, and that only works
 * if `height`, `legend`, `tooltip` and `format` mean the same thing on all of
 * them.
 *
 * `variant` defaults to `ghost` and `padded` to `false`, which is the one place
 * a chart deviates from `PlBox`. A chart is a *drawing*, not a sheet — it goes
 * on a `PlCard`, next to the number it explains, and a sheet of its own inside
 * that card would be two edges where the design language wants one.
 * `variant="glass"` is there for the chart that stands on the page by itself.
 */
/**
 * How a mark answers the pointer: the three properties one is allowed to change
 * when the reader points at it, and how long each takes.
 *
 * One declaration and one class on every mark, rather than one per property.
 * `transition` is a shorthand, so two of them on the same element are decided by
 * their order in the generated stylesheet rather than by intent — a scatter mark
 * carrying a fade *and* a grow written separately keeps whichever Tailwind
 * happened to emit last, which is the kind of bug that looks like the browser's
 * fault. A property an element never changes costs it nothing.
 *
 * **`opacity`** is two states that are the same sentence at two scales. A whole
 * *series* drops to 0.28 when the legend is pointed at one of the others; a
 * single *datum* sits at 0.92 until the crosshair reaches it. Both mean "this is
 * the one you asked about". It is also the one place a chart may say something
 * with opacity at all: nothing here is a control, and "not the one you are
 * pointing at" is not a state a colour family can carry without recolouring the
 * data.
 *
 * **`r`** and **`scale`** are the same pixel of growth reached two ways, because
 * the two shapes that grow are drawn differently. A line's marker is a
 * `<circle>`, whose radius is the geometry property `r` — a number, which
 * travels. A scatter's mark is an arbitrary `<path>`, whose size lives inside
 * `d`, which does not; that one grows on the independent `scale` property about
 * the point it is pinned to, so a triangle grows where it stands rather than
 * drifting toward the middle of its own bounding box.
 *
 * Only the pie and the heatmap ever moved on any of this. The line, the area,
 * the bar, the scatter and the timeline snapped, and a dashboard holding two of
 * each showed both answers at once.
 */
export const markTransitionClasses = [
  '[transition:opacity_var(--plass-duration)_var(--plass-ease),',
  'r_var(--plass-duration)_var(--plass-ease),',
  'scale_var(--plass-duration)_var(--plass-ease)]'
].join('');

export interface ChartBaseProps extends Omit<PlBoxProps, 'children' | 'title'> {
  /**
   * How tall the drawing is. A number is pixels; a string is any CSS length.
   * Defaults to the `size` ladder.
   *
   * The axis labels are drawn *inside* this, not under it, so a card sized to
   * the chart is a card the chart fits in.
   */
  height?: number | string;
  /**
   * How the numbers are written, everywhere they appear — the axis, the
   * tooltip, the labels on the marks. `Intl.NumberFormat` options, the same
   * prop Statistic and the progress indicators take.
   *
   * Without it an axis tick is compacted past ten thousand (`12.4K`), because
   * four labels of seven digits is a chart with a column of numbers beside it.
   */
  format?: Intl.NumberFormatOptions;
  /** Which language the chart's own words and dates are in. @default the reader's */
  locale?: string;
  /**
   * The chart's accessible name — what it is a chart *of*. Read out in place of
   * the drawing, and used as the caption of the table underneath it.
   */
  label?: string;
  /**
   * The legend. Shown automatically from two series up and left off below that,
   * because a legend with one swatch in it restates the title.
   *
   * `false` turns it off; an object places it and says whether it does anything
   * when clicked.
   */
  legend?: boolean | PlassChartLegend;
  /**
   * What the pointer uncovers. On by default — a chart drawn in a browser is
   * interactive, and a reader who wants the number for March should not have to
   * measure it against a gridline.
   *
   * It never carries a value that is not readable another way: the table under
   * every chart has all of them.
   */
  tooltip?: boolean | PlassChartTooltip;
  /** What to draw when there is nothing to draw. */
  empty?: React.ReactNode;
}

/** The props a chart with two axes adds. */
export interface CartesianChartProps extends ChartBaseProps {
  /** The series, in the order their colours are handed out. */
  series: readonly PlassChartSeries[];
  /** The category axis' labels. Points may carry their own `x` instead. */
  categories?: readonly PlassChartCategory[];
  /** The category axis. */
  xAxis?: PlassChartAxis;
  /** The value axis. */
  yAxis?: PlassChartAxis;
}

/* ---------------------------------------------------------------------------
 * Visibility
 * ------------------------------------------------------------------------- */

interface Visibility {
  visible: boolean[];
  hovered: number | null;
  toggle: (index: number) => void;
  setHovered: (index: number | null) => void;
}

/**
 * Which series are drawn, and which one the pointer is resting on in the legend.
 *
 * Keyed by index into the array as it was passed, which is what keeps a hidden
 * series from renumbering the ones after it. The colours come off the same
 * index, so hiding Europe leaves Asia exactly the colour it was.
 */
function useVisibility(series: readonly PlassChartSeries[]): Visibility {
  const [hidden, setHidden] = React.useState<ReadonlySet<number>>(() => {
    const initial = new Set<number>();

    series.forEach((one, index) => {
      if (one.hidden) {
        initial.add(index);
      }
    });

    return initial;
  });

  const [hovered, setHovered] = React.useState<number | null>(null);

  const toggle = React.useCallback((index: number) => {
    setHidden((current) => {
      const next = new Set(current);

      if (next.has(index)) {
        next.delete(index);
      } else {
        next.add(index);
      }

      return next;
    });
  }, []);

  return {
    visible: series.map((_, index) => !hidden.has(index)),
    hovered,
    toggle,
    setHovered
  };
}

/* ---------------------------------------------------------------------------
 * Legend
 * ------------------------------------------------------------------------- */

const legendSideClasses = {
  top: 'flex-col-reverse',
  bottom: 'flex-col',
  left: 'flex-row-reverse',
  right: 'flex-row'
} as const;

const legendAlignClasses = {
  start: 'justify-start',
  center: 'justify-center',
  end: 'justify-end'
} as const;

interface LegendProps {
  series: readonly PlassChartSeries[];
  colors: readonly string[];
  options: PlassChartLegend;
  visibility: Visibility;
  size: PlassSize;
  values?: readonly (string | undefined)[];
  swatch?: (index: number, color: string) => React.ReactNode;
}

/**
 * The dependable identity channel.
 *
 * A swatch and a word, and the swatch is the only thing on it wearing the
 * series colour — the name is ink, at whatever the size ladder says, because a
 * light hue is illegible as text and because colour is what the swatch beside
 * it is for.
 *
 * A hidden series stays in the legend and goes grey rather than disappearing:
 * a list that shortens when you click it is a list you cannot click twice.
 *
 * `swatch` is for the chart whose marks carry a second identity channel. A
 * scatter past the third series tells its series apart by shape as well as by
 * hue, and a legend that answered with eight identical squares would be back to
 * colour alone — which is the thing the shapes were added to fix.
 */
function ChartLegendBar({
  series,
  colors,
  options,
  visibility,
  size,
  values,
  swatch
}: LegendProps) {
  const interactive = options.interactive !== false;
  const vertical = options.side === 'left' || options.side === 'right';

  return (
    <ul
      className={cx(
        'flex list-none flex-wrap items-center gap-x-3 gap-y-1 p-0',
        vertical ? 'min-w-0 flex-col items-start' : '',
        legendAlignClasses[options.align ?? 'center'],
        metaTextClasses[size]
      )}
    >
      {series.map((one, index) => {
        const shown = visibility.visible[index];
        const dimmed = visibility.hovered !== null && visibility.hovered !== index;
        const name = one.name ?? `${index + 1}`;

        const ink = shown ? colors[index] : 'var(--plass-disabled-fg)';

        const content = (
          <>
            {swatch ? (
              <span
                aria-hidden="true"
                className="flex size-2.5 shrink-0 items-center justify-center"
              >
                {swatch(index, ink)}
              </span>
            ) : (
              <span
                aria-hidden="true"
                className={`size-2.5 shrink-0 rounded-[0.1875rem] ${transitionClasses}`}
                style={{ backgroundColor: ink }}
              />
            )}
            <span className="min-w-0 truncate">{name}</span>
            {values?.[index] ? (
              <span className="shrink-0 tabular-nums text-(--plass-muted-fg)">{values[index]}</span>
            ) : null}
          </>
        );

        return (
          <li key={one.name ?? index} className="min-w-0">
            {interactive ? (
              <button
                type="button"
                aria-pressed={shown}
                onClick={() => visibility.toggle(index)}
                onPointerEnter={() => visibility.setHovered(index)}
                onPointerLeave={() => visibility.setHovered(null)}
                onFocus={() => visibility.setHovered(index)}
                onBlur={() => visibility.setHovered(null)}
                className={cx(
                  'flex min-w-0 cursor-pointer items-center gap-1.5 rounded-(--plass-radius-xs)',
                  'px-1 py-0.5 text-(--plass-fg)',
                  // Its own list rather than the house one: `transitionClasses`
                  // names the four properties a control answers a pointer with,
                  // and `opacity` — the only thing that changes when a *sibling*
                  // row is hovered — is not among them, so the dimming below was
                  // written down and never ran.
                  '[transition-property:background-color,color,opacity]',
                  '[transition-duration:var(--plass-duration)]',
                  '[transition-timing-function:var(--plass-ease)]',
                  'hover:bg-(--p-soft)',
                  'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-1',
                  shown ? '' : 'text-(--plass-disabled-fg)',
                  dimmed ? 'opacity-55' : ''
                )}
              >
                {content}
              </button>
            ) : (
              <span
                className={cx(
                  'flex min-w-0 items-center gap-1.5 px-1 py-0.5 text-(--plass-fg)',
                  shown ? '' : 'text-(--plass-disabled-fg)'
                )}
              >
                {content}
              </span>
            )}
          </li>
        );
      })}
    </ul>
  );
}

interface ScaleLegendProps {
  /** The steps, palest first, as the `var()`s that resolve them. */
  steps: readonly string[];
  /** What the two ends of the scale say. */
  from: string;
  to: string;
  /** And the middle, on a diverging scale where the middle means something. */
  middle?: string;
  align: NonNullable<PlassChartLegend['align']>;
  vertical: boolean;
  size: PlassSize;
}

/**
 * The legend a magnitude needs, which is a bar and not a list of swatches.
 *
 * `ChartLegendBar` answers "which one is Europe" — a set of names, in no order,
 * each with a colour beside it. A sequential scale is the other question
 * entirely: nothing here has a name, the order *is* the meaning, and what the
 * reader needs is the two numbers at the ends. A key of five unnamed swatches
 * would say neither.
 *
 * The steps are drawn as five joined blocks rather than as a CSS gradient,
 * because five is what the cells are actually coloured with — a smooth bar
 * would promise a continuum the chart cannot deliver, and a reader matching a
 * cell against it would be guessing.
 */
function ChartScaleLegend({ steps, from, to, middle, align, vertical, size }: ScaleLegendProps) {
  return (
    <div className={cx('flex', vertical ? '' : legendAlignClasses[align])}>
      {/* A grid rather than a row, so the middle label can sit in the bar's own
          column. Written beside the bar it reads as a third end. */}
      <div
        className={cx(
          'grid grid-cols-[auto_auto_auto] items-center gap-x-2',
          metaTextClasses[size]
        )}
      >
        <span className="shrink-0 tabular-nums text-(--plass-muted-fg)">{from}</span>
        <span
          aria-hidden="true"
          className={cx(
            'flex h-2.5 overflow-hidden rounded-[0.1875rem]',
            vertical ? 'w-20' : 'w-24'
          )}
        >
          {steps.map((step) => (
            <span key={step} className="h-full flex-1" style={{ backgroundColor: step }} />
          ))}
        </span>
        <span className="shrink-0 tabular-nums text-(--plass-muted-fg)">{to}</span>

        {middle ? (
          <>
            <span />
            <span className="text-center tabular-nums text-(--plass-muted-fg)">{middle}</span>
            <span />
          </>
        ) : null}
      </div>
    </div>
  );
}

/* ---------------------------------------------------------------------------
 * Tooltip
 * ------------------------------------------------------------------------- */

/** One row of a tooltip: a series, and what it says at the active category. */
export interface ChartTooltipItem {
  seriesIndex: number;
  name?: string;
  color: string;
  value: number | null;
  formatted: string;
  label?: React.ReactNode;
}

interface TooltipProps {
  heading: React.ReactNode;
  items: readonly ChartTooltipItem[];
  /** Where along the plot the anchor sits, in pixels from the chart's left. */
  x: number;
  /** And how far down. */
  y: number;
  /** Which half of the chart the anchor is in — the tooltip opens the other way. */
  flip: boolean;
  size: PlassSize;
}

/**
 * The panel under the pointer.
 *
 * Anchored by its near edge rather than centred with a translate: the design
 * language spends no `transform` on anything, and anchoring left-or-right by
 * which half of the plot the pointer is in is also the only placement that
 * cannot run off the side of a narrow card.
 *
 * It is `pointer-events-none` because it is a readout, not a surface — a panel
 * that the pointer can enter is a panel that steals the hover that produced it
 * and then flickers.
 */
function ChartTooltipPanel({ heading, items, x, y, flip, size }: TooltipProps) {
  return (
    <div
      // The panel carries no role at all. It is drawn inside the element that
      // carries `role="img"`, which prunes its whole subtree from the
      // accessibility tree — so anything semantic written here would be
      // written for nobody. `ChartStatus` is the half a reader hears; this is
      // the half they see, and the attribute is what a stylesheet or a test
      // reaches it by.
      data-plass-tooltip=""
      className={cx(
        'pointer-events-none absolute z-10 max-w-56 min-w-24',
        'rounded-(--plass-radius-sm) border p-2',
        '[background-image:var(--plass-grain),var(--plass-sheen)]',
        '[background-blend-mode:overlay,normal] [backdrop-filter:var(--plass-blur)]',
        'bg-(--plass-panel-press) [border-color:var(--plass-glass-line)]',
        '[box-shadow:var(--plass-shadow-2),var(--plass-plate-glass)]',
        metaTextClasses[size]
      )}
      style={flip ? { right: `calc(100% - ${x}px + 10px)`, top: y } : { left: x + 10, top: y }}
    >
      <div className="mb-1 font-medium text-(--plass-fg)">{heading}</div>
      <ul className="flex list-none flex-col gap-0.5 p-0">
        {items.map((item) => (
          <li key={item.seriesIndex} className="flex items-center gap-1.5">
            <span
              aria-hidden="true"
              className="size-2 shrink-0 rounded-[0.125rem]"
              style={{ backgroundColor: item.color }}
            />
            {item.name ? (
              <span className="min-w-0 flex-1 truncate text-(--plass-muted-fg)">{item.name}</span>
            ) : null}
            <span className="ms-auto shrink-0 font-medium tabular-nums text-(--plass-fg)">
              {item.label ?? item.formatted}
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}

/**
 * The same reading, said out loud rather than drawn.
 *
 * It cannot be the panel above, and that is not a preference. The panel is
 * drawn inside the element carrying `role="img"`, and `img` is a leaf role:
 * everything under it is cut out of the accessibility tree, so a live region
 * in there announces to nobody. This is a *sibling* of the picture, clipped
 * instead of painted, and it is what makes the arrow keys mean something to a
 * reader who is not looking at the plot.
 *
 * Empty when nothing is active, so leaving the chart clears what was said
 * rather than leaving the last column standing in the region forever.
 */
function ChartStatus({
  heading,
  items
}: {
  heading?: React.ReactNode;
  items: readonly ChartTooltipItem[];
}) {
  return (
    <span role="status" aria-live="polite" className={srOnlyClasses}>
      {items.length === 0 ? null : (
        <>
          {hasContent(heading) ? <>{heading}, </> : null}
          {items.map((item, index) => (
            <React.Fragment key={item.seriesIndex}>
              {index > 0 ? ', ' : null}
              {item.name ? `${item.name}: ` : null}
              {item.label ?? item.formatted}
            </React.Fragment>
          ))}
        </>
      )}
    </span>
  );
}

/* ---------------------------------------------------------------------------
 * The table under every chart
 * ------------------------------------------------------------------------- */

interface DataTableProps {
  id: string;
  caption?: string;
  corner?: React.ReactNode;
  categories: readonly PlassChartCategory[];
  series: readonly PlassChartSeries[];
  values: readonly ChartValue[][];
  format: (value: number) => string;
  locale?: string;
}

/**
 * The chart, as a table, for the readers a drawing does not reach.
 *
 * Not an option and not a toggle. A tooltip that is the only way to a number
 * gates that number behind a pointer, and an SVG with an `aria-label` on it
 * says "revenue by month" and then says nothing else at all. This is the same
 * data in the one form every assistive technology already reads, so the picture
 * is free to be a picture.
 *
 * It is clipped rather than `display: none`, for the reason `srOnlyClasses`
 * gives: the second one takes it off the accessibility tree along with the
 * screen, which would leave the chart exactly as mute as before.
 */
function ChartDataTable({
  id,
  caption,
  corner,
  categories,
  series,
  values,
  format,
  locale
}: DataTableProps) {
  return (
    <table id={id} className={srOnlyClasses}>
      {caption ? <caption>{caption}</caption> : null}
      <thead>
        <tr>
          <th scope="col">{corner ?? ''}</th>
          {series.map((one, index) => (
            <th key={one.name ?? index} scope="col">
              {one.name ?? index + 1}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {categories.map((category, index) => (
          <tr key={index}>
            <th scope="row">{formatCategory(category, locale)}</th>
            {series.map((one, seriesIndex) => {
              const datum = values[seriesIndex]?.[index];

              // A point's own `label` wins, exactly as it does in the tooltip.
              // That is what keeps the caller's number reachable on a chart
              // stacked to `full`, where the value being *drawn* is a share.
              if (datum?.label !== undefined) {
                return <td key={one.name ?? seriesIndex}>{datum.label}</td>;
              }

              return (
                <td key={one.name ?? seriesIndex}>
                  {datum?.value === null || datum?.value === undefined ? '' : format(datum.value)}
                </td>
              );
            })}
          </tr>
        ))}
      </tbody>
    </table>
  );
}

/* ---------------------------------------------------------------------------
 * The surface every chart sits on
 * ------------------------------------------------------------------------- */

interface SurfaceProps extends Omit<PlBoxProps, 'children'> {
  legend: React.ReactNode;
  legendSide: NonNullable<PlassChartLegend['side']>;
  children: React.ReactNode;
  table: React.ReactNode;
}

/** Box, with the legend on one of its four sides and the table underneath. */
function ChartSurface({ legend, legendSide, children, table, className, ...box }: SurfaceProps) {
  return (
    <PlBox
      {...box}
      className={cx('relative flex gap-3', legendSideClasses[legendSide], className ?? undefined)}
    >
      <div className="relative min-w-0 flex-1">{children}</div>
      {legend}
      {table}
    </PlBox>
  );
}

/* ---------------------------------------------------------------------------
 * Cartesian charts
 * ------------------------------------------------------------------------- */

/**
 * One mark on a plot whose marks are not arranged in columns.
 *
 * A scatter has no shared categories, so there is no column for a pointer to
 * be inside and nothing for a crosshair to be dropped through: the only
 * question a reader can be asking is "which of these dots". A chart that says
 * so hands the frame its marks and gets the nearest-mark search, the arrow
 * keys and the tooltip anchoring for free.
 */
export interface ChartMark {
  /** Its series' place in the array as it was passed — where its colour is from. */
  series: number;
  /** Its own place within that series. */
  index: number;
  /** Its centre, in pixels from the chart's top-left. */
  x: number;
  y: number;
  /** How big it is. Widens the hit target, so a bubble is easier to hit than a dot. */
  r: number;
  /**
   * Its half-width and half-height, when the mark is a box rather than a disc.
   *
   * A span on a Gantt is two hundred pixels of bar whose centre a pointer may
   * never go near, so measuring to the centre would hand the row's short bar a
   * hover the reader is plainly not making. Given these, the pointer is tested
   * against the *body*.
   */
  rx?: number;
  ry?: number;
}

/**
 * Where everything goes — the half of the context that is settled before the
 * pointer is consulted.
 *
 * It is split out because the marks are built from it: a chart hands the frame
 * a builder, the frame runs it on the layout, and only then is there a list for
 * the pointer to be nearest to. A builder that could read what is active would
 * be reading a value that does not exist yet.
 */
export interface CartesianLayout {
  plot: PlotBox;
  /** Every series unpacked, in the order it was passed. */
  values: readonly ChartValue[][];
  /** Which of them are drawn. */
  visible: readonly boolean[];
  /** And what colour each one is, by its original index. */
  colors: readonly string[];
  scale: ValueScale;
  band: BandScale;
  /** Bars run along the category axis rather than across it. */
  horizontal: boolean;
  /** Where a value sits along the value axis, in pixels from the chart's edge. */
  valuePx: (value: number) => number;
  /** Where a category's centre sits along the category axis. */
  categoryPx: (index: number) => number;
  /** The two combined, whichever way round the chart runs. */
  point: (index: number, value: number) => { x: number; y: number };
  /**
   * The scale the *category* axis runs on, when `xScale` made it a second value
   * axis. `null` on every chart whose categories are columns.
   */
  categoryScale: ValueScale | null;
  /**
   * Where a value sits along the category axis, in pixels from the chart's
   * edge — the same absolute reckoning `valuePx` uses, and deliberately not
   * `categoryPx`'s offset-along-the-axis. Only meaningful with `xScale="value"`.
   */
  categoryValuePx: (value: number) => number;
  /** Where the baseline is along the value axis. */
  zeroPx: number;
  categories: readonly PlassChartCategory[];
  format: (value: number) => string;
  size: PlassSize;
}

/** The layout, plus everything the pointer decides. */
export interface CartesianContext extends CartesianLayout {
  /** The series the legend is being hovered over, if any. */
  hovered: number | null;
  /** The category under the pointer, if any. */
  activeIndex: number | null;
  /** Every mark, when the chart supplied a builder. Empty otherwise. */
  marks: readonly ChartMark[];
  /** The one the pointer is on, or the one the arrow keys walked to. */
  activeMark: ChartMark | null;
}

interface CartesianProps extends CartesianChartProps {
  /**
   * Makes the category axis a second value axis instead of a row of columns.
   * `value` is what a scatter needs and what nothing else does.
   * @default 'band'
   */
  xScale?: 'band' | 'value';
  /**
   * Builds every mark on the plot, which swaps the frame's column hit-testing
   * for a nearest-mark search and makes the arrow keys walk this list. The
   * result comes back on the context, so the marks are laid out once and drawn
   * from the same array they are hit-tested against.
   */
  marks?: (layout: CartesianLayout) => readonly ChartMark[];
  /**
   * How far off a mark the pointer still counts as on it, in pixels. Added to
   * the mark's own radius — a 4px dot is not a hit target.
   * @default 24
   */
  markRadius?: number;
  /** The table under the chart, for a chart whose data is not a grid. */
  table?: (id: string) => React.ReactNode;
  /** The legend's swatch, for a chart whose marks are not all the same shape. */
  swatch?: (index: number, color: string) => React.ReactNode;
  /**
   * The value axis' scale, already worked out.
   *
   * For the axis that is not a count. `valueScale` rounds to 1-2-5, which is
   * the family a reader does arithmetic in and exactly the wrong one for an
   * instant — sixty, twenty-four, seven, twelve. A chart whose axis has its own
   * arithmetic builds the scale itself and hands it over.
   */
  scale?: ValueScale;
  /**
   * What the tooltip says about a mark.
   *
   * Without it a mark is read as "this series at this category", which is right
   * for anything whose marks sit in a grid the frame already understands. A
   * Gantt's rows are the frame's *categories* and its marks are spans within
   * them, so there is no cell for the frame to look the answer up in.
   */
  markTooltip?: (mark: ChartMark) => {
    heading: React.ReactNode;
    items: readonly ChartTooltipItem[];
  } | null;
  /** Bars, and only bars, run the other way. */
  horizontal?: boolean;
  /** The value axis measures totals rather than parts. */
  stacked?: boolean;
  /** A line chart is free to leave zero out; a bar chart is not. */
  includeZero?: boolean;
  /** How much of a band the marks take — bars need room reserved, lines do not. */
  bandRatio?: number;
  /**
   * Lines and areas sit *on* the category ticks; bars sit *between* them. The
   * difference is one half-step, and getting it wrong is what makes a line
   * chart's first point float a centimetre off the axis.
   */
  inset?: boolean;
  /** Extra room at the top of the plot, for value labels that ride the marks. */
  headroom?: number;
  /**
   * Room on **every** side of the plot, for marks drawn from their centre.
   *
   * `headroom` is not enough for those: a bubble at the largest x hangs over the
   * right edge and one at the smallest hangs over the value axis' own labels.
   * A line's marker gets away with it because a line is inset from both ends
   * anyway; a scatter places a mark wherever the number says, including exactly
   * on the corner.
   */
  markInset?: number;
  /** Draws the marks. */
  children: (context: CartesianContext) => React.ReactNode;
}

/**
 * The frame: two axes, a grid, a crosshair, a legend, a tooltip and the table.
 *
 * Everything here is one of two things — a measurement, or a piece of chrome
 * that is identical on a line chart and a bar chart. The marks are the `children`
 * function's business, and they are handed pixels rather than values so a
 * component never has to know which way round the axes are.
 */
export function CartesianChart({
  series,
  categories,
  xAxis,
  yAxis,
  horizontal = false,
  stacked = false,
  includeZero = true,
  bandRatio = 1,
  inset = false,
  headroom = 0,
  markInset = 0,
  xScale = 'band',
  marks,
  markRadius = 24,
  table,
  swatch,
  scale: givenScale,
  markTooltip,
  height,
  format,
  locale: localeProp,
  label,
  legend,
  tooltip,
  empty,
  size: sizeProp,
  variant = 'ghost',
  padded = false,
  className,
  children,
  ...box
}: CartesianProps) {
  /* Two of the three defaults a provider can set, resolved here rather than
     left to `PlBox`: the size decides the type scale, the marker radii and how
     much room the axes reserve, so the frame has to know it before it hands
     anything to the box, and the locale is what every number and date on the
     drawing is written in. `density` is not among them — it reaches the box
     untouched, and the one chart that needs it for arithmetic reads it
     itself. */
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const locale = localeProp ?? defaults.locale;

  const hostRef = React.useRef<HTMLDivElement>(null);
  const width = useMeasuredWidth(hostRef);
  const words = useLabels();
  const tableId = React.useId();

  const visibility = useVisibility(series);
  const [columnIndex, setColumnIndex] = React.useState<number | null>(null);
  /** Which entry of `markList` the pointer is on — the other way to be active. */
  const [markIndex, setMarkIndex] = React.useState<number | null>(null);
  /** Where the pointer is along the value axis. `null` when it arrived by key. */
  const [pointer, setPointer] = React.useState<number | null>(null);

  /* No `useMemo` around the formatter: `format` is an options object, and the
     ordinary way that prop gets written is a literal in the JSX — a fresh
     object on every render, which a memo keyed on its identity would miss every
     single time. The cache in `internal/format.ts` is keyed on what the options
     say instead, so it hits. */
  const formatValue = React.useCallback(
    (value: number) =>
      format ? numberFormatter(locale, format).format(value) : compactNumber(value, locale),
    [format, locale]
  );

  const values = React.useMemo(() => toValues(series), [series]);
  const colors = React.useMemo(() => series.map((one, index) => seriesColor(one, index)), [series]);

  const count = categoryCount(series);
  const labels = React.useMemo(
    () => Array.from({ length: count }, (_, index) => categoryAt(index, categories, values)),
    [count, categories, values]
  );

  const shownValues = values.filter((_, index) => visibility.visible[index]);
  const extent = extentOf(shownValues, stacked);

  const plotHeight =
    typeof height === 'number' ? height : height === undefined ? plotHeights[size] : null;

  const fontSize = chartFontSizes[size];

  /* `xAxis` is the category axis and `yAxis` is the value axis, on every chart
     and in both orientations — which is the whole point of naming them that
     way: turning a bar chart on its side is a change to the drawing, not to
     what the caller's data means, so it must not also move their axis options
     from one prop to the other.

     These were swapped by `horizontal`, and it produced exactly the collision
     that argument predicts: a horizontal `stacked="full"` PlBarChart sends the
     `%` tick format to the axis holding the category names and prints
     `Seoul%`. Where the axes are *drawn* is still decided by `horizontal`,
     below and in `ChartAxes`; that part was never in question. */
  const valueAxis = yAxis;
  const categoryAxis = xAxis;

  /* The scales. The value axis is rounded to clean numbers before anything is
     measured, because how much room the axis needs depends on how wide its
     widest tick prints — which is not knowable until the ticks exist. */
  const scale =
    givenScale ??
    valueScale(extent, {
      min: valueAxis?.min,
      max: valueAxis?.max,
      tickCount: valueAxis?.tickCount,
      includeZero
    });

  /* And a second one of the same kind when the categories are numbers rather
     than columns. Zero is deliberately not forced in: what a position along an
     axis encodes is a *place*, so cropping the scale moves every mark by the
     same amount and the picture survives — which is the argument a line chart
     already makes, and the opposite of the one a bar's length makes. An x that
     runs from 100 to 140 dragged down to zero is a plot with all of its data in
     one corner. */
  const spread = xScale === 'value' ? categoryExtent(shownValues, categories) : null;
  const categoryScale =
    xScale === 'value'
      ? valueScale(spread, {
          min: categoryAxis?.min,
          max: categoryAxis?.max,
          tickCount: categoryAxis?.tickCount,
          includeZero: false
        })
      : null;

  const tickTexts = scale.ticks.map((tick, index) =>
    valueAxis?.tickFormat ? String(valueAxis.tickFormat(tick, index)) : formatValue(tick)
  );

  /* The category axis writes either its labels or its own ticks. `format`
     belongs to the value axis and is not borrowed for these — a currency
     applied to an axis of years prints `$2,019` — so the fallback is the plain
     compaction and `xAxis.tickFormat` is how a caller says more. */
  const rawCategoryTexts = categoryScale
    ? categoryScale.ticks.map((tick, index) =>
        categoryAxis?.tickFormat
          ? String(categoryAxis.tickFormat(tick, index))
          : compactNumber(tick, locale)
      )
    : labels.map((category, index) =>
        categoryAxis?.tickFormat
          ? String(categoryAxis.tickFormat(category, index))
          : formatCategory(category, locale)
      );

  const widestTick = tickTexts.reduce((most, text) => Math.max(most, textWidth(text, fontSize)), 0);
  const axisLabelBand = fontSize + 6;

  /* How much room one category label has, before anything is laid out.
     A horizontal chart gives each label a row of its own on the left, so the
     limit is a column width; a vertical one gives it a slot along the bottom,
     so the limit is the slot. */
  const valueBand = valueAxis?.hidden
    ? 0
    : widestTick + 10 + (valueAxis?.label ? axisLabelBand : 0);
  const slot = (width - (horizontal ? 0 : valueBand) - 16) / Math.max(1, count);

  /* Cut a long name to its slot rather than dropping labels until the rest fit —
     five categories called "Onboarding flow" would otherwise leave one label on
     the axis. Below about four characters that stops helping, and the stride in
     `ChartAxes` takes over instead. A tick is a number that was already rounded
     to be short, so it is never cut: half of `12.4K` is not a smaller number,
     it is a wrong one. */
  const categoryTexts = categoryScale
    ? rawCategoryTexts
    : horizontal || slot - 6 >= fontSize * 2.4
      ? rawCategoryTexts.map((text) => truncate(text, horizontal ? 150 : slot - 6, fontSize))
      : rawCategoryTexts;

  const widestCategory = categoryTexts.reduce(
    (most, text) => Math.max(most, textWidth(text, fontSize)),
    0
  );

  /* The two bands the axes take out of the box. `hidden` gives the room back to
     the plot, which is the whole reason a sparkline-shaped chart is the same
     component with both axes off rather than a different one. */
  const leftBand = horizontal
    ? categoryAxis?.hidden
      ? 0
      : widestCategory + 10 + (categoryAxis?.label ? axisLabelBand : 0)
    : valueBand;

  const bottomBand = horizontal
    ? valueAxis?.hidden
      ? 0
      : fontSize + 12 + (valueAxis?.label ? axisLabelBand : 0)
    : categoryAxis?.hidden
      ? 0
      : fontSize + 12 + (categoryAxis?.label ? axisLabelBand : 0);

  // `thickness` belongs to whichever axis is actually on that edge, which swaps
  // with `horizontal` — read off the wrong one, a bar chart turned on its side
  // would take its left margin from the axis along the bottom.
  const left = (horizontal ? categoryAxis : valueAxis)?.thickness ?? leftBand;
  const bottom = (horizontal ? valueAxis : categoryAxis)?.thickness ?? bottomBand;

  // The last category's label is centred on the last tick, so half of it hangs
  // past the plot. Reserving that half is what stops a chart clipping the one
  // label a reader looks for first — and a value axis needs none of it, because
  // it anchors its two end labels inward instead.
  const rightPad =
    (horizontal || categoryScale
      ? 12
      : Math.max(8, categoryTexts.length ? widestCategory / 2 : 8)) + markInset;
  // A mark is drawn from its centre, so half of the widest one hangs over the
  // top of the plot. On a scatter that half is a whole bubble, which is what
  // `markInset` is reserving on the other three sides.
  const topPad = markerRadii[size] + 4 + headroom + markInset;

  const boxHeight = plotHeight ?? 0;
  const plot: PlotBox = {
    left: left + markInset,
    top: topPad,
    width: Math.max(0, width - left - markInset - rightPad),
    height: Math.max(0, boxHeight - topPad - bottom - markInset)
  };

  const categoryLength = horizontal ? plot.height : plot.width;
  // Bars divide the axis into `count` slots and sit in the middle of one; lines
  // divide it into `count - 1` gaps and sit on the joins. Both need a `step`,
  // because the hit target for a category is one step wide either way.
  const band = bandScale(inset ? Math.max(1, count - 1) : count, categoryLength, bandRatio);

  /* A line's first point sits *on* the axis and a bar's first band starts at
     it, which is one half-step apart. `inset` is which of the two this is. */
  const categoryPx = React.useCallback(
    (index: number) =>
      inset
        ? count <= 1
          ? categoryLength / 2
          : (categoryLength * index) / (count - 1)
        : band.centre(index),
    [inset, count, categoryLength, band]
  );

  const valuePx = React.useCallback(
    (value: number) =>
      horizontal
        ? plot.left + scale.fraction(value) * plot.width
        : plot.top + (1 - scale.fraction(value)) * plot.height,
    [horizontal, plot.left, plot.top, plot.width, plot.height, scale]
  );

  const point = React.useCallback(
    (index: number, value: number) =>
      horizontal
        ? { x: valuePx(value), y: plot.top + categoryPx(index) }
        : { x: plot.left + categoryPx(index), y: valuePx(value) },
    [horizontal, valuePx, categoryPx, plot.left, plot.top]
  );

  const categoryValuePx = React.useCallback(
    (value: number) =>
      horizontal
        ? plot.top + (1 - (categoryScale?.fraction(value) ?? 0)) * plot.height
        : plot.left + (categoryScale?.fraction(value) ?? 0) * plot.width,
    [horizontal, plot.left, plot.top, plot.width, plot.height, categoryScale]
  );

  const zeroPx = valuePx(Math.min(Math.max(0, scale.min), scale.max));

  const layout: CartesianLayout = {
    plot,
    values,
    visible: visibility.visible,
    colors,
    scale,
    band,
    horizontal,
    valuePx,
    categoryPx,
    point,
    categoryScale,
    categoryValuePx,
    zeroPx,
    categories: labels,
    format: formatValue,
    size
  };

  /* The marks, laid out once. They are what the pointer is tested against and
     what `children` draws, and they are the same array both times — a chart
     that placed its dots twice would eventually place them in two places. */
  const markList = marks ? marks(layout) : noMarks;

  /* Hover. The nearest category to the pointer rather than the one it is
     literally over: a two-pixel line is not something a pointer can be asked to
     land on, and the hit area for a category is its whole column. */
  const tooltipOptions: PlassChartTooltip =
    tooltip === false ? { mode: 'none' } : tooltip === true || tooltip === undefined ? {} : tooltip;
  const tooltipMode = tooltipOptions.mode ?? (marks ? 'item' : 'index');

  const indexAt = (clientX: number, clientY: number) => {
    const host = hostRef.current;

    if (!host || count === 0) {
      return null;
    }

    const rect = host.getBoundingClientRect();
    const along = horizontal ? clientY - rect.top - plot.top : clientX - rect.left - plot.left;

    if (along < -band.step || along > categoryLength + band.step) {
      return null;
    }

    const raw = inset
      ? count <= 1
        ? 0
        : Math.round((along / categoryLength) * (count - 1))
      : Math.floor(along / band.step);

    return Math.min(count - 1, Math.max(0, raw));
  };

  /**
   * The mark nearest the pointer, or `null` if it is not near one.
   *
   * A plain squared-distance sweep over the visible marks. The textbook answer
   * is a Voronoi layer, and at the sizes a chart in a card is drawn at — a few
   * hundred marks, recomputed only while a pointer is actually moving over it —
   * building one costs more than it saves.
   *
   * The cap is the mark's own radius plus `markRadius`, so a bubble is easier
   * to hit than a dot and neither is as small as it looks: an 8px dot is not
   * something a pointer can be asked to land on.
   */
  const nearestMark = (clientX: number, clientY: number) => {
    const host = hostRef.current;

    if (!host || markList.length === 0) {
      return null;
    }

    const rect = host.getBoundingClientRect();
    const x = clientX - rect.left;
    const y = clientY - rect.top;

    let found: number | null = null;
    let best = Infinity;
    let tie = Infinity;

    // Hidden marks are the builder's business, not this loop's: it is the one
    // place that knows which of its own marks belong to a hidden row, and a
    // chart whose rows are not the frame's series has no `visible` to consult.
    markList.forEach((mark, at) => {
      const toCentre = Math.hypot(mark.x - x, mark.y - y);
      // How far the pointer is from the mark's *edge*, which is zero anywhere
      // inside it. Ranking on this rather than on the centre is what stops a
      // small mark next door winning a hover the pointer is making on a big one.
      const body =
        mark.rx === undefined
          ? Math.max(0, toCentre - mark.r)
          : Math.hypot(
              Math.max(0, Math.abs(mark.x - x) - mark.rx),
              Math.max(0, Math.abs(mark.y - y) - (mark.ry ?? mark.rx))
            );

      // Inside two overlapping marks the edge distance is zero for both, and
      // the nearer centre is the one being pointed at.
      if (body <= markRadius && (body < best || (body === best && toCentre < tie))) {
        best = body;
        tie = toCentre;
        found = at;
      }
    });

    return found;
  };

  /** Where the pointer sits along the *value* axis — `item` mode's other half. */
  const valueAt = (clientX: number, clientY: number) => {
    const host = hostRef.current;

    if (!host) {
      return null;
    }

    const rect = host.getBoundingClientRect();

    return horizontal ? clientX - rect.left : clientY - rect.top;
  };

  /* Which mark is being read, and the two ways of arriving at one. A chart with
     marks is walked mark by mark; a chart without them is walked column by
     column, and `activeIndex` is then the column. */
  const activeMark = markIndex === null ? null : (markList[markIndex] ?? null);
  const activeIndex = marks ? (activeMark ? activeMark.index : null) : columnIndex;
  const walkLength = marks ? markList.length : count;

  const clearActive = () => {
    setColumnIndex(null);
    setMarkIndex(null);
    setPointer(null);
  };

  const goTo = (at: number | null) => {
    const bounded = at === null ? null : Math.min(walkLength - 1, Math.max(0, at));

    if (marks) {
      setMarkIndex(bounded);
    } else {
      setColumnIndex(bounded);
    }
  };

  const step = (delta: number) => {
    setPointer(null);

    const current = marks ? markIndex : columnIndex;

    goTo((current ?? (delta > 0 ? -1 : walkLength)) + delta);
  };

  const onKeyDown = (event: React.KeyboardEvent) => {
    const forward = horizontal ? 'ArrowDown' : 'ArrowRight';
    const back = horizontal ? 'ArrowUp' : 'ArrowLeft';

    if (event.key === forward) {
      step(1);
    } else if (event.key === back) {
      step(-1);
    } else if (event.key === 'Home') {
      goTo(0);
    } else if (event.key === 'End') {
      goTo(walkLength - 1);
    } else if (event.key === 'Escape') {
      clearActive();
    } else {
      return;
    }

    event.preventDefault();
  };

  const column: ChartTooltipItem[] =
    activeIndex === null
      ? []
      : series.flatMap((one, index) => {
          // A mark names its own series, so there is no column to narrow: two
          // dots at the same index are two unrelated points that happen to be
          // the nth of their series, not two readings of one category.
          if (!visibility.visible[index] || (activeMark && activeMark.series !== index)) {
            return [];
          }

          const value = values[index]?.[activeIndex];

          if (!value || value.value === null) {
            return [];
          }

          return [
            {
              seriesIndex: index,
              name: one.name,
              color: value.color ?? colors[index],
              value: value.value,
              formatted: formatValue(value.value),
              label: value.label
            }
          ];
        });

  /* `item` is the whole column narrowed to the one mark the pointer is nearest,
     measured along the *value* axis — the category is already decided by where
     the pointer is across the plot, so the only question left is which of the
     series stacked at that category it is closest to. */
  /* A chart whose marks are not cells of a grid answers for its own panel. */
  const supplied = activeMark && markTooltip ? markTooltip(activeMark) : null;

  const items = supplied
    ? supplied.items
    : tooltipMode === 'item' && column.length > 1 && pointer !== null
      ? [
          column.reduce((nearest, item) =>
            Math.abs(valuePx(item.value ?? 0) - pointer) <
            Math.abs(valuePx(nearest.value ?? 0) - pointer)
              ? item
              : nearest
          )
        ]
      : column;

  /* Where the panel hangs, and what it is titled. A column is anchored on its
     own centre and titled with the category every series in it shares; a mark
     is anchored on itself and titled with its own x, because on a plot with two
     value axes the x is data rather than a heading the marks were filed under. */
  const markCategory = activeMark
    ? (values[activeMark.series]?.[activeMark.index]?.x ??
      categories?.[activeMark.index] ??
      activeMark.index)
    : undefined;

  const anchorX = activeMark
    ? activeMark.x
    : horizontal
      ? valuePx(items[0]?.value ?? 0)
      : plot.left + categoryPx(activeIndex ?? 0);
  const anchorY = activeMark
    ? activeMark.y
    : horizontal
      ? plot.top + categoryPx(activeIndex ?? 0)
      : plot.top;
  const anchorFlip = activeMark
    ? (activeMark.x - plot.left) / Math.max(1, plot.width) > 0.6
    : (horizontal
        ? scale.fraction(items[0]?.value ?? 0)
        : categoryPx(activeIndex ?? 0) / Math.max(1, categoryLength)) > 0.6;

  const legendOptions: PlassChartLegend =
    legend === false
      ? { interactive: false }
      : legend === true || legend === undefined
        ? {}
        : legend;
  const showLegend = legend === true || (legend !== false && series.length > 1);
  const legendSide = legendOptions.side ?? 'bottom';

  const context: CartesianContext = {
    ...layout,
    hovered: visibility.hovered,
    activeIndex,
    marks: markList,
    activeMark
  };

  // A category axis running on numbers has one more way to have nothing to
  // draw: every point placed by a string, which is not a position on a number
  // line. Drawing the empty state is the honest answer — the alternative is an
  // axis of zeroes with every mark stacked on it.
  const nothing = count === 0 || extent === null || (xScale === 'value' && spread === null);

  return (
    <ChartSurface
      {...box}
      size={size}
      variant={variant}
      padded={padded}
      className={className}
      legendSide={legendSide}
      legend={
        showLegend ? (
          <ChartLegendBar
            series={series}
            colors={colors}
            options={legendOptions}
            visibility={visibility}
            size={size}
            swatch={swatch}
            values={
              legendOptions.showValue && activeIndex !== null
                ? series.map((_, index) => {
                    const value = values[index]?.[activeIndex]?.value;

                    return value === null || value === undefined ? undefined : formatValue(value);
                  })
                : undefined
            }
          />
        ) : null
      }
      table={
        nothing
          ? null
          : (table?.(tableId) ?? (
              <ChartDataTable
                id={tableId}
                caption={label}
                corner={categoryAxis?.label}
                categories={labels}
                series={series}
                values={values}
                format={formatValue}
                locale={locale}
              />
            ))
      }
    >
      {/* Two children rather than one: the readout under the picture has to be
          a *sibling* of it and not a child — see `ChartStatus`. */}
      <div
        ref={hostRef}
        role="img"
        tabIndex={nothing ? undefined : 0}
        // Never the bare prop: `label` is optional, and a focusable `role="img"`
        // with nothing to be called by is a tab stop that announces silence.
        aria-label={label ?? words.chart}
        aria-describedby={nothing ? undefined : tableId}
        onPointerMove={(event) => {
          if (tooltipMode === 'none') {
            return;
          }

          if (marks) {
            setMarkIndex(nearestMark(event.clientX, event.clientY));
          } else {
            setColumnIndex(indexAt(event.clientX, event.clientY));
          }

          // Only `item` mode reads this, and only it may pay for it. The index
          // above settles to the same value everywhere inside one column, so
          // React bails out of the re-render — but a pointer offset is a fresh
          // pixel on every event, and storing one the tooltip never consults
          // would re-lay the whole chart out for each pixel the pointer moves.
          if (tooltipMode === 'item') {
            setPointer(valueAt(event.clientX, event.clientY));
          }
        }}
        onPointerLeave={clearActive}
        // A key press moves the crosshair without a pointer, so `item` mode has
        // nothing to measure against and falls back to the whole column.
        onKeyDown={tooltipMode === 'none' ? undefined : onKeyDown}
        onBlur={clearActive}
        className={cx(
          'relative w-full',
          'rounded-(--plass-radius-xs)',
          'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-2'
        )}
        style={{ height: plotHeight ?? height }}
      >
        {nothing ? (
          <div
            className={cx(
              'flex h-full items-center justify-center text-(--plass-muted-fg)',
              metaTextClasses[size]
            )}
          >
            {empty ?? words.empty}
          </div>
        ) : width > 0 ? (
          <svg
            width={width}
            height={boxHeight || '100%'}
            viewBox={`0 0 ${width} ${boxHeight}`}
            aria-hidden="true"
            className="block overflow-visible"
          >
            <ChartAxes
              plot={plot}
              scale={scale}
              band={band}
              horizontal={horizontal}
              inset={inset}
              categoryPx={categoryPx}
              valuePx={valuePx}
              tickTexts={tickTexts}
              categoryTexts={categoryTexts}
              categoryScale={categoryScale}
              categoryValuePx={categoryValuePx}
              valueAxis={valueAxis}
              categoryAxis={categoryAxis}
              fontSize={fontSize}
              zeroPx={zeroPx}
            />

            {/* No crosshair on a chart with marks, whatever mode was asked for:
                a crosshair says "these numbers all belong to this column", and
                there is no column — it would be a line through one dot. */}
            {activeIndex !== null &&
            !marks &&
            tooltipMode === 'index' &&
            tooltipOptions.crosshair !== false
              ? (() => {
                  const along = categoryPx(activeIndex);

                  return horizontal ? (
                    <line
                      x1={plot.left}
                      x2={plot.left + plot.width}
                      y1={plot.top + along}
                      y2={plot.top + along}
                      stroke="var(--plass-chart-baseline)"
                      strokeWidth={1}
                    />
                  ) : (
                    <line
                      x1={plot.left + along}
                      x2={plot.left + along}
                      y1={plot.top}
                      y2={plot.top + plot.height}
                      stroke="var(--plass-chart-baseline)"
                      strokeWidth={1}
                    />
                  );
                })()
              : null}

            {children(context)}
          </svg>
        ) : null}

        {activeIndex !== null && items.length > 0 && tooltipMode !== 'none' ? (
          tooltipOptions.render ? (
            <div
              className="pointer-events-none absolute z-10"
              style={
                anchorFlip
                  ? { right: `calc(100% - ${anchorX}px + 10px)`, top: anchorY }
                  : { left: anchorX + 10, top: anchorY }
              }
            >
              {tooltipOptions.render({
                index: activeIndex,
                category: markCategory ?? labels[activeIndex],
                items
              })}
            </div>
          ) : (
            <ChartTooltipPanel
              heading={
                supplied
                  ? supplied.heading
                  : formatCategory(markCategory ?? labels[activeIndex], locale)
              }
              items={items}
              x={anchorX}
              y={anchorY}
              flip={anchorFlip}
              size={size}
            />
          )
        ) : null}
      </div>

      {/* Only where there is a crosshair to report. A chart with its tooltip
          turned off has nothing to announce, and a live region standing empty
          in the tree forever is a promise it never keeps. */}
      {tooltipMode === 'none' ? null : (
        <ChartStatus
          heading={
            activeIndex === null
              ? undefined
              : (supplied?.heading ?? formatCategory(markCategory ?? labels[activeIndex], locale))
          }
          items={items}
        />
      )}
    </ChartSurface>
  );
}

/* ---------------------------------------------------------------------------
 * Axes
 * ------------------------------------------------------------------------- */

interface AxesProps {
  plot: PlotBox;
  scale: ValueScale;
  band: BandScale;
  horizontal: boolean;
  inset: boolean;
  categoryPx: (index: number) => number;
  valuePx: (value: number) => number;
  tickTexts: readonly string[];
  /** Either the category labels or, with `categoryScale`, that scale's ticks. */
  categoryTexts: readonly string[];
  categoryScale: ValueScale | null;
  categoryValuePx: (value: number) => number;
  valueAxis?: PlassChartAxis;
  categoryAxis?: PlassChartAxis;
  fontSize: number;
  zeroPx: number;
}

/**
 * The grid, the rules and the labels.
 *
 * Gridlines run from the value axis only, and they are solid hairlines one step
 * off the surface. The category axis casts none by default: a grid in both
 * directions is graph paper, and the vertical rules would be doing the job the
 * crosshair already does under the pointer.
 */
function ChartAxes({
  plot,
  scale,
  horizontal,
  categoryPx,
  valuePx,
  tickTexts,
  categoryTexts,
  categoryScale,
  categoryValuePx,
  valueAxis,
  categoryAxis,
  fontSize,
  zeroPx
}: AxesProps) {
  const grid = valueAxis?.grid !== false && !valueAxis?.hidden;
  /* A grid in both directions is graph paper, and on a chart of columns the
     vertical rules do the job the crosshair is already doing under the pointer.
     A plot with two value axes is the exception that makes the rule: there is
     no column to be in, and reading a mark's x off the picture is half of what
     the reader came for — so there, graph paper is the point. */
  const categoryGrid = categoryAxis?.hidden
    ? false
    : (categoryAxis?.grid ?? categoryScale !== null);

  /* Where each category label goes, and how many of them there is room for.
     Ticks and labels are the same problem either way: a value scale's steps are
     already evenly spaced, so both paths are `categoryTexts` laid along an axis
     at a stride. */
  const categoryAlong = (index: number) =>
    categoryScale
      ? categoryValuePx(categoryScale.ticks[index])
      : (horizontal ? plot.top : plot.left) + categoryPx(index);

  const stride = tickStride(
    categoryTexts.length,
    horizontal ? plot.height : plot.width,
    horizontal
      ? fontSize * 1.8
      : Math.max(...categoryTexts.map((t) => textWidth(t, fontSize)), 1) + 12
  );

  /* The value axis needs a stride of its own once it is the *horizontal* one:
     five stacked labels never touch, and five laid across a narrow card read as
     one long number. The gridlines are not thinned with them — a line at a value
     with no label on it is still a line the eye can measure against. */
  const valueStride = tickStride(
    scale.ticks.length,
    horizontal ? plot.width : plot.height,
    horizontal ? Math.max(...tickTexts.map((t) => textWidth(t, fontSize)), 1) + 16 : fontSize * 2
  );

  /* Whether the end of each axis still has room to be written down. Measured
     from the step it would sit at rather than assumed from the stride. */
  const categoryStep =
    categoryTexts.length > 1 ? Math.abs(categoryAlong(1) - categoryAlong(0)) : plot.width;
  const valueStep =
    scale.ticks.length > 1
      ? Math.abs(valuePx(scale.ticks[1]) - valuePx(scale.ticks[0]))
      : plot.height;

  const lastCategory = fitsLast(
    categoryTexts.length,
    stride,
    categoryStep,
    horizontal ? fontSize * 1.8 : textWidth(categoryTexts[categoryTexts.length - 1] ?? '', fontSize)
  );
  const lastValue = fitsLast(
    scale.ticks.length,
    valueStride,
    valueStep,
    horizontal ? textWidth(tickTexts[tickTexts.length - 1] ?? '', fontSize) : fontSize * 1.6
  );

  return (
    <g>
      {/* The value axis' gridlines, and its labels beside them. */}
      {scale.ticks.map((tick, index) => {
        const along = valuePx(tick);
        const isZero = Math.abs(tick) < 1e-9;

        return (
          <g key={tick}>
            {grid ? (
              horizontal ? (
                <line
                  x1={along}
                  x2={along}
                  y1={plot.top}
                  y2={plot.top + plot.height}
                  stroke={isZero ? 'var(--plass-chart-baseline)' : 'var(--plass-chart-grid)'}
                  strokeWidth={1}
                />
              ) : (
                <line
                  x1={plot.left}
                  x2={plot.left + plot.width}
                  y1={along}
                  y2={along}
                  stroke={isZero ? 'var(--plass-chart-baseline)' : 'var(--plass-chart-grid)'}
                  strokeWidth={1}
                />
              )
            ) : null}

            {valueAxis?.hidden ||
            !showsTick(index, scale.ticks.length, valueStride, lastValue) ? null : horizontal ? (
              <text
                x={along}
                // The first and last labels are centred on the ends of the plot,
                // so half of each hangs outside it. Anchoring them inward is
                // cheaper than reserving a margin nothing else would use.
                y={plot.top + plot.height + fontSize + 6}
                textAnchor={
                  index === 0 ? 'start' : index === scale.ticks.length - 1 ? 'end' : 'middle'
                }
                fontSize={fontSize}
                fill="var(--plass-muted-fg)"
                className="tabular-nums"
              >
                {tickTexts[index]}
              </text>
            ) : (
              <text
                x={plot.left - 8}
                y={along}
                textAnchor="end"
                dominantBaseline="central"
                fontSize={fontSize}
                fill="var(--plass-muted-fg)"
                className="tabular-nums"
              >
                {tickTexts[index]}
              </text>
            )}
          </g>
        );
      })}

      {/* The category axis. Its rule sits at the baseline rather than at the
          bottom of the plot: on a chart with negative values those are not the
          same line, and the one the bars grow from is the one that means zero. */}
      {categoryAxis?.hidden ? null : (
        <>
          {horizontal ? (
            <line
              x1={zeroPx}
              x2={zeroPx}
              y1={plot.top}
              y2={plot.top + plot.height}
              stroke="var(--plass-chart-axis)"
              strokeWidth={1}
            />
          ) : (
            <line
              x1={plot.left}
              x2={plot.left + plot.width}
              y1={zeroPx}
              y2={zeroPx}
              stroke="var(--plass-chart-axis)"
              strokeWidth={1}
            />
          )}

          {categoryTexts.map((text, index) => {
            const along = categoryAlong(index);
            // The grid is drawn at every tick and the labels are thinned, for
            // the same reason the value axis does it: a rule with no number on
            // it is still a rule the eye can measure against.
            const labelled = showsTick(index, categoryTexts.length, stride, lastCategory);

            return horizontal ? (
              labelled ? (
                <text
                  key={index}
                  x={plot.left - 8}
                  y={along}
                  textAnchor="end"
                  dominantBaseline="central"
                  fontSize={fontSize}
                  fill="var(--plass-muted-fg)"
                  className={categoryScale ? 'tabular-nums' : undefined}
                >
                  {text}
                </text>
              ) : null
            ) : (
              <g key={index}>
                {categoryGrid ? (
                  <line
                    x1={along}
                    x2={along}
                    y1={plot.top}
                    y2={plot.top + plot.height}
                    stroke="var(--plass-chart-grid)"
                    strokeWidth={1}
                  />
                ) : null}
                {labelled ? (
                  <text
                    x={along}
                    y={plot.top + plot.height + fontSize + 6}
                    // A value scale's two end ticks sit on the ends of the plot,
                    // so half of each hangs outside it — the same inward anchor
                    // the horizontal value axis makes, and the reason a scatter
                    // needs no margin reserved on its right.
                    textAnchor={
                      !categoryScale
                        ? 'middle'
                        : index === 0
                          ? 'start'
                          : index === categoryTexts.length - 1
                            ? 'end'
                            : 'middle'
                    }
                    fontSize={fontSize}
                    fill="var(--plass-muted-fg)"
                    className={categoryScale ? 'tabular-nums' : undefined}
                  >
                    {text}
                  </text>
                ) : null}
              </g>
            );
          })}
        </>
      )}

      {/* The axis names. The value axis' name is set above its ticks rather than
          turned on its side — a rotated label is unreadable at a glance and it
          takes a band of the plot to be unreadable in. */}
      {valueAxis?.label ? (
        <text
          x={horizontal ? plot.left + plot.width : plot.left}
          y={horizontal ? plot.top + plot.height + fontSize * 2 + 12 : plot.top - 8}
          textAnchor={horizontal ? 'end' : 'start'}
          fontSize={fontSize}
          fill="var(--plass-muted-fg)"
          fontWeight={500}
        >
          {valueAxis.label}
        </text>
      ) : null}
      {categoryAxis?.label && !horizontal ? (
        <text
          x={plot.left + plot.width}
          y={plot.top + plot.height + fontSize * 2 + 12}
          textAnchor="end"
          fontSize={fontSize}
          fill="var(--plass-muted-fg)"
          fontWeight={500}
        >
          {categoryAxis.label}
        </text>
      ) : null}
    </g>
  );
}

/* ---------------------------------------------------------------------------
 * Pieces the non-cartesian charts need too
 * ------------------------------------------------------------------------- */

export {
  ChartDataTable,
  ChartLegendBar,
  ChartScaleLegend,
  ChartStatus,
  ChartSurface,
  ChartTooltipPanel,
  useMeasuredWidth,
  useVisibility
};
export type { Visibility };
