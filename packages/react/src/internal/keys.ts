/**
 * The shortcut vocabulary, read rather than written.
 *
 * `PlHotKeys` turns `Mod+Enter` into a pair of key caps; this turns the same
 * string into a predicate over a real keyboard event. They are one file because
 * a shortcut a component **displays** and a shortcut it **binds** have to be
 * spelled the same way — otherwise the cap on the screen is a claim nobody
 * checked. `PlCommandPalette` made that argument first and carried a private
 * copy of the matcher to make it; the fields that take a `hotKeys` map are the
 * reason it lives here instead, and `PlHotKeys` now reads the alias table and
 * the platform out of this file rather than owning them.
 *
 * Nothing here is exported from `src/index.ts`. The one public name is
 * `PlassHotKeys` in `src/types.ts`, which is the map a caller writes.
 */

import type * as React from 'react';
import type { PlassHotKeys } from '../types.js';

/** The three real platforms, once `auto` has been resolved. */
export type PlassOS = 'mac' | 'windows' | 'linux';

/**
 * What the browser says it is running on.
 *
 * `userAgentData.platform` is the modern spelling and `navigator.platform` the
 * deprecated one that every browser still answers; the user agent string is the
 * last resort. All three are matched at once because the question here is coarse
 * — which of three key caps to print, and which modifier `Mod` stands for — and
 * getting it slightly wrong is a label, not a bug.
 */
export function detectOS(): PlassOS {
  if (typeof navigator === 'undefined') {
    return 'windows';
  }

  const data = (navigator as Navigator & { userAgentData?: { platform?: string } }).userAgentData;
  const haystack = `${data?.platform ?? ''} ${navigator.platform ?? ''} ${navigator.userAgent ?? ''}`;

  if (/mac|iphone|ipad|ipod/i.test(haystack)) {
    return 'mac';
  }

  if (/win/i.test(haystack)) {
    return 'windows';
  }

  return 'linux';
}

/**
 * The spellings that mean the same key, folded onto one name.
 *
 * A caller writes what is printed on their own keyboard — `Cmd`, `Option`,
 * `Return`, `Esc` — and every one of those has to reach the same cap and the
 * same binding.
 */
export const keyAliases: Record<string, string> = {
  cmdorctrl: 'mod',
  commandorcontrol: 'mod',
  cmd: 'meta',
  command: 'meta',
  super: 'meta',
  win: 'meta',
  windows: 'meta',
  control: 'ctrl',
  option: 'alt',
  opt: 'alt',
  return: 'enter',
  esc: 'escape',
  del: 'delete',
  caps: 'capslock'
};

/** One token of a chord, folded: case, spacing and the aliases above. */
export function canonicalKey(token: string): string {
  const normalized = token.toLowerCase().replace(/[\s_-]/g, '');

  return keyAliases[normalized] ?? normalized;
}

/**
 * The handful of keys whose DOM `key` is not what is printed on them.
 *
 * A cap says `↑` and `event.key` says `ArrowUp`; a cap says `Space` and
 * `event.key` says a literal space. Everything else — `Enter`, `Escape`, `Tab`,
 * a letter — already matches once both sides are lower-cased.
 */
const domKeys: Record<string, string> = {
  up: 'arrowup',
  down: 'arrowdown',
  left: 'arrowleft',
  right: 'arrowright',
  space: ' ',
  plus: '+'
};

/**
 * Only the parts of an event a chord is decided on, so the same matcher takes a
 * React synthetic event and a DOM one without either being converted.
 */
export interface PlassKeyState {
  key: string;
  metaKey: boolean;
  ctrlKey: boolean;
  shiftKey: boolean;
  altKey: boolean;
}

/**
 * Is this the chord?
 *
 * Every modifier is checked in **both** directions, which is the difference
 * between binding a shortcut and binding a key: `'Enter'` must not fire on
 * `Mod+Enter`, or a field that saves on Enter also saves on every chord that
 * happens to end in one.
 */
export function matchesHotKey(event: PlassKeyState, chord: string): boolean {
  const parts = chord.split('+').map(canonicalKey);
  const wanted = new Set(parts.slice(0, -1));
  const last = parts[parts.length - 1];
  const key = domKeys[last] ?? last;
  const mod = detectOS() === 'mac' ? event.metaKey : event.ctrlKey;

  if (wanted.has('mod') !== mod) {
    return false;
  }

  if (wanted.has('shift') !== event.shiftKey || wanted.has('alt') !== event.altKey) {
    return false;
  }

  // Only when `Mod` was not asked for. It *is* one of these two, and checking
  // both would make `Mod+K` require a Ctrl that a Mac never sends.
  if (!wanted.has('mod')) {
    if (wanted.has('ctrl') !== event.ctrlKey || wanted.has('meta') !== event.metaKey) {
      return false;
    }
  }

  return event.key.toLowerCase() === key;
}

/**
 * The `onKeyDown` a control carrying a `hotKeys` map wears.
 *
 * `undefined` when there is nothing to bind and no handler to call, so a field
 * with neither attaches no listener at all.
 *
 * The caller's own `onKeyDown` runs **first** and unconditionally: it is the
 * lower-level hook and it should see every key, including the ones the map is
 * about to claim. If it consumed the event — `preventDefault()` — the map is
 * skipped, which is how a caller overrules one of their own bindings for a
 * particular key without taking the map apart.
 */
export function hotKeyHandler<E extends Element>(
  hotKeys: PlassHotKeys | undefined,
  onKeyDown: React.KeyboardEventHandler<E> | undefined
): React.KeyboardEventHandler<E> | undefined {
  if (!hotKeys && !onKeyDown) {
    return undefined;
  }

  return (event) => {
    onKeyDown?.(event);

    if (!hotKeys || event.defaultPrevented) {
      return;
    }

    for (const chord of Object.keys(hotKeys)) {
      if (matchesHotKey(event, chord)) {
        // Consumed. The page asked for this key, so it does not also reach the
        // form around the field, the dialog around that, or the browser.
        event.preventDefault();
        event.stopPropagation();
        hotKeys[chord]();

        return;
      }
    }
  };
}
