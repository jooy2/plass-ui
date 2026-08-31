'use client';

import * as React from 'react';
import { PlButton } from '../button/PlButton.js';
import { PlPopover } from '../popover/PlPopover.js';
import { useDefaults } from '../../internal/defaults.js';
import { cx } from '../../internal/styles.js';
import type { PlassAlign, PlassColor, PlassSize, PlassSide } from '../../types.js';

export interface PlPopconfirmProps {
  /** What opens it. The element it is put on keeps everything it already had. */
  trigger: React.ReactElement;
  /** The question, as the heading that names the popup. */
  title?: React.ReactNode;
  /** A line under it. Say what happens. */
  description?: React.ReactNode;
  /** The word on the button that answers yes. @default 'Confirm' */
  confirmLabel?: React.ReactNode;
  /** The word on the button that answers no. @default 'Cancel' */
  cancelLabel?: React.ReactNode;
  /**
   * What confirming does. **A promise is waited for**: the button shows its
   * loading state until it settles and the popup closes only if it resolves, so
   * a failed request leaves the question on screen instead of pretending.
   *
   * A rejection is caught and goes no further. Keeping the question up is the
   * whole of what this component owes a failure; what the failure *means* is
   * the caller's, and `onConfirm` is where to report it from.
   */
  onConfirm?: () => void | Promise<unknown>;
  /** What cancelling does, beyond closing. */
  onCancel?: () => void;
  /** @default 'danger' */
  color?: PlassColor;
  /** @default 'md' */
  size?: PlassSize;
  /** Which edge of the trigger it opens against. @default 'top' */
  side?: PlassSide;
  /** @default 'center' */
  align?: PlassAlign;
  /** How wide the sheet may get. @default 280 */
  width?: number | string;
  /** The popup is open. Use with `onOpenChange` for a controlled one. */
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Classes on the popup, alongside the component's own. */
  className?: string;
}

/**
 * A question asked where it was raised, rather than in the middle of the page.
 *
 * The difference from [`PlConfirmProvider`](../feedback/confirm) is not the
 * words, it is **how much it interrupts**. A modal takes the page away and is
 * right for the question that deserves that — deleting an account, discarding
 * an hour of work. This is right for the row's own delete button: the question
 * appears against the thing it is about, the rest of the table stays readable,
 * and a reader who changes their mind presses Escape and is exactly where they
 * were.
 *
 * The rule of thumb is what happens if they answer by accident. If the answer
 * is "they can undo it", this is the one.
 *
 * `color` defaults to `danger` here and to `primary` on a `PlButton`, and that
 * is not an inconsistency: nobody reaches for a popconfirm to ask whether to
 * save.
 */
export function PlPopconfirm({
  trigger,
  title,
  description,
  confirmLabel = 'Confirm',
  cancelLabel = 'Cancel',
  onConfirm,
  onCancel,
  color: colorProp,
  size: sizeProp,
  side = 'top',
  align = 'center',
  width = 280,
  open: openProp,
  defaultOpen,
  onOpenChange,
  className
}: PlPopconfirmProps) {
  const defaults = useDefaults();
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? 'danger';

  const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? false);
  const open = openProp ?? uncontrolledOpen;
  const [running, setRunning] = React.useState(false);

  const setOpen = (next: boolean) => {
    if (openProp === undefined) {
      setUncontrolledOpen(next);
    }

    onOpenChange?.(next);
  };

  const confirm = async () => {
    const result = onConfirm?.();

    if (!(result instanceof Promise)) {
      setOpen(false);

      return;
    }

    setRunning(true);

    try {
      await result;
      setOpen(false);
    } catch {
      // Caught and gone no further, on purpose. What this component owes a
      // failure is the **question, still on screen** — closing it would be the
      // component saying the thing happened. What the failure *means* is the
      // caller's: they returned the promise, they are the ones with the
      // context to raise a toast about it, and re-throwing here would only
      // surface it as an unhandled rejection with none of that context
      // attached. `onConfirm` is where a failure is reported from.
    } finally {
      // Whether it resolved or threw. A button left spinning over a question
      // that failed is worse than the failure.
      setRunning(false);
    }
  };

  return (
    <PlPopover
      trigger={trigger}
      open={open}
      onOpenChange={(next) => {
        // A request in flight is not something Escape should abandon halfway.
        if (running) return;
        if (!next) onCancel?.();
        setOpen(next);
      }}
      title={title}
      description={description}
      side={side}
      align={align}
      width={width}
      color={color}
      size={size}
      showClose={false}
      className={className}
    >
      <div className={cx('mt-3 flex items-center justify-end gap-2')}>
        <PlButton
          variant="ghost"
          color="secondary"
          size={size}
          density="compact"
          disabled={running}
          onClick={() => {
            onCancel?.();
            setOpen(false);
          }}
        >
          {cancelLabel}
        </PlButton>

        <PlButton
          color={color}
          size={size}
          density="compact"
          loading={running}
          // The focus lands here rather than on Cancel, which is the other way
          // round from `PlConfirmProvider` — and deliberately. A popconfirm is
          // opened *by* the button it is asking about, so the reader has
          // already said what they want once; the modal is for the question
          // that has to be argued with.
          autoFocus
          onClick={confirm}
        >
          {confirmLabel}
        </PlButton>
      </div>
    </PlPopover>
  );
}
