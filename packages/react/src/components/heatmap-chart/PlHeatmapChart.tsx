'use client';

import * as React from 'react';
import {
  ChartScaleLegend,
  ChartStatus,
  ChartSurface,
  ChartTooltipPanel,
  markTransitionClasses,
  type ChartTooltipItem,
  useMeasuredWidth
} from '../../internal/chart-frame.js';
import {
  categoryAt,
  chartFontSizes,
  compactNumber,
  formatCategory,
  markGap,
  plotHeights,
  rampFill,
  rampInk,
  rampStep,
  rampSteps,
  squarify,
  textWidth,
  toValues,
  truncate,
  type ChartScaleKind,
  type ChartValue
} from '../../internal/chart.js';
import { numberFormatter } from '../../internal/format.js';
import { cx, metaTextClasses, srOnlyClasses } from '../../internal/styles.js';
import { useLabels } from '../../internal/labels.js';
import type {
  PlassChartCategory,
  PlassChartLegend,
  PlassChartSeries,
  PlassChartTooltip
} from '../../types.js';
import type { ChartBaseProps } from '../../internal/chart-frame.js';
import { useDefaults } from '../../internal/defaults.js';

/** The corner radius of a cell. Small — a tile is a block, not a chip. */
const cellRadius = 3;

export interface PlHeatmapChartProps extends Omit<ChartBaseProps, 'legend'> {
  /**
   * The rows. Each series is a row of the grid or a group of the treemap, and
   * each datum a cell or a tile.
   *
   * `y` is the magnitude and `x` names the column. A `null` is a gap: the cell
   * is left as surface rather than drawn as the bottom of the scale, because
   * "nothing happened" and "the least of anything" are not the same reading.
   */
  series: readonly PlassChartSeries[];
  /** The column names. Points may carry their own `x` instead. */
  categories?: readonly PlassChartCategory[];
  /**
   * - `grid` — a cell per row and column, which is the shape for two
   *   categorical axes and one magnitude: hours against weekdays, a cohort
   *   against a week.
   * - `treemap` — a tile per datum, sized by its share and packed to fill the
   *   box. For parts of a whole where the parts are grouped and there are more
   *   of them than a [`PlPieChart`](./pie-chart) can hold.
   * @default 'grid'
   */
  shape?: 'grid' | 'treemap';
  /**
   * How the magnitude is coloured.
   *
   * - `sequential` — one hue, pale to deep. The default, and right whenever
   *   more is simply more.
   * - `diverging` — two hues either side of a neutral, for a value with a
   *   *middle* that means something: over and under target, gained and lost.
   *   Reached for on a plain magnitude it invents a boundary the data has none
   *   of.
   * @default 'sequential'
   */
  scale?: ChartScaleKind;
  /** Where a `diverging` scale turns over. @default 0 */
  midpoint?: number;
  /** Where the scale starts and ends. Taken from the data otherwise. */
  min?: number;
  max?: number;
  /**
   * Writes each cell's value on it, where the cell is big enough for the text
   * to fit with room either side. A label that does not fit is dropped rather
   * than clipped — the tooltip and the table still have it.
   * @default 'none'
   */
  valueLabels?: 'none' | 'all';
  /** Where the scale legend sits. `false` leaves it off. */
  legend?: boolean | Pick<PlassChartLegend, 'side' | 'align'>;
}

/**
 * A magnitude per cell, coloured rather than measured.
 *
 * Two shapes of the same idea. A `grid` is the one to reach for when both axes
 * are categorical and the question is *where* — which hour of which day, which
 * cohort in which week; a bar chart of the same data would be forty bars nobody
 * can scan. A `treemap` is for parts of a whole with more parts than a
 * [`PlPieChart`](./pie-chart) can hold, and it is the same component because the
 * data is the same shape: a row of a heatmap and a group of a treemap are both
 * a named series of named magnitudes.
 *
 * Colour here encodes *size* and not identity, so it comes off a one-hue ramp
 * rather than off the categorical palette — a heatmap in eight hues says its
 * cells are eight unrelated things.
 */
export function PlHeatmapChart({
  series,
  categories,
  shape = 'grid',
  scale = 'sequential',
  midpoint = 0,
  min,
  max,
  valueLabels = 'none',
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
  ...box
}: PlHeatmapChartProps) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const locale = localeProp ?? defaults.locale;

  const hostRef = React.useRef<HTMLDivElement>(null);
  const width = useMeasuredWidth(hostRef);
  const words = useLabels();
  const tableId = React.useId();

  const [active, setActive] = React.useState<{ row: number; index: number } | null>(null);

  const formatValue = React.useCallback(
    (value: number) =>
      format ? numberFormatter(locale, format).format(value) : compactNumber(value, locale),
    [format, locale]
  );

  const values = React.useMemo(() => toValues(series), [series]);

  const columns = values.reduce((most, row) => Math.max(most, row.length), 0);
  const labels = React.useMemo(
    () => Array.from({ length: columns }, (_, index) => categoryAt(index, categories, values)),
    [columns, categories, values]
  );
  /* Memoised because `rowNames` below depends on it, and a fresh array here
     would make that memo miss on every render — putting a `truncate` over every
     row name back on the render path, which is what it exists to stay off. */
  const names = React.useMemo(
    () => series.map((row, index) => row.name ?? `${index + 1}`),
    [series]
  );

  /* The scale, over every cell. One ladder for the whole chart and not one per
     row: the colour of a cell has to mean the same number wherever it is, which
     is the entire promise a heatmap makes. */
  const extent = React.useMemo(() => {
    let low = Infinity;
    let high = -Infinity;
    let seen = false;

    for (const row of values) {
      for (const cell of row) {
        if (cell.value === null) {
          continue;
        }

        seen = true;
        low = Math.min(low, cell.value);
        high = Math.max(high, cell.value);
      }
    }

    return seen ? { min: low, max: high } : null;
  }, [values]);

  const low = min ?? extent?.min ?? 0;
  const high = max ?? extent?.max ?? 1;

  const stepOf = React.useCallback(
    (value: number) => rampStep(value, low, high, scale, midpoint),
    [low, high, scale, midpoint]
  );

  const plotHeight = typeof height === 'number' ? height : (plotHeights[size] ?? 220);
  const fontSize = chartFontSizes[size];

  const legendOptions = legend === true || legend === undefined || legend === false ? {} : legend;
  const showLegend = legend !== false;
  const legendSide = legendOptions.side ?? 'bottom';

  const tooltipOptions: PlassChartTooltip =
    tooltip === false ? { mode: 'none' } : tooltip === true || tooltip === undefined ? {} : tooltip;
  const tooltipOff = tooltipOptions.mode === 'none';

  const nothing = extent === null || columns === 0 || series.length === 0;

  /* The two bands the names take out of the box, measured from the names
     themselves. A treemap has neither: its tiles are named on their own faces,
     which is the trade it makes for filling the box edge to edge.

     The row band is capped at a quarter of the width. A grid that hands a third
     of itself to a column of words has stopped being a grid, and a name that
     does not fit is cut — the tooltip and the table both still have it whole. */
  const rowNames = React.useMemo(() => {
    if (shape === 'treemap' || width <= 0) {
      return { texts: [] as string[], band: 0 };
    }

    const room = Math.min(150, width * 0.25);
    const texts = names.map((name) => truncate(name, room, fontSize));

    return {
      texts,
      band: texts.reduce((most, text) => Math.max(most, textWidth(text, fontSize)), 0) + 10
    };
  }, [shape, names, width, fontSize]);

  const columnBand = shape === 'treemap' ? 0 : fontSize + 8;

  const plot = {
    left: rowNames.band,
    width: Math.max(0, width - rowNames.band),
    height: Math.max(0, plotHeight - columnBand)
  };

  /* Where each cell goes. A grid divides the box evenly and a treemap packs it,
     and past that the two are one drawing — the same fill, the same ink, the
     same label rule — which is what makes them one component. */
  const cells = React.useMemo(() => {
    if (plot.width <= 0 || plot.height <= 0) {
      return [] as Cell[];
    }

    if (shape === 'treemap') {
      const flat: { row: number; index: number; cell: ChartValue }[] = [];

      values.forEach((row, at) =>
        row.forEach((cell, index) => {
          if (cell.value !== null) {
            flat.push({ row: at, index, cell });
          }
        })
      );

      // A tile's *area* is its share, so a negative has no area to be. It stays
      // in the table and off the picture, which is the honest half of each.
      return squarify(
        flat.map((one) => Math.max(0, one.cell.value ?? 0)),
        plot.width,
        plot.height
      ).map((tile) => ({
        row: flat[tile.index].row,
        index: flat[tile.index].index,
        cell: flat[tile.index].cell,
        x: plot.left + tile.x,
        y: tile.y,
        width: tile.width,
        height: tile.height
      }));
    }

    const rowHeight = plot.height / Math.max(1, series.length);
    const cellWidth = plot.width / Math.max(1, columns);
    const list: Cell[] = [];

    values.forEach((row, at) =>
      row.forEach((cell, index) => {
        if (cell.value === null) {
          return;
        }

        list.push({
          row: at,
          index,
          cell,
          x: plot.left + index * cellWidth,
          y: at * rowHeight,
          width: cellWidth,
          height: rowHeight
        });
      })
    );

    return list;
  }, [shape, values, series.length, columns, plot.left, plot.width, plot.height]);

  /** What a tile calls itself: its own column name, not its group's. */
  const cellName = React.useCallback(
    (one: Cell) =>
      formatCategory(
        one.cell.x ?? categories?.[one.index] ?? labels[one.index] ?? one.index,
        locale
      ),
    [categories, labels, locale]
  );

  const hovered =
    active === null
      ? null
      : (cells.find((one) => one.row === active.row && one.index === active.index) ?? null);

  /* One row, with no name on it. The heading already says which cell this is —
     both of its coordinates — so a name here would print one of them twice. */
  const items: ChartTooltipItem[] =
    hovered === null
      ? []
      : [
          {
            seriesIndex: hovered.row,
            color: hovered.cell.color ?? rampFill(stepOf(hovered.cell.value ?? 0), scale),
            value: hovered.cell.value,
            formatted: formatValue(hovered.cell.value ?? 0),
            label: hovered.cell.label
          }
        ];

  const steps = Array.from({ length: rampSteps }, (_, step) => rampFill(step, scale));

  return (
    <ChartSurface
      {...box}
      size={size}
      variant={variant}
      padded={padded}
      className={className}
      legendSide={legendSide}
      legend={
        showLegend && !nothing ? (
          <ChartScaleLegend
            steps={steps}
            from={formatValue(scale === 'diverging' ? -reach(low, high, midpoint) + midpoint : low)}
            to={formatValue(scale === 'diverging' ? reach(low, high, midpoint) + midpoint : high)}
            middle={scale === 'diverging' ? formatValue(midpoint) : undefined}
            align={legendOptions.align ?? 'center'}
            vertical={legendSide === 'left' || legendSide === 'right'}
            size={size}
          />
        ) : null
      }
      table={
        nothing ? null : (
          <table id={tableId} className={srOnlyClasses}>
            {label ? <caption>{label}</caption> : null}
            <thead>
              <tr>
                <th scope="col" />
                {labels.map((category, index) => (
                  <th key={index} scope="col">
                    {formatCategory(category, locale)}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {values.map((row, at) => (
                <tr key={at}>
                  <th scope="row">{names[at]}</th>
                  {labels.map((_, index) => {
                    const cell = row[index];

                    return (
                      <td key={index}>
                        {cell?.label !== undefined
                          ? cell.label
                          : cell?.value === null || cell?.value === undefined
                            ? ''
                            : formatValue(cell.value)}
                      </td>
                    );
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        )
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
        onPointerLeave={() => setActive(null)}
        onBlur={() => setActive(null)}
        onKeyDown={(event) => {
          if (tooltipOff || cells.length === 0) {
            return;
          }

          const at =
            active === null
              ? -1
              : cells.findIndex((one) => one.row === active.row && one.index === active.index);

          if (event.key === 'ArrowRight' || event.key === 'ArrowDown') {
            const next = cells[Math.min(cells.length - 1, at + 1)];

            setActive({ row: next.row, index: next.index });
          } else if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') {
            const next = cells[Math.max(0, (at === -1 ? cells.length : at) - 1)];

            setActive({ row: next.row, index: next.index });
          } else if (event.key === 'Escape') {
            setActive(null);
          } else {
            return;
          }

          event.preventDefault();
        }}
        className={cx(
          'relative w-full rounded-(--plass-radius-xs)',
          'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-2'
        )}
        style={{ height: plotHeight }}
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
            height={plotHeight}
            viewBox={`0 0 ${width} ${plotHeight}`}
            aria-hidden="true"
            className="block"
          >
            {cells.map((one) => {
              const step = stepOf(one.cell.value ?? 0);
              const is = active?.row === one.row && active?.index === one.index;
              // The 2px between two cells is the surface showing through and
              // never a stroke, exactly as it is between two bars.
              const w = Math.max(0, one.width - markGap);
              const h = Math.max(0, one.height - markGap);

              if (w <= 0 || h <= 0) {
                return null;
              }

              /* A tile says what it is and a cell says how much. On the grid
                 the two coordinates are already written down the side and along
                 the bottom, so the only thing left to write is the number; on a
                 treemap nothing is written anywhere else, so the name comes
                 first and the value only if there is still room under it. */
              const value = formatValue(one.cell.value ?? 0);
              const lines =
                shape === 'treemap'
                  ? valueLabels === 'all'
                    ? [cellName(one), value]
                    : [cellName(one)]
                  : valueLabels === 'all'
                    ? [value]
                    : [];
              const written = lines.filter((line) => fits(line, w, h / lines.length, fontSize));
              const ink = one.cell.color ? 'var(--plass-surface)' : rampInk(step, scale);

              return (
                <g key={`${one.row}-${one.index}`}>
                  <rect
                    x={one.x + markGap / 2}
                    y={one.y + markGap / 2}
                    width={w}
                    height={h}
                    rx={Math.min(cellRadius, w / 2, h / 2)}
                    fill={one.cell.color ?? rampFill(step, scale)}
                    opacity={is ? 1 : 0.94}
                    onPointerEnter={
                      tooltipOff ? undefined : () => setActive({ row: one.row, index: one.index })
                    }
                    className={markTransitionClasses}
                  />
                  {written.map((line, row) => (
                    <text
                      key={row}
                      x={one.x + one.width / 2}
                      y={one.y + one.height / 2 + (row - (written.length - 1) / 2) * (fontSize + 2)}
                      textAnchor="middle"
                      dominantBaseline="central"
                      fontSize={fontSize}
                      fontWeight={row === 0 ? 500 : 400}
                      // Inside a filled mark is the one place a label does not
                      // wear a text token. Which of the two it wears is decided
                      // per step in `styles.css`, where the step's lightness is
                      // known and the answer flips between the themes.
                      fill={ink}
                      opacity={row === 0 ? 1 : 0.85}
                      pointerEvents="none"
                      className={row === 0 && shape === 'treemap' ? undefined : 'tabular-nums'}
                    >
                      {truncate(line, one.width - 8, fontSize)}
                    </text>
                  ))}
                </g>
              );
            })}

            {/* The grid's two axes. Names down the side and along the bottom,
                each in a band of its own — written over the cells they would be
                unreadable, and a heatmap's cells are the one thing on the page
                with no spare contrast to lend. */}
            {shape === 'grid'
              ? rowNames.texts.map((text, index) => (
                  <text
                    key={`row-${index}`}
                    x={plot.left - 8}
                    y={((index + 0.5) * plot.height) / Math.max(1, series.length)}
                    textAnchor="end"
                    dominantBaseline="central"
                    fontSize={fontSize}
                    fill="var(--plass-muted-fg)"
                  >
                    {text}
                  </text>
                ))
              : null}

            {shape === 'grid'
              ? labels.map((category, index) => {
                  const slot = plot.width / Math.max(1, columns);
                  const text = formatCategory(category, locale);
                  // Every nth, chosen so the labels clear each other — the same
                  // answer the cartesian axis gives, and never a rotated one.
                  const stride = Math.max(
                    1,
                    Math.ceil((textWidth(text, fontSize) + 8) / Math.max(1, slot))
                  );

                  if (index % stride !== 0) {
                    return null;
                  }

                  return (
                    <text
                      key={`col-${index}`}
                      x={plot.left + (index + 0.5) * slot}
                      y={plot.height + fontSize}
                      textAnchor="middle"
                      fontSize={fontSize}
                      fill="var(--plass-muted-fg)"
                    >
                      {text}
                    </text>
                  );
                })
              : null}
          </svg>
        ) : null}

        {hovered && !tooltipOff ? (
          tooltipOptions.render ? (
            <div
              className="pointer-events-none absolute z-10"
              style={{ left: hovered.x + hovered.width / 2, top: hovered.y }}
            >
              {tooltipOptions.render({
                index: hovered.index,
                category: hovered.cell.x ?? labels[hovered.index] ?? hovered.index,
                items
              })}
            </div>
          ) : (
            <ChartTooltipPanel
              // Both coordinates, which is what a cell *is*. The row underneath
              // then has only the number left to carry.
              heading={`${names[hovered.row]} · ${cellName(hovered)}`}
              items={items}
              x={hovered.x + hovered.width / 2}
              y={hovered.y}
              flip={hovered.x + hovered.width / 2 > width * 0.6}
              size={size}
            />
          )
        ) : null}
      </div>

      {/* Only where there is a crosshair to report — see `ChartStatus`. */}
      {tooltipOff ? null : (
        <ChartStatus
          heading={hovered ? `${names[hovered.row]} · ${cellName(hovered)}` : undefined}
          items={items}
        />
      )}
    </ChartSurface>
  );
}

/** One cell or tile, placed. */
interface Cell {
  row: number;
  index: number;
  cell: ChartValue;
  x: number;
  y: number;
  width: number;
  height: number;
}

/** How far the further arm of a diverging scale reaches from its middle. */
function reach(low: number, high: number, midpoint: number): number {
  return Math.max(Math.abs(high - midpoint), Math.abs(midpoint - low));
}

/**
 * Whether a label fits its tile with room either side.
 *
 * Measured before it is placed and dropped when it does not, which is the same
 * rule the pie's share labels follow: a clipped label is worse than a missing
 * one, because a missing one sends the reader to the tooltip and a clipped one
 * sends them nowhere.
 */
function fits(text: string, width: number, height: number, fontSize: number): boolean {
  return (
    height >= fontSize * 1.8 && width >= Math.min(textWidth(text, fontSize), fontSize * 2.5) + 8
  );
}
