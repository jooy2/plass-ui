/**
 * The chrome a `PlWindowPane` draws, and the tables that say how big it is.
 *
 * It lives here for the reason `internal/mockup.tsx` does. One component reads
 * it, but what it holds is reference data rather than a piece of that component
 * — four systems' worth of title bars, three buttons each, drawn four different
 * ways — and a component file with all of that in it would be a table with a
 * `forwardRef` at the bottom.
 *
 * Three conventions run through it:
 *
 * **Every length is a CSS pixel at `md`, scaled once by `size`.** A title bar is
 * 32px on Windows 11 and 38px on macOS because those are the heights they are,
 * not because a ladder in `internal/styles.ts` says so — this is the one place
 * in the library where the numbers come from somewhere else. `size` multiplies
 * them, which is why they are written as numbers rather than as utilities.
 *
 * **The buttons are drawings of what they do and carry no other party's marks.**
 * A traffic light is three circles; a Windows control is a line, a box and a
 * cross. Their names come from `internal/labels.ts` and are read out; nothing here
 * writes a word.
 *
 * **Nothing is mixed out of `currentColor`.** Every fill a control can take is a
 * slot computed once in `windowSlots`, because a hover that changes the ink and
 * a fill derived from the ink are the same declaration arguing with itself —
 * which is exactly how a close button ends up white on white.
 */

import * as React from 'react';
import { cx } from './styles.js';
import type { PlassColor, PlassSize } from '../types.js';

/* ---------------------------------------------------------------------------
 * The vocabulary
 *
 * `PlWindowPane`'s public types, declared here because the drawings below need
 * them. `PlWindowPane.tsx` re-exports them, so a caller never learns this file
 * exists.
 * ------------------------------------------------------------------------- */

/**
 * Whose window this is a picture of.
 *
 * Versions are separate entries wherever the *title bar* is what changed, which
 * is why Windows has five and the others have one or two. XP painted its bar in
 * Luna blue and framed the window in it; 7 made it glass; 8 threw both away for
 * a flat square sheet; 10 ruled the bar off from the body; 11 rounded the
 * corners and made the two one Mica sheet again. `macosx` is Aqua — the striped
 * grey bar, the glossy lights and the square bottom corners — against the flat
 * `macos` that replaced it.
 *
 * They are named the way the systems are, so `windows11` rather than `win11`
 * and `macos` rather than `mac`. Nothing here is a copy of any of them: what is
 * drawn is a bar, a border and three buttons at the proportions the system used,
 * and no mark, wordmark or icon belonging to anyone else.
 */
export type PlWindowOs =
  'macos' | 'macosx' | 'windows11' | 'windows10' | 'windows8' | 'windows7' | 'windowsxp' | 'linux';

/** The three buttons a title bar can carry. */
export type PlWindowControl = 'minimize' | 'maximize' | 'close';

/** How far the window has been dragged from where the layout put it. */
export interface PlWindowOffset {
  x: number;
  y: number;
}

/* ---------------------------------------------------------------------------
 * Metrics
 * ------------------------------------------------------------------------- */

/** Everything the component needs to lay a title bar out, in CSS pixels. */
export interface PlWindowMetrics {
  /** The title bar's height. */
  bar: number;
  /** The window's own corner, at the top. */
  radius: number;
  /** And at the bottom, which the older systems leave square. */
  radiusBottom: number;
  /** The hairline around the window. */
  frame: number;
  /**
   * The *band* around it, which is a different thing: the stretch of the
   * system's own colour that XP and Aero put down the sides of a window and
   * along the bottom of it, with the content inset into it. Zero on the systems
   * that have only a hairline.
   */
  band: { side: number; bottom: number };
  /** The air at the leading edge of the bar. */
  padX: number;
  /** And at the trailing edge, which is nothing where the buttons run to it. */
  padEnd: number;
  /** Between one control and the next. */
  gap: number;
  /** The title's type size. */
  title: number;
  /** One control's box. */
  control: { width: number; height: number };
  /** The mark inside it. */
  glyph: number;
  /** How heavy the title is written. */
  weight: number;
  /** How much room the whole set of them takes, given how many are drawn. */
  controlsWidth: (count: number) => number;
  /** Aero's close button, which is wider than the two beside it. */
  closeWidth: number;
}

interface PlWindowChrome {
  bar: number;
  radius: number;
  /** Square on every system before the corners were rounded all the way round. */
  radiusBottom: number;
  padX: number;
  /** The air at the trailing end, which is nothing where the buttons run to it. */
  padEnd: number;
  gap: number;
  title: number;
  glyph: number;
  weight: number;
  frame: number;
  band: { side: number; bottom: number };
  control: { width: number; height: number };
  /** Aero's close button is wider than the two beside it. */
  closeWidth?: number;
  /** Where the title sits along the bar. */
  titleAlign: 'start' | 'center';
  /** Which end the controls are on. */
  controlsSide: 'start' | 'end';
  /**
   * How one control is drawn.
   *
   * - `dot` — a flat traffic light, and `gloss-dot` the same one with Aqua's
   *   highlight and ring on it.
   * - `square` — a flat rectangle running to the corner of the window.
   * - `plate` — XP's coloured, gradient-filled button.
   * - `aero` — a pane of glass hung off the top edge, close first among equals.
   * - `circle` — GNOME's small disc.
   */
  shape: 'dot' | 'gloss-dot' | 'square' | 'plate' | 'aero' | 'circle';
  /** Whether the bar is ruled off from the body. */
  rule: boolean;
  /** How thick the glyphs are drawn. */
  stroke: number;
  /** The corner on the maximize box: Windows 11 rounds it, Windows 10 does not. */
  boxRadius: number;
  /** How much of the page's ink is stirred into the bar, in front and behind. */
  tint: [number, number];
  /** Whether an accented window carries the colour into its border as well. */
  accentBorder: boolean;
  /**
   * The chrome's own colours, for the systems that painted their title bar
   * rather than taking the page's.
   *
   * Fixed values rather than theme tokens, exactly as `PlMockup`'s finishes are:
   * Luna blue is Luna blue on a page switched to dark, and a title bar that
   * changed colour with the theme would be a drawing of the theme rather than
   * of a window. `dark` says which way its own controls have to lighten.
   */
  paint: { fill: string; ink: string; dark: boolean } | null;
  /** What is laid over that fill: the gradient, the gloss, the stripes. */
  image: string | null;
  /** The title's own shadow — XP's hard one, Aero's glow, Aqua's emboss. */
  shadow: string | null;
  /** Whether the bar blurs what is behind it, which is what made Aero glass. */
  glass: boolean;
}

/**
 * The four systems, at `md`.
 *
 * macOS puts three coloured dots on the left and centres the title over the
 * whole window. Windows puts three full-height rectangles hard against the
 * top-right corner — they are wide because they are a corner target, and that
 * is what makes a Windows title bar recognisable at a glance. A GNOME header
 * bar is taller than either, centres its title and draws its buttons as small
 * circles held clear of the edge.
 */
const chromes: Record<PlWindowOs, PlWindowChrome> = {
  macos: {
    bar: 38,
    radius: 10,
    radiusBottom: 10,
    padX: 12,
    padEnd: 12,
    gap: 8,
    title: 13,
    glyph: 7,
    weight: 500,
    frame: 1,
    band: { side: 0, bottom: 0 },
    control: { width: 12, height: 12 },
    titleAlign: 'center',
    controlsSide: 'start',
    shape: 'dot',
    rule: false,
    stroke: 1.4,
    boxRadius: 0,
    tint: [6, 3],
    accentBorder: false,
    paint: null,
    image: null,
    shadow: null,
    glass: false
  },
  macosx: {
    // Aqua: a short striped bar, glossy lights, a bold embossed title in the
    // middle of it, a hairline under it and a bottom that was never rounded.
    bar: 26,
    radius: 8,
    radiusBottom: 0,
    padX: 10,
    padEnd: 10,
    gap: 8,
    title: 12,
    glyph: 7,
    weight: 700,
    frame: 1,
    band: { side: 0, bottom: 0 },
    control: { width: 13, height: 13 },
    titleAlign: 'center',
    controlsSide: 'start',
    shape: 'gloss-dot',
    rule: true,
    stroke: 1.5,
    boxRadius: 0,
    tint: [0, 0],
    accentBorder: false,
    paint: { fill: '#e4e4e4', ink: '#333333', dark: false },
    image:
      'repeating-linear-gradient(180deg, rgb(255 255 255 / 0.55) 0 1px, rgb(0 0 0 / 0.035) 1px 2px), linear-gradient(180deg, rgb(255 255 255 / 0.8), rgb(0 0 0 / 0.07))',
    shadow: '0 1px 0 rgb(255 255 255 / 0.85)',
    glass: false
  },
  windows11: {
    // 32px bar, 46x32 buttons: the real proportion, and the reason the buttons
    // reach the top edge of the window rather than sitting inside a padding.
    bar: 32,
    radius: 8,
    radiusBottom: 8,
    padX: 12,
    padEnd: 0,
    gap: 0,
    title: 12,
    glyph: 10,
    weight: 400,
    frame: 1,
    band: { side: 0, bottom: 0 },
    control: { width: 46, height: 32 },
    titleAlign: 'start',
    controlsSide: 'end',
    shape: 'square',
    rule: false,
    // Mica: the bar is the same sheet as the window, and what separates them is
    // the title and the buttons rather than a change of shade.
    tint: [3, 1],
    stroke: 1,
    boxRadius: 1.6,
    accentBorder: false,
    paint: null,
    image: null,
    shadow: null,
    glass: false
  },
  windows10: {
    // Square corners, a shorter bar, a rule under it, thinner glyphs and a
    // border that takes the accent colour: the five things that say "not 11".
    bar: 30,
    radius: 0,
    radiusBottom: 0,
    padX: 10,
    padEnd: 0,
    gap: 0,
    title: 12,
    glyph: 10,
    weight: 400,
    frame: 1,
    band: { side: 0, bottom: 0 },
    control: { width: 45, height: 30 },
    titleAlign: 'start',
    controlsSide: 'end',
    shape: 'square',
    rule: true,
    tint: [0, 0],
    stroke: 0.9,
    boxRadius: 0,
    accentBorder: true,
    paint: null,
    image: null,
    shadow: null,
    glass: false
  },
  windows8: {
    // The flat one. Where 10 rules its bar off from the body, 8 leaves the two
    // as one white sheet and draws a band of colour around the whole window —
    // which is the trait it is remembered by.
    bar: 32,
    radius: 0,
    radiusBottom: 0,
    padX: 10,
    padEnd: 0,
    gap: 0,
    title: 12,
    glyph: 11,
    weight: 400,
    frame: 2,
    band: { side: 0, bottom: 0 },
    control: { width: 45, height: 32 },
    titleAlign: 'start',
    controlsSide: 'end',
    shape: 'square',
    rule: false,
    tint: [0, 0],
    stroke: 1,
    boxRadius: 0,
    accentBorder: true,
    paint: null,
    image: null,
    shadow: null,
    glass: false
  },
  windows7: {
    // Aero, and the band is most of it: an Aero window is a sheet of glass with
    // the content sunk into the middle of it, so the page is blurred down both
    // sides and along the bottom as well as behind the caption. Drawn without
    // that, all that is left is a pale blue title bar on an ordinary window —
    // which is exactly what it looked like.
    bar: 30,
    radius: 7,
    radiusBottom: 0,
    padX: 10,
    padEnd: 3,
    gap: 2,
    title: 12,
    glyph: 10,
    weight: 400,
    frame: 1,
    band: { side: 7, bottom: 7 },
    control: { width: 29, height: 20 },
    closeWidth: 45,
    titleAlign: 'start',
    controlsSide: 'end',
    shape: 'aero',
    rule: false,
    tint: [0, 0],
    stroke: 1.1,
    boxRadius: 0,
    accentBorder: false,
    // Half a sheet of glass rather than a whole one: the band lays the first
    // layer down and the caption lays this one over it, so the top of the
    // window is denser than its sides — which is how Aero reads.
    paint: { fill: 'rgb(198 218 242 / 0.45)', ink: '#12314f', dark: false },
    image:
      'linear-gradient(180deg, rgb(255 255 255 / 0.62), rgb(255 255 255 / 0.1) 46%, rgb(255 255 255 / 0.34) 88%, rgb(255 255 255 / 0.5))',
    shadow: '0 0 6px rgb(255 255 255 / 0.95), 0 0 3px rgb(255 255 255 / 0.95)',
    glass: true
  },
  windowsxp: {
    // Luna: the bar is the system's blue rather than the page's white, the
    // window is framed in the same blue on three sides, and the buttons are
    // coloured plates rather than marks on the bar.
    bar: 30,
    radius: 8,
    radiusBottom: 0,
    padX: 6,
    padEnd: 4,
    gap: 2,
    title: 13,
    glyph: 9,
    weight: 700,
    frame: 1,
    band: { side: 4, bottom: 4 },
    control: { width: 21, height: 21 },
    // The close plate is the wide one on XP, as it is on Aero — the only two
    // systems here that made the button you least want to hit the easiest one.
    closeWidth: 26,
    titleAlign: 'start',
    controlsSide: 'end',
    shape: 'plate',
    rule: false,
    tint: [0, 0],
    stroke: 1.8,
    boxRadius: 3,
    accentBorder: false,
    paint: { fill: '#1f66d6', ink: '#ffffff', dark: true },
    // Luna's caption is not a slope from light to dark, which is what made a
    // flat overlay wrong: it is bright at the very top, sinks through the
    // middle, comes back up in a band at about four fifths, and is closed off by
    // a dark line at the bottom edge. That inflated, glossy profile is the whole
    // of what makes it recognisable. Written in white and black rather than in
    // blues, so a caller who dyes the bar with `accent` gets the same curve in
    // their own colour.
    image:
      'linear-gradient(180deg, rgb(255 255 255 / 0.55), rgb(255 255 255 / 0.26) 7%, rgb(0 0 0 / 0.11) 42%, rgb(0 0 0 / 0.05) 56%, rgb(255 255 255 / 0.22) 76%, rgb(255 255 255 / 0.34) 88%, rgb(0 0 0 / 0.16) 96%, rgb(0 0 0 / 0.34))',
    shadow: '0 1px 1px rgb(0 0 0 / 0.45)',
    glass: false
  },
  linux: {
    bar: 44,
    radius: 12,
    radiusBottom: 12,
    padX: 10,
    padEnd: 10,
    gap: 6,
    title: 14,
    glyph: 10,
    weight: 600,
    frame: 1,
    band: { side: 0, bottom: 0 },
    control: { width: 24, height: 24 },
    titleAlign: 'center',
    controlsSide: 'end',
    shape: 'circle',
    rule: false,
    stroke: 1.2,
    boxRadius: 0,
    tint: [11, 5],
    accentBorder: false,
    paint: null,
    image: null,
    shadow: null,
    glass: false
  }
};

/**
 * `size` on a WindowPane, and the third component after Box and Mockup where it
 * does not mean a control height.
 *
 * What it scales is the chrome — the bar, the buttons, the title — and nothing
 * else: a window's *content* is the caller's and is laid out at its own scale,
 * exactly as it would be on a real desktop where the title bar does not grow
 * with the document. The steps are gentle for the same reason a 24px title bar
 * is not a smaller title bar but an unusable one.
 */
const scales: Record<PlassSize, number> = {
  xs: 0.8,
  sm: 0.9,
  md: 1,
  lg: 1.15,
  xl: 1.3
};

export function windowMetrics(os: PlWindowOs, size: PlassSize): PlWindowMetrics {
  const chrome = chromes[os];
  const scale = scales[size];
  const round = (value: number) => Math.round(value * scale);

  const control = { width: round(chrome.control.width), height: round(chrome.control.height) };
  const gap = round(chrome.gap);

  const closeWidth = chrome.closeWidth === undefined ? control.width : round(chrome.closeWidth);

  return {
    bar: round(chrome.bar),
    // The corners are *not* scaled with the rest: they are the shape of the
    // window rather than a measure of its chrome, and an `xs` macOS window with
    // a 7px corner stops reading as macOS.
    radius: chrome.radius,
    radiusBottom: chrome.radiusBottom,
    frame: chrome.frame,
    band: { side: round(chrome.band.side), bottom: round(chrome.band.bottom) },
    padX: round(chrome.padX),
    // A Windows caption button is a corner target — it runs to the edge of the
    // window, which is what makes it hittable by throwing the pointer at the
    // corner. Everything else keeps its air.
    padEnd: round(chrome.padEnd),
    gap,
    title: round(chrome.title),
    glyph: round(chrome.glyph),
    weight: chrome.weight,
    control,
    controlsWidth: (count: number) =>
      count <= 0
        ? 0
        : // The close button is the odd one out on Aero, so the set is counted
          // as one of it and the rest of the others.
          closeWidth + (count - 1) * control.width + (count - 1) * gap,
    closeWidth
  };
}

export function windowChrome(os: PlWindowOs): PlWindowChrome {
  return chromes[os];
}

/**
 * The order the buttons go in, per system, and the reason `controls` is a set
 * rather than a list: which three a window has is the caller's decision, and
 * what order they sit in is the system's.
 */
const controlOrder: Record<PlWindowOs, readonly PlWindowControl[]> = {
  macos: ['close', 'minimize', 'maximize'],
  macosx: ['close', 'minimize', 'maximize'],
  windows11: ['minimize', 'maximize', 'close'],
  windows10: ['minimize', 'maximize', 'close'],
  windows8: ['minimize', 'maximize', 'close'],
  windows7: ['minimize', 'maximize', 'close'],
  windowsxp: ['minimize', 'maximize', 'close'],
  linux: ['minimize', 'maximize', 'close']
};

export function orderControls(
  os: PlWindowOs,
  controls: readonly PlWindowControl[]
): PlWindowControl[] {
  return controlOrder[os].filter((control) => controls.includes(control));
}

/* ---------------------------------------------------------------------------
 * Colour
 *
 * Everything a window is painted with goes through slots, so the component
 * itself never writes a colour and a caller can reach any of them. They are
 * computed rather than tabled because three of the props they answer to —
 * `accent`, `transparency` and whether the window is in front — are continuous
 * or combinatorial, and `color-mix()` is the only thing that can state "this
 * surface, but 30% of it is whatever is behind the window".
 * ------------------------------------------------------------------------- */

/** Mixes a colour toward nothing. `0` leaves it exactly as it was. */
function veil(color: string, transparency: number): string {
  const keep = Math.round((1 - transparency) * 100);

  return keep >= 100 ? color : `color-mix(in oklab, ${color} ${keep}%, transparent)`;
}

export function windowSlots(options: {
  os: PlWindowOs;
  color: PlassColor;
  accent: boolean;
  transparency: number;
  active: boolean;
  elevation: number;
}): React.CSSProperties {
  const { os, color, accent, transparency, active, elevation } = options;
  const chrome = chromes[os];
  const veiled = Math.min(Math.max(transparency, 0), 1);

  const surface = 'var(--plass-surface)';
  const tint = chrome.tint[active ? 0 : 1];
  const plain =
    tint === 0 ? surface : `color-mix(in oklab, ${surface} ${100 - tint}%, var(--plass-fg))`;

  // A window behind the one in front keeps its shape and loses its emphasis —
  // its colour drains, its shadow drops a step and its title greys. Never
  // `opacity`, which would take the content down with the chrome.
  const dyed = accent && active;
  const paint = chrome.paint;
  // A painted bar that is not in front washes out rather than greys: that is
  // what XP did to Luna blue and what Aqua did to its stripes.
  const painted = paint
    ? active
      ? paint.fill
      : `color-mix(in oklab, ${paint.fill} 45%, #c6c9ce)`
    : null;

  const bar = dyed ? `var(--plass-${color}-solid)` : (painted ?? plain);
  const barFg = dyed
    ? `var(--plass-${color}-on-solid)`
    : paint
      ? active
        ? paint.ink
        : `color-mix(in oklab, ${paint.ink} 60%, transparent)`
      : active
        ? 'var(--plass-fg)'
        : 'var(--plass-muted-fg)';

  const banded = chrome.band.side > 0;
  // The band is the same material as the caption: XP's blue frame is the blue
  // of its title bar, and Aero's is the first of the two layers of glass.
  const band = banded
    ? veil(dyed ? `var(--plass-${color}-solid)` : (painted ?? plain), veiled)
    : 'transparent';
  const line = banded
    ? // A banded window is outlined in a darker cut of its own band rather than
      // in the page's border colour, which would be a grey line drawn around a
      // blue window.
      `color-mix(in oklab, ${dyed ? `var(--plass-${color}-solid)` : (painted ?? 'var(--plass-border)')} 72%, black)`
    : dyed && chrome.accentBorder
      ? `var(--plass-${color}-solid)`
      : active
        ? 'var(--plass-border)'
        : 'color-mix(in oklab, var(--plass-border) 55%, transparent)';

  // Which way a control has to lighten when the pointer arrives is a property
  // of what it is sitting on, not of the page.
  const onDark = dyed || (paint?.dark ?? false);

  return {
    '--p-window-bar': veil(bar, veiled),
    '--p-window-bar-fg': barFg,
    '--p-window-bar-image': chrome.image ?? 'none',
    '--p-window-bar-shadow': chrome.shadow ?? 'none',
    '--p-window-body': veil(surface, veiled),
    '--p-window-line': line,
    '--p-window-band': band,
    // What a control's hover is mixed out of. Fixed rather than derived from
    // `currentColor`: the close button turns its own ink white on hover, and a
    // fill mixed out of that ink would turn white with it — which is a close
    // button that disappears at the moment it is aimed at.
    '--p-window-hover': onDark
      ? 'rgb(255 255 255 / 0.18)'
      : 'color-mix(in oklab, var(--plass-fg) 9%, transparent)',
    '--p-window-press': onDark
      ? 'rgb(255 255 255 / 0.28)'
      : 'color-mix(in oklab, var(--plass-fg) 16%, transparent)',
    // The window in front sits a step further off the page than the ones behind
    // it. This is the whole of what "highlighted" means here — a ring around a
    // window is not something any of these systems draws.
    '--p-window-shadow': `var(--plass-shadow-${active ? elevation : Math.max(elevation - 1, 0)})`,
    '--p-accent': `var(--plass-${color}-accent)`,
    '--p-ring': `var(--plass-${color}-ring)`
  } as React.CSSProperties;
}

/* ---------------------------------------------------------------------------
 * The glyphs
 *
 * Drawn on a 10x10 grid and scaled by the caller, so a Windows minimize and a
 * GNOME one are the same line at two weights rather than two drawings. The
 * weight and the corner are the system's: Windows 11 rounds the maximize box
 * and draws it at a full pixel, Windows 10 leaves it sharp and hairline-thin,
 * XP draws it heavy enough to read white on blue.
 * ------------------------------------------------------------------------- */

function Glyph({
  size,
  stroke,
  round,
  children
}: {
  size: number;
  stroke: number;
  round: boolean;
  children: React.ReactNode;
}) {
  return (
    <svg
      viewBox="0 0 10 10"
      width={size}
      height={size}
      fill="none"
      stroke="currentColor"
      strokeWidth={stroke}
      strokeLinecap={round ? 'round' : 'square'}
      strokeLinejoin={round ? 'round' : 'miter'}
      aria-hidden="true"
    >
      {children}
    </svg>
  );
}

function controlGlyph(
  control: PlWindowControl,
  maximized: boolean,
  chrome: PlWindowChrome,
  size: number
) {
  const stroke = chrome.stroke;
  const round = chrome.boxRadius > 0 || chrome.shape !== 'square';
  const r = chrome.boxRadius;

  if (control === 'minimize') {
    return (
      <Glyph size={size} stroke={stroke} round={round}>
        {/* On the systems whose button is a plate, the minimize mark sits low in
            it rather than through the middle, which is where every one of them
            drew it. */}
        <path d={chrome.shape === 'plate' ? 'M2 7.5h6' : 'M1.5 5h7'} />
      </Glyph>
    );
  }

  if (control === 'close') {
    return (
      <Glyph size={size} stroke={stroke} round={round}>
        <path d="m1.6 1.6 6.8 6.8M8.4 1.6 1.6 8.4" />
      </Glyph>
    );
  }

  // Restore is two boxes, one behind the other — the drawing every system uses
  // to say "this window came from somewhere smaller".
  return maximized ? (
    <Glyph size={size} stroke={stroke} round={round}>
      <rect x="1.4" y="3.4" width="5.2" height="5.2" rx={r} />
      <path d="M3.6 3.4v-2h5v5h-2" />
    </Glyph>
  ) : (
    <Glyph size={size} stroke={stroke} round={round}>
      <rect x="1.5" y="1.5" width="7" height="7" rx={r} />
    </Glyph>
  );
}

/* ---------------------------------------------------------------------------
 * The buttons
 * ------------------------------------------------------------------------- */

/** The traffic lights, which are hardware colours rather than theme tokens: a
 *  red close button is red on a page switched to dark. */
const trafficColors: Record<PlWindowControl, string> = {
  close: '#ff5f57',
  minimize: '#febc2e',
  maximize: '#28c840'
};

/** And XP's plates, which are the same three ideas at a different weight. */
const plateColors: Record<PlWindowControl, string> = {
  close: '#cf4b36',
  minimize: '#4b85d4',
  maximize: '#4b85d4'
};

/** What each system turns the close button when the pointer is on it. */
const closeHover: Record<PlWindowOs, string | null> = {
  macos: null,
  macosx: null,
  windows11: '#c42b1c',
  windows10: '#e81123',
  windows8: '#e81123',
  windows7: '#e04a45',
  windowsxp: null,
  linux: null
};

/** A dot that has gone grey is a window that is not in front. */
const dimLight = 'color-mix(in oklab, var(--plass-fg) 22%, transparent)';

/** What one button is painted with, before the pointer arrives. */
function controlFace(
  chrome: PlWindowChrome,
  control: PlWindowControl,
  active: boolean
): { face?: string; ink?: string; image?: string; plate?: string } {
  switch (chrome.shape) {
    case 'dot':
    case 'gloss-dot':
      return {
        face: active ? trafficColors[control] : dimLight,
        ink: 'rgb(0 0 0 / 0.55)',
        image:
          chrome.shape === 'gloss-dot'
            ? 'radial-gradient(circle at 50% 26%, rgb(255 255 255 / 0.8), rgb(255 255 255 / 0) 62%)'
            : undefined,
        plate:
          chrome.shape === 'gloss-dot'
            ? 'inset 0 0 0 1px rgb(0 0 0 / 0.22), inset 0 -1px 1px rgb(0 0 0 / 0.15)'
            : undefined
      };
    case 'plate':
      return {
        face: active
          ? plateColors[control]
          : `color-mix(in oklab, ${plateColors[control]} 45%, #c6c9ce)`,
        ink: '#ffffff',
        image:
          'linear-gradient(180deg, rgb(255 255 255 / 0.5), rgb(255 255 255 / 0.05) 55%, rgb(0 0 0 / 0.14))',
        plate: 'inset 0 0 0 1px rgb(255 255 255 / 0.4)'
      };
    case 'aero':
      return {
        face: 'rgb(255 255 255 / 0.3)',
        image:
          'linear-gradient(180deg, rgb(255 255 255 / 0.6), rgb(255 255 255 / 0.08) 52%, rgb(255 255 255 / 0.3))',
        plate: 'inset 0 0 0 1px rgb(255 255 255 / 0.55)'
      };
    default:
      return {};
  }
}

export interface PlPlWindowControlsProps {
  os: PlWindowOs;
  metrics: PlWindowMetrics;
  controls: readonly PlWindowControl[];
  maximized: boolean;
  active: boolean;
  /** What each button is called, plus the word the maximize one takes once the
   *  window is maximized. */
  labels: Record<PlWindowControl | 'restore', string>;
  onCommand: (control: PlWindowControl) => void;
}

/**
 * The buttons on a title bar.
 *
 * Real `<button>`s with real names, in every system: the whole point of drawing
 * a window rather than a picture of one is that its controls work, and a
 * `<div>` with a click handler on it is invisible to a keyboard. They also stop
 * the press from reaching the bar underneath, or every close would begin by
 * dragging the window half a pixel.
 *
 * Every fill is written into a slot and every state is a class that reads one,
 * so no two declarations are ever left arguing about which of them paints the
 * button — which is the bug that made a hovered close button vanish.
 */
export function PlWindowControls({
  os,
  metrics,
  controls,
  maximized,
  active,
  labels,
  onCommand
}: PlPlWindowControlsProps) {
  const chrome = chromes[os];
  const ordered = orderControls(os, controls);

  if (ordered.length === 0) {
    return null;
  }

  const dots = chrome.shape === 'dot' || chrome.shape === 'gloss-dot';
  const circles = chrome.shape === 'circle';
  const plates = chrome.shape === 'plate';
  const aero = chrome.shape === 'aero';

  return (
    <div
      // `group/controls` is what lets the traffic lights hold their glyphs back
      // until the pointer is on the set rather than on one of them, which is how
      // the originals behave — the three are one control in three parts.
      className={cx(
        'group/controls flex shrink-0 items-center',
        // Aero's group hangs off the top edge of the window rather than sitting
        // in the middle of the bar. Everything else is centred in it.
        aero ? 'self-start' : 'self-stretch'
      )}
      style={{ gap: metrics.gap }}
      // The bar under it drags the window; the buttons on it do not.
      onPointerDown={(event) => event.stopPropagation()}
      onDoubleClick={(event) => event.stopPropagation()}
    >
      {ordered.map((control) => {
        const name = control === 'maximize' && maximized ? labels.restore : labels[control];
        const danger = control === 'close' ? closeHover[os] : null;
        const { face, ink, image, plate } = controlFace(chrome, control, active);

        return (
          <button
            key={control}
            type="button"
            aria-label={name}
            title={name}
            className={cx(
              'relative flex shrink-0 cursor-pointer items-center justify-center',
              '[transition:background-color_var(--plass-duration)_var(--plass-ease),color_var(--plass-duration)_var(--plass-ease),filter_var(--plass-duration)_var(--plass-ease)]',
              'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:[outline-offset:-2px]',
              dots || circles ? 'rounded-full' : '',
              circles ? 'bg-(--p-window-hover)' : '',
              face ? 'bg-(--p-window-face)' : '',
              // An if/else rather than two hover classes of equal specificity:
              // which of them won would be decided by their order in the
              // generated stylesheet, which is not something a component may
              // depend on.
              danger
                ? 'hover:bg-(--p-window-danger) hover:text-white active:bg-(--p-window-danger)'
                : dots
                  ? ''
                  : plates
                    ? // A plate is already carrying its own colour, so what the
                      // pointer changes is how bright that colour is.
                      'hover:brightness-110 active:brightness-95'
                    : circles
                      ? 'hover:bg-(--p-window-press) active:bg-(--p-window-press)'
                      : aero
                        ? 'hover:brightness-110 active:brightness-95'
                        : 'hover:bg-(--p-window-hover) active:bg-(--p-window-press)'
            )}
            style={
              {
                width: dots
                  ? metrics.control.height
                  : control === 'close'
                    ? metrics.closeWidth
                    : metrics.control.width,
                height: metrics.control.height,
                borderRadius: plates
                  ? chrome.boxRadius + 1
                  : // Aero's group is rounded where it leaves the window and
                    // square where it meets the edge it is hanging from.
                    aero
                    ? '0 0 3px 3px'
                    : undefined,
                backgroundImage: image,
                boxShadow: plate,
                color: ink,
                ...(face ? { '--p-window-face': face } : {}),
                ...(danger ? { '--p-window-danger': danger } : {})
              } as React.CSSProperties
            }
            onClick={() => onCommand(control)}
          >
            {/*
              On macOS the glyph is an affordance rather than a state: it stays
              out of the way of a window that is only being looked at, and comes
              back the moment the pointer is over the set. That is the same
              exception `chipRemoveClasses` makes to the rule against carrying
              state in `opacity` — nothing here is changing what it is.
            */}
            <span
              className={cx(
                'flex items-center justify-center',
                dots
                  ? 'opacity-0 [transition:opacity_var(--plass-duration)_var(--plass-ease)] group-hover/controls:opacity-100'
                  : ''
              )}
            >
              {controlGlyph(control, maximized, chrome, metrics.glyph)}
            </span>
          </button>
        );
      })}
    </div>
  );
}
