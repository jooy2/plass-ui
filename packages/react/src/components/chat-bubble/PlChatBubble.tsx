'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { CheckIcon, ClockIcon, LinkIcon, severityIcon } from '../../internal/icons.js';
import {
  controlSlots,
  focusRingClasses,
  glassClasses,
  hasContent,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  srOnlyClasses,
  transitionClasses
} from '../../internal/styles.js';
import type {
  PlassColor,
  PlassDensity,
  PlassElevation,
  PlassSize,
  PlassVariant
} from '../../types.js';

/**
 * Whose message this is.
 *
 * `start` and `end` rather than `them`/`me` or `left`/`right`: a thread runs the
 * way the language does, and the same two words already mean this everywhere
 * else in the library. `start` is the default because a message from someone
 * else is the one you have no other way of knowing about.
 */
export type PlChatBubbleSide = 'start' | 'end';

/**
 * How far a message has got.
 *
 * The four steps are a ladder and the fifth is not on it: `failed` is the
 * message that did not go, which is why it is the only one drawn in another
 * colour family.
 */
export type PlChatBubbleStatus = 'sending' | 'sent' | 'delivered' | 'read' | 'failed';

/** What a link inside a message unfurls to. */
export interface PlChatBubbleLinkPreview {
  /** Where the card goes. */
  url: string;
  /** The page's title. */
  title?: React.ReactNode;
  /** Its summary, clamped to two lines. */
  description?: React.ReactNode;
  /** The share image, drawn across the top of the card. */
  image?: string;
  /** Who published it — a domain, a site name. */
  site?: React.ReactNode;
  /**
   * Opens the card in a new tab.
   * @default false
   */
  newTab?: boolean;
}

export interface PlChatBubbleProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'title'
> {
  /**
   * Whose message this is.
   * @default 'start'
   */
  side?: PlChatBubbleSide;
  /** Who sent it, above the bubble. */
  name?: React.ReactNode;
  /** When it was sent, beside the name. */
  time?: React.ReactNode;
  /**
   * The sender's picture — a `PlAvatar`, at the size the thread uses. Left out,
   * the bubble takes the whole row.
   */
  avatar?: React.ReactNode;
  /**
   * How far the message has got, drawn as a mark under the bubble. Left out,
   * nothing is drawn — a received message has no delivery state worth showing.
   */
  status?: PlChatBubbleStatus;
  /**
   * What the mark is read out as. Never drawn. Defaults to the English word for
   * whichever `status` is set.
   */
  statusLabel?: string;
  /**
   * Draws the three dots instead of the message. What `children` holds is left
   * alone, so the same bubble can go back to it when the message arrives.
   * @default false
   */
  typing?: boolean;
  /**
   * What the dots are read out as. Never drawn.
   * @default 'Typing…'
   */
  typingLabel?: string;
  /**
   * A picture, a video, a map — drawn edge to edge above the text, so the
   * bubble's corners crop it.
   */
  media?: React.ReactNode;
  /** A link in the message, unfurled into a card under the text. */
  preview?: PlChatBubbleLinkPreview;
  /**
   * The message's own actions — a menu trigger, most of the time. Sits beside
   * the bubble and stays out of the way until the row is hovered or something in
   * it takes focus.
   */
  actions?: React.ReactNode;
  /**
   * What the bubble's surface is made of. `solid` is the usual way to tell your
   * own messages from everyone else's; `side` deliberately does not decide this,
   * because which end is filled is a decision about the product, not about the
   * component.
   * @default 'glass'
   */
  variant?: PlassVariant;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /**
   * Padding inside the bubble, and nothing else.
   * @default 'default'
   */
  density?: PlassDensity;
  /**
   * Drop shadow depth. `0` is the default — a message lies in the thread rather
   * than floating over it.
   * @default 0
   */
  elevation?: PlassElevation;
  /** The message. */
  children?: React.ReactNode;
}

/**
 * A bubble's own padding track, tighter than a sheet's.
 *
 * A sheet is a region of a page and a bubble is a sentence with a surface behind
 * it: 20px of padding around eight words is a card, not a message. Both axes,
 * because unlike a control a bubble has no height to fight.
 */
const bubblePaddingClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: {
    xs: 'px-2 py-1',
    sm: 'px-2.5 py-1.5',
    md: 'px-3 py-2',
    lg: 'px-3.5 py-2.5',
    xl: 'px-4 py-3'
  },
  compact: {
    xs: 'px-1.5 py-0.5',
    sm: 'px-2 py-1',
    md: 'px-2.5 py-1.5',
    lg: 'px-3 py-1.5',
    xl: 'px-3.5 py-2'
  }
};

/**
 * The corner nearest the speaker is cut short.
 *
 * This is the library's one piece of chat vocabulary, and it does the job a
 * drawn tail does elsewhere: it says which end of the row the message came from,
 * without hanging a triangle off a sheet of glass that is supposed to have been
 * cut with a straight edge. Written as the logical properties rather than as
 * `rounded-tl`, so a thread in Arabic squares the other corner without being
 * told.
 *
 * A flat 4px rather than a step down the radius ladder, and that is the whole
 * point of writing it out: the ladder runs 8px to 16px, so `--plass-radius-xs`
 * against `--plass-radius-md` is a four-pixel difference nobody would ever read
 * as meaning something. The cut has to be obvious at a glance in a column of
 * forty messages or it is not saying anything.
 */
const tailClasses: Record<PlChatBubbleSide, string> = {
  start: '[border-start-start-radius:0.25rem]',
  end: '[border-start-end-radius:0.25rem]'
};

/**
 * The three materials.
 *
 * A bubble *is* the thing being coloured — unlike a `PlCard`, which holds other
 * people's content and so keeps its sheet undyed — so `solid` floods it and the
 * text switches to `--p-on-solid`. That is what makes a column of your own
 * messages read as yours at a glance rather than one line at a time.
 */
const variantClasses: Record<PlassVariant, string> = {
  solid: /* @__PURE__ */ [
    'text-(--p-on-solid) [background-image:var(--p-fill)]',
    '[box-shadow:var(--p-elev),var(--p-lift)]'
  ].join(' '),
  glass: /* @__PURE__ */ [
    glassClasses,
    'border text-(--plass-fg) bg-(--plass-glass)',
    '[border-color:var(--plass-glass-line)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost: 'text-(--plass-fg) bg-(--p-soft) [box-shadow:var(--p-elev)]'
};

/**
 * The double tick, drawn here rather than in `internal/icons` because it is the
 * one glyph in the library only one component has any use for.
 *
 * Two ticks overlapping by a third of their width, which is what says "two"
 * without doubling the width of the mark — a delivered message and a sent one
 * have to be told apart at 12px, side by side, in a column.
 */
function DoubleCheckIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m1.5 8.5 2.75 2.75L9.5 6"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M7 10.75 8.25 12l5.25-5.25"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

/** One glyph per step. `read` shares the mark with `delivered` and takes the colour. */
const statusIcons: Record<PlChatBubbleStatus, React.ReactNode> = {
  sending: <ClockIcon />,
  sent: <CheckIcon />,
  delivered: <DoubleCheckIcon />,
  read: <DoubleCheckIcon />,
  failed: /* @__PURE__ */ severityIcon('danger')
};

/**
 * What each mark is read out as. English, like every other default string in the
 * library — a page already knows its own language, and `statusLabel` is where it
 * says so.
 */
const statusLabels: Record<PlChatBubbleStatus, string> = {
  sending: 'Sending',
  sent: 'Sent',
  delivered: 'Delivered',
  read: 'Read',
  failed: 'Not delivered'
};

/**
 * Only two of the five carry a colour: the one that arrived and the one that did
 * not. The three in between are the ordinary course of events, and a thread
 * where every message is marked in colour is a thread where the colour has
 * stopped meaning anything.
 */
const statusToneClasses: Record<PlChatBubbleStatus, string> = {
  sending: 'text-(--plass-muted-fg)',
  sent: 'text-(--plass-muted-fg)',
  delivered: 'text-(--plass-muted-fg)',
  read: 'text-(--p-accent)',
  failed: 'text-(--plass-danger-accent)'
};

/**
 * The card a link unfurls into.
 *
 * Its surface is mixed out of `currentColor` rather than out of a token, because
 * it is the one part of a bubble that has to work on both a filled surface and a
 * bare one: on `solid` the text is white and the card is a white wash, on
 * `glass` the text is the page's ink and the card is a grey one. A fixed token
 * would be invisible against one of the two.
 */
const previewSurfaceClasses = /* @__PURE__ */ [
  'block overflow-hidden rounded-(--plass-radius-sm) border no-underline',
  '[border-color:color-mix(in_oklab,currentColor_18%,transparent)]',
  '[background-color:color-mix(in_oklab,currentColor_7%,transparent)]',
  'hover:[background-color:color-mix(in_oklab,currentColor_12%,transparent)]',
  '[transition-property:background-color] [transition-duration:var(--plass-duration)]',
  '[transition-timing-function:var(--plass-ease)]',
  focusRingClasses
].join(' ');

/**
 * The affordance stays out of the way of the message until the row is reached
 * for — the same allowance a chip's × takes, and for the same reason: this is
 * not a control changing what it is, it is a handle that would otherwise sit in
 * the middle of a conversation being read.
 *
 * A pointer that cannot hover has nothing to reveal it, so it is simply always
 * there on touch.
 */
const actionsClasses = /* @__PURE__ */ [
  'shrink-0 opacity-0',
  '[transition:opacity_var(--plass-duration)_var(--plass-ease)]',
  'group-hover/bubble:opacity-100 group-focus-within/bubble:opacity-100',
  '[@media(hover:none)]:opacity-100'
].join(' ');

/**
 * One message in a conversation.
 *
 * Everything around the bubble is optional and nothing about it is fixed by
 * `side`: the avatar, the sender's name, the time, the delivery mark, the media
 * above the text and the link card below it are each drawn only when they are
 * given something. What `side` decides is which way the row runs and which
 * corner of the sheet is cut short.
 *
 * `variant` is what tells your own messages from everyone else's, and it is
 * deliberately not tied to `side` — filling the right-hand column is a
 * convention, not a law, and a thread that fills neither is a perfectly good
 * thread.
 */
export const PlChatBubble = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlChatBubbleProps>(
  function PlChatBubble(
    {
      side = 'start',
      name,
      time,
      avatar,
      status,
      statusLabel,
      typing = false,
      typingLabel: typingLabelProp,
      media,
      preview,
      actions,
      variant = 'glass',
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      elevation = 0,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const labels = useLabels();
    const typingLabel = typingLabelProp ?? labels.typing;
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    const end = side === 'end';

    const hasHeader = hasContent(name) || hasContent(time);
    const hasBody = typing || hasContent(children) || Boolean(preview);

    const bubbleClasses = [
      'flex min-w-0 flex-col overflow-hidden',
      radiusClasses[size],
      tailClasses[side],
      variantClasses[variant],
      transitionClasses
    ].join(' ');

    return (
      <div
        ref={ref}
        className={[
          'group/bubble flex w-full items-start gap-2',
          end ? 'flex-row-reverse' : '',
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        style={{ ...controlSlots(color, elevation, variant), ...style }}
        {...props}
      >
        {hasContent(avatar) ? <div className="shrink-0">{avatar}</div> : null}

        <div
          className={[
            'flex max-w-[min(100%,32rem)] min-w-0 flex-col',
            sheetHeaderGapClasses[size],
            end ? 'items-end' : 'items-start'
          ].join(' ')}
        >
          {hasHeader ? (
            <div className={`flex items-baseline gap-2 ${metaTextClasses[size]}`}>
              {hasContent(name) ? <span className="font-semibold">{name}</span> : null}
              {hasContent(time) ? <span className="text-(--plass-muted-fg)">{time}</span> : null}
            </div>
          ) : null}

          <div className={`flex min-w-0 items-center gap-1 ${end ? 'flex-row-reverse' : ''}`}>
            <div className={bubbleClasses}>
              {/* Edge to edge: the bubble's own corners are what crop it, which
                  is why the padding lives on the sections rather than on the
                  sheet. */}
              {hasContent(media) ? (
                <div className="[&_img]:block [&_img]:w-full [&_video]:block [&_video]:w-full">
                  {media}
                </div>
              ) : null}

              {hasBody ? (
                <div
                  className={[
                    bubblePaddingClasses[density][size],
                    'flex min-w-0 flex-col gap-2',
                    sheetBodyClasses[size]
                  ].join(' ')}
                >
                  {typing ? (
                    <TypingDots label={typingLabel} />
                  ) : hasContent(children) ? (
                    <div className="min-w-0 break-words whitespace-pre-line">{children}</div>
                  ) : null}

                  {preview ? <LinkPreview preview={preview} /> : null}
                </div>
              ) : null}
            </div>

            {hasContent(actions) ? <div className={actionsClasses}>{actions}</div> : null}
          </div>

          {status ? (
            <div
              className={[
                'flex items-center gap-1',
                metaTextClasses[size],
                statusToneClasses[status],
                '[&_svg]:size-[1.15em] [&_svg]:shrink-0'
              ].join(' ')}
            >
              {statusIcons[status]}
              {/* The mark is the whole of what is drawn; the word behind it is
                  for the readers the mark says nothing to. */}
              <span className={srOnlyClasses}>{statusLabel ?? statusLabels[status]}</span>
            </div>
          ) : null}
        </div>
      </div>
    );
  }
);

/**
 * Three dots that light in sequence.
 *
 * Colour only, like every other indeterminate indicator in the library — the
 * dots never move, so a bubble that is being typed into does not bounce in a
 * thread somebody is reading. The delay is carried per dot in `--p-i`.
 */
function TypingDots({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-1 py-[0.35em]" role="status">
      {[0, 1, 2].map((index) => (
        <span
          key={index}
          aria-hidden="true"
          className="plass-typing-dot size-[0.45em] rounded-full"
          style={{ '--p-i': index } as React.CSSProperties}
        />
      ))}
      <span className={srOnlyClasses}>{label}</span>
    </div>
  );
}

/** The unfurled link: an image, who published it, a title and two lines of summary. */
function LinkPreview({ preview }: { preview: PlChatBubbleLinkPreview }) {
  const { url, title, description, image, site, newTab = false } = preview;

  return (
    <a
      href={url}
      target={newTab ? '_blank' : undefined}
      rel={newTab ? 'noopener noreferrer' : undefined}
      className={previewSurfaceClasses}
    >
      {image ? (
        // Decorative: everything the picture is saying is written underneath it.
        <img src={image} alt="" className="block h-28 w-full object-cover" />
      ) : null}
      <div className="flex flex-col gap-0.5 p-2">
        {hasContent(site) ? (
          <span className="flex items-center gap-1 text-[0.85em] opacity-70 [&_svg]:size-[1em] [&_svg]:shrink-0">
            <LinkIcon />
            <span className="truncate">{site}</span>
          </span>
        ) : null}
        {hasContent(title) ? <span className="font-semibold">{title}</span> : null}
        {hasContent(description) ? (
          <span className="line-clamp-2 text-[0.9em] opacity-80">{description}</span>
        ) : null}
      </div>
    </a>
  );
}
