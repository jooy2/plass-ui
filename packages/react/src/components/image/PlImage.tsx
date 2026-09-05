'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { PlSkeleton } from '../skeleton/PlSkeleton.js';
import { cx, focusRingClasses, radiusClasses, transitionClasses } from '../../internal/styles.js';
import type { PlassColor, PlassSize } from '../../types.js';

/** How the picture is fitted to the box. `object-fit`'s own words. */
export type PlImageFit = 'cover' | 'contain' | 'fill' | 'none';

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
  /** @default 'cover' */
  fit?: PlImageFit;
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
   * What is drawn while the picture is loading. A `PlSkeleton` by default;
   * `null` draws nothing and leaves the reserved box empty.
   */
  placeholder?: React.ReactNode;
  /**
   * What is drawn when the picture does not arrive — a wrong URL, a dead host,
   * a file that is not an image.
   *
   * A muted panel with the `alt` text in it by default, which is the one thing
   * that is certainly available and certainly describes what is missing.
   */
  fallback?: React.ReactNode;
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
  /** Called when the picture has loaded, and when it has failed. */
  onStatusChange?: (status: PlImageStatus) => void;
}

/** Where the picture has got to. */
export type PlImageStatus = 'loading' | 'loaded' | 'error';

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

const fitClasses: Record<PlImageFit, string> = {
  cover: 'object-cover',
  contain: 'object-contain',
  fill: 'object-fill',
  none: 'object-none'
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
      filter,
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
      loading = 'lazy',
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const labels = useLabels();
    const previewLabel = previewLabelProp ?? labels.preview;
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';

    const [status, setStatus] = React.useState<PlImageStatus>('loading');
    const [open, setOpen] = React.useState(false);

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

    const settle = (next: PlImageStatus) => {
      if (reported.current === next) {
        return;
      }

      reported.current = next;
      setStatus(next);
      onStatusChange?.(next);
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
        settle(node.naturalWidth > 0 ? 'loaded' : 'error');

        return;
      }

      // A new `src` starts again. Without this a second picture would inherit
      // the first one's `loaded` and be shown before it had arrived.
      reported.current = 'loading';
      setStatus('loading');
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

    const picture = (
      <img
        ref={setImgRef}
        src={src}
        alt={alt}
        loading={loading}
        onLoad={() => settle('loaded')}
        onError={() => settle('error')}
        // A slot rather than `filter` itself, so a caller's own rule — a
        // gallery tile dimming what is under the pointer — can still reach it.
        style={
          filterChain === undefined
            ? undefined
            : ({ '--p-filter': filterChain } as React.CSSProperties)
        }
        className={cx(
          'block size-full',
          fitClasses[fit],
          // `filter` is already on the house transition, so a treatment swapped
          // on hover travels at the same pace as the picture's own fade instead
          // of snapping while the fade is still moving.
          filterChain === undefined ? '' : '[filter:var(--p-filter,none)]',
          transitionClasses,
          // Hidden rather than unmounted: an `<img>` that is not in the document
          // never loads, so unmounting it while it loads is a picture that never
          // arrives.
          status === 'loaded' ? 'opacity-100' : 'opacity-0',
          status === 'error' ? 'hidden' : ''
        )}
        {...props}
      />
    );

    const body = (
      <>
        {picture}

        {status === 'loading' ? (
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
              placeholder
            )}
          </span>
        ) : null}

        {status === 'error' ? (
          <span className="absolute inset-0 flex items-center justify-center bg-(--plass-glass-press) p-3 text-center text-[0.8125rem] text-(--plass-muted-fg)">
            {fallback ?? alt}
          </span>
        ) : null}
      </>
    );

    const boxClasses = cx('relative block overflow-hidden', radius, className);
    const boxStyle: React.CSSProperties = { aspectRatio: ratio, ...style };

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
          className={cx(boxClasses, 'cursor-zoom-in p-0', focusRingClasses)}
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
          />
        </React.Suspense>
      </>
    );
  }
);
