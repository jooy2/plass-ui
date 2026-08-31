'use client';

/**
 * Which way the page runs, as React sees it.
 *
 * Almost nothing in this library needs to ask. Every padding, radius and inset
 * is a logical property, so the browser turns the layout over on its own the
 * moment `dir="rtl"` is on the document — that is the whole of the styling and
 * it needs no JavaScript at all.
 *
 * **Behaviour is the part CSS cannot answer.** Base UI reads the direction from
 * a React context and nowhere else: with no provider its `useDirection()`
 * returns `'ltr'`, whatever the document says. That decides a slider's arrow
 * keys, which way a composite walks under ←/→, and how a popup's logical
 * `align` resolves to a physical edge — so a page that set `dir` and stopped
 * would look right and behave the other way round.
 *
 * So `PlassProvider` puts Base UI's `DirectionProvider` in the tree, and this
 * is where it gets the answer: **read off the document rather than configured**,
 * because the direction is already written there and a second place to declare
 * it is a second place to get it wrong.
 */

import * as React from 'react';

/** The two directions a document can run in. */
export type PlassDirection = 'ltr' | 'rtl';

/**
 * `getComputedStyle` rather than the `dir` attribute, so a page that set the
 * direction in CSS — or inherited it from `<body>` — is read the same as one
 * that set the attribute.
 */
function read(): PlassDirection {
  if (typeof document === 'undefined') {
    return 'ltr';
  }

  return getComputedStyle(document.documentElement).direction === 'rtl' ? 'rtl' : 'ltr';
}

/* ---------------------------------------------------------------------------
 * One observer for the document, however many providers ask
 *
 * `useSyncExternalStore` calls its snapshot on every render, and a snapshot
 * that ran `getComputedStyle` every time would force a style recalculation on
 * every render of every provider. So the answer is cached and the observer is
 * what invalidates it.
 * ------------------------------------------------------------------------- */

let cached: PlassDirection | null = null;
let observer: MutationObserver | null = null;
const listeners = new Set<() => void>();

function snapshot(): PlassDirection {
  if (cached === null) {
    cached = read();
  }

  return cached;
}

/** A server has no document, and `ltr` is what Base UI would have said anyway. */
function onServer(): PlassDirection {
  return 'ltr';
}

function subscribe(onChange: () => void): () => void {
  listeners.add(onChange);

  if (!observer && typeof document !== 'undefined') {
    observer = new MutationObserver(() => {
      const next = read();

      if (next !== cached) {
        cached = next;
        listeners.forEach((listener) => listener());
      }
    });

    // `class` and `style` are in the list because the direction can be set in
    // CSS, and a theme toggle that writes a class is the ordinary way that
    // happens.
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['dir', 'class', 'style']
    });
  }

  return () => {
    listeners.delete(onChange);

    if (listeners.size === 0) {
      observer?.disconnect();
      observer = null;
      // Dropped rather than kept: the next mount re-reads, so a document whose
      // direction changed while nothing was listening is not answered stale.
      cached = null;
    }
  };
}

/** Which way the document runs, re-rendering when it turns over. */
export function useDocumentDirection(): PlassDirection {
  return React.useSyncExternalStore(subscribe, snapshot, onServer);
}
