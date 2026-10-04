/**
 * Whether the rows a `keepMounted` `PlTree` keeps in a shut branch are out of
 * sight, which only the stylesheet can answer.
 *
 * Base UI marks a shut fold `hidden`, and the browser's own `display: none` for
 * that attribute is all that hides it, so this loads `src/standalone.css` the
 * way `drawer.test.tsx` does and asks whether a class on the fold outranks it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTree } from 'plass-ui';
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

describe('a tree that keeps its shut branches', () => {
  it('draws none of their rows', async () => {
    await render(
      <PlTree
        keepMounted
        items={[{ id: 'src', label: 'src', children: [{ id: 'index', label: 'index.ts' }] }]}
      />
    );

    const kept = Array.from(document.querySelectorAll<HTMLElement>('[role="treeitem"]')).find(
      (row) => row.textContent === 'index.ts'
    )!;

    expect(getComputedStyle(kept.closest('[hidden]')!).display).toBe('none');
    expect(kept.checkVisibility()).toBe(false);
  });
});
