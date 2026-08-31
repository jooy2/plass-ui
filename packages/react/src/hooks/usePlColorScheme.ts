'use client';

import * as React from 'react';
import {
  DEFAULT_STORAGE_KEY,
  applyColorScheme,
  darkQuery,
  useColorSchemeStore,
  type PlColorScheme,
  type PlResolvedColorScheme
} from '../internal/color-scheme.js';
import { useMediaQuery } from '../internal/media.js';

export type { PlColorScheme, PlResolvedColorScheme };

export interface PlColorSchemeOptions {
  /**
   * What to use when nothing has been stored.
   *
   * `system` — follow the platform — and it should stay `system`: a library
   * that pinned a page to light on first visit would be overruling a preference
   * the reader has already expressed to their operating system.
   * @default 'system'
   */
  defaultScheme?: PlColorScheme;
  /**
   * Where the choice is kept, in `localStorage`.
   *
   * Change it to scope the choice to one app on a shared origin. There is no
   * way to turn storage off, because a toggle whose answer does not survive a
   * reload is a toggle that looks broken.
   * @default 'plass-color-scheme'
   */
  storageKey?: string;
}

export interface PlColorSchemeResult {
  /** What the reader chose. `system` is the absence of a choice. */
  scheme: PlColorScheme;
  /** What the page is painted in, once `system` has been resolved. */
  resolved: PlResolvedColorScheme;
  /** Chooses one. Written to `<html>` and to storage, and every other caller of this hook hears about it. */
  setScheme: (next: PlColorScheme) => void;
  /**
   * Light ⇄ dark, from whatever is currently *painted*.
   *
   * So the first press on a system-dark page gives light, which is what a
   * reader pressing a toggle means. It leaves `system` behind, deliberately:
   * they have now expressed a preference of their own.
   */
  toggle: () => void;
}

/**
 * The dark mode toggle, and what it takes to make one that does not flash.
 *
 * The library's tokens already answer to `.dark` / `[data-theme]` on any
 * ancestor and to `prefers-color-scheme` when neither is there, so a page that
 * only ever follows the platform needs nothing at all — this is for the app that
 * offers a **choice**, which needs three things the CSS cannot do on its own:
 * somewhere to keep it, something to write it onto `<html>`, and a way to paint
 * it before the first frame.
 *
 * The third one is not this hook. React runs after the document has been
 * parsed, so a scheme applied from an effect is applied one paint too late and
 * the reader sees a white flash. [`PlColorSchemeScript`](./PlColorSchemeScript)
 * is the answer to that and belongs in `<head>`.
 *
 * ```tsx
 * const { resolved, toggle } = usePlColorScheme();
 *
 * <PlIconButton label="Switch theme" icon={resolved === 'dark' ? <Sun /> : <Moon />} onClick={toggle} />
 * ```
 *
 * **`storageKey` and `defaultScheme` are read once**, when the first component
 * using that key mounts, and are ignored on every call after it. That is what
 * makes two toggles on one page agree with each other — they share one store —
 * and it means these two are decisions to make where the app is set up rather
 * than props to compute. Changing them at runtime does nothing.
 */
export function usePlColorScheme(options: PlColorSchemeOptions = {}): PlColorSchemeResult {
  const { defaultScheme = 'system', storageKey = DEFAULT_STORAGE_KEY } = options;

  const [scheme, setScheme] = useColorSchemeStore(storageKey, defaultScheme);
  const prefersDark = useMediaQuery(darkQuery);

  const resolved: PlResolvedColorScheme =
    scheme === 'system' ? (prefersDark ? 'dark' : 'light') : scheme;

  // Not the source of truth — the script in `<head>` already wrote this, and
  // `setScheme` writes it on every change. What this catches is the page that
  // shipped **without** the script: the flash happens once and the document is
  // right from then on, rather than the toggle appearing not to work.
  React.useEffect(() => {
    applyColorScheme(scheme);
  }, [scheme]);

  const toggle = React.useCallback(() => {
    setScheme(resolved === 'dark' ? 'light' : 'dark');
  }, [resolved, setScheme]);

  return { scheme, resolved, setScheme, toggle };
}
