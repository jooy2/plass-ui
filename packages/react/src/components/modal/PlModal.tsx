import * as React from 'react';
import { Dialog as BaseUIDialog } from '@base-ui/react/dialog';
import { CloseIcon } from '../../internal/icons.js';
import {
  focusRingClasses,
  glassClasses,
  hasContent,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetLineClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type { PlassSize, PlassStyleProps } from '../../types.js';

/**
 * A modal takes `size`, `color` and `density` and stops there.
 *
 * There is no `variant`: the three materials answer "how much does this surface
 * assert itself against the page around it", and a modal has already taken the
 * page. There is no `elevation` either — see `popupClasses`.
 */
export interface PlModalProps
  extends
    Pick<PlassStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title' | 'children'> {
  /** The modal is shown. Use with `onOpenChange` for a controlled modal. */
  open?: boolean;
  /** Whether it starts open, for an uncontrolled one. */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * The element that opens the modal, wired up by Base UI. Optional — a
   * controlled modal opened from somewhere else in the app needs no trigger at
   * all, and passing one here is only a convenience for the common case.
   */
  trigger?: React.ReactElement;
  /** The heading. Rendered as the `<h2>` that names the modal. */
  title?: React.ReactNode;
  /** A line under the title, and the modal's accessible description. */
  description?: React.ReactNode;
  /**
   * The bottom row. Laid out end-aligned, so a pair of buttons needs no wrapper
   * of its own — and `PlModalClose` is what makes one of them dismiss.
   */
  actions?: React.ReactNode;
  /**
   * Scores the sheet between the header, the body and the actions instead of
   * separating them with space. Worth turning on the moment the body scrolls:
   * the lines are what say the header stayed put.
   * @default false
   */
  dividers?: boolean;
  /**
   * Shows the × in the corner.
   *
   * On by default, unlike most booleans in the library. A modal takes the page
   * away until it is answered, and the visible way out should not have to be
   * remembered.
   * @default true
   */
  showClose?: boolean;
  /**
   * Accessible name of the × button. Never drawn.
   * @default 'Close'
   */
  closeLabel?: string;
  /**
   * A hard cap on the sheet's width, overriding the one `size` implies. Numbers
   * are pixels. For the modal whose content decides its width — a wide table, a
   * narrow confirmation — rather than for tuning the scale, which is `size`.
   */
  width?: number | string;
  /**
   * The sheet takes the full width its `size` allows.
   *
   * On by default, which is the other way round from every other component.
   * Elsewhere `fullWidth` means "fill the container"; a modal's container is
   * the viewport, and a modal that shrank to fit two words would be a tooltip.
   * @default true
   */
  fullWidth?: boolean;
  /** Fills the viewport edge to edge. For a mobile-sized screen, or an editor. */
  fullScreen?: boolean;
  /**
   * Whether the page behind is taken away. `'trap-focus'` keeps the page
   * scrollable and clickable while still holding focus inside.
   * @default true
   */
  modal?: boolean | 'trap-focus';
  /**
   * Whether pressing Escape or clicking outside closes the modal. Turn it off
   * for the one that has to be answered — and then give it actions that answer
   * it, because there will be no other way out.
   * @default true
   */
  dismissible?: boolean;
  /** The body. */
  children?: React.ReactNode;
}

export type PlModalCloseProps = React.ComponentPropsWithoutRef<typeof BaseUIDialog.Close>;

/**
 * How wide the sheet is allowed to get, per `size`.
 *
 * `size` and the width are one axis here rather than two. A second five-value
 * scale spelled `maxWidth` would be a second spelling of an idea the library
 * already has a word for, and the case it exists for — "small type, wide sheet"
 * — is what the `width` escape hatch is.
 *
 * The steps are wider apart than the control ladder because they answer a
 * different question: not how big is this thing, but how long a line of text is
 * comfortable inside it.
 */
const maxWidthClasses: Record<PlassSize, string> = {
  xs: 'max-w-80',
  sm: 'max-w-96',
  md: 'max-w-lg',
  lg: 'max-w-2xl',
  xl: 'max-w-4xl'
};

/**
 * The sheet, and — with the PlSelect popup — one of the two surfaces in the
 * library that is *supposed* to float. So unlike everything else it carries a
 * shadow by default, at level 3.
 *
 * It is the glass at its most opaque, because what is behind it is arbitrary:
 * a modal floats over whatever the page happens to be, and a 62%-translucent
 * pane over a photograph is a pane you read the photograph through.
 *
 * There is no `elevation` prop for the same reason there is no `variant`: a
 * modal that could be told to sit flat on the page would be a modal that could
 * be told to stop being one.
 */
const popupClasses = [
  glassClasses,
  'relative flex w-full flex-col overflow-hidden',
  'border text-(--plass-fg) bg-(--plass-glass-press)',
  '[border-color:var(--plass-glass-line)]',
  '[box-shadow:var(--plass-shadow-4),var(--plass-gloss-glass)]',
  '[outline:none]',
  // Opacity only. A modal that scales or slides in drags its own text across
  // the screen for 200ms, which is the exact thing the house style is against —
  // and unlike a control, this one is full of text.
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const backdropClasses = [
  'fixed inset-0 z-50 bg-(--plass-scrim)',
  '[backdrop-filter:blur(2px)] [-webkit-backdrop-filter:blur(2px)]',
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

/**
 * Closes the modal it is inside.
 *
 * Exported because an uncontrolled modal has no `setOpen` for its Cancel button
 * to call, and the alternative — making every modal controlled — is a piece of
 * state per modal that exists only to answer a button.
 *
 * `render` is Base UI's own escape hatch, so a real Plass button dismisses:
 * `<PlModalClose render={<PlButton variant="ghost">Cancel</PlButton>} />`.
 */
export const PlModalClose = BaseUIDialog.Close;

/**
 * A sheet that takes the page away until it is answered.
 *
 * The sections are props rather than compound sub-components, exactly as they
 * are on PlCard: the arrangement of a modal is fixed — heading, description,
 * body, actions — and what a caller wants to decide is what goes in each slot.
 * Base UI owns everything hard about it: the focus trap, the scroll lock, the
 * `aria-labelledby` / `aria-describedby` wiring, restoring focus to the trigger,
 * and the inert page behind.
 *
 * What is left here is the surface, the width ladder and the scroll behaviour —
 * the header and the actions stay put while only the body scrolls, which is why
 * `dividers` matters more here than on a PlCard.
 */
export function PlModal({
  size = 'md',
  color = 'primary',
  density = 'default',
  open,
  defaultOpen,
  onOpenChange,
  trigger,
  title,
  description,
  actions,
  dividers = false,
  showClose = true,
  closeLabel = 'Close',
  width,
  fullWidth = true,
  fullScreen = false,
  modal = true,
  dismissible = true,
  className,
  style,
  children,
  ...props
}: PlModalProps) {
  const insetX = sheetPaddingXClasses[density][size];
  const insetY = sheetPaddingYClasses[density][size];
  // With dividers the lines have to reach both edges, so the sheet gives up its
  // padding and every section takes it on instead — the same trade PlCard makes.
  const sectionClasses = dividers ? `${insetX} ${insetY}` : insetX;

  const hasHeader = hasContent(title) || hasContent(description);
  const hasActions = hasContent(actions);

  return (
    <BaseUIDialog.Root
      open={open}
      defaultOpen={defaultOpen}
      modal={modal}
      disablePointerDismissal={!dismissible}
      onOpenChange={(next, details) => {
        // `disablePointerDismissal` covers the click outside; Escape has no prop
        // of its own, so it is cancelled here by the reason it arrives with.
        if (!dismissible && !next && details.reason === 'escape-key') {
          details.cancel();

          return;
        }
        onOpenChange?.(next);
      }}
    >
      {trigger ? <BaseUIDialog.Trigger render={trigger} /> : null}

      <BaseUIDialog.Portal>
        {/* `plass-portal` is a hook, not a style: a portalled surface leaves the
            subtree a host may have scoped its CSS reset to. */}
        <BaseUIDialog.Backdrop className={`plass-portal ${backdropClasses}`} />

        <BaseUIDialog.Viewport
          className={[
            'plass-portal fixed inset-0 z-50 flex justify-center',
            // `items-center` alone would clip the top of a modal taller than the
            // viewport, because a centred flex item cannot scroll past its own
            // container's start edge. The popup caps its height instead and
            // scrolls its body, so the header and the actions stay put.
            fullScreen ? 'items-stretch' : 'items-center p-4'
          ].join(' ')}
        >
          <BaseUIDialog.Popup
            className={[
              popupClasses,
              sheetBodyClasses[size],
              fullScreen
                ? 'h-full max-w-none rounded-none'
                : `max-h-full ${radiusClasses[size]} ${width === undefined ? maxWidthClasses[size] : ''}`,
              !fullScreen && !fullWidth ? 'w-auto' : '',
              dividers ? '' : `${insetY} ${sheetSectionGapClasses[size]}`,
              className ?? ''
            ]
              .filter(Boolean)
              .join(' ')}
            style={{
              ...surfaceSlots(color, 3),
              ...(width === undefined
                ? null
                : { maxWidth: typeof width === 'number' ? `${width}px` : width }),
              ...style
            }}
            {...props}
          >
            {hasHeader || showClose ? (
              <div className={`flex shrink-0 items-start gap-3 ${sectionClasses}`}>
                <div className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
                  {hasContent(title) ? (
                    <BaseUIDialog.Title className={`m-0 font-semibold ${sheetTitleClasses[size]}`}>
                      {title}
                    </BaseUIDialog.Title>
                  ) : null}
                  {hasContent(description) ? (
                    <BaseUIDialog.Description
                      className={`m-0 text-(--plass-muted-fg) ${metaTextClasses[size]}`}
                    >
                      {description}
                    </BaseUIDialog.Description>
                  ) : null}
                </div>

                {showClose ? (
                  <BaseUIDialog.Close
                    aria-label={closeLabel}
                    className={[
                      'flex size-[1.6em] shrink-0 cursor-pointer items-center justify-center',
                      'rounded-full text-(--plass-muted-fg)',
                      '[&_svg]:size-[1.1em] [&_svg]:shrink-0',
                      '[transition:background-color_var(--plass-duration)_var(--plass-ease),color_var(--plass-duration)_var(--plass-ease)]',
                      'hover:bg-(--p-soft) hover:text-(--plass-fg)',
                      focusRingClasses
                    ].join(' ')}
                  >
                    <CloseIcon />
                  </BaseUIDialog.Close>
                ) : null}
              </div>
            ) : null}

            {hasContent(children) ? (
              // The only part that scrolls. `min-h-0` is what lets it: a flex
              // item's default `min-height: auto` refuses to shrink below its
              // content, and the sheet would grow past the viewport instead.
              <div
                className={[
                  'min-h-0 flex-1 overflow-y-auto overscroll-contain',
                  sectionClasses,
                  dividers && (hasHeader || showClose) ? sheetLineClasses : '',
                  // A scroll container clips at its padding box, and a focus
                  // ring is drawn 2px outside the control that owns it — so a
                  // field at the top or bottom of an unruled body would have its
                  // ring sliced off. The padding is room for the ring and the
                  // negative margin hands the space straight back, so nothing on
                  // the sheet moves. Only without `dividers`: with them the body
                  // already carries `insetY`, and pulling it up would drag the
                  // rule into the section above.
                  dividers ? '' : '-my-1 py-1'
                ]
                  .filter(Boolean)
                  .join(' ')}
              >
                {children}
              </div>
            ) : null}

            {hasActions ? (
              <div
                className={[
                  'flex shrink-0 flex-wrap items-center justify-end gap-2',
                  sectionClasses,
                  dividers ? sheetLineClasses : ''
                ]
                  .filter(Boolean)
                  .join(' ')}
              >
                {actions}
              </div>
            ) : null}
          </BaseUIDialog.Popup>
        </BaseUIDialog.Viewport>
      </BaseUIDialog.Portal>
    </BaseUIDialog.Root>
  );
}
