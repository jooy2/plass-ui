import * as React from 'react';
import { Toast as BaseUIToast } from '@base-ui/react/toast';
import { CloseIcon, severityIcon } from '../../internal/icons.js';
import {
  controlSlots,
  focusRingClasses,
  glassClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetSectionGapClasses,
  sheetTitleClasses
} from '../../internal/styles.js';
import type {
  PlassAlign,
  PlassColor,
  PlassSize,
  PlassStyleProps,
  PlassVariant
} from '../../types.js';

/**
 * Where the stack sits.
 *
 * Written as two words rather than as a `side` plus an `align` pair, because
 * they are not independent: a toast stack is always pinned to the top or the
 * bottom, never to a side, and offering `left`/`right` as a "side" would invite
 * a stack down the middle of the screen that nothing in the layout survives.
 * The second half is `PlassAlign`, the same word every other component uses.
 */
export type PlToastPosition = `top-${PlassAlign}` | `bottom-${PlassAlign}`;

/**
 * The Plass style props a single toast can override, carried in Base UI's
 * per-toast `data`. Anything not set here falls back to the provider.
 */
export interface PlToastData {
  color?: PlassColor;
  variant?: PlassVariant;
  icon?: React.ReactNode | false;
}

export interface PlToastOptions extends PlToastData {
  /**
   * Reusing an id updates that toast in place and restarts its timer, which is
   * what "uploading… / uploaded" wants: one toast that changed its mind, not two
   * stacked on each other.
   */
  id?: string;
  /** The headline. */
  title?: React.ReactNode;
  /** The detail under it. A toast with only this is a one-line toast. */
  description?: React.ReactNode;
  /**
   * How long before it dismisses itself, in milliseconds. `0` means it stays
   * until it is closed — which is the right answer for anything the reader has
   * to act on, because a toast that leaves before it is read said nothing.
   */
  timeout?: number;
  /**
   * `high` interrupts a screen reader; `low` waits for a pause. An error is
   * worth interrupting for and a save confirmation is not.
   * @default 'low'
   */
  priority?: 'low' | 'high';
  /** The label of the action button. Passing it is what makes the button appear. */
  actionLabel?: React.ReactNode;
  onAction?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  /** Called when the toast closes, however it closed. */
  onClose?: () => void;
  /** Called once it has finished animating out and left the DOM. */
  onRemove?: () => void;
}

export interface PlToastProviderProps extends Pick<
  PlassStyleProps,
  'variant' | 'size' | 'density'
> {
  /** The default colour family. A single toast overrides it in `add`. */
  color?: PlassColor;
  /** @default 'bottom-end' */
  position?: PlToastPosition;
  /**
   * How long a toast lasts by default, in milliseconds. `0` keeps every toast up
   * until it is closed.
   * @default 5000
   */
  timeout?: number;
  /**
   * How many are shown at once. The rest are kept and revealed as the stack
   * drains rather than being thrown away.
   * @default 3
   */
  limit?: number;
  /**
   * How wide a toast is allowed to get. Numbers are pixels.
   * @default 380
   */
  width?: number | string;
  /**
   * Accessible name of every toast's × button. Never drawn.
   * @default 'Close'
   */
  closeLabel?: string;
  children?: React.ReactNode;
}

/**
 * How a stack is pinned, per position.
 *
 * The viewport is full width in every case and the alignment is done with
 * `items-*`, rather than by pinning one edge and nudging the centre back with a
 * translate. That keeps the one `transform` this component could have wanted out
 * of it, and it means the same three classes serve all six positions.
 */
const viewportClasses: Record<PlToastPosition, string> = {
  'top-start': 'top-0 items-start',
  'top-center': 'top-0 items-center',
  'top-end': 'top-0 items-end',
  'bottom-start': 'bottom-0 flex-col-reverse items-start',
  'bottom-center': 'bottom-0 flex-col-reverse items-center',
  'bottom-end': 'bottom-0 flex-col-reverse items-end'
};

/**
 * A toast floats over the page, so — with the `PlSelect` popup, the `PlModal`
 * sheet and the `PlTooltip` plate — it carries a shadow by default, at level 3.
 *
 * The two undyed materials are the glass at its most opaque, for the reason the
 * modal's sheet is: what is behind a toast is arbitrary, and a 62%-translucent
 * pane over a photograph is a pane you read the photograph through.
 */
const rootClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'text-(--p-on-solid) [background-image:var(--p-fill)]',
    '[box-shadow:var(--plass-shadow-3),var(--p-lift)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'border text-(--plass-fg) bg-(--plass-glass-press)',
    '[border-color:var(--p-line)]',
    '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: /* @__PURE__ */ [
    glassClasses,
    'text-(--plass-fg) bg-(--plass-glass-press)',
    '[box-shadow:var(--plass-shadow-3),var(--plass-gloss-glass)]'
  ].join(' ')
};

const accentClasses: Record<PlassVariant, string> = {
  solid: '',
  glass: 'text-(--p-accent)',
  ghost: 'text-(--p-accent)'
};

/**
 * Turns a Plass toast into the object Base UI's manager stores.
 *
 * The style props go into `data` rather than becoming top-level fields, because
 * `data` is the slot Base UI reserves for exactly this and the alternative —
 * shadowing the manager's own option names — is how a library ends up with two
 * `type` props that mean different things.
 */
function toManagerOptions(options: PlToastOptions) {
  const { color, variant, icon, actionLabel, onAction, ...rest } = options;

  return {
    ...rest,
    data: { color, variant, icon } satisfies PlToastData,
    actionProps:
      actionLabel === undefined
        ? undefined
        : { children: actionLabel, onClick: onAction as React.MouseEventHandler<HTMLButtonElement> }
  };
}

/**
 * Raises toasts from anywhere under a `PlToastProvider`.
 *
 * A hook rather than a component, because the thing a caller has at the moment a
 * toast is warranted is a click handler, not a place in the tree — and a
 * `<PlToast open={…} />` they would have to keep mounted, with a piece of state
 * per message, is the shape this component exists to avoid.
 */
export function usePlToast() {
  const manager = BaseUIToast.useToastManager<PlToastData>();

  return React.useMemo(
    () => ({
      /** Raises a toast and returns its id. */
      add: (options: PlToastOptions) => manager.add(toManagerOptions(options)),
      /** Closes one toast, or every toast when called with nothing. */
      close: (id?: string) => manager.close(id),
      /** Changes a toast already on screen. */
      update: (id: string, options: PlToastOptions) =>
        manager.update(id, toManagerOptions(options)),
      /**
       * One toast that follows a promise: the loading message while it runs, then
       * the success or the error. `timeout: 0` is applied to the loading state by
       * Base UI, so a slow request cannot dismiss its own toast.
       */
      promise: <Value,>(
        promise: Promise<Value>,
        options: {
          loading: PlToastOptions;
          success: PlToastOptions | ((value: Value) => PlToastOptions);
          error: PlToastOptions | ((error: unknown) => PlToastOptions);
        }
      ) =>
        manager.promise(promise, {
          loading: toManagerOptions(options.loading),
          success: (value: Value) =>
            toManagerOptions(
              typeof options.success === 'function' ? options.success(value) : options.success
            ),
          error: (error: unknown) =>
            toManagerOptions(
              typeof options.error === 'function' ? options.error(error) : options.error
            )
        }),
      /** Every toast currently in the stack, newest first. */
      toasts: manager.toasts
    }),
    [manager]
  );
}

interface ToastItemProps extends Pick<PlToastProviderProps, 'variant' | 'density'> {
  toast: BaseUIToast.Root.ToastObject<PlToastData>;
  color: PlassColor;
  size: PlassSize;
  closeLabel: string;
  /** Which way it can be flicked away, derived from where the stack is pinned. */
  swipeDirection: ('up' | 'down' | 'left' | 'right')[];
}

function ToastItem({
  toast,
  variant: providerVariant,
  color: providerColor,
  size,
  density,
  closeLabel,
  swipeDirection
}: ToastItemProps) {
  const variant = toast.data?.variant ?? providerVariant ?? 'glass';
  const color = toast.data?.color ?? providerColor;
  const glyph = toast.data?.icon === undefined ? severityIcon(color) : toast.data.icon;
  const accent = accentClasses[variant];
  const titled = hasContent(toast.title);

  return (
    <BaseUIToast.Root
      toast={toast}
      swipeDirection={swipeDirection}
      className={[
        'pointer-events-auto flex w-full items-start',
        sheetPaddingXClasses[density ?? 'default'][size],
        sheetPaddingYClasses[density ?? 'default'][size],
        radiusClasses[size],
        sheetSectionGapClasses[size],
        sheetBodyClasses[size],
        rootClasses[variant],
        iconClasses,
        // Opacity, and only opacity — the same restraint the modal shows, and
        // for the same reason: this is a box full of text. Base UI still moves
        // it while a finger is dragging it, which is the reader's hand rather
        // than a state change, and it stops the moment the finger lifts.
        '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
        'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0',
        // A toast pushed out by the limit is kept in the DOM so it can come
        // back; it just has nothing to say while it waits.
        'data-[limited]:hidden',
        focusRingClasses,
        '[outline:none]'
      ]
        .filter(Boolean)
        .join(' ')}
      style={controlSlots(color, 3, variant)}
    >
      {hasContent(glyph) ? (
        <span className={`flex h-[1lh] shrink-0 items-center ${accent}`}>{glyph}</span>
      ) : null}

      <div className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
        <BaseUIToast.Title
          className={`plass-title font-semibold ${sheetTitleClasses[size]} ${accent}`}
        />
        <BaseUIToast.Description
          className={titled && variant !== 'solid' ? 'text-(--plass-muted-fg)' : ''}
        />
      </div>

      <BaseUIToast.Action
        className={[
          'flex h-[1lh] shrink-0 cursor-pointer items-center rounded-full px-2',
          'font-medium underline-offset-2',
          accent || 'text-(--p-on-solid)',
          'hover:underline',
          focusRingClasses,
          metaTextClasses[size]
        ].join(' ')}
      />

      <span className="flex h-[1lh] shrink-0 items-center">
        <BaseUIToast.Close
          aria-label={closeLabel}
          className={[
            'inline-flex size-[1.15em] cursor-pointer items-center justify-center rounded-full',
            'opacity-70 [transition:opacity_var(--plass-duration)_var(--plass-ease)]',
            'hover:opacity-100 focus-visible:opacity-100',
            focusRingClasses
          ].join(' ')}
        >
          <CloseIcon />
        </BaseUIToast.Close>
      </span>
    </BaseUIToast.Root>
  );
}

/** The stack itself. Rendered by the provider, never by a caller. */
function ToastViewport(
  props: Required<Pick<PlToastProviderProps, 'position' | 'size' | 'width'>> &
    Pick<PlToastProviderProps, 'variant' | 'density'> & { color: PlassColor; closeLabel: string }
) {
  const { toasts } = BaseUIToast.useToastManager<PlToastData>();
  const { position, width, ...rest } = props;
  const swipeDirection: ('up' | 'down' | 'left' | 'right')[] = [
    position.startsWith('top') ? 'up' : 'down',
    'left',
    'right'
  ];

  return (
    <BaseUIToast.Portal>
      {/* `plass-portal` is a hook, not a style: a portalled surface leaves the
          subtree a host may have scoped its CSS reset to. */}
      <BaseUIToast.Viewport
        className={[
          // Full width and `pointer-events-none`, so the strip across the top or
          // the bottom of the page is not a wall the rest of the app is behind.
          // The toasts themselves take their events back.
          'plass-portal pointer-events-none fixed inset-x-0 z-50 flex flex-col gap-2 p-4',
          viewportClasses[position]
        ].join(' ')}
      >
        {toasts.map((toast) => (
          <div
            key={toast.id}
            className="w-full"
            style={{ maxWidth: typeof width === 'number' ? `${width}px` : width }}
          >
            <ToastItem toast={toast} swipeDirection={swipeDirection} {...rest} />
          </div>
        ))}
      </BaseUIToast.Viewport>
    </BaseUIToast.Portal>
  );
}

/**
 * Puts the toast stack on the page and lets anything under it raise a message.
 *
 * Wrap the application once. Everything about how a toast *looks* is decided
 * here — where the stack sits, how wide it is, which material it wears, how long
 * it lasts — so the call site stays the one thing it should be: what happened.
 *
 * Base UI owns the parts of this that are genuinely hard and invisible when they
 * work: the timers and their pausing on hover and on window blur, the limit, the
 * swipe, the F6 focus hotkey, and the live region that makes a message which
 * appeared out of nowhere reach a screen reader at all.
 */
export function PlToastProvider({
  variant = 'glass',
  size = 'md',
  color = 'primary',
  density = 'default',
  position = 'bottom-end',
  timeout = 5000,
  limit = 3,
  width = 380,
  closeLabel = 'Close',
  children
}: PlToastProviderProps) {
  return (
    <BaseUIToast.Provider timeout={timeout} limit={limit}>
      {children}
      <ToastViewport
        position={position}
        variant={variant}
        size={size}
        color={color}
        density={density}
        width={width}
        closeLabel={closeLabel}
      />
    </BaseUIToast.Provider>
  );
}
