'use client';

import * as React from 'react';
import { canonicalKey, detectOS } from '../../internal/keys.js';
import {
  controlHeightClasses,
  controlSlots,
  controlTextClasses,
  glassClasses,
  paddingXClasses,
  radiusClasses,
  srOnlyClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassElevation, PlassSize, PlassStyleProps, PlassVariant } from '../../types.js';

/**
 * Which keyboard the shortcut is being read on.
 *
 * `auto` asks the browser, which is right for a shortcut a reader is about to
 * press. The three explicit values are for documentation that has to name a
 * platform rather than the reader's own — a support page describing the Windows
 * build, a table comparing the two.
 */
export type PlHotKeysOS = 'auto' | 'mac' | 'windows' | 'linux';

/** The three real platforms, once `auto` has been resolved. */
type ResolvedOS = Exclude<PlHotKeysOS, 'auto'>;

/** Four keys laid out as an inverted T: one on top, three beneath. */
export interface PlHotKeysCluster {
  up: string;
  left: string;
  down: string;
  right: string;
}

export interface PlHotKeysProps
  extends PlassStyleProps, Omit<React.ComponentPropsWithoutRef<'span'>, 'color' | 'children'> {
  /**
   * The keys, innermost punctuation and all.
   *
   * A string is split on `+` — `'Mod+Shift+P'` — which covers everything except
   * a shortcut whose key *is* a plus. For that one, pass the array form:
   * `keys={['Ctrl', '+']}`.
   */
  keys?: string | string[];
  /**
   * Draws the four movement keys as an inverted T instead of an inline combo —
   * `WASD`, or the arrow cluster. Takes precedence over `keys`.
   *
   * It is its own prop rather than a `layout` on `keys`, because the two are
   * different objects: a combo is keys pressed *together*, and a cluster is four
   * keys pressed one at a time whose arrangement on the keyboard is the point.
   */
  cluster?: PlHotKeysCluster;
  /**
   * Which keyboard to name the modifiers for.
   * @default 'auto'
   */
  os?: PlHotKeysOS;
  /**
   * What goes between two keys. Omit it for the platform's own convention: a `+`
   * on Windows and Linux, and nothing at all on macOS, where a shortcut is
   * written as a run of symbols — `⇧⌘P`, never `⇧+⌘+P`.
   */
  separator?: React.ReactNode;
  /**
   * Drop shadow depth. `0` is the default. A key cap already has a lip under it
   * — this is a picture of a key, not a key, and raising it off the page as well
   * is one depth cue too many.
   * @default 0
   */
  elevation?: PlassElevation;
}

export interface PlKbdProps
  extends
    Pick<PlassStyleProps, 'variant' | 'size' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'kbd'>, 'color'> {
  children?: React.ReactNode;
}

/**
 * What a key is called, and what it is drawn as.
 *
 * `symbol` is what a sighted reader sees and `name` is what a screen reader
 * says. They differ on exactly the keys macOS draws as glyphs — `⌘` announced by
 * its Unicode name is "place of interest sign", which is not a key anybody has
 * on their keyboard.
 */
interface KeyLabel {
  symbol: string;
  name: string;
}

const word = (text: string): KeyLabel => ({ symbol: text, name: text });

/**
 * One entry per key that is spelled differently somewhere, keyed by the token
 * with its case and spaces taken off.
 *
 * The aliases are deliberate and not generosity: `Cmd`, `Command` and `Meta` are
 * three names one key already has, and a component that accepted only one of
 * them would be a component every caller has to look up.
 *
 * `Mod` is the entry the rest exist for. It is the only token whose *meaning*
 * changes with the platform rather than just its spelling — the modifier a
 * shortcut is actually built on, which is Command on a Mac and Control
 * everywhere else. Writing `Ctrl` and hoping is what makes a documentation page
 * wrong for half its readers.
 */
const keyLabels: Record<string, Record<ResolvedOS, KeyLabel>> = {
  mod: {
    mac: { symbol: '⌘', name: 'Command' },
    windows: word('Ctrl'),
    linux: word('Ctrl')
  },
  meta: {
    mac: { symbol: '⌘', name: 'Command' },
    windows: word('Win'),
    linux: word('Super')
  },
  ctrl: {
    mac: { symbol: '⌃', name: 'Control' },
    windows: word('Ctrl'),
    linux: word('Ctrl')
  },
  alt: {
    mac: { symbol: '⌥', name: 'Option' },
    windows: word('Alt'),
    linux: word('Alt')
  },
  shift: {
    mac: { symbol: '⇧', name: 'Shift' },
    windows: word('Shift'),
    linux: word('Shift')
  },
  enter: {
    mac: { symbol: '↩', name: 'Enter' },
    windows: word('Enter'),
    linux: word('Enter')
  },
  tab: {
    mac: { symbol: '⇥', name: 'Tab' },
    windows: word('Tab'),
    linux: word('Tab')
  },
  escape: {
    mac: { symbol: '⎋', name: 'Escape' },
    windows: word('Esc'),
    linux: word('Esc')
  },
  backspace: {
    mac: { symbol: '⌫', name: 'Backspace' },
    windows: word('Backspace'),
    linux: word('Backspace')
  },
  delete: {
    mac: { symbol: '⌦', name: 'Delete' },
    windows: word('Del'),
    linux: word('Del')
  },
  capslock: {
    mac: { symbol: '⇪', name: 'Caps Lock' },
    windows: word('Caps Lock'),
    linux: word('Caps Lock')
  }
};

/**
 * The keys drawn as arrows on every platform, not just on a Mac. An arrow is not
 * a Mac convention — it is what is printed on the key.
 */
const arrowLabels: Record<string, KeyLabel> = {
  up: { symbol: '↑', name: 'Arrow up' },
  down: { symbol: '↓', name: 'Arrow down' },
  left: { symbol: '←', name: 'Arrow left' },
  right: { symbol: '→', name: 'Arrow right' },
  arrowup: { symbol: '↑', name: 'Arrow up' },
  arrowdown: { symbol: '↓', name: 'Arrow down' },
  arrowleft: { symbol: '←', name: 'Arrow left' },
  arrowright: { symbol: '→', name: 'Arrow right' }
};

/** Resolves one token into what to draw and what to announce. */
function labelFor(token: string, os: ResolvedOS): KeyLabel {
  // The same fold the binder applies, out of `internal/keys` — a cap and a
  // chord that disagreed about what `Esc` means would be two vocabularies.
  const canonical = canonicalKey(token);

  const arrow = arrowLabels[canonical];

  if (arrow) {
    return arrow;
  }

  const known = keyLabels[canonical];

  if (known) {
    return known[os];
  }

  // Everything else is printed as it was written, with the one courtesy that a
  // single letter is capitalised: `keys="mod+k"` should draw a K, because that
  // is what is on the key.
  return word(token.length === 1 ? token.toUpperCase() : token);
}

/**
 * Splits the string form. Empty segments are what `'Ctrl++'` leaves behind, and
 * dropping them is why the array form exists for that case.
 */
function tokenize(keys: string | string[]): string[] {
  if (Array.isArray(keys)) {
    return keys.map((key) => key.trim()).filter(Boolean);
  }

  return keys
    .split('+')
    .map((key) => key.trim())
    .filter(Boolean);
}

/** The platform never changes under a running page, so there is nothing to subscribe to. */
function subscribe() {
  return () => {};
}

function serverOS(): ResolvedOS {
  return 'windows';
}

/**
 * `useSyncExternalStore` rather than `useEffect` plus state, and rather than
 * reading `navigator` during render.
 *
 * Reading it during render is a hydration mismatch waiting to happen: the server
 * has no `navigator`, so it would render `Ctrl` and the client would render `⌘`
 * into the same markup. This hook is the one API that tells React the two are
 * *meant* to differ — it hydrates with the server's answer and re-renders with
 * the browser's, which is exactly the sequence a Mac reader sees.
 */
function useDetectedOS(): ResolvedOS {
  return React.useSyncExternalStore(subscribe, detectOS, serverOS);
}

/**
 * A key cap sits one step down the control ladder: it is a token inside a line
 * of text, not a control the line lines up against.
 */
const keyScale: Record<PlassSize, PlassSize> = {
  xs: 'xs',
  sm: 'xs',
  md: 'sm',
  lg: 'md',
  xl: 'lg'
};

/**
 * The three materials, and the one place in the library where a filled surface
 * gets a hard-edged shadow directly under it.
 *
 * That lip is not the gloss line the design language rules out — a gloss line is
 * a highlight *on* the surface, claiming a lamp. This is a two-pixel offset
 * shadow *under* it, which is the one thing every printed manual has used to
 * mean "this is a key you press". A picture of a key is allowed to look like a
 * key; a control is not allowed to look like a picture of one.
 *
 * `glass` is the default, because a hairline box is what a key cap has looked
 * like in every manual ever printed. Its edge is `--plass-border` rather than
 * the sheet's white hairline, or a cap set on a light card would have no edge.
 */
const variantClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'text-(--p-on-solid) [background-image:var(--p-fill)]',
    '[box-shadow:var(--p-elev),0_2px_0_0_var(--p-tint)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'border text-(--p-accent) bg-(--plass-glass)',
    '[border-color:var(--plass-border)]',
    '[box-shadow:var(--p-elev),0_2px_0_0_var(--plass-shadow-ambient)]'
  ].join(' '),
  ghost: 'text-(--p-accent) bg-(--p-soft)'
};

/** The width a single-letter cap is held to, so `⌘` and `K` are the same square. */
const keyMinWidthClasses: Record<PlassSize, string> = {
  xs: 'min-w-6',
  sm: 'min-w-8',
  md: 'min-w-10',
  lg: 'min-w-12',
  xl: 'min-w-14'
};

/**
 * One key cap.
 *
 * Exported so a caller can compose a layout this component does not draw — a
 * numeric keypad, a row of function keys — out of the same object the shortcut
 * strip is made of.
 *
 * It reads its colour slots from whatever set them, which is the `PlHotKeys`
 * around it in the common case. On its own it falls back to the page's own ink,
 * so a bare `<PlKbd>` still draws.
 */
export const PlKbd = /* @__PURE__ */ React.forwardRef<HTMLElement, PlKbdProps>(function PlKbd(
  { variant = 'glass', size = 'md', density = 'compact', className, children, ...props },
  ref
) {
  const step = keyScale[size];

  return (
    <kbd
      ref={ref}
      className={[
        'inline-flex shrink-0 items-center justify-center',
        'font-mono leading-none font-medium tabular-nums whitespace-nowrap',
        controlHeightClasses[step],
        controlTextClasses[step],
        keyMinWidthClasses[step],
        paddingXClasses[density][step],
        radiusClasses[step],
        variantClasses[variant],
        transitionClasses,
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      {...props}
    >
      {children}
    </kbd>
  );
});

/**
 * A keyboard key, a combination of them, or the four movement keys as they sit
 * on the keyboard.
 *
 * Two things make this more than a styled `<kbd>`, and both are about the label
 * rather than the box around it.
 *
 * The first is `Mod`. A shortcut written as `Ctrl+K` is wrong for every Mac
 * reader and one written as `⌘K` is wrong for everybody else, so the token that
 * means "the modifier shortcuts are built on" resolves per platform — and `os`
 * is there for the pages that have to name a platform rather than the reader's.
 *
 * The second is that `⌘` is not a word. A screen reader reads it as "place of
 * interest sign", so every key drawn as a glyph carries its name beside it, in
 * the clipped box `srOnlyClasses` describes. What is announced is "Command K",
 * which is what the shortcut is called.
 *
 * The keys are real `<kbd>` elements; the wrapper around them is a `<span>`.
 * Nesting `<kbd>` inside `<kbd>` is allowed and would also be defensible, but a
 * `kbd` wrapper is a second box for a host stylesheet to reach into for no gain
 * — the semantics are carried by the keys themselves either way.
 */
export const PlHotKeys = /* @__PURE__ */ React.forwardRef<HTMLSpanElement, PlHotKeysProps>(
  function PlHotKeys(
    {
      variant = 'glass',
      size = 'md',
      color = 'secondary',
      density = 'compact',
      elevation = 0,
      keys,
      cluster,
      os = 'auto',
      separator,
      className,
      style,
      ...props
    },
    ref
  ) {
    const detected = useDetectedOS();
    const resolved: ResolvedOS = os === 'auto' ? detected : os;

    const slots = { ...controlSlots(color, elevation, variant), ...style };
    const capProps = { variant, size, density } as const;
    const gap = size === 'xs' || size === 'sm' ? 'gap-1' : 'gap-1.5';

    if (cluster) {
      return (
        <span
          ref={ref}
          className={['inline-flex flex-col items-center align-middle', gap, className ?? '']
            .filter(Boolean)
            .join(' ')}
          style={slots}
          {...props}
        >
          <PlKbd {...capProps}>{cluster.up}</PlKbd>
          <span className={`inline-flex ${gap}`}>
            <PlKbd {...capProps}>{cluster.left}</PlKbd>
            <PlKbd {...capProps}>{cluster.down}</PlKbd>
            <PlKbd {...capProps}>{cluster.right}</PlKbd>
          </span>
        </span>
      );
    }

    const labels = tokenize(keys ?? []).map((token) => labelFor(token, resolved));

    // macOS writes a shortcut as a run of symbols with nothing between them; the
    // other two join theirs with a `+`. A caller who passes one gets theirs.
    const joiner = separator === undefined ? (resolved === 'mac' ? null : '+') : separator;

    return (
      <span
        ref={ref}
        className={['inline-flex max-w-full items-center gap-1 align-middle', className ?? '']
          .filter(Boolean)
          .join(' ')}
        style={slots}
        {...props}
      >
        {labels.map((label, index) => (
          // The index is a legitimate key here: the list is the `keys` prop, in
          // order, and two identical keys in one shortcut are the same key.
          <React.Fragment key={index}>
            {index > 0 && joiner !== null ? (
              <span aria-hidden="true" className="text-(--plass-muted-fg)">
                {joiner}
              </span>
            ) : null}

            <PlKbd {...capProps}>
              {label.symbol === label.name ? (
                label.symbol
              ) : (
                <>
                  <span aria-hidden="true">{label.symbol}</span>
                  <span className={srOnlyClasses}>{label.name}</span>
                </>
              )}
            </PlKbd>
          </React.Fragment>
        ))}
      </span>
    );
  }
);
