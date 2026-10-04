'use client';

import * as React from 'react';
import { PlButton } from '../button/PlButton.js';
import type { PlModalProps } from '../modal/PlModal.js';
import { useLabels } from '../../internal/labels.js';
import { lazyPart, type LazyPartProps } from '../../internal/lazy.js';
import type { PlassColor, PlassSize } from '../../types.js';

/**
 * The dialog the questions are asked in, which is a download of its own.
 *
 * A provider sits at the root of every page, and most pages never ask it
 * anything, so the dialog stack — the focus trap, the scroll lock, the inert
 * page — should not be in the first paint's bundle on their account. Behind
 * `React.lazy` the chunk is fetched once the page has gone idle, and the modal
 * is mounted by the first question. A question asked before the chunk arrives
 * is answered as soon as it does, and one asked of a chunk that cannot be had
 * is answered as Escape answers it.
 */
const PlModal = /* @__PURE__ */ lazyPart(() =>
  import('../modal/PlModal.js').then((module) => module.PlModal)
);

/**
 * Calls `callback` once the browser has nothing more pressing to do, and
 * returns what calls it off. A browser without `requestIdleCallback` gets a
 * timer instead, long enough to leave the page's own first requests ahead of
 * the chunk.
 */
function whenIdle(callback: () => void): () => void {
  if (typeof window.requestIdleCallback === 'function') {
    const handle = window.requestIdleCallback(callback, { timeout: 2000 });

    return () => window.cancelIdleCallback(handle);
  }

  const handle = window.setTimeout(callback, 500);

  return () => window.clearTimeout(handle);
}

/**
 * The modal, mounted closed and opened one commit later.
 *
 * The first question is what mounts it, and a dialog that mounts already open
 * has no closed state to fade in from: Base UI starts the transition when
 * `open` changes. Opening it from a layout effect, before the browser paints,
 * gives the first question the same arrival every later one gets.
 */
function ConfirmModal({
  open,
  ...props
}: LazyPartProps<PlModalProps> & { initialFocus?: React.RefObject<HTMLElement | null> }) {
  const [mounted, setMounted] = React.useState(false);

  React.useLayoutEffect(() => {
    // The second render is the point: the closed one has to be committed for
    // the open one to have something to change from. It runs once, on mount.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMounted(true);
  }, []);

  return <PlModal open={open === true && mounted} {...props} />;
}

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
  /** Which question this is, so the buttons of the next one are new buttons. */
  id: number;
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
  const labels = useLabels();
  const [open, setOpen] = React.useState(false);
  const [current, setCurrent] = React.useState<Request | null>(null);

  // The live request and the ones behind it, in refs rather than in state:
  // `settle` has to read and clear them without waiting for a render, and
  // nothing here is drawn from them except through `current`.
  const live = React.useRef<Request | null>(null);
  const queue = React.useRef<Request[]>([]);
  const asked = React.useRef(0);
  // The button that takes the focus when the dialog opens.
  const answer = React.useRef<HTMLButtonElement>(null);

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
      asked.current += 1;

      const request: Request = { id: asked.current, kind, options, resolve };

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

  // Fetched ahead of the first question, so the dialog is normally there the
  // moment that question is asked rather than a download later.
  React.useEffect(() => whenIdle(PlModal.preload), []);

  /*
   * The dialog's chunk could not be fetched, twice. Every question waiting on
   * it is answered the way Escape answers one — `false`, and an `alert`
   * resolves — because nobody was shown a question to say yes to. Clearing
   * `current` unmounts the modal, so the next question is the next try.
   */
  const unavailable = React.useCallback(() => {
    const waiting = [live.current, ...queue.current];

    live.current = null;
    queue.current = [];
    waiting.forEach((request) => request?.resolve(false));
    setOpen(false);
    setCurrent(null);
  }, []);

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

  // Whether the dialog was open before the question now in it arrived.
  const wasOpen = React.useRef(false);

  // A question that takes the place of another in a dialog that stays open,
  // from the queue or asked as soon as the last one was answered, gets the
  // focus here: the dialog's `initialFocus` ran when it opened and does not run
  // again. Before paint, so an Enter pressed twice cannot reach the button just
  // pressed and confirm the next question from the last one's harmless yes.
  React.useLayoutEffect(() => {
    if (open && wasOpen.current) {
      answer.current?.focus();
    }

    wasOpen.current = open;
  }, [open, current]);

  // Nothing is mounted until something asks, and `current` is cleared only
  // when the dialog could not be fetched, so from the first question on the
  // modal stays mounted between questions exactly as it would have from the
  // start.
  const modal = current ? (
    <React.Suspense fallback={null}>
      <ConfirmModal
        open={open}
        onUnavailable={unavailable}
        // The only path that reaches here is Escape or a click outside — the
        // buttons below settle and close it themselves, and a controlled `open`
        // does not call this back for that.
        onOpenChange={(next) => {
          if (!next) {
            settle(false);
          }
        }}
        // No ×, as in the Flutter build. A question is answered by its own
        // buttons, which say what each answer does; a × beside them would be a
        // third answer that means the same as Cancel without saying so.
        showClose={false}
        // The dialog moves the focus onto the button rather than the button
        // taking it with `autoFocus`. The dialog notes where the focus was as it
        // opens, and an `autoFocus` has already moved it by then, so an answer
        // would hand the focus back to a button that is gone, and the reader
        // would land on the page's body. `PlModal` hands what it does not name
        // to Base UI's popup, which is where this is read.
        initialFocus={answer}
        size={options?.size ?? size}
        color={options?.color ?? color}
        width={options?.width ?? width}
        dismissible={options?.dismissible ?? true}
        title={options?.title}
        description={options?.description}
        actions={
          // Keyed by the question, so a question that takes the place of another
          // in the open sheet gets buttons of its own rather than the last
          // one's, one of which was pressed a moment ago.
          <React.Fragment key={current?.id}>
            {isAlert ? null : (
              <PlButton
                ref={focusConfirm ? undefined : answer}
                variant="ghost"
                color="secondary"
                size={options?.size ?? size}
                onClick={() => settle(false)}
              >
                {options?.cancelLabel ?? cancelLabel ?? labels.cancel}
              </PlButton>
            )}

            <PlButton
              ref={focusConfirm ? answer : undefined}
              color={options?.color ?? color}
              size={options?.size ?? size}
              onClick={() => settle(true)}
            >
              {options?.confirmLabel ??
                (isAlert
                  ? (acknowledgeLabel ?? labels.acknowledge)
                  : (confirmLabel ?? labels.confirm))}
            </PlButton>
          </React.Fragment>
        }
      >
        {options?.children}
      </ConfirmModal>
    </React.Suspense>
  ) : null;

  return (
    <ConfirmContext.Provider value={value}>
      {children}
      {modal}
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
