/**
 * The clipped copy the four text effects put beside the line they draw.
 *
 * It is there so a screen reader hears the line once rather than one word, one
 * character or one frame at a time. A selection across the pair used to hand
 * the line back twice, and only the real stylesheet can say whether it still
 * does: `select-none` is a class name and nothing else without it. Loaded the
 * way `code-block.test.tsx` loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAnimateCounter,
  PlAnimateScramble,
  PlAnimateSplit,
  PlAnimateTyping
} from 'plass-ui';
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

const effects = [
  ['PlAnimateSplit', <PlAnimateSplit key="split">Internationalization is long</PlAnimateSplit>],
  ['PlAnimateScramble', <PlAnimateScramble key="scramble">Deploying</PlAnimateScramble>],
  ['PlAnimateCounter', <PlAnimateCounter key="counter" to={42} />],
  ['PlAnimateTyping', <PlAnimateTyping key="typing">Ship it</PlAnimateTyping>]
] as const;

describe('the clipped copy of a text effect', () => {
  for (const [name, element] of effects) {
    it(`is left out of a selection on ${name}`, async () => {
      const screen = await render(element);
      const copies = screen.container.querySelectorAll('[data-plass-animation] > span');

      // The clipped copy first, the drawn one after it.
      expect(copies).toHaveLength(2);
      expect(getComputedStyle(copies[0]!).userSelect).toBe('none');
      expect(getComputedStyle(copies[1]!).userSelect).not.toBe('none');
    });
  }
});
