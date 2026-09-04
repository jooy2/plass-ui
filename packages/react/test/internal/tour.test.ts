import { describe, expect, it } from 'vitest';
import { inflate, spotlightPath } from '../../src/internal/tour.js';

/** The outer rectangle the scrim's shape is drawn at, from `internal/tour.ts`. */
const EDGE = 100000;

describe('inflate', () => {
  it('grows a rectangle on every side', () => {
    expect(inflate({ top: 100, left: 200, width: 50, height: 20 }, 6)).toEqual({
      top: 94,
      left: 194,
      width: 62,
      height: 32
    });
  });

  it('never shrinks past nothing', () => {
    // A negative padding on a hairline target would otherwise ask for a
    // rectangle with a negative width, which draws inside out.
    expect(inflate({ top: 0, left: 0, width: 4, height: 4 }, -10).width).toBe(0);
  });
});

describe('spotlightPath', () => {
  it('covers everything when there is nothing to cut out', () => {
    // A welcome step: the page dims and nothing is spotlit. The rectangle is
    // drawn bigger than any screen rather than measured — a clip larger than
    // its element clips nothing away, and not reading `window` is what lets
    // this be called during a render that has no window.
    expect(spotlightPath(null, 10)).toBe(`path(evenodd,'M0,0H${EDGE}V${EDGE}H0Z')`);
  });

  it('is even-odd, which is what makes the second shape a hole', () => {
    expect(spotlightPath({ top: 10, left: 10, width: 100, height: 40 }, 8)).toContain('evenodd');
  });

  it('cuts a rounded rectangle out of it', () => {
    const path = spotlightPath({ top: 10, left: 20, width: 100, height: 40 }, 8);

    expect(path).toContain(`M0,0H${EDGE}V${EDGE}H0Z`);
    // Starts one radius in from the corner, and every corner is an arc.
    expect(path).toContain('M28,10');
    expect(path.match(/A8,8/g)).toHaveLength(4);
  });

  it('draws square corners rather than arcs at a radius of zero', () => {
    const path = spotlightPath({ top: 10, left: 20, width: 100, height: 40 }, 0);

    expect(path).toContain('M20,10H120V50H20Z');
    expect(path).not.toContain('A');
  });

  it('never lets the radius exceed half the shorter side', () => {
    // A radius larger than that draws a bow tie rather than a rounded corner,
    // which is what a two-pixel-tall target would ask for.
    const path = spotlightPath({ top: 0, left: 0, width: 100, height: 4 }, 20);

    expect(path).toContain('A2,2');
    expect(path).not.toContain('A20,20');
  });

  it('cuts nothing out of a target with no area', () => {
    expect(spotlightPath({ top: 10, left: 10, width: 0, height: 40 }, 8)).toBe(
      `path(evenodd,'M0,0H${EDGE}V${EDGE}H0Z')`
    );
  });
});
