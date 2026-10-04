/**
 * What a macOS traffic light shows, where the move handle lies, how tall a
 * window is once it is rolled up, in its box or from its first render, or
 * resized as short as it goes, what a close button turns under a finger, and
 * whether a window inside a scaled ancestor moves and resizes in its own
 * pixels, which the stylesheet decides.
 *
 * The mark is held back with `opacity` and brought out by a hover on the set and
 * by the focus on one light, so nothing about it can be read off the markup —
 * the component writes the same two class names either way. The handle is laid
 * over the bar by utilities alone, and without them it is an empty inline box
 * that no press could ever land on. A scaled window needs the reset's
 * `box-sizing` for the size it is laid out at to be the `width` it was given.
 * `src/standalone.css` is loaded the way `marquee.test.tsx` loads it, and the
 * assertions are a mark that is there or is not and a box that matches another
 * or the size the test itself gave, never a shade or a size of the design's.
 */
import * as React from 'react';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { commands } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlWindowPane } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { press } from '../support/keys';
import { emulateMedia } from '../support/media';
import { moveMouseOntoPage } from '../support/pointer';

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

describe('a window rolled up by its button and then made another size or system', () => {
  // Where the window comes to rest is what is asserted, so the roll-up is made
  // instant rather than left to travel for 260ms under the poll.
  beforeAll(async () => {
    await emulateMedia({ reducedMotion: 'reduce' });
  });

  afterAll(async () => {
    await emulateMedia({ reducedMotion: 'no-preference' });
  });

  const changes = [
    { name: 'size', from: { size: 'md' }, to: { size: 'xl' } },
    { name: 'os', from: { os: 'macos' }, to: { os: 'linux' } }
  ] as const;

  for (const change of changes) {
    it(`is as tall as its new bar and the frame round it, after its ${change.name} changes`, async () => {
      const screen = await render(
        <PlWindowPane title="Notes" {...change.from}>
          <p>Body</p>
        </PlWindowPane>
      );

      const pane = screen.getByRole('group', { name: 'Notes' }).element() as HTMLElement;
      const bar = pane.firstElementChild as HTMLElement;
      const frame = () => parseFloat(getComputedStyle(pane).borderBottomWidth);
      const rolled = () =>
        bar.getBoundingClientRect().bottom + frame() - pane.getBoundingClientRect().top;
      const height = () => pane.getBoundingClientRect().height;

      await screen.getByRole('button', { name: 'Minimize' }).click();
      await expect.poll(() => height() - rolled()).toBeCloseTo(0, 0);

      const before = bar.getBoundingClientRect().height;

      await screen.rerender(
        <PlWindowPane title="Notes" {...change.to}>
          <p>Body</p>
        </PlWindowPane>
      );

      // The bar has grown, and the window with it rather than over it.
      await expect.poll(() => bar.getBoundingClientRect().height).toBeGreaterThan(before);
      await expect.poll(() => height() - rolled()).toBeCloseTo(0, 0);
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

describe('a window inside a scaled ancestor', () => {
  // Where the window comes to rest is what is asserted, so it moves and resizes
  // at once rather than travelling for 260ms under the assertions.
  beforeAll(async () => {
    await emulateMedia({ reducedMotion: 'reduce' });
  });

  afterAll(async () => {
    await emulateMedia({ reducedMotion: 'no-preference' });
  });

  /**
   * A box drawn at half its size from the top-left corner of the view, as a
   * scaled `PlMockup` draws its screen, so a window in it is laid out at twice
   * the size it is drawn at.
   */
  function Scaled({ children }: { children: React.ReactNode }) {
    return (
      <div
        style={{
          position: 'fixed',
          top: 0,
          left: 0,
          transform: 'scale(0.5)',
          transformOrigin: '0 0'
        }}
      >
        {children}
      </div>
    );
  }

  const windowIn = (screen: { container: HTMLElement }) =>
    screen.container.querySelector<HTMLElement>('.plass-window')!;

  /** The size the window is laid out at, which is what its `width` and `height` set. */
  const laidOut = (element: HTMLElement) => {
    const style = getComputedStyle(element);

    return { width: parseFloat(style.width), height: parseFloat(style.height) };
  };

  /** Dispatches a mouse press, move or release at `element`, with the mouse's own id. */
  async function mouse() {
    const pointerId = await moveMouseOntoPage();

    return (element: HTMLElement, type: string, x: number, y: number) =>
      element.dispatchEvent(
        new PointerEvent(type, {
          bubbles: true,
          pointerType: 'mouse',
          pointerId,
          button: 0,
          buttons: type === 'pointerup' ? 0 : 1,
          clientX: x,
          clientY: y
        })
      );
  }

  /** One task, so the render a key asked for has landed before the next key. */
  const settle = () => new Promise((resolve) => setTimeout(resolve, 0));

  it('keeps its title bar under the pointer dragging it', async () => {
    const onOffsetChange = vi.fn();
    const screen = await render(
      <Scaled>
        <PlWindowPane
          os="windows11"
          title="Notes"
          draggable
          position="absolute"
          width={240}
          height={160}
          defaultOffset={{ x: 40, y: 40 }}
          onOffsetChange={onOffsetChange}
        >
          Body
        </PlWindowPane>
      </Scaled>
    );

    const pane = windowIn(screen);
    const bar = pane.firstElementChild as HTMLElement;
    const send = await mouse();
    const before = pane.getBoundingClientRect();
    const held = bar.getBoundingClientRect();
    const x = held.left + 30;
    const y = held.top + held.height / 2;

    send(bar, 'pointerdown', x, y);
    send(bar, 'pointermove', x + 40, y + 20);

    // As far on the screen as the pointer went, which is twice as far in the
    // window's own pixels.
    await expect.poll(() => pane.getBoundingClientRect().left - before.left).toBeCloseTo(40, 0);
    expect(pane.getBoundingClientRect().top - before.top).toBeCloseTo(20, 0);
    expect(onOffsetChange).toHaveBeenLastCalledWith({ x: 120, y: 80 });

    send(bar, 'pointerup', x + 40, y + 20);
  });

  it.each([
    ['se', '.cursor-nwse-resize.bottom-0', 1],
    ['nw', '.cursor-nwse-resize.top-0', -1]
  ])(
    'resizes from the size it is laid out at and keeps the %s corner under the pointer',
    async (_, selector, outwards) => {
      const onResize = vi.fn();
      const onOffsetChange = vi.fn();
      const screen = await render(
        <Scaled>
          <PlWindowPane
            os="windows11"
            title="Notes"
            resizable
            position="absolute"
            width={240}
            height={160}
            defaultOffset={{ x: 40, y: 40 }}
            onResize={onResize}
            onOffsetChange={onOffsetChange}
          >
            Body
          </PlWindowPane>
        </Scaled>
      );

      const pane = windowIn(screen);
      const corner = pane.querySelector<HTMLElement>(selector)!;
      const send = await mouse();
      const before = pane.getBoundingClientRect();
      const held = corner.getBoundingClientRect();
      const x = held.left + held.width / 2;
      const y = held.top + held.height / 2;
      const edge = () => {
        const box = pane.getBoundingClientRect();

        return outwards > 0 ? { x: box.right, y: box.bottom } : { x: box.left, y: box.top };
      };
      const from = edge();

      send(corner, 'pointerdown', x, y);
      send(corner, 'pointermove', x + 30 * outwards, y + 20 * outwards);

      // The corner went as far on the screen as the pointer did, and the window
      // grew twice that in its own pixels.
      await expect.poll(() => edge().x - from.x).toBeCloseTo(30 * outwards, 0);
      expect(edge().y - from.y).toBeCloseTo(20 * outwards, 0);
      expect(onResize).toHaveBeenLastCalledWith({ width: 300, height: 200 });
      expect(laidOut(pane)).toEqual({ width: 300, height: 200 });

      // The opposite corner stayed where it was, which takes a leading corner
      // moving the window as far as it grew.
      const after = pane.getBoundingClientRect();

      if (outwards > 0) {
        expect(after.left).toBeCloseTo(before.left, 0);
        expect(after.top).toBeCloseTo(before.top, 0);
        expect(onOffsetChange).not.toHaveBeenCalled();
      } else {
        expect(after.right).toBeCloseTo(before.right, 0);
        expect(after.bottom).toBeCloseTo(before.bottom, 0);
        expect(onOffsetChange).toHaveBeenLastCalledWith({ x: -20, y: 0 });
      }

      send(corner, 'pointerup', x + 30 * outwards, y + 20 * outwards);
    }
  );

  it('steps its size from the size it is laid out at', async () => {
    const onResize = vi.fn();
    const screen = await render(
      <Scaled>
        <PlWindowPane
          os="windows11"
          title="Notes"
          resizable
          position="absolute"
          width={240}
          height={160}
          onResize={onResize}
        >
          Body
        </PlWindowPane>
      </Scaled>
    );

    const corner = screen.getByRole('button', { name: 'Resize window' }).element();

    // One press is 16 of the window's own pixels, which is 8 on the screen.
    press(corner, 'ArrowRight');

    expect(onResize).toHaveBeenLastCalledWith({ width: 256, height: 160 });
    await expect.poll(() => laidOut(windowIn(screen)).width).toBe(256);

    press(corner, 'ArrowDown');

    expect(onResize).toHaveBeenLastCalledWith({ width: 256, height: 176 });
  });

  it('stops a key step where its title bar meets the edge of the view', async () => {
    const onOffsetChange = vi.fn();
    const view = document.documentElement.clientWidth;
    // Laid out 200 wide and drawn 100 wide, with its right edge drawn 12 pixels
    // short of the view's.
    const x = (view - 12) * 2 - 200;
    const screen = await render(
      <Scaled>
        <PlWindowPane
          title="Notes"
          draggable
          position="absolute"
          width={200}
          defaultOffset={{ x, y: 0 }}
          onOffsetChange={onOffsetChange}
        >
          Body
        </PlWindowPane>
      </Scaled>
    );

    const handle = screen.getByRole('button', { name: 'Move window' }).element();

    handle.focus();

    // A whole step, 16 of the window's own pixels and 8 on the screen.
    press(handle, 'ArrowRight');
    await settle();

    expect(onOffsetChange).toHaveBeenLastCalledWith({ x: x + 16, y: 0 });

    // What is left of the way to the edge, and no more.
    press(handle, 'ArrowRight');
    await settle();

    expect(onOffsetChange).toHaveBeenLastCalledWith({ x: x + 24, y: 0 });
    await expect.poll(() => windowIn(screen).getBoundingClientRect().right).toBeCloseTo(view, 0);
  });

  it('holds the height it is laid out at while it rolls up and comes back down', async () => {
    const screen = await render(
      <Scaled>
        <PlWindowPane os="windows11" title="Notes" position="absolute" width={240}>
          <div style={{ height: 200 }}>Body</div>
        </PlWindowPane>
      </Scaled>
    );

    const pane = windowIn(screen);
    const before = laidOut(pane).height;
    const pinned: number[] = [];
    const watch = new MutationObserver(() => {
      const height = parseFloat(pane.style.height);

      if (!Number.isNaN(height)) {
        pinned.push(height);
      }
    });

    watch.observe(pane, { attributes: true, attributeFilter: ['style'] });

    try {
      await screen.getByRole('button', { name: 'Minimize' }).click();
      await expect.poll(() => laidOut(pane).height).toBeLessThan(before / 2);

      // The same button lets it back down.
      await screen.getByRole('button', { name: 'Minimize' }).click();

      // The height it travels from and back to is the one it had, in its own
      // pixels, rather than the one it was drawn at.
      expect(pinned[0]).toBeCloseTo(before, 0);
      await expect.poll(() => laidOut(pane).height).toBeCloseTo(before, 0);
    } finally {
      watch.disconnect();
    }
  });
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

describe('a close button pressed on a touch screen', () => {
  // A finger brings no hover, and Tailwind puts every `hover:` utility inside
  // `@media (hover: hover)`, so a press is all that is left to turn the button.
  // Taking the hover away in a test means emulating touch, which on a headless
  // Linux Chromium never gives back the mouse Playwright launched it with, and
  // every hover test after it in the shard then fails. So the rule is read out
  // of the stylesheet instead: a press on its own, outside any hover query,
  // has to write the mark white.
  type Found = { rule: CSSStyleRule; underHover: boolean };

  function rulesFor(escaped: string, rules: CSSRuleList, underHover = false): Found[] {
    const found: Found[] = [];

    for (const rule of Array.from(rules)) {
      if (rule instanceof CSSStyleRule) {
        if (rule.selectorText.includes(escaped)) {
          found.push({ rule, underHover });
        }
      } else if (rule instanceof CSSGroupingRule) {
        const hover =
          underHover || (rule instanceof CSSMediaRule && rule.conditionText.includes('hover'));

        found.push(...rulesFor(escaped, rule.cssRules, hover));
      }
    }

    return found;
  }

  it('draws its mark white on the red while it is held', async () => {
    const screen = await render(
      <PlWindowPane os="windows11" title="Notes">
        Body
      </PlWindowPane>
    );
    const close = screen.getByRole('button', { name: 'Close' }).element() as HTMLElement;

    expect(close.classList.contains('active:bg-(--p-window-danger)')).toBe(true);
    expect(close.classList.contains('active:text-white')).toBe(true);

    const pressed = rulesFor('active\\:text-white', sheet.sheet!.cssRules).filter(
      (one) => one.rule.selectorText.includes(':active') && !one.underHover
    );

    expect(pressed.length).toBeGreaterThan(0);

    // The colour the rule writes, resolved against the page's own tokens.
    const probe = document.createElement('span');
    probe.style.color = pressed[0].rule.style.color;
    document.body.append(probe);
    const ink = getComputedStyle(probe).color;
    probe.remove();

    expect(ink).toBe('rgb(255, 255, 255)');
  });
});
