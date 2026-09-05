'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  PlMockupCutout,
  defaultNotch,
  elevationFilters,
  finishSlots,
  mockupChrome,
  mockupMetrics,
  resolveOs,
  shellClasses
} from '../../internal/mockup.js';
import type {
  PlMockupBezel,
  PlMockupDevice,
  PlMockupFinish,
  PlMockupHardware,
  PlMockupNotch,
  PlMockupOrientation,
  PlMockupOs,
  PlMockupResolution
} from '../../internal/mockup.js';
import { cx, surfaceSlots } from '../../internal/styles.js';
import { usePlElementSize } from '../../hooks/usePlElementSize.js';
import type { PlassColor, PlassElevation, PlassSize } from '../../types.js';
import { useDefaults } from '../../internal/defaults.js';

export type {
  PlMockupBezel,
  PlMockupDevice,
  PlMockupFinish,
  PlMockupHardware,
  PlMockupNotch,
  PlMockupOrientation,
  PlMockupOs,
  PlMockupResolution
} from '../../internal/mockup.js';

export interface PlMockupProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Which machine this is a picture of. The one prop with no default: a mockup
   * that has not said what it is a mockup of has not said anything.
   */
  device: PlMockupDevice;
  /**
   * The system whose chrome is drawn on the screen. A desktop runs `macos`,
   * `windows` or `linux`; a tablet runs `ipados` or `android`; a phone runs `ios`
   * or `android`. Anything else falls back to the device's own default —
   * `macos`, `ipados` and `ios` respectively.
   */
  os?: PlMockupOs;
  /**
   * What holds a desktop screen up: a stand under it, or a keyboard in front of
   * it. Ignored on a tablet and a phone, which hold themselves up.
   * @default 'monitor'
   */
  hardware?: PlMockupHardware;
  /**
   * How big the device is, on a five-step ladder of real resolutions per device
   * — from a 320-wide phone to a 430-wide one, from a 1024-wide desktop to a
   * 1920-wide one.
   *
   * As on Box, `size` here does not set a height or a type scale. What it sets
   * is the resolution of the screen, which is the only thing about a device
   * there is to scale. `resolution` overrides it outright.
   * @default 'md'
   */
  size?: PlassSize;
  /**
   * The screen's logical resolution in CSS pixels, when none of the five steps
   * is the machine you mean. This is the viewport the content is laid out
   * against, not the panel's physical pixel count.
   */
  resolution?: PlMockupResolution;
  /**
   * Which way a handheld is held. Landscape turns the screen, the bezel and the
   * cut-out together. Ignored on a desktop, whose stand does not turn with it.
   * @default 'portrait'
   */
  orientation?: PlMockupOrientation;
  /**
   * How much hardware there is around the screen. `none` is not a thinner
   * bezel — it is no hardware at all, leaving the screen on its own with its
   * corners cut, which is what a mockup that only wants the viewport asks for.
   * `thick` is an older device: narrow sides, a forehead and a chin.
   * @default 'standard'
   */
  bezel?: PlMockupBezel;
  /**
   * What the hardware is made of. Fixed colours rather than theme tokens — a
   * graphite phone stays graphite on a page switched to dark.
   * @default 'graphite'
   */
  finish?: PlMockupFinish;
  /**
   * The camera cut-out. Hardware rather than chrome, so it is drawn whether or
   * not `systemUi` is on. Defaults to what the device would have: a dynamic
   * island on an iOS phone, a punch hole on an Android one, nothing anywhere
   * else.
   */
  notch?: PlMockupNotch;
  /**
   * Draws the system's own bars — a status bar and a home indicator, a menu bar
   * and a dock, a taskbar. Each one takes its own space rather than covering the
   * content, so turning it off gives the screen back to `children` rather than
   * uncovering anything.
   * @default true
   */
  systemUi?: boolean;
  /**
   * Whether content taller than the screen scrolls. Off, it is clipped, which is
   * what a still picture of a device wants.
   * @default false
   */
  scroll?: boolean;
  /**
   * What is behind the content: any CSS `background` value — a colour, a
   * gradient, a `url()`.
   * @default the page's own surface colour
   */
  wallpaper?: string;
  /**
   * The clock in the status bar or the taskbar, and the only text the chrome
   * draws. A string rather than a `Date`, because a mockup's clock is a prop of
   * the picture and reading the real one would differ between the server that
   * renders the page and the browser that hydrates it.
   * @default '9:41'
   */
  time?: string;
  /**
   * The rendered width of the whole device on the page — a number in pixels or
   * any CSS length. The device is laid out at its own resolution and then scaled
   * to whatever this comes to, so the content inside is genuinely a screen's
   * worth rather than a page's worth shrunk.
   * @default '100%'
   */
  width?: number | string;
  /**
   * The rendered height. Given on its own it decides the size and the width
   * follows the device's proportion, which is what a mockup in a row of fixed
   * height wants.
   */
  height?: number | string;
  /** Reaches the accent in the chrome — a dock's first icon, a taskbar's. */
  color?: PlassColor;
  /**
   * How far off the page the device sits. Drawn as a silhouette rather than a
   * box, so the shadow follows a lid on a neck on a foot, and it does not shrink
   * with the device.
   * @default 0
   */
  elevation?: PlassElevation;
  /** Renders something other than a `<div>`: `render={<figure />}`. */
  render?: useRender.RenderProp;
  /** What is on the screen. */
  children?: React.ReactNode;
}

/**
 * A device with a screen you can put anything on: a phone, a tablet, a monitor
 * or a laptop, with the system's own bars drawn on it.
 *
 * The screen is a viewport at the device's own resolution — a `md` phone is 390
 * by 844 CSS pixels — and the whole device is then scaled once to whatever room
 * it has been given. So the content inside is laid out against a screen rather
 * than against the page: a 390-pixel column wraps where it would wrap on a
 * phone, and the mockup can be 200 pixels wide on the page without the content
 * knowing.
 *
 * That scale is a `transform`, and it is the one place in the library where one
 * is used. The rule it is an exception to is about controls, where a scale
 * resamples a label under the pointer that is pressing it. Nothing here is
 * pressed and the scale never changes on an interaction: it is set once from the
 * space available, which is the only way to draw a 1440-pixel desktop in a
 * paragraph's width at all.
 *
 * The screen is also a container (`plass-screen`), so content inside can answer
 * to the device's width with a container query rather than to the window's.
 */
export const PlMockup = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlMockupProps>(
  function PlMockup(rawProps, ref) {
    const {
      device,
      os,
      hardware = 'monitor',
      size: sizeProp,
      resolution,
      orientation = 'portrait',
      bezel = 'standard',
      finish = 'graphite',
      notch,
      systemUi = true,
      scroll = false,
      wallpaper,
      time = '9:41',
      width,
      height,
      color: colorProp,
      elevation = 0,
      render,
      className,
      style,
      children,
      ...props
    } = rawProps;

    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';

    const system = resolveOs(device, os);
    const cutout = notch ?? defaultNotch(device, system);
    const landscape = device !== 'desktop' && orientation === 'landscape';
    const metrics = mockupMetrics({ device, size, resolution, orientation, bezel, hardware });
    const { screen, frame, body, stand, base } = metrics;

    const boxRef = React.useRef<HTMLDivElement | null>(null);

    /*
     * One measurement, and the reason the device cannot simply be sized in CSS:
     * the scale is a ratio between a length the stylesheet knows and a length
     * only this file knows, and there is no CSS operator that divides one by the
     * other.
     *
     * Both axes, because `height` on its own is a legitimate way to size a mockup
     * and because a caller who pins both would otherwise get a device overflowing
     * whichever one it was not scaled against.
     */
    const box = usePlElementSize(boxRef);
    const scale =
      box === null || box.width <= 0 || box.height <= 0
        ? null
        : Math.min(box.width / frame.width, box.height / frame.height);

    const setRef = React.useCallback(
      (node: HTMLDivElement | null) => {
        boxRef.current = node;

        if (typeof ref === 'function') {
          ref(node);
        } else if (ref) {
          ref.current = node;
        }
      },
      [ref]
    );

    const chrome = systemUi ? mockupChrome({ os: system, notch: cutout, landscape, time }) : {};
    const bare = bezel === 'none';

    const screenNode = (
      <div
        className="plass-mockup-screen relative flex flex-col overflow-hidden"
        style={{
          width: screen.width,
          height: screen.height,
          borderRadius: metrics.screenRadius,
          background: wallpaper ?? 'var(--plass-surface)',
          // The glass sits a hair below the hardware around it. Not a bevel — a
          // ring in the finish's own dark tone, so a silver phone gets a silver
          // shadow rather than a black line.
          boxShadow: bare ? undefined : 'inset 0 0 0 1px var(--p-shell-shade)'
        }}
      >
        {chrome.top?.node}
        <div className="flex min-h-0 flex-1">
          {chrome.start?.node}
          <div
            className={`min-w-0 flex-1 ${scroll ? 'overflow-auto' : 'overflow-hidden'}`}
            style={{ containerType: 'size', containerName: 'plass-screen' }}
          >
            {children}
          </div>
        </div>
        {chrome.bottom?.node}
        <PlMockupCutout notch={cutout} screen={screen} landscape={landscape} />
      </div>
    );

    // `plass-mockup` and `plass-mockup-screen` are hooks rather than styles, the way
    // `plass-link` and `plass-portal` are: the device draws itself, and these are
    // there so a caller can reach the glass without counting elements.
    const classNames = cx('plass-mockup relative block', className ?? '');

    return useRender({
      render,
      ref: setRef,
      props: {
        className: classNames,
        style: {
          ...surfaceSlots(color, elevation),
          ...finishSlots[finish],
          width: width ?? (height === undefined ? '100%' : 'auto'),
          height: height ?? 'auto',
          aspectRatio: `${frame.width} / ${frame.height}`,
          // Outside the scale on purpose: a device drawn at a third of its size
          // would otherwise get a third of its shadow and stop reading as an
          // object on a page.
          filter: elevationFilters[elevation],
          ...style
        } as React.CSSProperties,
        children: (
          // Centred by the box rather than by a half-offset and a translate,
          // which is what keeps the device off the two physical sides. A
          // half-offset from one of them would have to be measured from the
          // other in a right-to-left page, and there is nothing about a phone
          // that runs either way.
          <div
            className="absolute inset-0 flex items-center justify-center"
            style={{
              // Until the box has been measured there is no honest size to draw
              // at. One frame, and only ever on the very first paint.
              visibility: scale === null ? 'hidden' : undefined
            }}
          >
            <div
              className="flex shrink-0 flex-col items-center"
              style={{
                width: frame.width,
                height: frame.height,
                transform: `scale(${scale ?? 1})`
              }}
            >
              <div
                className={bare ? '' : shellClasses}
                style={{
                  width: body.width,
                  height: body.height,
                  borderRadius: metrics.frameRadius,
                  paddingBlock: `${metrics.bezel.top}px ${metrics.bezel.bottom}px`,
                  paddingInline: metrics.bezel.x
                }}
              >
                {screenNode}
              </div>

              {stand ? (
                <>
                  <div
                    aria-hidden="true"
                    style={{
                      width: stand.neckWidth,
                      height: stand.neckHeight,
                      background: 'var(--p-shell-shade)',
                      clipPath: 'polygon(16% 0, 84% 0, 100% 100%, 0 100%)'
                    }}
                  />
                  <div
                    aria-hidden="true"
                    className={shellClasses}
                    style={{
                      width: stand.footWidth,
                      height: stand.footHeight,
                      borderRadius: stand.footHeight / 2
                    }}
                  />
                </>
              ) : null}

              {base ? (
                <div
                  aria-hidden="true"
                  className={`relative ${shellClasses}`}
                  style={{
                    width: base.width,
                    height: base.height,
                    borderRadius: `0 0 ${Math.round(base.height * 0.55)}px ${Math.round(base.height * 0.55)}px`,
                    clipPath: 'polygon(0 0, 100% 0, 98.5% 100%, 1.5% 100%)'
                  }}
                >
                  {/* The lip the lid is opened by — the one detail that says this is
                  a laptop rather than a monitor on a very short stand. */}
                  <div
                    // `inset-x-0` and an auto margin rather than a half-offset,
                    // for the reason the frame above is centred that way.
                    className="absolute inset-x-0 top-0 mx-auto"
                    style={{
                      width: base.lipWidth,
                      height: Math.round(base.height * 0.34),
                      borderRadius: `0 0 ${Math.round(base.height * 0.2)}px ${Math.round(base.height * 0.2)}px`,
                      background: 'var(--p-shell-shade)'
                    }}
                  />
                </div>
              ) : null}
            </div>
          </div>
        ),
        ...props
      }
    });
  }
);
