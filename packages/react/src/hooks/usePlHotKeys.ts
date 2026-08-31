'use client';

import * as React from 'react';
import { editsText, hasHardModifier, isTypingTarget, matchesHotKey } from '../internal/keys.js';
import type { PlassHotKeys } from '../types.js';

/** Anything a listener can be attached to, plus the ref a React caller holds. */
export type PlHotKeysTarget =
  Window | Document | HTMLElement | React.RefObject<HTMLElement | null> | null;

export interface PlHotKeysOptions {
  /**
   * Whether the chords are bound at all. `false` removes the listener rather
   * than making the handlers no-ops, so a shortcut that is off does not consume
   * the key from whatever else wanted it.
   * @default true
   */
  enabled?: boolean;
  /**
   * What the listener is attached to.
   *
   * `window` is the default and is what a global shortcut means. A ref, an
   * element or `document` scopes the binding to a region — but note that a
   * `keydown` only reaches an element that contains the focus, so scoping to a
   * panel nobody has tabbed into binds nothing.
   * @default window
   */
  target?: PlHotKeysTarget;
  /**
   * Whether a chord is answered while the focus is in a text field.
   *
   * Off by default, and this is the decision the hook exists to get right: a
   * global `/` that jumps to search must not eat the slash out of a URL
   * somebody is typing into a form.
   *
   * It is narrower than it sounds, and only two kinds of chord are ever held
   * back. A chord carrying **`Mod`, `Ctrl`, `Meta` or `Alt` is answered either
   * way**, because none of those can appear in a field's value — so the
   * ordinary `Mod+K` needs nothing set here. Shift does not count as one:
   * `Shift+A` is how a capital A is typed. And a key that **does nothing in a
   * field** is answered either way too: `Escape` is the one that matters, since
   * a panel that closes on Escape has to close from inside its own form.
   *
   * What is left is exactly the case this is for: a printable character, or one
   * of the keys that edits or moves through text, pressed while the focus is in
   * a field. Turn it on for a chord that belongs to the field the reader is in.
   * @default false
   */
  whileTyping?: boolean;
}

function resolve(target: PlHotKeysTarget | undefined): EventTarget | null {
  if (target === undefined) {
    return typeof window === 'undefined' ? null : window;
  }

  if (target === null) {
    return null;
  }

  if ('current' in target) {
    return target.current;
  }

  return target;
}

/**
 * Binds keyboard chords outside any one control.
 *
 * The map is the same `PlassHotKeys` a field's `hotKeys` prop takes and the
 * chords are spelled the way `PlHotKeys` draws them, which is the whole point:
 * a shortcut that is **displayed** on a key cap and a shortcut that is **bound**
 * are one string rather than two that drift. `Mod` is Command on a Mac and
 * Control everywhere else.
 *
 * `PlCommandPalette` is the hook's first caller — it has bound its own opener
 * this way since it existed, with a private copy of the matcher — and an
 * application's own shortcuts are the reason it is public.
 *
 * Three rules it shares with the `hotKeys` prop:
 *
 * - **A modifier is checked in both directions.** `Enter` does not fire on
 *   `Shift+Enter`, and `Mod+K` does not fire on `Mod+Shift+K`.
 * - **A chord that matches is consumed** — `preventDefault()`, so the browser's
 *   own `Mod+K` search bar does not also open. Read from the other end, an
 *   event that is **already** consumed is left alone: a field's own `hotKeys`
 *   map wins over a page's.
 * - **These are chords rather than letters.** A single unmodified key is
 *   allowed and is sometimes right (`?` for help), but it is the case
 *   `whileTyping` is about.
 *
 * The handlers are read fresh on every keystroke, so an inline object literal
 * costs nothing and a handler closing over current state is never stale. What
 * rebinds the listener is the **set of chords** changing, not the map's
 * identity.
 *
 * @example
 * usePlHotKeys({
 *   'Mod+K': () => setPaletteOpen(true),
 *   'Mod+S': save
 * });
 */
export function usePlHotKeys(
  hotKeys: PlassHotKeys | undefined,
  options: PlHotKeysOptions = {}
): void {
  const { enabled = true, target, whileTyping = false } = options;

  const latest = React.useRef(hotKeys);

  React.useEffect(() => {
    latest.current = hotKeys;
  });

  // The chords rather than the map: a caller writing the object inline hands us
  // a new one every render, and re-attaching a listener on every render of a
  // page-level component is the cost this hook is meant to remove.
  const chords = Object.keys(hotKeys ?? {}).join('\n');

  React.useEffect(() => {
    // Resolved **inside** the effect, which is the only place a ref can be
    // read: React sets refs during the commit and runs this after it, so a
    // `target` resolved during render would still be `null` here and would
    // never bind at all.
    const element = resolve(target);

    if (!enabled || !element || chords === '') {
      return undefined;
    }

    const list = chords.split('\n');

    const onKeyDown = (event: Event) => {
      const key = event as KeyboardEvent;

      // Something closer to the reader has already answered this key. The same
      // rule the `hotKeys` prop follows, read from the other end: a field's own
      // binding wins over a page's.
      if (key.defaultPrevented) {
        return;
      }

      for (const chord of list) {
        if (!matchesHotKey(key, chord)) {
          continue;
        }

        if (
          !whileTyping &&
          !hasHardModifier(chord) &&
          editsText(key.key) &&
          isTypingTarget(key.target)
        ) {
          return;
        }

        // The page asked for this key, so the browser does not also get it.
        key.preventDefault();
        latest.current?.[chord]?.();

        return;
      }
    };

    element.addEventListener('keydown', onKeyDown);

    return () => element.removeEventListener('keydown', onKeyDown);
  }, [chords, target, enabled, whileTyping]);
}
