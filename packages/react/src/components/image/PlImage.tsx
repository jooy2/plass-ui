'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { PlOverlay } from '../overlay/PlOverlay.js';
import { PlSkeleton } from '../skeleton/PlSkeleton.js';
import { cx, focusRingClasses, radiusClasses, transitionClasses } from '../../internal/styles.js';
import type { PlassColor, PlassSize } from '../../types.js';

/** How the picture is fitted to the box. `object-fit`'s own words. */
export type PlImageFit = 'cover' | 'contain' | 'fill' | 'none';

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

const fitClasses: Record<PlImageFit, string> = {
  cover: 'object-cover',
  contain: 'object-contain',
  fill: 'object-fill',
  none: 'object-none'
};

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

    // A new `src` starts again. Without this a second picture would inherit the
    // first one's `loaded`, and its own load event would be the only thing that
    // ever moved it back — which never fires for a cached image.
    React.useEffect(() => {
      setStatus('loading');
    }, [src]);

    const settle = (next: PlImageStatus) => {
      setStatus(next);
      onStatusChange?.(next);
    };

    const radius = rounded ? radiusClasses[size] : '';

    const picture = (
      <img
        ref={ref}
        src={src}
        alt={alt}
        loading={loading}
        onLoad={() => settle('loaded')}
        onError={() => settle('error')}
        className={cx(
          'block size-full',
          fitClasses[fit],
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

        <PlOverlay
          open={open}
          onOpenChange={setOpen}
          tone="glass"
          dismissible
          color={color}
          label={previewLabel}
        >
          <img src={src} alt={alt} className="max-h-[85vh] max-w-[90vw] object-contain" />
        </PlOverlay>
      </>
    );
  }
);
