import type { PlassHeadingLevel } from '../types.js';

/**
 * The heading level a caller asked for, or `undefined` when what arrived is
 * not one.
 *
 * The type keeps a TypeScript caller inside the six; this keeps a JavaScript
 * one there too, where a `7` would have written an `<h7>`, which is no heading
 * at all. Every component that takes a `headingLevel` reads it through here,
 * so they cannot come to disagree about what a level is.
 */
export function headingLevelOf(value: unknown): PlassHeadingLevel | undefined {
  return typeof value === 'number' && Number.isInteger(value) && value >= 1 && value <= 6
    ? (value as PlassHeadingLevel)
    : undefined;
}
