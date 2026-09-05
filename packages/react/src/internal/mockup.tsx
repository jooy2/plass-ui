/**
 * The device a `PlMockup` is a picture of: the tables that say how big it is,
 * and the drawings that go on its screen.
 *
 * It lives here for the reason `internal/color.ts` does. Only one component
 * reads it, but what it holds is a body of reference data rather than a piece of
 * that component — five resolutions per device, three shells, six systems' worth
 * of chrome — and a component file with all of that in it would be a table with
 * a `forwardRef` at the bottom.
 *
 * Two conventions run through the whole file:
 *
 * **Every length in here is a device pixel.** The screen is laid out at the
 * resolution it claims to have and the whole frame is scaled once, at the top,
 * so a 54px status bar is 54px on the phone rather than 54px on the page. That
 * is also why the geometry is written as inline styles rather than as utilities:
 * these are numbers off a table, computed per render, and Tailwind only ever
 * sees class names that appear literally in the source. Utilities are still what
 * does the layout — the inline styles are only ever the measurements.
 *
 * **The chrome draws no words except the clock.** A menu bar's titles, a dock's
 * icons and a status bar's carrier are abstract shapes, which is what keeps this
 * an impression of a system rather than a copy of one: nothing to translate,
 * nothing to redraw when a version ships, and no other party's marks in the
 * library. The clock is the exception because a blank rectangle where the time
 * goes reads as a bug, and it is a prop.
 */

import * as React from 'react';
import type { PlassSize } from '../types.js';

/* ---------------------------------------------------------------------------
 * The vocabulary
 *
 * These are Mockup's public types. They are declared here rather than in the
 * component because the drawings below need them, and a component importing its
 * own types back out of `internal/` would be a circle. `Mockup.tsx` re-exports
 * them, so a caller never learns this file exists.
 * ------------------------------------------------------------------------- */

/** Which machine the mockup is a picture of. */
export type PlMockupDevice = 'desktop' | 'tablet' | 'mobile';

/**
 * The system whose chrome is drawn on the screen.
 *
 * One union across all three devices rather than one per device: a caller
 * reading the type should see the whole set, and a device offered an OS that is
 * not its own falls back to its default rather than failing to compile — which
 * is the behaviour a single `Mockup` with a `device` prop has to have anyway.
 */
export type PlMockupOs = 'macos' | 'windows' | 'linux' | 'ios' | 'ipados' | 'android';

/** What the hardware around a desktop screen is. */
export type PlMockupHardware = 'monitor' | 'laptop';

/**
 * The camera cut-out at the top of a screen.
 *
 * Hardware, not chrome — it is drawn whether or not `systemUi` is on, because a
 * phone with the status bar hidden still has a hole in its screen.
 */
export type PlMockupNotch = 'none' | 'notch' | 'dynamic-island' | 'punch-hole';

/**
 * How much hardware there is around the screen.
 *
 * `none` is not a thinner bezel — it is no hardware at all: no frame, no stand,
 * no laptop base, just the screen with its corners cut. It is what a mockup that
 * only wants to say "this is a phone-shaped viewport" asks for.
 *
 * `thick` is an older device rather than a wider version of `standard`: the
 * sides stay narrow and the forehead and chin grow, which is where a bezel
 * actually goes when there is a lot of it.
 */
export type PlMockupBezel = 'none' | 'thin' | 'standard' | 'thick';

/** What the hardware is made of. */
export type PlMockupFinish = 'graphite' | 'silver' | 'white';

/**
 * Which way a handheld is held.
 *
 * `portrait`/`landscape` rather than `PlassOrientation`'s `vertical`/`horizontal`,
 * and this is the one place the library spells the idea twice on purpose. A
 * `PlDivider` running horizontally is not "landscape", and a device held upright is
 * not "vertical" in any vocabulary a designer or a media query uses. CSS itself
 * keeps both pairs for exactly this reason.
 */
export type PlMockupOrientation = 'portrait' | 'landscape';

/** A screen's logical resolution, in CSS pixels. */
export interface PlMockupResolution {
  width: number;
  height: number;
}

/* ---------------------------------------------------------------------------
 * Which systems a device runs
 * ------------------------------------------------------------------------- */

/** The systems each device offers, its default first. */
const systems: Record<PlMockupDevice, readonly PlMockupOs[]> = {
  desktop: ['macos', 'windows', 'linux'],
  tablet: ['ipados', 'android'],
  mobile: ['ios', 'android']
};

/**
 * The system a device will actually draw.
 *
 * An OS the device does not run falls back to its default, with one nicety: a
 * caller who writes `ios` on a tablet or `ipados` on a phone meant the Apple one
 * and gets it, rather than being sent back to the start of the list.
 */
export function resolveOs(device: PlMockupDevice, os?: PlMockupOs): PlMockupOs {
  const allowed = systems[device];

  if (os && allowed.includes(os)) {
    return os;
  }

  if (os === 'ios' && device === 'tablet') {
    return 'ipados';
  }

  if (os === 'ipados' && device === 'mobile') {
    return 'ios';
  }

  return allowed[0];
}

/** What a device puts in its screen when the caller says nothing. */
export function defaultNotch(device: PlMockupDevice, os: PlMockupOs): PlMockupNotch {
  if (device !== 'mobile') {
    return 'none';
  }

  return os === 'android' ? 'punch-hole' : 'dynamic-island';
}

/* ---------------------------------------------------------------------------
 * Resolutions
 *
 * Logical CSS pixels — the width a page inside the screen would report — rather
 * than the panel's physical pixel count, because that is the number the content
 * is laid out against and the only one a caller can do anything with.
 *
 * The ladder is `PlassSize`, and this is the second component after Box where
 * `size` does not mean a control height. On a Box it is the size of the sheet;
 * here it is the size of the *device*, which is the only thing a mockup could
 * sensibly scale. Five steps is one more than most families of hardware come in,
 * so the ends are the extremes rather than exotica.
 * ------------------------------------------------------------------------- */

export const resolutions: Record<PlMockupDevice, Record<PlassSize, PlMockupResolution>> = {
  mobile: {
    xs: { width: 320, height: 568 },
    sm: { width: 360, height: 780 },
    md: { width: 390, height: 844 },
    lg: { width: 414, height: 896 },
    xl: { width: 430, height: 932 }
  },
  tablet: {
    xs: { width: 744, height: 1133 },
    sm: { width: 768, height: 1024 },
    md: { width: 820, height: 1180 },
    lg: { width: 834, height: 1194 },
    xl: { width: 1024, height: 1366 }
  },
  desktop: {
    xs: { width: 1024, height: 640 },
    sm: { width: 1280, height: 800 },
    md: { width: 1440, height: 900 },
    lg: { width: 1680, height: 1050 },
    xl: { width: 1920, height: 1200 }
  }
};

/* ---------------------------------------------------------------------------
 * Shells
 * ------------------------------------------------------------------------- */

/** How much hardware sits on each side of the screen. */
export interface PlMockupInset {
  x: number;
  top: number;
  bottom: number;
}

interface PlMockupShell {
  bezel: PlMockupInset;
  /** The outside of the hardware. */
  frameRadius: number;
  /** The glass inside it. Written out rather than derived from the bezel: on a
   *  thick-bezelled device the screen is square-cornered, which no amount of
   *  subtracting from the frame's radius produces. */
  screenRadius: number;
}

const shells: Record<PlMockupDevice, Record<'thin' | 'standard' | 'thick', PlMockupShell>> = {
  mobile: {
    thin: { bezel: { x: 8, top: 8, bottom: 8 }, frameRadius: 50, screenRadius: 42 },
    standard: { bezel: { x: 13, top: 13, bottom: 13 }, frameRadius: 56, screenRadius: 43 },
    thick: { bezel: { x: 16, top: 62, bottom: 62 }, frameRadius: 40, screenRadius: 4 }
  },
  tablet: {
    thin: { bezel: { x: 12, top: 12, bottom: 12 }, frameRadius: 34, screenRadius: 22 },
    standard: { bezel: { x: 20, top: 20, bottom: 20 }, frameRadius: 42, screenRadius: 22 },
    thick: { bezel: { x: 28, top: 74, bottom: 74 }, frameRadius: 36, screenRadius: 4 }
  },
  desktop: {
    thin: { bezel: { x: 8, top: 8, bottom: 8 }, frameRadius: 12, screenRadius: 4 },
    standard: { bezel: { x: 13, top: 13, bottom: 30 }, frameRadius: 16, screenRadius: 4 },
    thick: { bezel: { x: 22, top: 22, bottom: 62 }, frameRadius: 18, screenRadius: 3 }
  }
};

/** The screen's own radius when there is no hardware to be concentric with. */
const bareRadius: Record<PlMockupDevice, number> = { mobile: 42, tablet: 24, desktop: 8 };

/* ---------------------------------------------------------------------------
 * The whole object
 * ------------------------------------------------------------------------- */

/** Every number the component needs to lay a device out, in device pixels. */
export interface PlMockupMetrics {
  /** The screen, after `orientation` has had its say. */
  screen: PlMockupResolution;
  /** The hardware around it. Zero on all four sides when `bezel` is `none`. */
  bezel: PlMockupInset;
  /** Screen plus bezel: the part you would call the device's face. */
  body: { width: number; height: number };
  /** Face plus whatever holds it up. This is what gets scaled to fit. */
  frame: { width: number; height: number };
  frameRadius: number;
  screenRadius: number;
  /** A monitor's neck and foot, when there is one. */
  stand: { neckWidth: number; neckHeight: number; footWidth: number; footHeight: number } | null;
  /** A laptop's base, when there is one. */
  base: { width: number; height: number; lipWidth: number } | null;
}

export function mockupMetrics(options: {
  device: PlMockupDevice;
  size: PlassSize;
  resolution?: PlMockupResolution;
  orientation: PlMockupOrientation;
  bezel: PlMockupBezel;
  hardware: PlMockupHardware;
}): PlMockupMetrics {
  const { device, size, resolution, orientation, bezel, hardware } = options;

  const native = resolution ?? resolutions[device][size];
  // A desktop has one orientation and it is the one it is drawn in. Rotating a
  // monitor is a thing people do, but a mockup of it is a different picture —
  // the stand does not move — and pretending otherwise would draw a landscape
  // stand under a portrait screen.
  const landscape = device !== 'desktop' && orientation === 'landscape';

  const screen = landscape ? { width: native.height, height: native.width } : native;

  if (bezel === 'none') {
    return {
      screen,
      bezel: { x: 0, top: 0, bottom: 0 },
      body: { ...screen },
      frame: { ...screen },
      frameRadius: bareRadius[device],
      screenRadius: bareRadius[device],
      stand: null,
      base: null
    };
  }

  const shell = shells[device][bezel];
  // Turning the device turns its bezel with it: the forehead and chin of a
  // thick-bezelled phone become its left and right edges.
  const inset = landscape
    ? { x: shell.bezel.top, top: shell.bezel.x, bottom: shell.bezel.x }
    : shell.bezel;
  // A laptop's chin is on its base, not on its lid, so the lid's bezel is even.
  const laptop = device === 'desktop' && hardware === 'laptop';
  const bezelInset = laptop ? { ...inset, bottom: inset.top } : inset;

  const body = {
    width: screen.width + bezelInset.x * 2,
    height: screen.height + bezelInset.top + bezelInset.bottom
  };

  if (device !== 'desktop') {
    return {
      screen,
      bezel: bezelInset,
      body,
      frame: { ...body },
      frameRadius: shell.frameRadius,
      screenRadius: shell.screenRadius,
      stand: null,
      base: null
    };
  }

  if (laptop) {
    // The base is wider than the lid and shallow — the proportion a laptop seen
    // from the front actually has, rather than the wedge it has from the side.
    const base = {
      width: Math.round(body.width * 1.075),
      height: Math.round(body.height * 0.035),
      lipWidth: Math.round(body.width * 0.12)
    };

    return {
      screen,
      bezel: bezelInset,
      body,
      frame: { width: base.width, height: body.height + base.height },
      frameRadius: shell.frameRadius,
      screenRadius: shell.screenRadius,
      stand: null,
      base
    };
  }

  const stand = {
    neckWidth: Math.round(body.width * 0.11),
    neckHeight: Math.round(body.height * 0.09),
    footWidth: Math.round(body.width * 0.28),
    footHeight: Math.round(body.height * 0.018)
  };

  return {
    screen,
    bezel: bezelInset,
    body,
    frame: { width: body.width, height: body.height + stand.neckHeight + stand.footHeight },
    frameRadius: shell.frameRadius,
    screenRadius: shell.screenRadius,
    stand,
    base: null
  };
}

/* ---------------------------------------------------------------------------
 * Finishes
 *
 * Fixed colours rather than theme tokens, because hardware is hardware: a
 * graphite phone is the same graphite on a page that has been switched to dark,
 * and a device that changed colour with the theme would read as a drawing of the
 * theme rather than of a device. They are slots all the same, so a caller who
 * genuinely wants a rose one has somewhere to put it.
 * ------------------------------------------------------------------------- */

export const finishSlots: Record<PlMockupFinish, React.CSSProperties> = {
  graphite: {
    '--p-shell': '#2b2f38',
    '--p-shell-edge': 'rgb(255 255 255 / 0.16)',
    '--p-shell-shade': '#181b22'
  } as React.CSSProperties,
  silver: {
    '--p-shell': '#cfd2d7',
    '--p-shell-edge': 'rgb(255 255 255 / 0.75)',
    '--p-shell-shade': '#9ca1a9'
  } as React.CSSProperties,
  white: {
    '--p-shell': '#f3f4f6',
    '--p-shell-edge': 'rgb(255 255 255 / 0.9)',
    '--p-shell-shade': '#c1c4ca'
  } as React.CSSProperties
};

/**
 * The hardware's surface: the finish, a light top edge and a hairline all the
 * way round, which is the plate the design language puts on everything else. No
 * dark bevel underneath — the shade is a ring, not a shadow.
 */
export const shellClasses =
  'bg-(--p-shell) [box-shadow:inset_0_1px_0_var(--p-shell-edge),inset_0_0_0_1px_var(--p-shell-shade)]';

/** How far off the page the whole device sits, as a silhouette rather than a box.
 *
 *  `drop-shadow` rather than `box-shadow` for one reason: the shadow has to
 *  follow a rounded lid on a narrow neck on a wide foot, and a box-shadow would
 *  draw the rectangle that contains all three. It also sits outside the scale,
 *  so a device shrunk to a third of its size does not get a third of its shadow.
 */
export const elevationFilters = [
  'none',
  'drop-shadow(0 1px 2px var(--plass-shadow-ambient))',
  'drop-shadow(0 2px 4px var(--plass-shadow-ambient)) drop-shadow(0 8px 12px var(--plass-shadow-ambient))',
  'drop-shadow(0 4px 6px var(--plass-shadow-ambient)) drop-shadow(0 18px 28px var(--plass-shadow-ambient))'
] as const;

/* ---------------------------------------------------------------------------
 * The cut-out
 * ------------------------------------------------------------------------- */

/**
 * The camera, drawn on the glass.
 *
 * Portrait puts it against the top edge and landscape against the leading one,
 * which is where it goes on a real device turned the same way — and it is why
 * the island does not collide with the status bar in landscape: it has moved out
 * from under it.
 */
export function PlMockupCutout({
  notch,
  screen,
  landscape
}: {
  notch: PlMockupNotch;
  screen: PlMockupResolution;
  landscape: boolean;
}) {
  if (notch === 'none') {
    return null;
  }

  const along = landscape ? screen.height : screen.width;
  const common: React.CSSProperties = {
    position: 'absolute',
    background: 'oklch(12% 0.006 262)',
    pointerEvents: 'none',
    // Above the status bar, because it is a hole in the glass the status bar is
    // printed on. Left to the source order it would sit under the bar instead,
    // which is a camera behind a pane of frosted plastic.
    zIndex: 20
  };
  // A hook rather than a style, the same way `plass-link` and `plass-portal` are
  // one: it is the only part of the device a caller might want to reach, and
  // reaching it by structure would mean counting the screen's children.
  const hook = 'plass-mockup-cutout';

  if (notch === 'punch-hole') {
    const diameter = Math.max(16, Math.round(along * 0.07));
    const offset = Math.round(diameter * 0.55);

    return (
      <div
        aria-hidden="true"
        className={hook}
        style={{
          ...common,
          width: diameter,
          height: diameter,
          borderRadius: '50%',
          ...(landscape
            ? { left: offset, top: '50%', marginTop: -diameter / 2 }
            : { top: offset, left: '50%', marginLeft: -diameter / 2 })
        }}
      />
    );
  }

  if (notch === 'dynamic-island') {
    const length = Math.max(96, Math.round(along * 0.32));
    const depth = Math.round(length * 0.29);
    const offset = Math.round(depth * 0.32);

    return (
      <div
        aria-hidden="true"
        className={hook}
        style={{
          ...common,
          borderRadius: depth,
          ...(landscape
            ? { left: offset, top: '50%', width: depth, height: length, marginTop: -length / 2 }
            : { top: offset, left: '50%', width: length, height: depth, marginLeft: -length / 2 })
        }}
      />
    );
  }

  // A notch is cut out of the edge rather than floating on the glass, so it is
  // rounded only on the three corners that are not against it.
  const length = Math.max(120, Math.round(along * 0.42));
  const depth = Math.round(length * 0.23);
  const radius = Math.round(depth * 0.6);

  return (
    <div
      aria-hidden="true"
      className={hook}
      style={{
        ...common,
        ...(landscape
          ? {
              left: 0,
              top: '50%',
              width: depth,
              height: length,
              marginTop: -length / 2,
              borderRadius: `0 ${radius}px ${radius}px 0`
            }
          : {
              top: 0,
              left: '50%',
              width: length,
              height: depth,
              marginLeft: -length / 2,
              borderRadius: `0 0 ${radius}px ${radius}px`
            })
      }}
    />
  );
}

/* ---------------------------------------------------------------------------
 * The chrome
 * ------------------------------------------------------------------------- */

/**
 * A bar the system draws, and the space it takes from the content.
 *
 * Two things about the fill, and both are deliberate. It is `--plass-surface`
 * rather than `--plass-panel` because a status bar that inherited the wallpaper
 * would be unreadable the moment somebody passed a dark one, and `--plass-surface`
 * is the token `--plass-fg` is guaranteed to contrast with in either theme. It is
 * an impression of a status bar, and legible is part of the impression.
 *
 * And it is a flat translucency rather than the house `backdrop-filter`, which
 * is the one place the acrylic is given up. A backdrop filter inside a scaled
 * subtree samples the wrong region in Chromium — the blur lands beside the bar
 * rather than under it, and a status bar comes out with a smear across it. The
 * whole device is inside a `transform`, so there is nowhere to put the blur
 * where that is not true.
 */
const barClasses =
  'relative z-10 flex shrink-0 items-center [background:color-mix(in_oklab,var(--plass-surface)_88%,transparent)]';

const barTextClasses = 'font-medium text-(--plass-fg) tabular-nums';

/** An app icon, a menu title, a tray glyph — anything the chrome does not name. */
function Tile({
  width,
  height,
  radius,
  tone = 'muted'
}: {
  width: number;
  height?: number;
  radius: number;
  tone?: 'muted' | 'faint' | 'accent';
}) {
  const background =
    tone === 'accent'
      ? 'var(--p-accent)'
      : tone === 'faint'
        ? 'color-mix(in oklab, var(--plass-fg) 12%, transparent)'
        : 'color-mix(in oklab, var(--plass-fg) 26%, transparent)';

  return <div style={{ width, height: height ?? width, borderRadius: radius, background }} />;
}

/** A row of them, with the first one carrying the colour family. */
function Tiles({
  count,
  size,
  radius,
  gap,
  accent = false
}: {
  count: number;
  size: number;
  radius: number;
  gap: number;
  accent?: boolean;
}) {
  return (
    <div className="flex items-center" style={{ gap }}>
      {Array.from({ length: count }, (_, index) => (
        <Tile
          key={index}
          width={size}
          radius={radius}
          tone={accent && index === 0 ? 'accent' : 'muted'}
        />
      ))}
    </div>
  );
}

function SignalGlyph({ height }: { height: number }) {
  return (
    <svg
      viewBox="0 0 17 11"
      height={height}
      width={(height * 17) / 11}
      fill="currentColor"
      aria-hidden="true"
    >
      <rect y="7.5" width="3" height="3.5" rx="1" />
      <rect x="4.7" y="5" width="3" height="6" rx="1" />
      <rect x="9.4" y="2.5" width="3" height="8.5" rx="1" />
      <rect x="14" width="3" height="11" rx="1" opacity="0.35" />
    </svg>
  );
}

function WifiGlyph({ height }: { height: number }) {
  return (
    <svg
      viewBox="0 0 16 12"
      height={height}
      width={(height * 16) / 12}
      fill="none"
      aria-hidden="true"
    >
      <path
        d="M1 4.2a10.5 10.5 0 0 1 14 0"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <path
        d="M3.6 7a6.8 6.8 0 0 1 8.8 0"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <circle cx="8" cy="10.2" r="1.6" fill="currentColor" />
    </svg>
  );
}

function BatteryGlyph({ height }: { height: number }) {
  return (
    <svg
      viewBox="0 0 25 12"
      height={height}
      width={(height * 25) / 12}
      fill="none"
      aria-hidden="true"
    >
      <rect
        x="0.7"
        y="0.7"
        width="20.6"
        height="10.6"
        rx="3.2"
        stroke="currentColor"
        strokeWidth="1.3"
        opacity="0.45"
      />
      <rect x="2.6" y="2.6" width="12.8" height="6.8" rx="1.8" fill="currentColor" />
      <rect x="22.8" y="4" width="1.8" height="4" rx="0.9" fill="currentColor" opacity="0.45" />
    </svg>
  );
}

/** The trio on the trailing end of a status bar. */
function StatusGlyphs({ height, gap }: { height: number; gap: number }) {
  return (
    <div className="flex items-center text-(--plass-fg)" style={{ gap }}>
      <SignalGlyph height={height} />
      <WifiGlyph height={height} />
      <BatteryGlyph height={height} />
    </div>
  );
}

function NavGlyphs({ size, gap }: { size: number; gap: number }) {
  return (
    <div
      className="flex items-center justify-center text-(--plass-fg)"
      style={{ gap, opacity: 0.72 }}
    >
      <svg viewBox="0 0 16 16" width={size} height={size} fill="none" aria-hidden="true">
        <path
          d="M10 3 5 8l5 5"
          stroke="currentColor"
          strokeWidth="1.6"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
      <svg viewBox="0 0 16 16" width={size} height={size} fill="none" aria-hidden="true">
        <circle cx="8" cy="8" r="5" stroke="currentColor" strokeWidth="1.6" />
      </svg>
      <svg viewBox="0 0 16 16" width={size} height={size} fill="none" aria-hidden="true">
        <rect
          x="3.5"
          y="3.5"
          width="9"
          height="9"
          rx="1.6"
          stroke="currentColor"
          strokeWidth="1.6"
        />
      </svg>
    </div>
  );
}

function StartGlyph({ size }: { size: number }) {
  return (
    <svg viewBox="0 0 16 16" width={size} height={size} fill="currentColor" aria-hidden="true">
      <rect x="1" y="1" width="6" height="6" rx="1.4" />
      <rect x="9" y="1" width="6" height="6" rx="1.4" />
      <rect x="1" y="9" width="6" height="6" rx="1.4" />
      <rect x="9" y="9" width="6" height="6" rx="1.4" />
    </svg>
  );
}

/** What a system puts on the screen, and how much room it takes. */
export interface PlMockupChrome {
  top?: { size: number; node: React.ReactNode };
  bottom?: { size: number; node: React.ReactNode };
  /** A dock down the leading edge. Only Linux has one. */
  start?: { size: number; node: React.ReactNode };
}

/**
 * The bars, per system.
 *
 * Each one takes its own space rather than floating over the content: a caller
 * putting a screenshot in a mockup wants all of the screenshot, and a status bar
 * that covered the top of it would be a crop nobody asked for. The cut-out is
 * the exception, because that one really is a hole in the glass.
 */
export function mockupChrome(options: {
  os: PlMockupOs;
  notch: PlMockupNotch;
  landscape: boolean;
  time: string;
}): PlMockupChrome {
  const { os, notch, landscape, time } = options;

  if (os === 'ios' || os === 'ipados') {
    const tablet = os === 'ipados';
    // The island and the notch both stand in the middle of the status bar, so
    // the bar has to be tall enough to have a middle. In landscape they have
    // moved to the edge and it does not.
    const raised = !tablet && !landscape && notch !== 'none' && notch !== 'punch-hole';
    const height = tablet ? 30 : raised ? 54 : 44;
    const padding = tablet ? 22 : 26;

    return {
      top: {
        size: height,
        node: (
          <div
            aria-hidden="true"
            className={`${barClasses} justify-between`}
            style={{ height, paddingInline: padding }}
          >
            <span className={`${barTextClasses} text-[15px]`}>{time}</span>
            <StatusGlyphs height={tablet ? 11 : 12} gap={6} />
          </div>
        )
      },
      bottom: {
        size: tablet ? 22 : 34,
        node: (
          <div
            aria-hidden="true"
            className={`${barClasses} justify-center`}
            style={{ height: tablet ? 22 : 34, background: 'transparent' }}
          >
            <div
              style={{
                width: tablet ? 220 : 140,
                height: 5,
                borderRadius: 3,
                background: 'color-mix(in oklab, var(--plass-fg) 55%, transparent)'
              }}
            />
          </div>
        )
      }
    };
  }

  if (os === 'android') {
    return {
      top: {
        size: 34,
        node: (
          <div
            aria-hidden="true"
            className={`${barClasses} justify-between`}
            style={{ height: 34, paddingInline: 18 }}
          >
            <span className={`${barTextClasses} text-[13px]`}>{time}</span>
            <StatusGlyphs height={11} gap={5} />
          </div>
        )
      },
      bottom: {
        size: 48,
        node: (
          <div aria-hidden="true" className={`${barClasses} justify-center`} style={{ height: 48 }}>
            <NavGlyphs size={20} gap={72} />
          </div>
        )
      }
    };
  }

  if (os === 'macos') {
    return {
      top: {
        size: 28,
        node: (
          <div
            aria-hidden="true"
            className={`${barClasses} justify-between`}
            style={{ height: 28, paddingInline: 16 }}
          >
            <div className="flex items-center" style={{ gap: 16 }}>
              <Tile width={13} radius={4} />
              <Tile width={34} height={7} radius={4} />
              <Tile width={26} height={7} radius={4} tone="faint" />
              <Tile width={30} height={7} radius={4} tone="faint" />
              <Tile width={22} height={7} radius={4} tone="faint" />
            </div>
            <div className="flex items-center" style={{ gap: 14 }}>
              <Tile width={11} radius={3} tone="faint" />
              <Tile width={11} radius={3} tone="faint" />
              <span className={`${barTextClasses} text-[13px]`}>{time}</span>
            </div>
          </div>
        )
      },
      bottom: {
        size: 78,
        node: (
          // The dock is a sheet of its own floating clear of the edge, which is
          // the one thing about it that is unmistakable at any size.
          <div
            aria-hidden="true"
            className="flex shrink-0 items-end justify-center"
            style={{ height: 78 }}
          >
            <div
              className={`${barClasses} [box-shadow:var(--plass-shadow-2),var(--plass-gloss-glass)]`}
              style={{ gap: 10, padding: 8, marginBottom: 10, borderRadius: 22 }}
            >
              <Tiles count={5} size={52} radius={14} gap={10} accent />
              <div
                style={{
                  width: 1,
                  height: 44,
                  background: 'color-mix(in oklab, var(--plass-fg) 16%, transparent)'
                }}
              />
              <Tiles count={2} size={52} radius={14} gap={10} />
            </div>
          </div>
        )
      }
    };
  }

  if (os === 'windows') {
    return {
      bottom: {
        size: 52,
        node: (
          <div
            aria-hidden="true"
            className={`${barClasses} justify-center [border-block-start:1px_solid_var(--plass-border)]`}
            style={{ height: 52, paddingInline: 16 }}
          >
            <div className="flex items-center" style={{ gap: 10 }}>
              <div className="text-(--plass-fg)" style={{ opacity: 0.7 }}>
                <StartGlyph size={22} />
              </div>
              <Tiles count={6} size={30} radius={8} gap={10} accent />
            </div>
            <div className="absolute flex items-center" style={{ insetInlineEnd: 16, gap: 12 }}>
              <Tile width={11} radius={3} tone="faint" />
              <Tile width={11} radius={3} tone="faint" />
              <span className={`${barTextClasses} text-[12px]`}>{time}</span>
            </div>
          </div>
        )
      }
    };
  }

  return {
    top: {
      size: 34,
      node: (
        <div
          aria-hidden="true"
          className={`${barClasses} justify-center`}
          style={{ height: 34, paddingInline: 14 }}
        >
          <div className="absolute" style={{ insetInlineStart: 14 }}>
            <Tile width={52} height={9} radius={5} />
          </div>
          <span className={`${barTextClasses} text-[13px]`}>{time}</span>
          <div className="absolute flex items-center" style={{ insetInlineEnd: 14, gap: 10 }}>
            <Tile width={10} radius={3} tone="faint" />
            <Tile width={10} radius={3} tone="faint" />
            <Tile width={10} radius={3} tone="faint" />
          </div>
        </div>
      )
    },
    // The one dock that runs down an edge rather than along one, which is what
    // makes a Linux desktop recognisable from across a room.
    start: {
      size: 66,
      node: (
        <div
          aria-hidden="true"
          className={`${barClasses} flex-col justify-start [border-inline-end:1px_solid_var(--plass-border)]`}
          style={{ width: 66, height: '100%', gap: 10, paddingBlock: 12 }}
        >
          <Tile width={44} radius={12} tone="accent" />
          <Tile width={44} radius={12} />
          <Tile width={44} radius={12} />
          <Tile width={44} radius={12} />
        </div>
      )
    }
  };
}
