'use client';

import * as React from 'react';
import { PlButton } from '../button/PlButton.js';
import { PlModal } from '../modal/PlModal.js';
import type { PlassColor, PlassSize } from '../../types.js';

/** What one question looks like. Every field is optional but `title`. */
export interface PlConfirmOptions {
  /** The question, as the `<h2>` that names the dialog. */
  title?: React.ReactNode;
  /** A line under it, and the dialog's accessible description. Say what happens. */
  description?: React.ReactNode;
  /** Anything more that belongs in the body — a list of what is about to go. */
  children?: React.ReactNode;
  /** The word on the button that answers yes. @default 'Confirm' (`'OK'` on an alert) */
  confirmLabel?: React.ReactNode;
  /** The word on the button that answers no. Not drawn by `alert`. @default 'Cancel' */
  cancelLabel?: React.ReactNode;
  /**
   * The family the confirming button takes. `danger` for anything that removes
   * something.
   * @default 'primary'
   */
  color?: PlassColor;
  /** @default 'md' */
  size?: PlassSize;
  /**
   * Which button holds the focus when the dialog opens.
   *
   * **`cancel` by default**, and that is the decision worth stating: a confirm
   * dialog exists to make somebody stop, and an Enter key that lands on the
   * destructive action defeats the whole thing. Move it for a question whose
   * yes is the harmless answer — "Save before closing?" — where making somebody
   * reach for the mouse to agree is its own kind of rude.
   * @default 'cancel'
   */
  initialFocus?: 'confirm' | 'cancel';
  /**
   * Whether Escape and a click outside answer **no**.
   *
   * On, because Escape is the universal "no" and a question that cannot be
   * escaped is a trap. Turn it off for the one that has to be answered.
   * @default true
   */
  dismissible?: boolean;
  /** How wide the sheet may get. A number of pixels or any CSS length. */
  width?: number | string;
}

/** The two ways to ask. An `alert` has one button and no answer. */
type Kind = 'confirm' | 'alert';

interface Request {
  kind: Kind;
  options: PlConfirmOptions;
  resolve: (value: boolean) => void;
}

export interface PlConfirmValue {
  /**
   * Asks the question and resolves with the answer.
   *
   * ```tsx
   * if (await confirm({ title: 'Delete this project?', color: 'danger' })) {
   *   await remove(project);
   * }
   * ```
   */
  confirm: (options: PlConfirmOptions) => Promise<boolean>;
  /** Says something and resolves when it has been acknowledged. One button. */
  alert: (options: PlConfirmOptions) => Promise<void>;
}

const ConfirmContext = /* @__PURE__ */ React.createContext<PlConfirmValue | null>(null);

export interface PlConfirmProviderProps extends Pick<
  PlConfirmOptions,
  'size' | 'color' | 'confirmLabel' | 'cancelLabel' | 'width'
> {
  /** The word an `alert`'s single button says. @default 'OK' */
  acknowledgeLabel?: React.ReactNode;
  children?: React.ReactNode;
}

/**
 * One dialog, asked for from anywhere under it.
 *
 * The thing a caller has at the moment a question is warranted is a click
 * handler, not a place in the tree — `onClick={async () => { if (await
 * confirm(…)) remove() }}` is the shape this exists to make possible. The
 * alternative, and what every application writes without it, is a piece of
 * state per question plus a `<PlModal>` kept mounted beside every button that
 * might need one, and the branch after the answer torn in half across a
 * callback.
 *
 * It is `PlToastProvider`'s arrangement for the same reason and with the same
 * trade: one component near the root, and a hook everywhere else.
 *
 * **Questions asked while one is open are queued**, in the order they were
 * asked. The alternative is a promise nobody ever resolves, which is a hung
 * button rather than a visible bug.
 */
export function PlConfirmProvider({
  size,
  color,
  confirmLabel,
  cancelLabel,
  acknowledgeLabel,
  width,
  children
}: PlConfirmProviderProps) {
  const [open, setOpen] = React.useState(false);
  const [current, setCurrent] = React.useState<Request | null>(null);

  // The live request and the ones behind it, in refs rather than in state:
  // `settle` has to read and clear them without waiting for a render, and
  // nothing here is drawn from them except through `current`.
  const live = React.useRef<Request | null>(null);
  const queue = React.useRef<Request[]>([]);

  const settle = React.useCallback((value: boolean) => {
    const request = live.current;

    if (!request) {
      return;
    }

    request.resolve(value);

    const next = queue.current.shift();

    if (next) {
      // The dialog stays open and its content changes. Closing and reopening in
      // one tick would play neither transition, and would take the focus out of
      // a dialog the reader is about to be asked something else in.
      live.current = next;
      setCurrent(next);

      return;
    }

    live.current = null;
    // `current` is deliberately kept, so the sheet has something to draw while
    // it animates out.
    setOpen(false);
  }, []);

  const ask = React.useCallback((kind: Kind, options: PlConfirmOptions) => {
    return new Promise<boolean>((resolve) => {
      const request: Request = { kind, options, resolve };

      if (live.current) {
        queue.current.push(request);

        return;
      }

      live.current = request;
      setCurrent(request);
      setOpen(true);
    });
  }, []);

  const value = React.useMemo<PlConfirmValue>(
    () => ({
      confirm: (options) => ask('confirm', options),
      alert: (options) => ask('alert', options).then(() => undefined)
    }),
    [ask]
  );

  // Everything an unmounting provider is still holding. A promise that is never
  // settled is a handler that never runs its `finally`, so a route change would
  // leave a button spinning for the rest of the session.
  React.useEffect(() => {
    return () => {
      live.current?.resolve(false);
      queue.current.forEach((request) => request.resolve(false));
      live.current = null;
      queue.current = [];
    };
  }, []);

  const options = current?.options;
  const isAlert = current?.kind === 'alert';
  const focusConfirm = (options?.initialFocus ?? 'cancel') === 'confirm' || isAlert;

  return (
    <ConfirmContext.Provider value={value}>
      {children}

      <PlModal
        open={open}
        // The only path that reaches here is Escape, a click outside or the
        // close button — the buttons below settle and close it themselves, and
        // a controlled `open` does not call this back for that.
        onOpenChange={(next) => {
          if (!next) {
            settle(false);
          }
        }}
        size={options?.size ?? size}
        color={options?.color ?? color}
        width={options?.width ?? width}
        dismissible={options?.dismissible ?? true}
        title={options?.title}
        description={options?.description}
        actions={
          <>
            {isAlert ? null : (
              <PlButton
                variant="ghost"
                color="secondary"
                size={options?.size ?? size}
                autoFocus={!focusConfirm}
                onClick={() => settle(false)}
              >
                {options?.cancelLabel ?? cancelLabel ?? 'Cancel'}
              </PlButton>
            )}

            <PlButton
              color={options?.color ?? color}
              size={options?.size ?? size}
              autoFocus={focusConfirm}
              onClick={() => settle(true)}
            >
              {options?.confirmLabel ??
                (isAlert ? (acknowledgeLabel ?? 'OK') : (confirmLabel ?? 'Confirm'))}
            </PlButton>
          </>
        }
      >
        {options?.children}
      </PlModal>
    </ConfirmContext.Provider>
  );
}

/**
 * Asks a question from a click handler, and waits for the answer.
 *
 * ```tsx
 * const { confirm } = usePlConfirm();
 *
 * <PlButton color="danger" onClick={async () => {
 *   if (await confirm({ title: 'Delete this project?', color: 'danger', confirmLabel: 'Delete' })) {
 *     await remove(project);
 *   }
 * }}>Delete</PlButton>
 * ```
 *
 * Throws outside a `PlConfirmProvider`, rather than resolving `false`. A silent
 * `false` is a delete button that quietly does nothing, which is worse than a
 * missing provider that says so on the first press.
 */
export function usePlConfirm(): PlConfirmValue {
  const value = React.useContext(ConfirmContext);

  if (!value) {
    throw new Error('[plass-ui] usePlConfirm was called outside a <PlConfirmProvider>.');
  }

  return value;
}
