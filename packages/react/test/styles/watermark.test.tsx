/**
 * A tiled watermark, as the browser lays it out and turns it.
 *
 * `PlImage.test.tsx` asserts what the tile layer is given. Whether the turned
 * layer still reaches every corner of the picture is up to the container units
 * it is sized in and the transform it is turned by, so the thing under test here
 * is the layout, with `src/standalone.css` loaded the way `gallery.test.tsx`
 * loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlImage } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

const OK =
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

const mark = () =>
  document.querySelector('span[aria-hidden="true"].pointer-events-none') as HTMLElement | null;

describe('a tiled watermark', () => {
  it('covers every corner of a picture three times as wide as it is tall', async () => {
    await render(
      <div style={{ width: '390px' }}>
        <PlImage
          src={OK}
          alt="A panorama"
          ratio={3}
          watermark={{ text: 'PROOF', placement: 'tile' }}
        />
      </div>
    );

    await expect.poll(() => mark()).not.toBeNull();

    const box = mark()!;
    const layer = box.firstElementChild as HTMLElement;
    const { left, top, right, bottom, width, height } = box.getBoundingClientRect();

    expect(width / height).toBeCloseTo(3);

    // The mark takes no pointer, so a hit test would pass straight through it.
    // Letting it be hit moves nothing, and a hit test is what knows where a
    // turned box really is.
    box.style.pointerEvents = 'auto';

    // One pixel in from each corner of the picture, where a layer that is only
    // oversized by a share of each side leaves an empty triangle.
    const corners: Array<[number, number]> = [
      [left + 1, top + 1],
      [right - 1, top + 1],
      [left + 1, bottom - 1],
      [right - 1, bottom - 1]
    ];

    for (const [x, y] of corners) {
      expect(document.elementsFromPoint(x, y)).toContain(layer);
    }
  });

  // What a colour resolves to, read off an element that uses it the plain way.
  function resolved(color: string): string {
    const probe = document.createElement('span');

    probe.style.color = color;
    document.body.append(probe);

    const value = getComputedStyle(probe).color;

    probe.remove();

    return value;
  }

  it('draws in a token colour', async () => {
    await render(
      <PlImage
        src={OK}
        alt="A portrait"
        watermark={{ text: 'PROOF', placement: 'tile', color: 'var(--plass-primary-accent)' }}
      />
    );

    await expect.poll(() => mark()).not.toBeNull();

    const layer = mark()!.firstElementChild as HTMLElement;

    // An image cannot read the page's custom properties, so a token written
    // into the tile itself would come out black.
    expect(getComputedStyle(layer).backgroundColor).toBe(resolved('var(--plass-primary-accent)'));
  });

  it('draws in currentColor as the colour around it', async () => {
    await render(
      <div style={{ color: 'var(--plass-danger-accent)' }}>
        <PlImage
          src={OK}
          alt="A portrait"
          watermark={{ text: 'PROOF', placement: 'tile', color: 'currentColor' }}
        />
      </div>
    );

    await expect.poll(() => mark()).not.toBeNull();

    const layer = mark()!.firstElementChild as HTMLElement;

    expect(getComputedStyle(layer).backgroundColor).toBe(resolved('var(--plass-danger-accent)'));
  });
});
