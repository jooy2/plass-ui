'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { Dialog as BaseUIDialog } from '@base-ui/react/dialog';
import { CloseIcon } from '../../internal/icons.js';
import {
  cx,
  focusRingClasses,
  glassClasses,
  hasContent,
  metaTextClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetLineClasses,
  sheetPaddingXClasses,
  sheetPaddingYClasses,
  sheetSectionGapClasses,
  sheetTitleClasses,
  surfaceSlots,
  targetClasses
} from '../../internal/styles.js';
import type {
  PlassHeadingLevel,
  PlassPortalClassNames,
  PlassSide,
  PlassSize,
  PlassStyleProps
} from '../../types.js';

/**
 * How the panel relates to the page.
 *
 * - `overlay` — it is opened, it floats over the page on a scrim, it holds the
 *   focus, and it is dismissed. The navigation drawer behind a hamburger, the
 *   filter panel beside a table.
 * - `inline` — it is part of the layout and the page is laid out around it. No
 *   scrim, no portal, no focus trap, nothing to dismiss. The sidebar that is
 *   simply there.
 *
 * A separate axis from `variant`, which already means the weight of a surface
 * across the whole library and would be a second spelling of nothing.
 */
export type PlDrawerMode = 'overlay' | 'inline';

/**
 * A drawer takes `size`, `color` and `density` and stops there.
 *
 * There is no `variant`, for `PlModal`'s reason: the three materials answer
 * "how much does this surface assert itself against the page", and a panel that
 * has taken an edge of the window has answered it. There is no `elevation`
 * either — an `overlay` drawer floats and carries a shadow at the top of the
 * ladder, an `inline` one is part of the layout and carries none, and neither
 * is a decision worth offering.
 */
export interface PlDrawerProps
  extends
    Pick<PlassStyleProps, 'size' | 'color' | 'density'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'title' | 'children'> {
  /** Classes on the parts a `className` does not reach. */
  classNames?: PlassPortalClassNames;
  /**
   * Which edge the panel is attached to. Physical rather than logical, the way
   * `PlassSide` is everywhere: a drawer along the top of the window is along the
   * top in every writing direction.
   * @default 'left'
   */
  side?: PlassSide;
  /** @default 'overlay' */
  mode?: PlDrawerMode;
  /** The drawer is shown. Use with `onOpenChange` for a controlled drawer. */
  open?: boolean;
  /**
   * Whether the drawer starts open, for an uncontrolled one.
   *
   * Defaults to `false` in `overlay` mode and `true` in `inline` mode, because
   * a fixed sidebar that had to be opened before it appeared would not be a
   * fixed sidebar.
   */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * The element that opens the drawer, wired up by Base UI.
   *
   * `overlay` only. An `inline` drawer is not opened — it is in the layout — so
   * a trigger there would have nothing to do and is not rendered.
   */
  trigger?: React.ReactElement;
  /** The heading. Rendered as the element that names the drawer. */
  title?: React.ReactNode;
  /**
   * The level of the heading `title` is, `1` to `6`.
   *
   * An `inline` drawer's title sits in the page's outline, and a heading has
   * to sit one level under the one above it, or the outline skips a step. `2`
   * fits a sidebar beside the page's `<h1>`; a panel inside a section headed by
   * an `<h2>` wants `3`. An `overlay` drawer's title takes the level too and
   * still names the dialog. Only the element changes: the type scale is the
   * drawer's either way.
   * @default 2
   */
  headingLevel?: PlassHeadingLevel;
  /** A line under the title, and the drawer's accessible description. */
  description?: React.ReactNode;
  /**
   * The bottom row, held against the foot of the panel while the body scrolls.
   * Laid out end-aligned, so a pair of buttons needs no wrapper of its own —
   * and `PlDrawerClose` is what makes one of them dismiss.
   */
  actions?: React.ReactNode;
  /**
   * Scores the panel between the header, the body and the actions with a
   * hairline instead of separating them with space. Worth turning on the moment
   * the body scrolls: the lines are what say the header stayed put.
   * @default false
   */
  dividers?: boolean;
  /**
   * Shows the × in the corner. On in `overlay` mode, where the panel has taken
   * the page and the way out should not have to be remembered; off in `inline`
   * mode, where a × that closes a fixed sidebar with nothing to reopen it is a
   * one-way door.
   */
  showClose?: boolean;
  /** Accessible name of the × button. Never drawn. @default 'Close' */
  closeLabel?: string;
  /**
   * How far the panel reaches in from its edge: a **width** for `left` and
   * `right`, a **height** for `top` and `bottom`. Numbers are pixels.
   *
   * Left alone, a side panel takes the width its `size` implies and a top or
   * bottom panel is as tall as what is in it, up to 85% of the window.
   */
  extent?: number | string;
  /**
   * Rounds the two corners on the edge that faces the page — the top and bottom
   * of a side panel, the inner pair of a top or bottom one. The corners against
   * the window edge are always square, because a corner cut off something that
   * has no visible end is a corner cut off nothing.
   * @default true
   */
  rounded?: boolean;
  /**
   * Whether the page behind is taken away. `'trap-focus'` keeps the page
   * scrollable and clickable while still holding focus inside. `overlay` only.
   * @default true
   */
  modal?: boolean | 'trap-focus';
  /**
   * Whether pressing Escape or clicking the scrim closes the drawer. Turn it off
   * for the drawer that has to be answered — and then give it actions that
   * answer it, because there will be no other way out. `overlay` only.
   * @default true
   */
  dismissible?: boolean;
  /**
   * Keeps the drawer's content in the document while it is closed, hidden, out
   * of the focus order and off the accessibility tree, rather than taking it
   * out. `overlay` only.
   *
   * For a drawer that holds a site's navigation. A closed drawer is otherwise
   * not in the document, and neither are its links — which is what a search
   * engine finds on a phone, where the navigation is a drawer nobody has
   * opened. Off by default, because a drawer's content is usually work that
   * only needs doing once somebody opens it.
   * @default false
   */
  keepMounted?: boolean;
  /** The body. */
  children?: React.ReactNode;
}

export type PlDrawerCloseProps = React.ComponentPropsWithoutRef<typeof BaseUIDialog.Close>;

/**
 * How wide a `left` or `right` panel is when nothing says otherwise.
 *
 * Its own ladder rather than `PlModal`'s `maxWidth`, and deliberately narrower
 * at every step: a modal is measured by how long a line of text is comfortable
 * inside it, and a drawer is measured by how much of the window it is willing
 * to take away from what it is a drawer *for*.
 *
 * A `top` or `bottom` panel has no entry here on purpose — its extent is its
 * content, capped at 85% of the window, because a bottom sheet holding three
 * rows should be three rows tall.
 */
const extentClasses: Record<PlassSize, string> = {
  xs: 'w-56',
  sm: 'w-64',
  md: 'w-80',
  lg: 'w-96',
  xl: 'w-[28rem]'
};

/**
 * The corners on the free edge, written out per side and per step because
 * Tailwind only ever sees class names that appear literally in the source.
 */
const roundedClasses: Record<PlassSide, Record<PlassSize, string>> = {
  left: {
    xs: 'rounded-r-(--plass-radius-xs)',
    sm: 'rounded-r-(--plass-radius-sm)',
    md: 'rounded-r-(--plass-radius-md)',
    lg: 'rounded-r-(--plass-radius-lg)',
    xl: 'rounded-r-(--plass-radius-xl)'
  },
  right: {
    xs: 'rounded-l-(--plass-radius-xs)',
    sm: 'rounded-l-(--plass-radius-sm)',
    md: 'rounded-l-(--plass-radius-md)',
    lg: 'rounded-l-(--plass-radius-lg)',
    xl: 'rounded-l-(--plass-radius-xl)'
  },
  top: {
    xs: 'rounded-b-(--plass-radius-xs)',
    sm: 'rounded-b-(--plass-radius-sm)',
    md: 'rounded-b-(--plass-radius-md)',
    lg: 'rounded-b-(--plass-radius-lg)',
    xl: 'rounded-b-(--plass-radius-xl)'
  },
  bottom: {
    xs: 'rounded-t-(--plass-radius-xs)',
    sm: 'rounded-t-(--plass-radius-sm)',
    md: 'rounded-t-(--plass-radius-md)',
    lg: 'rounded-t-(--plass-radius-lg)',
    xl: 'rounded-t-(--plass-radius-xl)'
  }
};

/**
 * The hairline on the free edge only. A border all round would draw a line
 * along the window's own edge, where there is nothing on the other side of it
 * to be separated from.
 */
const edgeClasses: Record<PlassSide, string> = {
  left: 'border-r',
  right: 'border-l',
  top: 'border-b',
  bottom: 'border-t'
};

/** Which end of the viewport the panel is pushed to, and along which axis. */
const viewportClasses: Record<PlassSide, string> = {
  left: 'flex-row justify-start',
  right: 'flex-row justify-end',
  top: 'flex-col justify-start',
  bottom: 'flex-col justify-end'
};

/**
 * The sheet.
 *
 * Opacity only, exactly as on `PlModal`. A drawer that slid in would be
 * dragging its own text across the screen for the length of the transition, and
 * a panel is nothing but text and controls — this is the case the no-transform
 * rule was written for, not the exception to it. What says the panel came from
 * an edge is that it is *attached* to one: square against the window, cut on the
 * free side.
 */
const panelClasses = /* @__PURE__ */ [
  glassClasses,
  'relative flex flex-col overflow-hidden',
  'text-(--plass-fg) bg-(--plass-glass-press)',
  '[border-color:var(--plass-glass-line)]',
  '[outline:none]'
].join(' ');

const overlayShadowClasses = '[box-shadow:var(--plass-shadow-4),var(--plass-gloss-glass)]';
const inlineShadowClasses = '[box-shadow:var(--plass-gloss-glass)]';

/**
 * The slow duration, shared by the panel and the scrim so the two arrive as one
 * thing. A drawer takes the page the way a modal does, and the control duration
 * on a surface that size is a cut with a hint of blur on it rather than a fade.
 */
const fadeClasses = /* @__PURE__ */ [
  '[transition:opacity_var(--plass-duration-slow)_var(--plass-ease)]',
  'motion-reduce:[transition-duration:0ms]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const backdropClasses = /* @__PURE__ */ [
  'fixed inset-0 z-(--plass-z-portal) bg-(--plass-scrim)',
  '[backdrop-filter:var(--plass-scrim-blur)] [-webkit-backdrop-filter:var(--plass-scrim-blur)]',
  fadeClasses
].join(' ');

/** What keeps a closed drawer's parts out of sight when `keepMounted` keeps them. */
const keptClasses = '[&[hidden]]:hidden';

/** The × in the corner, shared by both modes. */
const closeButtonClasses = /* @__PURE__ */ [
  targetClasses,
  'flex size-[1.6em] shrink-0 cursor-pointer items-center justify-center',
  'rounded-full text-(--plass-muted-fg)',
  '[&_svg]:size-[1.1em] [&_svg]:shrink-0',
  '[transition:background-color_var(--plass-duration)_var(--plass-ease),color_var(--plass-duration)_var(--plass-ease)]',
  'motion-reduce:[transition-duration:0ms]',
  'hover:bg-(--p-soft) hover:text-(--plass-fg)',
  focusRingClasses
].join(' ');

/**
 * Closes the drawer it is inside.
 *
 * Exported for `PlModalClose`'s reason: an uncontrolled drawer has no `setOpen`
 * for its Cancel button to call. It is an `overlay` drawer's button — an
 * `inline` drawer is not a Base UI dialog and has nothing for this to talk to.
 *
 * `render` is Base UI's own escape hatch, so a real Plass button dismisses:
 * `<PlDrawerClose render={<PlButton variant="ghost">Cancel</PlButton>} />`.
 */
export const PlDrawerClose = BaseUIDialog.Close;

/**
 * A panel attached to one edge of the window.
 *
 * Two things in one component, because they are the same panel: `overlay` is the
 * drawer you open — a scrim, a focus trap, Escape — and `inline` is the drawer
 * that is simply part of the page. Everything else about them is identical,
 * which is exactly why they should not be two components a caller has to switch
 * between when a sidebar becomes a hamburger at a breakpoint.
 *
 * The sections are props rather than compound sub-components, as on `PlCard` and
 * `PlModal`: the arrangement is fixed — heading, description, body, actions —
 * and what a caller wants to decide is what goes in each slot. The body is the
 * only part that scrolls, so the heading and the actions stay put.
 *
 * In `overlay` mode Base UI owns everything hard about it: the focus trap, the
 * scroll lock, the `aria-labelledby` / `aria-describedby` wiring, restoring
 * focus to the trigger, and the inert page behind.
 */
export function PlDrawer({
  side = 'left',
  mode = 'overlay',
  size: sizeProp,
  color: colorProp,
  density: densityProp,
  open,
  defaultOpen,
  onOpenChange,
  trigger,
  title,
  headingLevel: headingLevelProp = 2,
  description,
  actions,
  dividers = false,
  showClose,
  closeLabel: closeLabelProp,
  extent,
  rounded = true,
  modal = true,
  dismissible = true,
  keepMounted = false,
  className,
  classNames,
  style,
  children,
  ...props
}: PlDrawerProps) {
  const defaults = useDefaults();
  const labels = useLabels();
  const closeLabel = closeLabelProp ?? labels.close;
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const overlay = mode === 'overlay';
  const along = side === 'left' || side === 'right';
  const showCloseButton = showClose ?? overlay;

  // Base UI keeps an overlay drawer's open state. An inline one is not a Base UI
  // dialog, so it keeps its own for the × to close when no `open` is passed.
  const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? true);

  const insetX = sheetPaddingXClasses[density][size];
  const insetY = sheetPaddingYClasses[density][size];
  // With dividers the lines have to reach both edges, so the sheet gives up its
  // padding and every section takes it on instead — the same trade PlCard makes.
  const sectionClasses = dividers ? `${insetX} ${insetY}` : insetX;

  const hasHeader = hasContent(title) || hasContent(description);
  const hasActions = hasContent(actions);

  const sizeStyle =
    extent === undefined
      ? null
      : { [along ? 'width' : 'height']: typeof extent === 'number' ? `${extent}px` : extent };

  const panel = cx(
    panelClasses,
    sheetBodyClasses[size],
    edgeClasses[side],
    rounded ? roundedClasses[side][size] : '',
    overlay ? overlayShadowClasses : inlineShadowClasses,
    overlay ? fadeClasses : '',
    along
      ? `h-full max-w-full ${extent === undefined ? extentClasses[size] : ''}`
      : `w-full ${extent === undefined ? 'max-h-[85%]' : ''}`,
    dividers ? '' : `${insetY} ${sheetSectionGapClasses[size]}`,
    className
  );

  // The type keeps a TypeScript caller inside the six; this keeps a JavaScript
  // one there too, where a `7` would have written an `<h7>`, which is no
  // heading at all.
  const Heading = `h${
    Number.isInteger(headingLevelProp) && headingLevelProp >= 1 && headingLevelProp <= 6
      ? headingLevelProp
      : 2
  }` as const;

  // Base UI's parts carry the `aria-labelledby` / `aria-describedby` wiring an
  // overlay drawer needs. An inline one is not a dialog and needs none, so it
  // gets the plain tags rather than a dialog's parts outside a dialog.
  const DescriptionTag = overlay ? BaseUIDialog.Description : 'p';

  const contents = (
    <>
      {hasHeader || showCloseButton ? (
        <div className={cx('flex shrink-0 items-start gap-3', sectionClasses)}>
          <div className={cx('flex min-w-0 flex-1 flex-col', sheetHeaderGapClasses[size])}>
            {hasContent(title) ? (
              overlay ? (
                // Base UI's title draws an `<h2>`. Through `render` it draws
                // the level asked for, and keeps the id the dialog is
                // labelled by.
                <BaseUIDialog.Title
                  render={<Heading />}
                  className={cx('m-0 font-semibold', sheetTitleClasses[size])}
                >
                  {title}
                </BaseUIDialog.Title>
              ) : (
                <Heading className={cx('m-0 font-semibold', sheetTitleClasses[size])}>
                  {title}
                </Heading>
              )
            ) : null}
            {hasContent(description) ? (
              <DescriptionTag className={cx('m-0 text-(--plass-muted-fg)', metaTextClasses[size])}>
                {description}
              </DescriptionTag>
            ) : null}
          </div>

          {showCloseButton ? (
            overlay ? (
              <BaseUIDialog.Close aria-label={closeLabel} className={closeButtonClasses}>
                <CloseIcon />
              </BaseUIDialog.Close>
            ) : (
              <button
                type="button"
                aria-label={closeLabel}
                className={closeButtonClasses}
                onClick={() => {
                  if (open === undefined) {
                    setUncontrolledOpen(false);
                  }

                  onOpenChange?.(false);
                }}
              >
                <CloseIcon />
              </button>
            )
          ) : null}
        </div>
      ) : null}

      {hasContent(children) ? (
        // The only part that scrolls. `min-h-0` is what lets it: a flex item's
        // default `min-height: auto` refuses to shrink below its content, and
        // the panel would grow past the window instead.
        <div
          className={cx(
            'min-h-0 flex-1 overflow-y-auto overscroll-contain',
            sectionClasses,
            dividers && (hasHeader || showCloseButton) ? sheetLineClasses : '',
            // A scroll container clips at its padding box and a focus ring is
            // drawn outside the control that owns it, so a field at the top or
            // bottom of an unruled body would have its ring sliced off. The
            // padding is room for the ring and the negative margin hands the
            // space straight back, so nothing on the sheet moves.
            dividers ? '' : '-my-1 py-1'
          )}
        >
          {children}
        </div>
      ) : null}

      {hasActions ? (
        <div
          className={cx(
            'flex shrink-0 flex-wrap items-center justify-end gap-2',
            sectionClasses,
            dividers ? sheetLineClasses : ''
          )}
        >
          {actions}
        </div>
      ) : null}
    </>
  );

  if (!overlay) {
    // An inline drawer is in the flow, so "closed" is "not in the layout".
    // There is nothing to animate on the way out: the page around it is what
    // moves, and moving the page is not this component's to do.
    if (!(open ?? uncontrolledOpen)) {
      return null;
    }

    return (
      <div
        className={panel}
        style={{ ...surfaceSlots(color, 0), ...sizeStyle, ...style }}
        {...props}
      >
        {contents}
      </div>
    );
  }

  return (
    <BaseUIDialog.Root
      open={open}
      defaultOpen={defaultOpen}
      modal={modal}
      disablePointerDismissal={!dismissible}
      onOpenChange={(next, details) => {
        // `disablePointerDismissal` covers the click on the scrim; Escape has no
        // prop of its own, so it is cancelled here by the reason it arrives
        // with.
        if (!dismissible && !next && details.reason === 'escape-key') {
          details.cancel();

          return;
        }

        onOpenChange?.(next);
      }}
    >
      {trigger ? <BaseUIDialog.Trigger render={trigger} /> : null}

      <BaseUIDialog.Portal keepMounted={keepMounted}>
        {/* `plass-portal` is a hook, not a style: a portalled surface leaves the
            subtree a host may have scoped its CSS reset to.

            A drawer kept while closed is `hidden` by Base UI, and the `flex`
            on the viewport and the panel would otherwise outrank the
            browser's own `display: none` for it and draw the panel. */}
        <BaseUIDialog.Backdrop
          className={cx(
            'plass-portal',
            backdropClasses,
            keepMounted ? keptClasses : '',
            classNames?.backdrop
          )}
        />

        <BaseUIDialog.Viewport
          className={cx(
            'plass-portal fixed inset-0 z-(--plass-z-portal) flex',
            viewportClasses[side],
            keepMounted ? keptClasses : ''
          )}
        >
          <BaseUIDialog.Popup
            className={cx(panel, keepMounted ? keptClasses : '')}
            style={{ ...surfaceSlots(color, 3), ...sizeStyle, ...style }}
            {...props}
          >
            {contents}
          </BaseUIDialog.Popup>
        </BaseUIDialog.Viewport>
      </BaseUIDialog.Portal>
    </BaseUIDialog.Root>
  );
}
