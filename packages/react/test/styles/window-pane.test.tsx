/**
 * What a macOS traffic light shows, where the move handle lies, and how tall a
 * window is once it is rolled up, in its box or from its first render, or
 * resized as short as it goes, which the stylesheet decides.
 *
 * The mark is held back with `opacity` and brought out by a hover on the set and
 * by the focus on one light, so nothing about it can be read off the markup —
 * the component writes the same two class names either way. The handle is laid
 * over the bar by utilities alone, and without them it is an empty inline box
 * that no press could ever land on. `src/standalone.css` is loaded the way
 * `marquee.test.tsx` loads it, and the assertions are a mark that is there or
 * is not and a box that matches another, never a shade or a size.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { commands } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlWindowPane } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { press } from '../support/keys';
import { emulateMedia } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** The box the mark is drawn in, inside the button of that name. */
function mark(button: HTMLElement): HTMLElement {
  return button.firstElementChild as HTMLElement;
}

const shown = (button: HTMLElement) => getComputedStyle(mark(button)).opacity === '1';

describe('the move handle', () => {
  it('lies over the whole bar and lets the pointer through to what is on it', async () => {
    const screen = await render(
      <PlWindowPane os="windows11" title="Notes" draggable width={320}>
        Body
      </PlWindowPane>
    );

    const handle = screen.getByRole('button', { name: 'Move window' }).element() as HTMLElement;
    const close = screen.getByRole('button', { name: 'Close' }).element() as HTMLElement;
    const bar = handle.parentElement as HTMLElement;

    const drawn = handle.getBoundingClientRect();
    const held = bar.getBoundingClientRect();

    // The keyboard's target is the bar a pointer takes hold of, not a grip
    // somewhere on it.
    expect(drawn.width).toBeCloseTo(held.width, 0);
    expect(drawn.height).toBeCloseTo(held.height, 0);

    // And it is not in the way: a press on a caption button reaches the button.
    const at = close.getBoundingClientRect();

    expect(
      close.contains(document.elementFromPoint(at.x + at.width / 2, at.y + at.height / 2))
    ).toBe(true);
  });
});

describe('a window both maximized and minimized', () => {
  /** A box for the window to fill, and the window in it, already maximized. */
  async function maximizedIn() {
    const screen = await render(
      <div style={{ position: 'relative', width: 480, height: 360 }}>
        <PlWindowPane os="windows11" title="Notes" position="absolute" defaultMaximized>
          <p>Body</p>
        </PlWindowPane>
      </div>
    );

    const pane = screen.container.querySelector<HTMLElement>('.plass-window')!;
    const bar = pane.firstElementChild as HTMLElement;

    return { screen, pane, bar };
  }

  it('fills its box across and rolls up to its bar, travelling there', async () => {
    // A transition is part of what is being asserted, so motion is asked for
    // rather than left to the runner's system.
    await emulateMedia({ reducedMotion: 'no-preference' });

    const { screen, pane, bar } = await maximizedIn();
    const travelled: string[] = [];

    pane.addEventListener('transitionrun', (event) => travelled.push(event.propertyName));

    await screen.getByRole('button', { name: 'Minimize' }).click();

    // As tall as the bar and the frame round it, and no taller.
    const rolled = () => {
      const frame = parseFloat(getComputedStyle(pane).borderBottomWidth);

      return bar.getBoundingClientRect().bottom + frame - pane.getBoundingClientRect().top;
    };

    await expect.poll(() => pane.getBoundingClientRect().height - rolled()).toBeCloseTo(0, 0);
    expect(pane.getBoundingClientRect().width).toBeCloseTo(480, 0);
    expect(travelled).toContain('height');
  });

  it('comes back down to its own height once it is restored, not to the height of its box', async () => {
    const { screen, pane } = await maximizedIn();
    const heights: string[] = [];
    const watch = new MutationObserver(() => heights.push(pane.style.height));

    await screen.getByRole('button', { name: 'Minimize' }).click();
    await screen.getByRole('button', { name: 'Restore' }).click();

    watch.observe(pane, { attributes: true, attributeFilter: ['style'] });

    try {
      await screen.getByRole('button', { name: 'Minimize' }).click();

      await expect.poll(() => pane.getBoundingClientRect().height).toBeLessThan(200);
      expect(heights).not.toContain('360px');
    } finally {
      watch.disconnect();
    }
  });
});

describe('a window that starts minimized', () => {
  // The height a window comes to rest at is what is asserted, not the journey
  // there, so the roll-up by the button is made instant: on a slow runner its
  // 260ms travel outlasted the poll that waits for it.
  beforeAll(async () => {
    await emulateMedia({ reducedMotion: 'reduce' });
  });

  afterAll(async () => {
    await emulateMedia({ reducedMotion: 'no-preference' });
  });

  const systems = [
    'macos',
    'macosx',
    'windows11',
    'windows10',
    'windows8',
    'windows7',
    'windowsxp',
    'linux'
  ] as const;

  /** The bar and the frame round it: what a rolled-up window should measure. */
  function rolled(pane: HTMLElement): number {
    const bar = pane.firstElementChild as HTMLElement;
    const frame = parseFloat(getComputedStyle(pane).borderBottomWidth);

    return bar.getBoundingClientRect().bottom + frame - pane.getBoundingClientRect().top;
  }

  for (const os of systems) {
    it(`is as tall as one rolled up by its button, on ${os}`, async () => {
      const screen = await render(
        <>
          <PlWindowPane os={os} title="Started" defaultMinimized>
            <p>Body</p>
          </PlWindowPane>
          <PlWindowPane os={os} title="Held" minimized height={240}>
            <p>Body</p>
          </PlWindowPane>
          <PlWindowPane os={os} title="Filled" defaultMinimized defaultMaximized>
            <p>Body</p>
          </PlWindowPane>
          <PlWindowPane os={os} title="Pressed">
            <p>Body</p>
          </PlWindowPane>
        </>
      );

      const pane = (name: string) => screen.getByRole('group', { name }).element() as HTMLElement;
      const height = (name: string) => pane(name).getBoundingClientRect().height;

      await screen
        .getByRole('group', { name: 'Pressed' })
        .getByRole('button', { name: 'Minimize' })
        .click();

      await expect.poll(() => height('Pressed') - rolled(pane('Pressed'))).toBeCloseTo(0, 0);

      for (const name of ['Started', 'Held', 'Filled']) {
        expect(height(name) - rolled(pane(name))).toBeCloseTo(0, 0);
        expect(height(name)).toBeCloseTo(height('Pressed'), 0);
      }
    });
  }
});

describe('a window resized as short as it goes', () => {
  // Where the window comes to rest is what is asserted, so the resize is made
  // instant rather than left to travel for 260ms under the poll.
  beforeAll(async () => {
    await emulateMedia({ reducedMotion: 'reduce' });
  });

  afterAll(async () => {
    await emulateMedia({ reducedMotion: 'no-preference' });
  });

  for (const minHeight of [undefined, 0]) {
    it(`keeps its bar and the frame round it, with a minHeight of ${minHeight}`, async () => {
      const screen = await render(
        <PlWindowPane
          os="windowsxp"
          title="Notes"
          resizable
          width={300}
          height={40}
          minHeight={minHeight}
        >
          <p>Body</p>
        </PlWindowPane>
      );

      const pane = screen.getByRole('group', { name: 'Notes' }).element() as HTMLElement;
      const bar = pane.firstElementChild as HTMLElement;
      const frame = () => parseFloat(getComputedStyle(pane).borderBottomWidth);
      const height = () => pane.getBoundingClientRect().height;

      // One step up from 40px asks for less than the bar and the frame come to.
      press(screen.getByRole('button', { name: 'Resize window' }).element(), 'ArrowUp');

      await expect.poll(height).toBeLessThan(40);
      expect(height()).toBeCloseTo(
        bar.getBoundingClientRect().bottom + frame() - pane.getBoundingClientRect().top,
        0
      );
    });
  }
});

describe('the macOS traffic lights', () => {
  it('hold their marks back until something is pointing at them', async () => {
    const screen = await render(
      <PlWindowPane os="macos" title="Notes">
        Body
      </PlWindowPane>
    );

    await commands.parkPointer();

    expect(shown(screen.getByRole('button', { name: 'Close' }).element() as HTMLElement)).toBe(
      false
    );
  });

  it('shows the mark of the light the keyboard has reached, and only that one', async () => {
    const screen = await render(
      <PlWindowPane os="macos" title="Notes">
        Body
      </PlWindowPane>
    );

    await commands.parkPointer();

    const close = screen.getByRole('button', { name: 'Close' }).element() as HTMLElement;
    const minimize = screen.getByRole('button', { name: 'Minimize' }).element() as HTMLElement;

    // Focused directly rather than with Tab: Firefox does not hand the first Tab
    // pressed in the runner's frame to the page. `focusVisible` makes it the
    // keyboard's focus, which is what the mark is drawn for; left to judge a
    // focus moved by script, a browser goes by the last press on the page, and
    // the tests above press with the pointer.
    close.focus({ focusVisible: true });

    await expect.poll(() => document.activeElement).toBe(close);
    // Polled, because the mark fades in over `--plass-duration` rather than
    // appearing on the frame the focus arrived.
    await expect.poll(() => shown(close)).toBe(true);
    // A ring is on one light. Lighting the other two would say the pointer is
    // over the set, which it is not.
    expect(shown(minimize)).toBe(false);
  });
});
