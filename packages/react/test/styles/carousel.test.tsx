/**
 * Which slide a `PlCarousel` strip shows, which only the stylesheet can answer.
 *
 * Without the real CSS the slides stack down the page and there is nothing to
 * scroll, so a carousel that opened on slide 3 while still showing slide 1 was
 * invisible to every component test: the dots were right and the strip was
 * never looked at. Loaded the way `back-top.test.tsx` loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCarousel } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

function Strip({
  value,
  defaultValue,
  dir
}: {
  value?: number;
  defaultValue?: number;
  dir?: 'rtl';
}) {
  return (
    <div dir={dir} style={{ width: 320 }}>
      <PlCarousel value={value} defaultValue={defaultValue}>
        <div style={{ height: 120 }}>Alpha</div>
        <div style={{ height: 120 }}>Bravo</div>
        <div style={{ height: 120 }}>Charlie</div>
      </PlCarousel>
    </div>
  );
}

/** How far the named slide stands from where the track's box starts. */
function offsetOf(name: string) {
  const track = document.querySelector('[role="group"][aria-label="Carousel"]')!;
  const slide = document.querySelector(`[role="group"][aria-label="${name}"]`)!;

  return Math.abs(slide.getBoundingClientRect().left - track.getBoundingClientRect().left);
}

describe('a PlCarousel that opens on a slide other than the first', () => {
  // Every reading is taken straight after the render and not polled for: a
  // strip that travelled there would still be on its way.
  it('shows the slide `defaultValue` names, without travelling to it', async () => {
    const screen = await render(<Strip defaultValue={2} />);

    expect(offsetOf('Slide 3 of 3')).toBeLessThan(1);
    await expect
      .element(screen.getByRole('button', { name: 'Slide 3 of 3' }))
      .toHaveAttribute('aria-current', 'true');
  });

  it('shows the slide a controlled `value` names', async () => {
    const screen = await render(<Strip value={1} />);

    expect(offsetOf('Slide 2 of 3')).toBeLessThan(1);
    await expect
      .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
      .toHaveAttribute('aria-current', 'true');
  });

  it('shows the slide `defaultValue` names once the box it was mounted hidden in is shown, without travelling to it', async () => {
    function Tab({ shown }: { shown: boolean }) {
      return (
        <div style={{ display: shown ? 'block' : 'none' }}>
          <Strip defaultValue={2} />
        </div>
      );
    }

    const screen = await render(<Tab shown={false} />);
    const track = document.querySelector('[role="group"][aria-label="Carousel"]')!;
    const positions: number[] = [];

    track.addEventListener('scroll', () => positions.push(track.scrollLeft));
    await screen.rerender(<Tab shown />);

    // Polled, unlike the readings above: the strip can only be placed once the
    // browser has laid the track out with a width, which is a frame after it
    // is shown.
    await expect.poll(() => offsetOf('Slide 3 of 3')).toBeLessThan(1);
    await expect.poll(() => positions.length).toBeGreaterThan(0);
    // In one step: a strip that travelled there would have passed through the
    // second slide on the way.
    expect(positions.every((position) => position === positions.at(-1))).toBe(true);
  });

  it('does the same the other way round under RTL', async () => {
    const screen = await render(<Strip defaultValue={2} dir="rtl" />);

    expect(offsetOf('Slide 3 of 3')).toBeLessThan(1);
    await expect
      .element(screen.getByRole('button', { name: 'Slide 3 of 3' }))
      .toHaveAttribute('aria-current', 'true');
  });
});
