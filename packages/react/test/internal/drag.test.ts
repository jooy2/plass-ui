import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { beginPointerDrag } from '../../src/internal/drag';
import { moveMouseOntoPage } from '../support/pointer';

/*
 * The scaffold on its own, with a plain element standing in for a handle. The
 * events are dispatched rather than performed, so each reaches the listeners in
 * the order the test picks, and they carry the id of the browser's own mouse,
 * which is the only id every browser lets a drag capture.
 */
describe('beginPointerDrag', () => {
  let target: HTMLElement;

  const selection = () => document.body.style.getPropertyValue('-webkit-user-select');

  const pointer = (type: string, pointerId: number, init: PointerEventInit = {}) =>
    target.dispatchEvent(
      new PointerEvent(type, { bubbles: true, pointerType: 'mouse', pointerId, ...init })
    );

  beforeEach(() => {
    target = document.createElement('div');
    target.style.cssText = 'width: 100px; height: 100px;';
    document.body.append(target);
    // Written inline, so a selection given back can be told from one blanked.
    document.body.style.setProperty('-webkit-user-select', 'text');
  });

  afterEach(() => {
    target.remove();
    document.body.style.removeProperty('-webkit-user-select');
  });

  it('ends on `pointercancel` as it ends on `pointerup`', async () => {
    const pointerId = await moveMouseOntoPage();
    const onMove = vi.fn();
    const onEnd = vi.fn();

    beginPointerDrag({ target, pointerId, onMove, onEnd });

    expect(target).toHaveAttribute('data-dragging', 'true');
    expect(selection()).toBe('none');

    pointer('pointercancel', pointerId);

    expect(onEnd).toHaveBeenCalledOnce();
    expect(target).not.toHaveAttribute('data-dragging');
    expect(selection()).toBe('text');

    // Nothing is listening any more.
    pointer('pointermove', pointerId, { buttons: 1, clientX: 40, clientY: 40 });
    pointer('pointerup', pointerId);

    expect(onMove).not.toHaveBeenCalled();
    expect(onEnd).toHaveBeenCalledOnce();
  });

  it('gives everything back and says nothing when an unmount releases it', async () => {
    const pointerId = await moveMouseOntoPage();
    const onMove = vi.fn();
    const onEnd = vi.fn();

    const release = beginPointerDrag({ target, pointerId, onMove, onEnd });

    release();

    expect(target).not.toHaveAttribute('data-dragging');
    expect(selection()).toBe('text');
    expect(onEnd).not.toHaveBeenCalled();

    // A move and a release arriving after it, and the teardown called a second
    // time: none of them does anything, including writing the selection back
    // over what the page has set since.
    pointer('pointermove', pointerId, { buttons: 1, clientX: 40, clientY: 40 });
    pointer('pointerup', pointerId);
    document.body.style.setProperty('-webkit-user-select', 'auto');
    release();

    expect(onMove).not.toHaveBeenCalled();
    expect(onEnd).not.toHaveBeenCalled();
    expect(selection()).toBe('auto');
  });
});
