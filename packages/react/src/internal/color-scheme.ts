'use client';

/**
 * The one piece of state in this library that lives in the DOM.
 *
 * `styles.css` answers to `.dark` / `.light` and `[data-theme]` on any
 * ancestor, and follows `prefers-color-scheme` when neither is there. So the
 * theme is already a document attribute before React knows anything about it —
 * which is the whole reason `PlColorSchemeScript` can set it in `<head>` and the
 * page can paint the right colours in its first frame.
 *
 * What is here is the arithmetic both halves have to agree on: the storage key,
 * the three values, and exactly which attributes and classes get written. The
 * script inlines it as text and the hook calls it; if the two ever disagreed the
 * page would paint one theme and then swap to the other, which is the flash the
 * script exists to prevent.
 */

import * as React from 'react';

/** What the reader chose. `system` is the absence of a choice, not a third theme. */
export type PlColorScheme = 'light' | 'dark' | 'system';

/** What the page is actually painted in, once `system` has been resolved. */
export type PlResolvedColorScheme = 'light' | 'dark';

export const DEFAULT_STORAGE_KEY = 'plass-color-scheme';

export const darkQuery = '(prefers-color-scheme: dark)';

/**
 * Writes the choice onto `<html>`.
 *
 * **Both** the attribute and the class, and not as belt and braces: the
 * attribute is what this library's tokens read, and the class is what a
 * consumer's own Tailwind `dark:` utilities read when they are configured
 * against a class rather than the media query. A toggle that moved one and not
 * the other would leave a page half switched.
 *
 * `system` removes both, which is not the same as writing `light`: it hands the
 * question back to `prefers-color-scheme`, so the page follows the platform
 * again rather than being pinned to the platform's current answer.
 */
export function applyColorScheme(scheme: PlColorScheme): void {
  if (typeof document === 'undefined') {
    return;
  }

  const root = document.documentElement;

  root.classList.remove('light', 'dark');

  if (scheme === 'system') {
    delete root.dataset.theme;

    return;
  }

  root.dataset.theme = scheme;
  root.classList.add(scheme);
}

/** Whatever was stored, if it is one of the three. */
export function readStoredScheme(key: string): PlColorScheme | null {
  if (typeof localStorage === 'undefined') {
    return null;
  }

  try {
    const stored = localStorage.getItem(key);

    return stored === 'light' || stored === 'dark' || stored === 'system' ? stored : null;
  } catch {
    // A browser with storage disabled, or a page in a sandboxed frame. The
    // choice simply does not survive a reload, which is the right failure.
    return null;
  }
}

function writeStoredScheme(key: string, scheme: PlColorScheme): void {
  try {
    localStorage.setItem(key, scheme);
  } catch {
    /* see above */
  }
}

/* ---------------------------------------------------------------------------
 * The store
 *
 * One per storage key, shared by every component that asks. Two toggles on one
 * page — a switch in the header and a menu item in the settings sheet — have to
 * agree with each other, and they cannot if each one holds its own `useState`.
 * ------------------------------------------------------------------------- */

interface Store {
  scheme: PlColorScheme;
  listeners: Set<() => void>;
}

const stores = new Map<string, Store>();

function storeFor(key: string, fallback: PlColorScheme): Store {
  let store = stores.get(key);

  if (!store) {
    store = { scheme: readStoredScheme(key) ?? fallback, listeners: new Set() };
    stores.set(key, store);
  }

  return store;
}

export function useColorSchemeStore(
  key: string,
  fallback: PlColorScheme
): [PlColorScheme, (next: PlColorScheme) => void] {
  const subscribe = React.useCallback(
    (onChange: () => void) => {
      const store = storeFor(key, fallback);

      store.listeners.add(onChange);

      // Another tab. The choice is one the reader made about themselves rather
      // than about this window, so a second window follows it.
      const onStorage = (event: StorageEvent) => {
        if (event.key !== key) return;

        const next = readStoredScheme(key) ?? fallback;

        if (next !== store.scheme) {
          store.scheme = next;
          applyColorScheme(next);
          store.listeners.forEach((listener) => listener());
        }
      };

      window.addEventListener('storage', onStorage);

      return () => {
        store.listeners.delete(onChange);
        window.removeEventListener('storage', onStorage);
      };
    },
    [key, fallback]
  );

  const snapshot = React.useCallback(() => storeFor(key, fallback).scheme, [key, fallback]);

  // A server has no storage and no document, so it answers with what the caller
  // said the default was. The *document* is already correct by then — the
  // script in `<head>` saw to that — so what this disagrees with for one render
  // is React's copy of the answer, never the painted page.
  const serverSnapshot = React.useCallback(() => fallback, [fallback]);

  const scheme = React.useSyncExternalStore(subscribe, snapshot, serverSnapshot);

  const setScheme = React.useCallback(
    (next: PlColorScheme) => {
      const store = storeFor(key, fallback);

      store.scheme = next;
      writeStoredScheme(key, next);
      applyColorScheme(next);
      store.listeners.forEach((listener) => listener());
    },
    [key, fallback]
  );

  return [scheme, setScheme];
}
