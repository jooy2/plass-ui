/**
 * Whether a server-rendered `PlMockup` whose size is a CSS length is drawn, at
 * the scale it will have, before the page hydrates, which only the stylesheet
 * can answer.
 *
 * The scale is the box over the device, and the browser measures the box once
 * the script runs. The device used to be hidden until then, and everything on
 * its screen with it. The stylesheet works the same ratio out now, so these
 * render on the server, put the HTML in a page with `src/standalone.css` loaded
 * the way `panes.test.tsx` loads it, and compare the device before hydration
 * with the device the measurement scales.
 */
import * as React from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { PlMockup } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { committed } from '../support/timing';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** The device as it is drawn: the element the scale is on. */
function deviceIn(host: Element): HTMLElement {
  return host.querySelector<HTMLElement>('.mockup-under-test > div > div') as HTMLElement;
}

/**
 * The device's box and whether its screen is visible in the server's HTML, and
 * the device's box again once that HTML has hydrated and the box has been
 * measured.
 */
async function serverThenMeasured(
  element: React.ReactElement,
  width: number
): Promise<{ server: DOMRect; visible: boolean; measured: DOMRect; errors: unknown[] }> {
  const host = document.createElement('div');
  const onRecoverableError = vi.fn();

  host.style.width = `${width}px`;
  host.innerHTML = renderToString(element);
  document.body.append(host);

  const server = deviceIn(host).getBoundingClientRect();
  const visible = host
    .querySelector('.plass-mockup-screen')!
    .checkVisibility({ visibilityProperty: true });
  let root: ReturnType<typeof hydrateRoot> | undefined;

  try {
    await committed(() => {
      root = hydrateRoot(host, element, { onRecoverableError });
    });

    // Measured once the scale is a number rather than the stylesheet's ratio.
    await expect.poll(() => deviceIn(host).style.transform).toMatch(/^scale\([\d.]+\)$/);

    return {
      server,
      visible,
      measured: deviceIn(host).getBoundingClientRect(),
      errors: onRecoverableError.mock.calls
    };
  } finally {
    await committed(() => root?.unmount());
    host.remove();
  }
}

/** That `actual` is where `expected` is and as big, each to within a pixel. */
function expectSameBox(actual: DOMRect, expected: DOMRect): void {
  for (const side of ['left', 'top', 'width', 'height'] as const) {
    expect(Math.abs(actual[side] - expected[side]), side).toBeLessThanOrEqual(1);
  }
}

// A `md` phone is 416 by 870 with its bezel.
describe('a server-rendered PlMockup sized by a CSS length', () => {
  it('draws the device at the width of its box before hydration', async () => {
    const { server, visible, measured, errors } = await serverThenMeasured(
      <PlMockup device="mobile" className="mockup-under-test">
        On the screen
      </PlMockup>,
      312
    );

    expect(visible).toBe(true);
    expect(Math.abs(server.width - 312)).toBeLessThanOrEqual(1);
    expectSameBox(server, measured);
    expect(errors).toEqual([]);
  });

  it('draws a width given as a percentage the same way', async () => {
    const { server, visible, measured } = await serverThenMeasured(
      <PlMockup device="mobile" width="50%" className="mockup-under-test" />,
      624
    );

    expect(visible).toBe(true);
    expect(Math.abs(server.width - 312)).toBeLessThanOrEqual(1);
    expectSameBox(server, measured);
  });

  it('takes the smaller of the two scales when the height is held as well', async () => {
    const { server, visible, measured } = await serverThenMeasured(
      <PlMockup device="mobile" height="435px" className="mockup-under-test" />,
      624
    );

    expect(visible).toBe(true);
    expect(Math.abs(server.height - 435)).toBeLessThanOrEqual(1);
    expectSameBox(server, measured);
  });

  it('answers to a height a style holds it to', async () => {
    const { server, measured } = await serverThenMeasured(
      <PlMockup device="mobile" className="mockup-under-test" style={{ height: 290 }} />,
      624
    );

    // 624 across would scale the phone to 1.5; 290 down holds it to a third.
    expect(Math.abs(server.height - 290)).toBeLessThanOrEqual(1);
    expectSameBox(server, measured);
  });
});
