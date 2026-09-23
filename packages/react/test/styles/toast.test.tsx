/**
 * Where a toast flicked away is while it fades, which only the stylesheet can
 * answer.
 *
 * Base UI moves a toast with an inline `transform` while a finger drags it and
 * drops that transform the moment the finger lifts, keeping only the distance in
 * `--toast-swipe-movement-x` and `-y`. What holds the toast there for its exit
 * is a class, and without the real CSS loaded a class is a name and nothing
 * else. Loaded the way `back-top.test.tsx` loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlToastProvider, usePlToast } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { moveMouseOntoPage } from '../support/pointer';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
  // Long enough that the exit is still under way when it is read, rather than
  // a race against a 150ms fade.
  document.documentElement.style.setProperty('--plass-duration', '10s');
});

afterAll(() => {
  sheet.remove();
  document.documentElement.style.removeProperty('--plass-duration');
});

function Raise() {
  const toast = usePlToast();

  return (
    <button type="button" onClick={() => toast.add({ title: 'Saved', timeout: 0 })}>
      Raise
    </button>
  );
}

/** Raises one toast and hands back its root once it is on screen. */
async function raise(): Promise<HTMLElement> {
  const screen = await render(
    <PlToastProvider>
      <Raise />
    </PlToastProvider>
  );

  await screen.getByRole('button', { name: 'Raise' }).click();
  await expect.element(screen.getByText('Saved')).toBeInTheDocument();

  return document.querySelector<HTMLElement>('[role="dialog"]')!;
}

describe('a toast on its way out', () => {
  it('fades from where it was swiped to', async () => {
    const toast = await raise();
    const box = toast.getBoundingClientRect();
    const x = box.left + 8;
    const y = box.top + box.height / 2;
    const pointerId = await moveMouseOntoPage();
    const pointer = (type: string, clientX: number) =>
      toast.dispatchEvent(
        new PointerEvent(type, {
          bubbles: true,
          button: 0,
          pointerType: 'mouse',
          pointerId,
          clientX,
          clientY: y
        })
      );

    pointer('pointerdown', x);
    // Base UI takes the first move as the start of the drag, so the gesture
    // is measured from there.
    pointer('pointermove', x);
    pointer('pointermove', x + 80);
    pointer('pointerup', x + 80);

    await expect.poll(() => toast.hasAttribute('data-ending-style')).toBe(true);

    // Still 80px along, rather than back in its place for the fade.
    expect(getComputedStyle(toast).transform).toBe('matrix(1, 0, 0, 1, 80, 0)');
  });

  it('fades where it is when it was closed any other way', async () => {
    const toast = await raise();

    toast.querySelector<HTMLButtonElement>('[aria-label]')!.click();

    await expect.poll(() => toast.hasAttribute('data-ending-style')).toBe(true);

    expect(getComputedStyle(toast).transform).toBe('none');
  });
});
