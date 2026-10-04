import { afterEach, describe, expect, it } from 'vitest';
import { layoutBox } from '../../src/internal/layout-box';

/** A box 200 wide and 100 tall, with 10 of padding and 2 of border on each side. */
function box(boxSizing: 'border-box' | 'content-box', scale = 1): HTMLElement {
  const host = document.createElement('div');
  const element = document.createElement('div');

  host.className = 'layout-box-under-test';
  host.style.cssText = `transform: scale(${scale}); transform-origin: 0 0;`;
  element.style.cssText = `width: 200px; height: 100px; padding: 10px; border: 2px solid; box-sizing: ${boxSizing};`;
  host.append(element);
  document.body.append(host);

  return element;
}

afterEach(() => {
  document.querySelectorAll('.layout-box-under-test').forEach((host) => host.remove());
});

describe('layoutBox', () => {
  it('reads the size a declaration sets, and the content box inside it', () => {
    expect(layoutBox(box('border-box'), true)).toEqual({ size: 200, content: 176, perPixel: 1 });
    expect(layoutBox(box('content-box'), true)).toEqual({ size: 200, content: 200, perPixel: 1 });
    expect(layoutBox(box('content-box'), false)).toEqual({ size: 100, content: 100, perPixel: 1 });
  });

  it('measures the box as it is laid out inside a scaled ancestor, and says how far it was scaled', () => {
    const element = box('border-box', 0.5);

    expect(element.getBoundingClientRect().width).toBe(100);
    expect(layoutBox(element, true)).toEqual({ size: 200, content: 176, perPixel: 2 });
    expect(layoutBox(element, false)).toEqual({ size: 100, content: 76, perPixel: 2 });
  });

  it('measures nothing when the box is not laid out', () => {
    const element = box('border-box');

    element.style.display = 'none';

    expect(layoutBox(element, true)).toEqual({ size: 0, content: 0, perPixel: 1 });
  });
});
