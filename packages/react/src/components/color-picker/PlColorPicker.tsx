'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { defaultPickerLabels } from '../../internal/calendar.js';
import { PickerShell } from '../../internal/picker.js';
import { CheckIcon } from '../../internal/icons.js';
import {
  checkerBackground,
  clamp,
  cssColor,
  defaultSwatches,
  formatColor,
  parseColor,
  readableInk
} from '../../internal/color.js';
import {
  controlTextClasses,
  cx,
  focusRingClasses,
  metaTextClasses,
  radiusClasses,
  stackGapClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type { PlColorFormat, PlassHsv } from '../../internal/color.js';
import type { PlassColor, PlassElevation, PlassSize, PlassStyleProps } from '../../types.js';

export type { PlColorFormat } from '../../internal/color.js';

/** The names for the parts of the picker that have no text on them. */
export interface PlColorPickerLabels {
  /** The saturation/brightness square. */
  area: string;
  /** The hue rail beside it. */
  hue: string;
  /** The opacity rail, when `alpha` is on. */
  alpha: string;
  /** The field the value can be typed into. */
  value: string;
  /** The grid of ready-made colours. */
  swatches: string;
  /** The × that empties the control. */
  clear: string;
  /** What the trigger reads before anything has been chosen. */
  empty: string;
}

/** The English the picker uses for the parts nobody can read a name off. */
export const defaultColorPickerLabels: PlColorPickerLabels = {
  area: 'Saturation and brightness',
  hue: 'Hue',
  alpha: 'Opacity',
  value: 'Colour value',
  swatches: 'Swatches',
  clear: 'Clear',
  empty: 'Pick a colour'
};

export interface PlColorPickerProps
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /** The colour, as a CSS string. Pass it to drive the picker yourself. */
  value?: string;
  /** Where an uncontrolled picker starts. @default '#1a58d1' */
  defaultValue?: string;
  /** Called with the new colour, written in `format`. */
  onValueChange?: (value: string) => void;
  /** Which notation the value is written in on the way out. @default 'hex' */
  format?: PlColorFormat;
  /** Offers an opacity rail, and lets the value carry a fourth channel. @default false */
  alpha?: boolean;
  /**
   * The ready-made colours under the panel. `false` draws none; an array of CSS
   * colour strings replaces the built-in set.
   */
  swatches?: readonly string[] | false;
  /** Draws the panel in the page instead of in a popup, with no trigger. @default false */
  inline?: boolean;
  /** The field under the panel that the value can be typed into. @default true */
  editable?: boolean;
  /** Label above the control. */
  label?: React.ReactNode;
  /** Helper text below it. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the control invalid. */
  error?: React.ReactNode;
  invalid?: boolean;
  required?: boolean;
  disabled?: boolean;
  /** Shows the colour and forbids changing it. @default false */
  readOnly?: boolean;
  /** Stretches the trigger to its container. @default false */
  fullWidth?: boolean;
  /** Offers the × that empties the control. @default false */
  clearable?: boolean;
  /** Submits with a form under this name. */
  name?: string;
  /** Whether the popup is open. Pass it to drive the popup yourself. */
  open?: boolean;
  /** Where an uncontrolled popup starts. @default false */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Overrides for the accessible names, one at a time. */
  labels?: Partial<PlColorPickerLabels>;
  /** Drop shadow depth on the trigger. `0` — the default — is flat. @default 0 */
  elevation?: PlassElevation;
}

/* ---------------------------------------------------------------------------
 * Scale
 * ------------------------------------------------------------------------- */

/**
 * How wide the panel is, and it is a ladder of its own rather than a step off
 * the control heights: a saturation square is a *space* to aim at, not a row to
 * read, and one 40px tall would give the pointer four hundred distinguishable
 * colours out of a possible ten thousand.
 */
const panelWidthClasses: Record<PlassSize, string> = {
  xs: 'w-40',
  sm: 'w-44',
  md: 'w-52',
  lg: 'w-60',
  xl: 'w-72'
};

const areaHeightClasses: Record<PlassSize, string> = {
  xs: 'h-24',
  sm: 'h-28',
  md: 'h-32',
  lg: 'h-40',
  xl: 'h-48'
};

const railHeightClasses: Record<PlassSize, string> = {
  xs: 'h-2.5',
  sm: 'h-3',
  md: 'h-3.5',
  lg: 'h-4',
  xl: 'h-5'
};

/** The panel's own gaps, one track tighter than a form's. */
const panelGapClasses: Record<PlassSize, string> = {
  xs: 'gap-1.5',
  sm: 'gap-2',
  md: 'gap-2.5',
  lg: 'gap-3',
  xl: 'gap-3.5'
};

/**
 * The thumb, in pixels rather than on the spacing scale.
 *
 * It is centred on its value with a negative margin instead of a `translate`,
 * which needs the number rather than a class — and a negative margin is also
 * the one centring that survives a caller's own transform on the panel.
 */
const thumbSizes: Record<PlassSize, number> = { xs: 10, sm: 12, md: 14, lg: 16, xl: 18 };

/* ---------------------------------------------------------------------------
 * Surfaces
 * ------------------------------------------------------------------------- */

/**
 * The spectrum, drawn rather than sampled.
 *
 * Seven stops at the six primaries plus a repeat of red, which is what makes
 * the rail seamless — the wheel is a circle and a gradient is a line, so the
 * only way for 359° to sit next to 0° is to write red down twice.
 */
const hueRailBackground =
  'linear-gradient(to right, #ff0000 0%, #ffff00 16.66%, #00ff00 33.33%, #00ffff 50%, #0000ff 66.66%, #ff00ff 83.33%, #ff0000 100%)';

/**
 * A hairline and a light edge, on something whose fill is the caller's.
 *
 * `--plass-border` and not the sheet's white cut edge: what is behind these is
 * an arbitrary colour rather than the page wash, and white light on a cut edge
 * is a claim about the wash.
 */
const wellClasses = /* @__PURE__ */ [
  'relative overflow-hidden border',
  '[border-color:var(--plass-border)]',
  '[box-shadow:var(--plass-gloss-glass)]'
].join(' ');

const thumbClasses = /* @__PURE__ */ [
  'pointer-events-none absolute rounded-full border-2 border-white',
  // Two shadows: a dark hairline so the white ring survives on white, and a
  // soft drop so it survives on black. Neither is tinted with the colour under
  // it, which would make the thumb disappear at exactly the moment it matters.
  '[box-shadow:0_0_0_1px_rgba(0,0,0,0.35),0_1px_3px_rgba(0,0,0,0.4)]'
].join(' ');

/* ---------------------------------------------------------------------------
 * Panel
 * ------------------------------------------------------------------------- */

interface PanelProps {
  hsv: PlassHsv;
  alphaValue: number;
  /**
   * One callback for both channels rather than two.
   *
   * A swatch changes the colour *and* the opacity, and two callbacks would mean
   * two updates in one event — the second built from the state the first has
   * only just replaced. That is not a race that shows up under a pointer drag,
   * where only one channel moves; it shows up the first time somebody picks a
   * translucent swatch and gets the old colour at the new opacity.
   */
  onChange: (next: { hsv: PlassHsv; alpha: number }) => void;
  text: string;
  onTextChange: (text: string) => void;
  withAlpha: boolean;
  swatches: readonly string[] | false;
  editable: boolean;
  size: PlassSize;
  inert: boolean;
  labels: PlColorPickerLabels;
}

/** Where a pointer landed inside an element, as a 0–1 fraction of each axis. */
function fractionsOf(event: React.PointerEvent<HTMLElement>): { x: number; y: number } {
  const rect = event.currentTarget.getBoundingClientRect();

  return {
    x: rect.width === 0 ? 0 : clamp((event.clientX - rect.left) / rect.width, 0, 1),
    y: rect.height === 0 ? 0 : clamp((event.clientY - rect.top) / rect.height, 0, 1)
  };
}

/**
 * Arrow keys, in the two step sizes every slider in the library uses.
 *
 * Returns `null` for a key it does not answer to, so the caller can leave the
 * event alone — a picker that swallowed Tab would trap the focus in a gradient.
 */
function arrowStep(event: React.KeyboardEvent): { x: number; y: number } | null {
  const step = event.shiftKey ? 10 : 1;

  switch (event.key) {
    case 'ArrowLeft':
      return { x: -step, y: 0 };
    case 'ArrowRight':
      return { x: step, y: 0 };
    case 'ArrowUp':
      return { x: 0, y: step };
    case 'ArrowDown':
      return { x: 0, y: -step };
    default:
      return null;
  }
}

function ColorPanel({
  hsv,
  alphaValue,
  onChange,
  text,
  onTextChange,
  withAlpha,
  swatches,
  editable,
  size,
  inert,
  labels
}: PanelProps) {
  const thumb = thumbSizes[size];
  const offset = -thumb / 2;
  const pure = cssColor({ h: hsv.h, s: 100, v: 100 });
  const solid = cssColor(hsv);

  /** Pointer capture on the element itself, so a drag off the panel keeps working. */
  const track = (handler: (event: React.PointerEvent<HTMLElement>) => void) => ({
    onPointerDown: (event: React.PointerEvent<HTMLElement>) => {
      if (inert) {
        return;
      }

      event.currentTarget.setPointerCapture(event.pointerId);
      handler(event);
    },
    onPointerMove: (event: React.PointerEvent<HTMLElement>) => {
      if (inert || !event.currentTarget.hasPointerCapture(event.pointerId)) {
        return;
      }

      handler(event);
    }
  });

  const railProps = (label: string, now: number, max: number, onStep: (delta: number) => void) => ({
    role: 'slider' as const,
    tabIndex: inert ? -1 : 0,
    'aria-label': label,
    'aria-valuemin': 0,
    'aria-valuemax': max,
    'aria-valuenow': Math.round(now),
    'aria-orientation': 'horizontal' as const,
    'aria-disabled': inert || undefined,
    onKeyDown: (event: React.KeyboardEvent) => {
      const step = arrowStep(event);

      if (inert || !step || step.x === 0) {
        return;
      }

      event.preventDefault();
      onStep(step.x);
    }
  });

  return (
    <div className={cx('flex flex-col', panelWidthClasses[size], panelGapClasses[size])}>
      <div
        {...track((event) => {
          const { x, y } = fractionsOf(event);

          onChange({ hsv: { h: hsv.h, s: x * 100, v: (1 - y) * 100 }, alpha: alphaValue });
        })}
        role="slider"
        tabIndex={inert ? -1 : 0}
        aria-label={labels.area}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-valuenow={Math.round(hsv.s)}
        aria-valuetext={`${Math.round(hsv.s)}%, ${Math.round(hsv.v)}%`}
        aria-disabled={inert || undefined}
        onKeyDown={(event) => {
          const step = arrowStep(event);

          if (inert || !step) {
            return;
          }

          event.preventDefault();
          onChange({
            hsv: {
              h: hsv.h,
              s: clamp(hsv.s + step.x, 0, 100),
              v: clamp(hsv.v + step.y, 0, 100)
            },
            alpha: alphaValue
          });
        }}
        className={cx(
          wellClasses,
          areaHeightClasses[size],
          radiusClasses[size],
          focusRingClasses,
          inert ? 'cursor-default' : 'cursor-crosshair touch-none'
        )}
        style={{
          backgroundColor: pure,
          // Black over white: the first image in the list is the one on top, and
          // the brightness ramp has to be above the saturation ramp or the
          // bottom of the square never reaches black.
          backgroundImage:
            'linear-gradient(to top, #000000, rgba(0, 0, 0, 0)), linear-gradient(to right, #ffffff, rgba(255, 255, 255, 0))'
        }}
      >
        <span
          className={thumbClasses}
          style={{
            width: thumb,
            height: thumb,
            left: `${hsv.s}%`,
            top: `${100 - hsv.v}%`,
            marginLeft: offset,
            marginTop: offset,
            backgroundColor: solid
          }}
        />
      </div>

      <div
        {...track((event) =>
          onChange({ hsv: { ...hsv, h: fractionsOf(event).x * 360 }, alpha: alphaValue })
        )}
        {...railProps(labels.hue, hsv.h, 360, (delta) =>
          onChange({ hsv: { ...hsv, h: (hsv.h + delta * 2 + 360) % 360 }, alpha: alphaValue })
        )}
        className={cx(
          wellClasses,
          railHeightClasses[size],
          'rounded-full',
          focusRingClasses,
          inert ? 'cursor-default' : 'cursor-pointer touch-none'
        )}
        style={{ backgroundImage: hueRailBackground }}
      >
        <span
          className={thumbClasses}
          style={{
            width: thumb,
            height: thumb,
            left: `${(hsv.h / 360) * 100}%`,
            top: '50%',
            marginLeft: offset,
            marginTop: offset,
            backgroundColor: pure
          }}
        />
      </div>

      {withAlpha ? (
        <div
          {...track((event) => onChange({ hsv, alpha: fractionsOf(event).x }))}
          {...railProps(labels.alpha, alphaValue * 100, 100, (delta) =>
            onChange({ hsv, alpha: clamp(alphaValue + delta / 100, 0, 1) })
          )}
          className={cx(
            wellClasses,
            railHeightClasses[size],
            'rounded-full',
            focusRingClasses,
            inert ? 'cursor-default' : 'cursor-pointer touch-none'
          )}
          style={checkerBackground}
        >
          {/* The ramp is a layer over the chequer rather than another background
              on the same element, because a gradient and a chequer cannot share
              one `background-image` without one of them tiling the other. */}
          <span
            aria-hidden="true"
            className="absolute inset-0"
            style={{
              backgroundImage: `linear-gradient(to right, ${cssColor(hsv, 0)}, ${solid})`
            }}
          />
          <span
            className={thumbClasses}
            style={{
              width: thumb,
              height: thumb,
              left: `${alphaValue * 100}%`,
              top: '50%',
              marginLeft: offset,
              marginTop: offset,
              backgroundColor: cssColor(hsv, alphaValue)
            }}
          />
        </div>
      ) : null}

      {editable ? (
        <div className={cx('flex items-center', panelGapClasses[size])}>
          <span
            aria-hidden="true"
            className="shrink-0 rounded-full border [border-color:var(--plass-border)]"
            style={{ width: thumb + 6, height: thumb + 6, ...checkerBackground }}
          >
            <span
              className="block size-full rounded-full"
              style={{ backgroundColor: cssColor(hsv, alphaValue) }}
            />
          </span>
          <input
            type="text"
            value={text}
            readOnly={inert}
            spellCheck={false}
            autoComplete="off"
            aria-label={labels.value}
            onChange={(event) => onTextChange(event.target.value)}
            className={cx(
              'min-w-0 flex-1 border bg-transparent px-1.5 py-1 font-mono lowercase',
              '[border-color:var(--plass-border)]',
              radiusClasses.xs,
              metaTextClasses[size],
              'text-(--plass-fg)',
              '[outline:none] focus-visible:[outline:2px_solid_var(--p-ring)]',
              'focus-visible:[outline-offset:0px]'
            )}
          />
        </div>
      ) : null}

      {swatches && swatches.length > 0 ? (
        <div role="group" aria-label={labels.swatches} className="grid grid-cols-8 gap-1">
          {swatches.map((swatch) => {
            const parsed = parseColor(swatch);
            const chosen =
              parsed !== null &&
              formatColor(parsed.hsv, parsed.alpha, 'hex') === formatColor(hsv, alphaValue, 'hex');

            return (
              <button
                key={swatch}
                type="button"
                disabled={inert}
                aria-label={swatch}
                aria-pressed={chosen}
                onClick={() => {
                  if (!parsed) {
                    return;
                  }

                  onChange(parsed);
                }}
                className={cx(
                  'flex aspect-square items-center justify-center rounded-full border',
                  '[border-color:var(--plass-border)]',
                  '[transition:box-shadow_var(--plass-duration)_var(--plass-ease)]',
                  focusRingClasses,
                  '[outline:none]',
                  inert
                    ? 'cursor-default'
                    : 'cursor-pointer hover:[box-shadow:var(--plass-shadow-1)]',
                  '[&_svg]:size-3'
                )}
                style={{ backgroundColor: swatch }}
              >
                {/* Black or white, decided by what can actually be read on the
                    swatch — a fixed white tick vanishes on yellow. */}
                {chosen && parsed ? (
                  <span style={{ color: readableInk(parsed.hsv) }}>
                    <CheckIcon />
                  </span>
                ) : null}
              </button>
            );
          })}
        </div>
      ) : null}
    </div>
  );
}

/* ---------------------------------------------------------------------------
 * The component
 * ------------------------------------------------------------------------- */

/** The widest string each notation can produce, so the trigger stops resizing. */
function widthSamples(format: PlColorFormat, withAlpha: boolean): string[] {
  if (format === 'hex') {
    return [withAlpha ? '#ffffffff' : '#ffffff'];
  }

  if (format === 'rgb') {
    return [withAlpha ? 'rgba(255, 255, 255, 0.55)' : 'rgb(255, 255, 255)'];
  }

  return [withAlpha ? 'hsla(360, 100%, 100%, 0.55)' : 'hsl(360, 100%, 100%)'];
}

const fallbackHsv: PlassHsv = { h: 217, s: 87, v: 82 };

/**
 * A colour, chosen by eye.
 *
 * A saturation square with a hue rail beside it — the arrangement every design
 * tool has settled on, because it is the one that puts every colour of a hue
 * within a single movement of the pointer. `alpha` adds a third rail, `format`
 * decides which notation comes back out, and `swatches` puts the handful of
 * colours a product actually uses one click away.
 *
 * The panel's state is **HSV and it never leaves that model**, which is what
 * keeps the hue rail still while the pointer is in the black corner: through
 * RGB, every shade of black is the same colour and the rail would snap to red.
 *
 * There is no colour library under this. The conversions are in
 * `internal/color.ts`, which is a hundred lines of arithmetic — the whole reason
 * no colour library comes with it.
 */
export const PlColorPicker = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlColorPickerProps>(
  function PlColorPicker(
    {
      value,
      defaultValue = '#1a58d1',
      onValueChange,
      format = 'hex',
      alpha = false,
      swatches = defaultSwatches,
      inline = false,
      editable = true,
      label,
      description,
      error,
      invalid,
      required = false,
      disabled = false,
      readOnly = false,
      fullWidth = false,
      clearable = false,
      name,
      open,
      defaultOpen = false,
      onOpenChange,
      labels: labelOverrides,
      variant = 'glass',
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      elevation = 0,
      className,
      style,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    const labels: PlColorPickerLabels = React.useMemo(
      () => ({ ...defaultColorPickerLabels, ...labelOverrides }),
      [labelOverrides]
    );

    const [uncontrolledValue, setUncontrolledValue] = React.useState(defaultValue);
    const current = value ?? uncontrolledValue;

    const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen);
    const isOpen = open ?? uncontrolledOpen;

    /*
     * HSV is the state, and the value is what it is written down as.
     *
     * The other way round — parsing the string on every render — is what makes
     * a picker's hue rail jump: `#000000` has no hue to read back, so dragging
     * into the bottom of the square would reset the rail to red. So the model is
     * kept and the string is derived from it, and an incoming `value` only
     * re-seeds the model when it says something different from what the model
     * already means.
     */
    const [model, setModel] = React.useState(
      () => parseColor(current) ?? { hsv: fallbackHsv, alpha: 1 }
    );
    const [text, setText] = React.useState(() => current);

    const written = formatColor(model.hsv, alpha ? model.alpha : 1, format);
    const empty = current === '';

    React.useEffect(() => {
      const parsed = parseColor(current);

      if (!parsed) {
        // Not a colour this understands — `''` after a clear, or something a
        // caller made up. The field shows it and the panel stays where it was.
        // eslint-disable-next-line react-hooks/set-state-in-effect
        setText(current);

        return;
      }

      // Compared as colours rather than as strings. `#FF0000` and `#ff0000` are
      // the same colour written two ways, and a string comparison would re-seed
      // the model from a value it had just produced, on every render, forever.
      if (formatColor(parsed.hsv, alpha ? parsed.alpha : 1, format) === written) {
        return;
      }

      setText(current);
      setModel(parsed);
    }, [current, written, alpha, format]);

    const commit = (next: { hsv: PlassHsv; alpha: number }, typed?: string) => {
      setModel(next);

      const output = formatColor(next.hsv, alpha ? next.alpha : 1, format);

      setText(typed ?? output);

      if (value === undefined) {
        setUncontrolledValue(output);
      }

      onValueChange?.(output);
    };

    const inert = disabled || readOnly;

    const panel = (
      <ColorPanel
        hsv={model.hsv}
        alphaValue={model.alpha}
        onChange={commit}
        text={text}
        onTextChange={(next) => {
          setText(next);

          const parsed = parseColor(next);

          if (parsed) {
            commit(parsed, next);
          }
        }}
        withAlpha={alpha}
        swatches={swatches}
        editable={editable}
        size={size}
        inert={inert}
        labels={labels}
      />
    );

    const hidden = name ? <input type="hidden" name={name} value={empty ? '' : written} /> : null;

    if (inline) {
      const family: PlassColor = (invalid ?? Boolean(error)) ? 'danger' : color;

      return (
        <div
          ref={ref}
          className={cx('flex flex-col', stackGapClasses[size], className)}
          style={{ ...surfaceSlots(family, elevation), ...style }}
          {...props}
        >
          {label ? (
            <span
              className={cx(
                metaTextClasses[size],
                'font-semibold',
                disabled ? 'text-(--plass-muted-fg)' : 'text-(--plass-fg)'
              )}
            >
              {label}
            </span>
          ) : null}

          {panel}

          {description ? (
            <span className={cx(metaTextClasses[size], 'text-(--plass-muted-fg)')}>
              {description}
            </span>
          ) : null}

          {error ? (
            <span className={cx(metaTextClasses[size], 'text-(--p-accent)')}>{error}</span>
          ) : null}

          {hidden}
        </div>
      );
    }

    return (
      <div ref={ref} className={fullWidth ? 'w-full' : 'inline-block'} {...props}>
        <PickerShell
          variant={variant}
          size={size}
          color={color}
          density={density}
          elevation={elevation}
          style={style}
          label={label}
          description={description}
          error={error}
          invalid={invalid}
          required={required}
          disabled={disabled}
          readOnly={readOnly}
          fullWidth={fullWidth}
          className={className}
          startIcon={
            <span
              aria-hidden="true"
              className="block size-[1.15em] shrink-0 rounded-full border [border-color:var(--plass-border)]"
              style={checkerBackground}
            >
              <span
                className="block size-full rounded-full"
                style={{
                  backgroundColor: empty
                    ? 'transparent'
                    : cssColor(model.hsv, alpha ? model.alpha : 1)
                }}
              />
            </span>
          }
          display={empty ? labels.empty : written}
          samples={widthSamples(format, alpha)}
          empty={empty}
          clearable={clearable}
          onClear={() => {
            if (value === undefined) {
              setUncontrolledValue('');
            }

            setText('');
            onValueChange?.('');
          }}
          open={isOpen}
          onOpenChange={(next) => {
            if (open === undefined) {
              setUncontrolledOpen(next);
            }

            onOpenChange?.(next);
          }}
          labels={{ ...defaultPickerLabels, clear: labels.clear }}
          hiddenValues={name ? [{ name, value: empty ? '' : written }] : undefined}
        >
          <div className={controlTextClasses[size]}>{panel}</div>
        </PickerShell>
      </div>
    );
  }
);
