/**
 * Colour arithmetic, written out rather than installed.
 *
 * `PlColorPicker` is the only component that has to *compute* a colour rather
 * than name one, and the whole of what it needs is here: three representations,
 * the conversions between them, one parser and one formatter. It is a hundred
 * lines of trigonometry-free arithmetic, which is the entire reason a component
 * that computes colours brings no colour library with it.
 *
 * Two decisions worth knowing before reading:
 *
 * - **HSV is the model the panel is drawn in, and it never leaves.** A
 *   saturation/value square with a hue rail beside it *is* HSV, so the picker
 *   keeps its state that way and converts on the way out. Round-tripping
 *   through RGB instead would lose the hue of every greyscale colour — black is
 *   `#000` at every hue — and the rail would jump to red the moment the pointer
 *   reached a corner.
 * - **`alpha` is 0–1, everything else is what CSS says it is.** `h` is degrees,
 *   `s`/`v`/`l` are percentages, `r`/`g`/`b` are 0–255. Nothing here invents a
 *   normalised unit, because every one of these numbers is eventually written
 *   into a string a human reads.
 *
 * Nothing here is exported from `src/index.ts` except the two types the picker's
 * own props need. It is the library talking to itself, in the sense that
 * `internal/` always means.
 */

/** 0–255 per channel, the way a hex triplet and `rgb()` both spell it. */
export interface PlassRgb {
  r: number;
  g: number;
  b: number;
}

/** `h` in degrees, `s` and `v` as percentages. The panel's own model. */
export interface PlassHsv {
  h: number;
  s: number;
  v: number;
}

/** `h` in degrees, `s` and `l` as percentages. Only ever an output format. */
export interface PlassHsl {
  h: number;
  s: number;
  l: number;
}

/** A colour and how much of it there is. `alpha` is 0–1. */
export interface PlassColorValue {
  hsv: PlassHsv;
  alpha: number;
}

/** The three ways the picker will write a colour back out. */
export type PlColorFormat = 'hex' | 'rgb' | 'hsl';

/* ---------------------------------------------------------------------------
 * Arithmetic
 * ------------------------------------------------------------------------- */

export function clamp(value: number, min: number, max: number): number {
  return value < min ? min : value > max ? max : value;
}

/** Degrees, wrapped rather than clamped — 370 is 10, and -10 is 350. */
function wrapHue(hue: number): number {
  const wrapped = hue % 360;

  return wrapped < 0 ? wrapped + 360 : wrapped;
}

function round(value: number): number {
  return Math.round(value);
}

/* ---------------------------------------------------------------------------
 * Conversions
 * ------------------------------------------------------------------------- */

export function hsvToRgb({ h, s, v }: PlassHsv): PlassRgb {
  const hue = wrapHue(h) / 60;
  const saturation = clamp(s, 0, 100) / 100;
  const value = clamp(v, 0, 100) / 100;

  const chroma = value * saturation;
  const second = chroma * (1 - Math.abs((hue % 2) - 1));
  const base = value - chroma;

  const sector = Math.floor(hue) % 6;
  const [r, g, b] = (
    [
      [chroma, second, 0],
      [second, chroma, 0],
      [0, chroma, second],
      [0, second, chroma],
      [second, 0, chroma],
      [chroma, 0, second]
    ] as const
  )[sector];

  return { r: round((r + base) * 255), g: round((g + base) * 255), b: round((b + base) * 255) };
}

export function rgbToHsv({ r, g, b }: PlassRgb): PlassHsv {
  const red = clamp(r, 0, 255) / 255;
  const green = clamp(g, 0, 255) / 255;
  const blue = clamp(b, 0, 255) / 255;

  const max = Math.max(red, green, blue);
  const min = Math.min(red, green, blue);
  const chroma = max - min;

  let hue = 0;

  if (chroma !== 0) {
    if (max === red) {
      hue = ((green - blue) / chroma) % 6;
    } else if (max === green) {
      hue = (blue - red) / chroma + 2;
    } else {
      hue = (red - green) / chroma + 4;
    }
  }

  return {
    h: wrapHue(hue * 60),
    s: max === 0 ? 0 : (chroma / max) * 100,
    v: max * 100
  };
}

export function rgbToHsl({ r, g, b }: PlassRgb): PlassHsl {
  const { h, s, v } = rgbToHsv({ r, g, b });
  const value = v / 100;
  const saturation = s / 100;

  const lightness = value * (1 - saturation / 2);
  const divisor = Math.min(lightness, 1 - lightness);

  return {
    h,
    s: divisor === 0 ? 0 : ((value - lightness) / divisor) * 100,
    l: lightness * 100
  };
}

export function hslToRgb({ h, s, l }: PlassHsl): PlassRgb {
  const lightness = clamp(l, 0, 100) / 100;
  const saturation = clamp(s, 0, 100) / 100;

  const value = lightness + saturation * Math.min(lightness, 1 - lightness);

  return hsvToRgb({
    h,
    s: value === 0 ? 0 : 2 * (1 - lightness / value) * 100,
    v: value * 100
  });
}

/* ---------------------------------------------------------------------------
 * Reading a colour in
 * ------------------------------------------------------------------------- */

const HEX_PATTERN = /^#?([0-9a-f]{3,8})$/i;

function hexToRgba(hex: string): PlassColorValue | null {
  const match = HEX_PATTERN.exec(hex.trim());

  if (!match) {
    return null;
  }

  const digits = match[1];
  // `#abc` and `#abcd` are the same colours as `#aabbcc` and `#aabbccdd`, so
  // the short forms are doubled rather than parsed a second way.
  const expanded =
    digits.length === 3 || digits.length === 4
      ? [...digits].map((digit) => digit + digit).join('')
      : digits;

  if (expanded.length !== 6 && expanded.length !== 8) {
    return null;
  }

  const channel = (index: number) => parseInt(expanded.slice(index * 2, index * 2 + 2), 16);

  return {
    hsv: rgbToHsv({ r: channel(0), g: channel(1), b: channel(2) }),
    alpha: expanded.length === 8 ? channel(3) / 255 : 1
  };
}

/** `rgb(12 34 56 / 50%)` and `rgba(12, 34, 56, .5)` are one shape once split. */
function numbersIn(source: string): number[] {
  return (source.match(/-?[\d.]+%?/g) ?? []).map((token) => parseFloat(token));
}

/** Whether the fourth number was written as a percentage rather than a fraction. */
function alphaOf(source: string, numbers: number[], index: number): number {
  if (numbers.length <= index) {
    return 1;
  }

  const tokens = source.match(/-?[\d.]+%?/g) ?? [];

  return clamp(tokens[index]?.endsWith('%') ? numbers[index] / 100 : numbers[index], 0, 1);
}

/**
 * A CSS colour string, or `null` if it is not one this understands.
 *
 * Hex in all four lengths, `rgb()`/`rgba()` and `hsl()`/`hsla()` in both the
 * comma and the space syntax. Named colours and `color()` are deliberately out:
 * a picker has to be able to write every value it can read, and there is no
 * honest way back from `rebeccapurple` to a point on the panel.
 */
export function parseColor(input: string): PlassColorValue | null {
  const source = input.trim().toLowerCase();

  if (!source) {
    return null;
  }

  if (source.startsWith('#') || HEX_PATTERN.test(source)) {
    return hexToRgba(source);
  }

  const functional = /^(rgba?|hsla?)\((.*)\)$/.exec(source);

  if (!functional) {
    return null;
  }

  const [, name, body] = functional;
  const numbers = numbersIn(body);

  if (numbers.length < 3 || numbers.some(Number.isNaN)) {
    return null;
  }

  const alpha = alphaOf(body, numbers, 3);

  if (name.startsWith('rgb')) {
    return {
      hsv: rgbToHsv({ r: numbers[0], g: numbers[1], b: numbers[2] }),
      alpha
    };
  }

  return {
    hsv: rgbToHsv(hslToRgb({ h: numbers[0], s: numbers[1], l: numbers[2] })),
    alpha
  };
}

/* ---------------------------------------------------------------------------
 * Writing a colour out
 * ------------------------------------------------------------------------- */

function hexPair(value: number): string {
  return clamp(round(value), 0, 255).toString(16).padStart(2, '0');
}

export function rgbToHex({ r, g, b }: PlassRgb, alpha = 1): string {
  const base = `#${hexPair(r)}${hexPair(g)}${hexPair(b)}`;

  return alpha >= 1 ? base : `${base}${hexPair(alpha * 255)}`;
}

/** Two decimals at most, and no trailing zeroes: `0.5`, not `0.50`. */
function alphaText(alpha: number): string {
  return String(Math.round(clamp(alpha, 0, 1) * 100) / 100);
}

/**
 * The value the component hands back, in whichever notation was asked for.
 *
 * `hex` drops the alpha pair when the colour is opaque, and the two functional
 * forms drop the fourth argument for the same reason — a caller who never
 * turned `alpha` on should never see `rgba(…, 1)` come out of a control they
 * only used three channels of.
 */
export function formatColor(hsv: PlassHsv, alpha: number, format: PlColorFormat): string {
  const rgb = hsvToRgb(hsv);

  if (format === 'hex') {
    return rgbToHex(rgb, alpha);
  }

  if (format === 'rgb') {
    const channels = `${round(rgb.r)}, ${round(rgb.g)}, ${round(rgb.b)}`;

    return alpha >= 1 ? `rgb(${channels})` : `rgba(${channels}, ${alphaText(alpha)})`;
  }

  const { h, s, l } = rgbToHsl(rgb);
  const channels = `${round(h)}, ${round(s)}%, ${round(l)}%`;

  return alpha >= 1 ? `hsl(${channels})` : `hsla(${channels}, ${alphaText(alpha)})`;
}

/** A plain `rgb()` for the swatches and rails, where alpha is drawn separately. */
export function cssColor(hsv: PlassHsv, alpha = 1): string {
  const { r, g, b } = hsvToRgb(hsv);

  return alpha >= 1 ? `rgb(${r}, ${g}, ${b})` : `rgba(${r}, ${g}, ${b}, ${alphaText(alpha)})`;
}

/**
 * Black or white, whichever can be read on top of this colour.
 *
 * The tick on a chosen swatch is the only thing the picker draws *on* an
 * arbitrary colour, and a fixed white tick disappears on yellow. The threshold
 * is relative luminance rather than plain lightness, because the eye weighs
 * green about six times as heavily as blue and a colour model that pretends
 * otherwise puts the tick the wrong way round on both.
 */
export function readableInk(hsv: PlassHsv): string {
  const { r, g, b } = hsvToRgb(hsv);
  const channel = (value: number) => {
    const scaled = value / 255;

    return scaled <= 0.03928 ? scaled / 12.92 : ((scaled + 0.055) / 1.055) ** 2.4;
  };

  const luminance = 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);

  return luminance > 0.42 ? '#000000' : '#ffffff';
}

/**
 * The swatches a picker shows when it was given none.
 *
 * Deliberately **not** the library's own six families: those are semantic roles
 * and a picker is asked for a colour, not for a meaning. This is a plain
 * spectrum plus the greys — the row somebody reaches for when they are
 * labelling a calendar, a tag or a project, which is what a colour picker in an
 * application is nearly always for.
 */
export const defaultSwatches: readonly string[] = [
  '#000000',
  '#4b5563',
  '#9ca3af',
  '#ffffff',
  '#ef4444',
  '#f97316',
  '#f59e0b',
  '#84cc16',
  '#22c55e',
  '#14b8a6',
  '#06b6d4',
  '#3b82f6',
  '#6366f1',
  '#8b5cf6',
  '#d946ef',
  '#ec4899'
];

/**
 * The chequerboard behind a translucent colour, as a background shorthand.
 *
 * Two conic gradients would be one declaration fewer, but a chequer drawn with
 * conic gradients has a seam down the middle of every tile on a fractional
 * device pixel ratio. Four linear stops at 45° do not.
 */
export const checkerBackground = {
  backgroundImage:
    'linear-gradient(45deg, var(--plass-border) 25%, transparent 25%), linear-gradient(-45deg, var(--plass-border) 25%, transparent 25%), linear-gradient(45deg, transparent 75%, var(--plass-border) 75%), linear-gradient(-45deg, transparent 75%, var(--plass-border) 75%)',
  backgroundSize: '8px 8px',
  backgroundPosition: '0 0, 0 4px, 4px -4px, -4px 0'
} as const;
