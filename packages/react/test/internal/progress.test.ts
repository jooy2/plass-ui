import { describe, expect, it } from 'vitest';
import {
  ringDiameters,
  ringMetrics,
  ringStrokeFor,
  ringStrokes
} from '../../src/internal/progress';
import type { PlassSize } from '../../src/types';

const sizes: PlassSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

describe('ringStrokeFor', () => {
  it('draws every rung of the ladder at that rung’s own stroke', () => {
    for (const size of sizes) {
      expect(ringStrokeFor(ringDiameters[size])).toBe(ringStrokes[size]);
    }
  });

  it('runs straight between two rungs', () => {
    // Halfway from `md` (20, 2) to `lg` (26, 2.5).
    expect(ringStrokeFor(23)).toBeCloseTo(2.25);
  });

  it('keeps the proportion of `xl` past the end of the ladder', () => {
    expect(ringStrokeFor(64)).toBeCloseTo(6);
    expect(ringStrokeFor(96)).toBeCloseTo(9);
  });

  it('keeps the proportion of `xs` below the start of the ladder', () => {
    expect(ringStrokeFor(14)).toBe(ringStrokes.xs);
    expect(ringStrokeFor(7)).toBeCloseTo(0.75);
    expect(ringStrokeFor(0.5)).toBeCloseTo(0.5 * (1.5 / 14));
  });

  it('leaves a radius above zero however small the ring', () => {
    for (const diameter of [0.5, 0.01, 1e-6]) {
      expect((diameter - ringStrokeFor(diameter)) / 2).toBeGreaterThan(0);
    }
  });
});

describe('ringMetrics', () => {
  it('is the rung when there is no diameter', () => {
    for (const size of sizes) {
      expect(ringMetrics(size, undefined)).toEqual({
        diameter: ringDiameters[size],
        stroke: ringStrokes[size]
      });
    }
  });

  it('takes the diameter over the rung, and the stroke follows it', () => {
    expect(ringMetrics('sm', 96)).toEqual({ diameter: 96, stroke: ringStrokeFor(96) });
  });

  it('ignores a diameter that is not a finite number above zero', () => {
    for (const diameter of [0, -40, Number.NaN, Infinity, -Infinity]) {
      expect(ringMetrics('lg', diameter)).toEqual({
        diameter: ringDiameters.lg,
        stroke: ringStrokes.lg
      });
    }
  });
});
