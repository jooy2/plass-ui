'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { PlSkeleton } from '../skeleton/PlSkeleton.js';
import { PlassWatermark } from '../../internal/watermark.js';
import {
  isSideways,
  layerStyle,
  objectPosition,
  poseStyle,
  quartersOf
} from '../../internal/image.js';
import type { PlassImageFlip } from '../../internal/image.js';
import { cx, focusRingClasses, radiusClasses, transitionClasses } from '../../internal/styles.js';
import type { PlassColor, PlassSide, PlassSize } from '../../types.js';
import type { PlassWatermarkOptions, PlassWatermarkPlacement } from '../../internal/watermark.js';

/** Where a watermark sits on the picture. */
export type PlImageWatermarkPlacement = PlassWatermarkPlacement;

/** A mark laid over the picture. A bare string is the text, in the usual corner. */
export type PlImageWatermark = PlassWatermarkOptions;

/**
 * How the picture is fitted to the box. `object-fit`'s own words, and the same
 * five `PlAspectRatio` takes: `scale-down` is `contain` that never enlarges a
 * file smaller than the box.
 */
export type PlImageFit = 'cover' | 'contain' | 'fill' | 'none' | 'scale-down';

/**
 * How far the picture is turned, clockwise, in degrees.
 *
 * Quarter turns and nothing between them. A picture turned by any other angle
 * no longer covers its own box, and filling the corners that leaves means
 * enlarging it by an amount a caller would then want to tune, which is a photo
 * editor's job rather than a component's.
 */
export type PlImageRotation = 0 | 90 | 180 | 270;

/**
 * Which way the picture is mirrored, along the axes it is shown on: `horizontal`
 * swaps left and right on the screen whether or not the picture is turned.
 */
export type PlImageFlip = PlassImageFlip;

/**
 * Where the picture sits in its box, spelled the way `object-position` spells
 * it: the centre, a side, a corner, or two percentages across and down.
 *
 * Physical rather than logical, on purpose. The subject of a photograph is on
 * the same side of it in every language, so a crop that keeps it must not move
 * to the other side on a right-to-left page.
 */
export type PlImagePosition =
  | 'center'
  | PlassSide
  | 'top left'
  | 'top right'
  | 'bottom left'
  | 'bottom right'
  | `${number}% ${number}%`;

/**
 * What fills the part of the box a picture leaves empty.
 *
 * `blur` is the picture itself, covering the box and blurred behind it, the way
 * a video player fills the sides of a portrait clip. Any other string is a CSS
 * `background`.
 */
export type PlImageLetterbox = 'none' | 'blur';

/**
 * A picture to stand in while the file arrives, in place of the skeleton.
 *
 * It is drawn the way the picture will be, with the same `fit`, `position`,
 * `rotate`, `flip` and `filter`, which is what it is for: a small copy of the
 * same file, a few hundred bytes as a data URI or already in memory as a
 * `Blob`, so the reader sees the picture's colours and shape before its detail.
 */
export interface PlImagePlaceholder {
  /**
   * The stand-in: a URL, a data URI or a `Blob`. A `Blob` is given an object URL
   * for as long as it is shown, and the URL is released when it is not.
   */
  src: string | Blob;
  /**
   * Blurs the stand-in, by this many pixels or by 20 for `true`. A copy
   * stretched up from a few pixels is blocky without it.
   * @default false
   */
  blur?: boolean | number;
}

/** The treatments that have a name. Anything else is written as CSS. */
export type PlImageFilter =
  'none' | 'grayscale' | 'sepia' | 'saturate' | 'desaturate' | 'contrast' | 'dim';

export interface PlImageProps extends Omit<
  React.ComponentPropsWithoutRef<'img'>,
  'color' | 'onError' | 'onLoad'
> {
  /**
   * The description a screen reader reads. **Required**, and `""` is a real
   * answer: it marks the picture decorative and takes it off the accessibility
   * tree, which is the right call for a background or a texture and the wrong
   * one for anything a reader would miss.
   */
  alt: string;
  /**
   * The proportion the box holds while the picture is on its way, written the
   * way CSS writes it — a number or `'16 / 9'`.
   *
   * This is what the component is really for. Without it the page has nothing
   * to reserve, and every image that arrives late pushes the paragraph under it
   * down the screen.
   */
  ratio?: number | string;
  /**
   * The file's own pixel dimensions, as an `<img>` takes them, or, given one at
   * a time, the size of the box.
   *
   * Together they describe the file, and the box keeps their proportion before
   * the file arrives, which is what they have always done on an `<img>`.
   *
   * One on its own is not a proportion, so it is read as the length it looks
   * like. `height={200}` is a box 200 pixels tall across the width it is given,
   * and `width={320}` is one 320 wide, never wider than its container, and as
   * tall as the picture makes it. A number or a string of digits is pixels, and
   * any other string is a CSS length. With a `ratio` as well, a lone `height`
   * takes its width from the ratio. `fit` decides what the picture does inside.
   *
   * They reach the `<img>` either way.
   */
  width?: number | string;
  height?: number | string;
  /**
   * How the picture fills its box.
   * @default 'cover'
   */
  fit?: PlImageFit;
  /**
   * Where the picture sits in its box: which part of it a `cover` crop keeps,
   * and where `contain`, `none` and `scale-down` leave their empty space.
   *
   * Read on the picture as it is shown, so it holds through `rotate` and
   * `flip`: `position="top"` keeps the top of what the reader sees rather than
   * the top of the file. Anything else `object-position` accepts is passed
   * through as written, without that conversion.
   * @default 'center'
   */
  position?: PlImagePosition | (string & {});
  /**
   * What fills the box where `contain`, `none` or `scale-down` leave it empty:
   * `blur` for the picture itself, blurred and covering the box behind it, or
   * any CSS `background` — a colour, a token, a gradient.
   *
   * The blurred copy loads from exactly what the picture loads from, so it is
   * the same request rather than a second one, and it is drawn only under a
   * `fit` that can leave space. It is hidden from the accessibility tree and
   * takes no pointer.
   * @default 'none'
   */
  letterbox?: PlImageLetterbox | (string & {});
  /**
   * Turns the picture clockwise, a quarter at a time.
   *
   * A picture on its side is laid out on its side. `width` and `height` still
   * describe the file, so `width={1200} height={800} rotate={90}` reserves a box
   * two wide by three tall, and a picture with neither takes the turned shape
   * once the file has said what it is. A `ratio` is the layout's and is kept,
   * with `fit` deciding how the turned picture fills it.
   *
   * Drawn with CSS's own `rotate` property rather than a `transform`, which
   * stays free for a hover effect or a class of your own.
   * @default 0
   */
  rotate?: PlImageRotation;
  /**
   * Mirrors the picture, along the axes it is shown on.
   *
   * `horizontal` swaps left and right on the screen and `vertical` swaps top
   * and bottom, whichever way `rotate` has turned the picture. Drawn with CSS's
   * own `scale` property, so `transform` stays free.
   * @default 'none'
   */
  flip?: PlImageFlip;
  /**
   * A treatment laid over the picture: one of the named ones, or any CSS
   * `filter` chain of your own — `'blur(2px) hue-rotate(20deg)'` is as valid a
   * value as `'sepia'`.
   *
   * It rides the same transition as the picture's own fade, so a caller who
   * swaps the filter on hover gets a change that travels rather than one that
   * snaps.
   */
  filter?: PlImageFilter | (string & {});
  /** Rounds the corners to the `size` step of the house ladder. @default false */
  rounded?: boolean;
  /** Which step of the radius ladder `rounded` uses. @default 'md' */
  size?: PlassSize;
  /** The family the skeleton and the focus ring take. @default 'primary' */
  color?: PlassColor;
  /**
   * What is drawn while the picture is loading. A `PlSkeleton` by default, a
   * node of your own, `{ src }` for a picture to stand in, or `null` for nothing
   * at all.
   *
   * A picture stand-in is a small copy of the same file, as a URL or a `Blob`.
   * It is drawn under the picture and stays until the picture has finished
   * fading in over it. Like the skeleton it fills the box, so it needs a box to
   * fill: a `ratio`, or both `width` and `height`.
   */
  placeholder?: React.ReactNode | PlImagePlaceholder;
  /**
   * What is drawn when the picture does not arrive — a wrong URL, a dead host,
   * a file that is not an image.
   *
   * A muted panel with the `alt` text in it by default, which is the one thing
   * that is certainly available and certainly describes what is missing.
   */
  fallback?: React.ReactNode;
  /**
   * A mark laid over the picture — a bare string for one in the bottom corner,
   * or an object to say where it goes, how visible it is, and at what angle.
   *
   * `placement: 'tile'` covers the whole picture instead, which is the one a
   * proof or a preview wants: a mark in a corner is cropped off in a second.
   *
   * It is drawn only once the picture has arrived, and it is `aria-hidden` and
   * takes no pointer. A watermark is a claim about the file, not something the
   * page is telling a reader — `alt` is where a picture says what it is.
   */
  watermark?: string | PlImageWatermark;
  /**
   * Makes the picture awkward to take: no context menu, no drag out of the
   * page, no text selection over it, and no long-press callout on iOS.
   *
   * **It is a deterrent and not a lock.** The file is still one request away —
   * it is in the network tab, it is in the cache, and a screenshot needs none of
   * that. What this stops is the casual right-click-and-save, which for most
   * pictures is the whole of what was wanted. Anything that genuinely must not
   * be copied does not belong on the page.
   * @default false
   */
  protect?: boolean;
  /**
   * Opens the picture over the page when it is pressed.
   *
   * Off by default. A picture that grows when you click it is a promise that
   * there is more of it to see, and most pictures on a page are not making it.
   * @default false
   */
  preview?: boolean;
  /** The accessible name of the preview overlay. @default 'Preview' */
  previewLabel?: string;
  /**
   * Marks the picture a page is judged by — usually the largest thing above the
   * fold, which is what Largest Contentful Paint measures — so it is fetched
   * early rather than lazily: `loading="eager"` and a high fetch priority.
   *
   * Everything else about when a picture loads belongs to the `<img>` and
   * passes straight through: `loading`, `decoding`, `fetchPriority`. An
   * attribute written out wins over what this implies.
   * @default false
   */
  priority?: boolean;
  /** Called when the picture has loaded, and when it has failed. */
  onStatusChange?: (status: PlImageStatus) => void;
}

/** Where the picture has got to. */
export type PlImageStatus = 'loading' | 'loaded' | 'error';

/** The file's own pixel dimensions, once something has said what they are. */
interface PixelSize {
  width: number;
  height: number;
}

/**
 * Where the picture has got to, and what it turned out to be.
 *
 * One value rather than two, so a picture arriving is still one render: the
 * size is only ever learned at the moment the status changes.
 */
interface PictureState {
  status: PlImageStatus;
  natural: PixelSize | null;
}

/**
 * The file two `<img>` dimensions describe, or `null` where they do not.
 *
 * They arrive as `number | string` because that is what the attribute takes, so
 * `'1200'` counts and `'50%'` does not. A percentage is a length and says
 * nothing about the file, and one dimension without the other says nothing
 * about its shape.
 */
function pixelSize(width?: number | string, height?: number | string): PixelSize | null {
  const w = Number(width);
  const h = Number(height);

  return width !== undefined && height !== undefined && w > 0 && h > 0
    ? { width: w, height: h }
    : null;
}

/**
 * A lone `width` or `height` as the length it sizes the box to.
 *
 * A number is pixels, and so is a string of digits, which is how the attribute
 * is written in markup. Anything else is already a CSS length and is used as
 * written.
 */
function boxLength(value: number | string): string {
  return typeof value === 'number' || /^\d+(\.\d+)?$/.test(value.trim())
    ? `${Number(value)}px`
    : value;
}

/** What a settled `<img>` says it is, or `null` for a file that did not arrive. */
function naturalSize(node: HTMLImageElement | null): PixelSize | null {
  return node !== null && node.naturalWidth > 0
    ? { width: node.naturalWidth, height: node.naturalHeight }
    : null;
}

/**
 * How far a blurred letterbox is blurred, in pixels. The copy is grown past the
 * box by two of these on every side, which is about where a blur has finished
 * fading its edge out.
 */
const LETTERBOX_BLUR = 24;

/**
 * The spelling React accepts for the `fetchpriority` attribute.
 *
 * React 19 knows it as `fetchPriority` and warns about the lower-case form.
 * React 18 does not know it at all, and warns about the camel-case form while
 * writing the attribute anyway. The attribute is the same either way, so this
 * only decides which of the two supported versions stays quiet.
 */
const FETCH_PRIORITY = Number.parseInt(React.version, 10) >= 19 ? 'fetchPriority' : 'fetchpriority';

/** How far a picture stand-in with `blur: true` is blurred, in pixels. */
const PLACEHOLDER_BLUR = 20;

/** Whether a placeholder is a picture to draw rather than a node to render. */
function isPicturePlaceholder(
  placeholder: React.ReactNode | PlImagePlaceholder
): placeholder is PlImagePlaceholder {
  return (
    typeof placeholder === 'object' &&
    placeholder !== null &&
    !React.isValidElement(placeholder) &&
    'src' in placeholder
  );
}

/**
 * A URL for a stand-in, whichever of the two forms it was given in.
 *
 * A `Blob` becomes an object URL in an effect rather than during the render. An
 * object URL is held by the document until it is revoked, and a render React
 * throws away would leave one behind with nothing to release it. The price is a
 * stand-in that appears a frame after its box, which is still sooner than any
 * file it stands in for.
 */
function useStandInUrl(source: string | Blob | undefined): string | undefined {
  // Kept with the Blob it was made from, so the next Blob is never handed the
  // last one's URL in the render before the effect has caught up.
  const [made, setMade] = React.useState<{ blob: Blob; url: string } | null>(null);

  React.useEffect(() => {
    if (typeof Blob === 'undefined' || !(source instanceof Blob)) {
      return undefined;
    }

    const url = URL.createObjectURL(source);

    // The object URL is the external system here: it is allocated in the one
    // place that can release it, and the state only carries it to the render.
    // It runs once per Blob rather than cascading.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMade({ blob: source, url });

    return () => URL.revokeObjectURL(url);
  }, [source]);

  if (typeof source === 'string') {
    return source;
  }

  return made !== null && made.blob === source ? made.url : undefined;
}

/**
 * What each named treatment is, as the CSS it stands for.
 *
 * Six names rather than a dial per effect. A picture is either being held back
 * from the page around it or it is not, and a component library that shipped
 * `saturation={1.35}` would be asking every caller to invent the same number.
 * The escape hatch is the whole of the rest: any other string is a `filter`
 * chain and is passed through untouched.
 */
const filterChains: Record<PlImageFilter, string> = {
  none: 'none',
  grayscale: 'grayscale(1)',
  sepia: 'sepia(0.72)',
  saturate: 'saturate(1.35)',
  desaturate: 'saturate(0.45)',
  contrast: 'contrast(1.2)',
  dim: 'brightness(0.82)'
};

/**
 * The four ways a picture is casually taken, refused.
 *
 * `-webkit-touch-callout` is the one that is easy to forget and the one that
 * matters most: on iOS a long press is the whole context menu, and a picture
 * that refuses the right-click on a desktop and offers Save on a phone has not
 * refused anything.
 */
const protectHandlers = {
  draggable: false,
  onDragStart: (event: React.DragEvent) => event.preventDefault(),
  onContextMenu: (event: React.MouseEvent) => event.preventDefault()
} as const;

const fitClasses: Record<PlImageFit, string> = {
  cover: 'object-cover',
  contain: 'object-contain',
  fill: 'object-fill',
  none: 'object-none',
  'scale-down': 'object-scale-down'
};

/**
 * The overlay a `preview` opens, which is a download of its own.
 *
 * `preview` is off by default and a lightbox is several times the weight of the
 * picture component that opens it, so a page drawing a wall of thumbnails should
 * not be carrying one. Behind `React.lazy` the chunk is fetched after the first
 * paint by the pages that ask for a preview, and never by the pages that do not.
 */
const PlImagePreview = /* @__PURE__ */ React.lazy(() =>
  import('./PlImagePreview.js').then((module) => ({ default: module.PlImagePreview }))
);

/**
 * A picture, and the two states a picture spends most of its life in.
 *
 * An `<img>` is one tag and it works, which is the reason to say what this adds
 * rather than to assume it. Three things: the space is **reserved** before the
 * picture arrives, so the paragraph under it does not move when it does; a
 * failure is *drawn* rather than left as the browser's broken-image glyph and
 * the alt text in a serif nobody chose; and the two are one state machine, so
 * the placeholder is not still there behind a picture that has already loaded.
 *
 * `ratio` is what makes the first one work and is the prop worth reaching for
 * every time. Without it there is nothing to reserve — the box is however tall
 * the picture turns out to be, which is not known until it arrives.
 */
export const PlImage = /* @__PURE__ */ React.forwardRef<HTMLImageElement, PlImageProps>(
  function PlImage(
    {
      alt,
      src,
      ratio,
      fit = 'cover',
      position,
      letterbox = 'none',
      rotate = 0,
      flip = 'none',
      filter,
      watermark,
      protect = false,
      rounded = false,
      size: sizeProp,
      color: colorProp,
      placeholder,
      fallback,
      preview = false,
      previewLabel: previewLabelProp,
      onStatusChange,
      className,
      style,
      loading: loadingProp,
      priority = false,
      width,
      height,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const labels = useLabels();
    const previewLabel = previewLabelProp ?? labels.preview;
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';

    const [picture, setPicture] = React.useState<PictureState>({
      status: 'loading',
      natural: null
    });
    const status = picture.status;
    const [open, setOpen] = React.useState(false);

    // Lazy unless the picture is the one the page is judged by, and whatever
    // the caller wrote out if they wrote anything.
    const loading = loadingProp ?? (priority ? 'eager' : 'lazy');
    const fetchPriority = props.fetchPriority ?? (priority ? 'high' : undefined);
    // Under whichever name this React knows it by, and only when there is one.
    const fetchAttribute = (
      fetchPriority === undefined ? null : { [FETCH_PRIORITY]: fetchPriority }
    ) as React.ImgHTMLAttributes<HTMLImageElement> | null;

    const standIn = isPicturePlaceholder(placeholder) ? placeholder : null;
    const standInUrl = useStandInUrl(standIn?.src);

    const imgRef = React.useRef<HTMLImageElement | null>(null);
    const setImgRef = React.useCallback(
      (node: HTMLImageElement | null) => {
        imgRef.current = node;

        if (typeof ref === 'function') {
          ref(node);
        } else if (ref) {
          ref.current = node;
        }
      },
      [ref]
    );

    /*
     * What `onStatusChange` was last told.
     *
     * A picture can settle twice — the effect below finding it already decoded,
     * and its own `load` arriving a task later — and a caller counting loads
     * should not hear about that.
     */
    const reported = React.useRef<PlImageStatus>('loading');

    const settle = (next: PlImageStatus, node: HTMLImageElement | null) => {
      const natural = next === 'loaded' ? naturalSize(node) : null;

      // The size is compared as well as the status: a new `src` that was
      // already decoded settles as `loaded` again, and it is a different file.
      setPicture((current) =>
        current.status === next &&
        current.natural?.width === natural?.width &&
        current.natural?.height === natural?.height
          ? current
          : { status: next, natural }
      );

      if (reported.current !== next) {
        reported.current = next;
        onStatusChange?.(next);
      }
    };

    /*
     * Where the picture actually got to, asked of the element rather than waited
     * for.
     *
     * `load` is an event, and an event is only heard by somebody already
     * listening. A file that is in the cache — or that a server rendered, so the
     * browser began fetching it while parsing the HTML — can be decoded before
     * React ever attaches a handler, and then the one thing that would have
     * moved this out of `loading` has already happened. The picture stays at
     * `opacity: 0` behind its own placeholder for good.
     *
     * So the element is asked instead, on mount and whenever `src` changes.
     * `complete` says whether it has finished and `naturalWidth` says which way
     * it went, which between them is the whole state machine — with one hole to
     * step around: an `<img>` that was never given a `src` is `complete` too,
     * and it has not failed, it has not been asked for anything.
     *
     * A layout effect rather than a passive one because this runs on the frame
     * the picture is already decoded on. Left to `useEffect` the placeholder
     * gets a frame it has no business being painted for.
     */
    React.useLayoutEffect(() => {
      const node = imgRef.current;

      if (node === null) {
        return;
      }

      if (node.getAttribute('src') && node.complete) {
        settle(node.naturalWidth > 0 ? 'loaded' : 'error', node);

        return;
      }

      // A new `src` starts again. Without this a second picture would inherit
      // the first one's `loaded` and be shown before it had arrived.
      reported.current = 'loading';
      setPicture((current) =>
        current.status === 'loading' ? current : { status: 'loading', natural: null }
      );
      // `settle` closes over `onStatusChange`, which a caller is free to write
      // inline; depending on it would restart every picture on every render.
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [src]);

    const radius = rounded ? radiusClasses[size] : '';

    /*
     * A named treatment, or a chain the caller wrote. Anything that is not one
     * of the six names is CSS, which is what makes the escape hatch free: there
     * is nothing to parse and nothing to allow.
     */
    const filterChain =
      filter === undefined ? undefined : (filterChains[filter as PlImageFilter] ?? filter);

    const quarters = quartersOf(rotate);
    const sideways = isSideways(quarters);
    const pose = poseStyle(quarters, flip);
    const placed = position === undefined ? undefined : objectPosition(position, quarters, flip);

    const pictureStyle: React.CSSProperties | undefined =
      filterChain === undefined && pose === null && placed === undefined
        ? undefined
        : {
            // A slot rather than `filter` itself, so a caller's own rule — a
            // gallery tile dimming what is under the pointer — can still reach
            // it.
            ...(filterChain === undefined ? null : { '--p-filter': filterChain }),
            objectPosition: placed,
            ...pose
          };

    /*
     * The blurred letterbox, only where it can show: `cover` and `fill` leave no
     * space around the picture. It is drawn from exactly what the picture is
     * drawn from — the same candidate out of a `srcSet`, the same CORS mode —
     * so the browser answers both with one request.
     */
    const blurred = letterbox === 'blur' && fit !== 'cover' && fit !== 'fill';
    const painted = letterbox === 'none' || letterbox === 'blur' ? undefined : letterbox;
    const tint = filterChain === undefined || filterChain === 'none' ? '' : `${filterChain} `;

    const backdrop =
      blurred && status !== 'error' ? (
        <img
          src={src}
          srcSet={props.srcSet}
          sizes={props.sizes}
          loading={loading}
          decoding={props.decoding}
          crossOrigin={props.crossOrigin}
          referrerPolicy={props.referrerPolicy}
          {...fetchAttribute}
          alt=""
          aria-hidden="true"
          draggable={false}
          // No pointer, so a right-click on the empty part of the box is a
          // right-click on the box and offers nothing to save.
          className={cx(
            'pointer-events-none block object-cover select-none',
            transitionClasses,
            status === 'loaded' ? 'opacity-100' : 'opacity-0'
          )}
          style={{
            ...layerStyle(quarters, flip, LETTERBOX_BLUR * 2),
            objectPosition: placed,
            filter: `${tint}blur(${LETTERBOX_BLUR}px)`
          }}
        />
      ) : null;

    const standInBlur =
      standIn === null || !standIn.blur
        ? 0
        : standIn.blur === true
          ? PLACEHOLDER_BLUR
          : standIn.blur;

    /*
     * The picture stand-in, under the picture rather than over it. The picture
     * fades in on top of it, and it is taken away in one step once that fade has
     * run, so the two are never both half there with the page showing through.
     * Written inline, so a gallery's own transition on its pictures cannot turn
     * the step back into a cross-fade. Gone entirely on a failure, which the
     * fallback reports instead.
     */
    const standInLayer =
      standIn === null || standInUrl === undefined || status === 'error' ? null : (
        <img
          src={standInUrl}
          alt=""
          aria-hidden="true"
          draggable={false}
          className={cx('pointer-events-none block select-none', fitClasses[fit])}
          style={{
            ...layerStyle(quarters, flip, standInBlur * 2),
            objectPosition: placed,
            filter: tint === '' && standInBlur === 0 ? undefined : `${tint}blur(${standInBlur}px)`,
            ...(status === 'loaded'
              ? { opacity: 0, transition: 'opacity 0ms linear var(--plass-duration)' }
              : null)
          }}
        />
      );

    const img = (
      <img
        ref={setImgRef}
        src={src}
        alt={alt}
        loading={loading}
        width={width}
        height={height}
        onLoad={(event) => settle('loaded', event.currentTarget)}
        onError={() => settle('error', null)}
        style={pictureStyle}
        className={cx(
          'block size-full',
          fitClasses[fit],
          // `filter` is already on the house transition, so a treatment swapped
          // on hover travels at the same pace as the picture's own fade instead
          // of snapping while the fade is still moving.
          filterChain === undefined ? '' : '[filter:var(--p-filter,none)]',
          transitionClasses,
          // Positioned, so it paints over the copy under it: an absolutely
          // positioned sibling paints above a static one whatever the order.
          blurred || standInLayer !== null ? 'relative' : '',
          // Hidden rather than unmounted: an `<img>` that is not in the document
          // never loads, so unmounting it while it loads is a picture that never
          // arrives.
          status === 'loaded' ? 'opacity-100' : 'opacity-0',
          status === 'error' ? 'hidden' : '',
          protect ? 'select-none [-webkit-touch-callout:none]' : ''
        )}
        // Before the caller's own attributes, so one they wrote out still wins.
        {...fetchAttribute}
        {...props}
        // After the spread on purpose: a caller who asked to protect a picture
        // and then passed their own `onContextMenu` would otherwise have turned
        // the protection off without saying so.
        {...(protect ? protectHandlers : null)}
      />
    );

    const body = (
      <>
        {backdrop}
        {standInLayer}
        {img}

        {status === 'loading' && standIn === null ? (
          <span className="absolute inset-0">
            {placeholder === undefined ? (
              <PlSkeleton
                shape="rect"
                color={color}
                size={size}
                width="100%"
                height="100%"
                className={radius}
              />
            ) : (
              (placeholder as React.ReactNode)
            )}
          </span>
        ) : null}

        {status === 'error' ? (
          <span className="absolute inset-0 flex items-center justify-center bg-(--plass-glass-press) p-3 text-center text-[0.8125rem] text-(--plass-muted-fg)">
            {fallback ?? alt}
          </span>
        ) : null}

        {/* Only once there is a picture to mark. A stamp over a skeleton is a
            claim about a file that has not arrived. */}
        {watermark !== undefined && status === 'loaded' ? (
          <PlassWatermark watermark={watermark} />
        ) : null}
      </>
    );

    /*
     * The proportion the box holds.
     *
     * A `ratio` is the layout's shape and is kept whichever way the picture
     * lies. Without one, an upright picture holds the box open itself — its two
     * dimensions reserve it before it arrives, the way an `<img>`'s always
     * have. A picture on its side is out of the flow and holds nothing open, so
     * the box takes the turned shape instead: from the two dimensions if the
     * caller gave them, and from the file once it has arrived if not. Written
     * onto this box rather than by swapping it for another, which would remount
     * the picture on the frame it arrived.
     */
    const file = pixelSize(width, height) ?? picture.natural;

    /*
     * One dimension on its own is not a proportion, so it sizes the box on its
     * own axis. A lone height leaves the width to the container, unless a
     * `ratio` can say what it is; a lone width is capped at the container's,
     * the way a reset caps an `<img>`.
     */
    const loneWidth = height === undefined && width !== undefined ? boxLength(width) : undefined;
    const loneHeight = width === undefined && height !== undefined ? boxLength(height) : undefined;

    // A height that fixes the box leaves nothing for a turned file's shape to
    // decide; written anyway, it would work the width out again from it.
    const turned =
      ratio === undefined && sideways && file !== null && loneHeight === undefined
        ? `${file.height} / ${file.width}`
        : ratio;

    const boxClasses = cx('relative block overflow-hidden', radius, className);
    const boxStyle: React.CSSProperties = {
      ...(loneWidth === undefined ? null : { width: loneWidth, maxWidth: '100%' }),
      ...(loneHeight === undefined
        ? null
        : {
            height: loneHeight,
            // `auto` so the width is worked out from the ratio, which on a
            // preview's button also outranks its `w-full`.
            ...(ratio === undefined ? null : { width: 'auto', maxWidth: '100%' })
          }),
      aspectRatio: turned,
      background: painted,
      // What the turned picture's container units read. Only while it is on its
      // side: size containment changes how the box is measured, and nothing
      // else needs it.
      containerType: sideways ? 'size' : undefined,
      ...style
    };

    if (!preview) {
      return (
        <span className={boxClasses} style={boxStyle}>
          {body}
        </span>
      );
    }

    return (
      <>
        <button
          type="button"
          // Named by the picture it opens rather than by the word "Preview":
          // three previews on a page would otherwise be three buttons with the
          // same name.
          aria-label={alt ? `${alt} — ${previewLabel.toLowerCase()}` : previewLabel}
          onClick={() => setOpen(true)}
          disabled={status !== 'loaded'}
          // `w-full` because a block `<button>` still sizes itself to its
          // content, and the content is a picture sized off the box: before
          // the file arrives that is nothing, and after it is the file's own
          // width. A `ratio` could then reserve no space at all.
          className={cx(boxClasses, 'w-full cursor-zoom-in p-0', focusRingClasses)}
          style={boxStyle}
        >
          {body}
        </button>

        <React.Suspense fallback={null}>
          <PlImagePreview
            open={open}
            onOpenChange={setOpen}
            src={src}
            alt={alt}
            label={previewLabel}
            color={color}
            protect={protect}
            watermark={watermark}
            quarters={quarters}
            flip={flip}
            file={file}
          />
        </React.Suspense>
      </>
    );
  }
);
