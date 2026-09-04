'use client';

import * as React from 'react';

/** What a caller gets back: the answer, and the four ways to change it. */
export interface PlDisclosureResult {
  /** Whether the thing is open. */
  open: boolean;
  /** Opens it. */
  onOpen: () => void;
  /** Closes it. */
  onClose: () => void;
  /** Turns it round. */
  onToggle: () => void;
  /** Sets it to a value, for the caller who already has one. */
  setOpen: (open: boolean) => void;
}

/**
 * One boolean and the four callbacks that change it.
 *
 * The smallest hook in the library and the one that saves the most typing: a
 * dialog, a drawer, a popover and a menu each need exactly this, and written by
 * hand it is a `useState` plus three arrow functions **that are new on every
 * render**. That last part is the reason it is worth a hook rather than a
 * snippet — an inline `() => setOpen(false)` handed to a memoised trigger
 * defeats the memo, and every one of the callbacks here is stable for the life
 * of the component.
 *
 * The names are the props they are handed to. `onOpenChange` is the one shape
 * every openable component in this library takes, and `setOpen` fits it
 * exactly, so the ordinary use is a spread:
 *
 * ```tsx
 * const dialog = usePlDisclosure();
 *
 * <PlButton onClick={dialog.onOpen}>Delete</PlButton>
 * <PlModal open={dialog.open} onOpenChange={dialog.setOpen} title="Delete this?">
 *   <PlButton onClick={dialog.onClose}>Cancel</PlButton>
 * </PlModal>
 * ```
 *
 * It holds no DOM, watches nothing and has no effect in it, so it costs the
 * same on a server as it does in a browser.
 *
 * @example
 * const drawer = usePlDisclosure(true);
 */
export function usePlDisclosure(initial = false): PlDisclosureResult {
  const [open, setOpen] = React.useState(initial);

  const onOpen = React.useCallback(() => setOpen(true), []);
  const onClose = React.useCallback(() => setOpen(false), []);
  // The updater form rather than `!open`, so the callback does not have to
  // change when the value does — which is the whole point of it being stable.
  const onToggle = React.useCallback(() => setOpen((was) => !was), []);

  return React.useMemo(
    () => ({ open, onOpen, onClose, onToggle, setOpen }),
    [open, onOpen, onClose, onToggle]
  );
}
