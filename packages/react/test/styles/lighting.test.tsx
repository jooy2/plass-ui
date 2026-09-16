/**
 * The easing of `PlAnimateLighting`, which runs on a pseudo-element.
 *
 * The arc is drawn by `.plass-anim-lighting::before`, so what curve it turns
 * on is written in `src/styles.css` and cannot be read off the element a
 * component test has. Loaded the way `code-block.test.tsx` loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateLighting } from 'plass-ui';
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

function arc(): CSSStyleDeclaration {
  return getComputedStyle(document.querySelector('.lighting-under-test')!, '::before');
}

describe('the PlAnimateLighting arc', () => {
  it('turns at a steady pace by default', async () => {
    await render(
      <PlAnimateLighting className="lighting-under-test">
        <span>Generating</span>
      </PlAnimateLighting>
    );

    expect(arc().animationTimingFunction).toBe('linear');
  });

  it('and on the curve it was given', async () => {
    await render(
      <PlAnimateLighting className="lighting-under-test" easing="ease-in-out">
        <span>Generating</span>
      </PlAnimateLighting>
    );

    // `easing` reached the root and stopped there: the pseudo-element had
    // `linear` written into it. The Flutter build follows its `curve`.
    expect(arc().animationTimingFunction).toBe('ease-in-out');
  });
});
