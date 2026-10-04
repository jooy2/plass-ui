import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import type { ReactElement } from 'react';
import { renderToString } from 'react-dom/server';
import { PlAnimateTyping } from 'plass-ui';
import standaloneCss from '../../../src/standalone.css?inline';
import { committed } from '../../support/timing';

/**
 * The visible half — the one that is `aria-hidden` and actually animates. What
 * it has typed is generated content, read from its `data-text`.
 */
function visible(root: Element | null): string {
  return root?.querySelector<HTMLElement>('[aria-hidden="true"]')?.dataset.text ?? '';
}

describe('PlAnimateTyping', () => {
  describe('the room it takes', () => {
    const LINE = 'Deploying to production';

    let sheet: HTMLStyleElement;

    // The claims here are about layout, so this group loads the stylesheet,
    // which the rest of the file has no use for.
    beforeAll(() => {
      sheet = document.createElement('style');
      sheet.textContent = standaloneCss;
      document.head.append(sheet);
    });

    afterAll(() => {
      sheet.remove();
    });

    function root(): HTMLElement {
      return document.querySelector<HTMLElement>('.typing-under-test')!;
    }

    function caretBox(): DOMRect {
      return root().querySelector('.plass-caret')!.getBoundingClientRect();
    }

    /** The line in a box too narrow for it, so it takes two lines. */
    function narrow(play: boolean) {
      return (
        <div style={{ width: '8rem' }}>
          <PlAnimateTyping
            className="typing-under-test"
            text={LINE}
            speed={200}
            trigger="manual"
            play={play}
          />
        </div>
      );
    }

    it('holds the box of the whole string before the first character arrives', async () => {
      const screen = await render(narrow(false));
      const before = root().getBoundingClientRect().height;
      const heights: number[] = [];

      await screen.rerender(narrow(true));

      for (let sample = 0; sample < 30; sample += 1) {
        heights.push(root().getBoundingClientRect().height);
        await new Promise((resolve) => setTimeout(resolve, 5));
      }

      await expect.poll(() => visible(root()).startsWith(LINE)).toBe(true);
      heights.push(root().getBoundingClientRect().height);

      // The finished line wraps, so the box it holds is more than one line.
      expect(root().querySelector('[aria-hidden="true"]')!.getClientRects().length).toBeGreaterThan(
        1
      );
      expect([...new Set(heights)]).toEqual([before]);
    });

    it('keeps the caret where the typing is', async () => {
      const screen = await render(narrow(false));
      const box = root().getBoundingClientRect();

      // Nothing typed yet: the start of the first line, ahead of the rest.
      expect(caretBox().left).toBeCloseTo(box.left, 0);
      expect(caretBox().top).toBeCloseTo(box.top, 0);

      await screen.rerender(narrow(true));
      await expect.poll(() => visible(root()).startsWith(LINE)).toBe(true);

      // Finished: after the last word, on the second line.
      expect(caretBox().left).toBeGreaterThan(box.left);
      expect(caretBox().top).toBeGreaterThan(box.top);
    });

    it('copies the line once, from the clipped copy, however far it has got', async () => {
      const screen = await render(narrow(false));
      const selection = window.getSelection()!;
      const copied = () => {
        selection.selectAllChildren(root());

        const text = selection.toString().replace(/\s+/g, ' ').trim();

        selection.removeAllRanges();

        return text;
      };

      // Nothing typed yet, and the caret is no part of the line either.
      expect(copied()).toBe(LINE);

      await screen.rerender(narrow(true));
      await expect.poll(() => visible(root())).toBe(LINE);

      // Typed out, and still once rather than twice.
      expect(copied()).toBe(LINE);
    });

    it('holds the same box in the server’s HTML', () => {
      const html = renderToString(<PlAnimateTyping text={LINE} />);

      expect(html).toContain(`data-sample="${LINE}"`);
    });
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateTyping className="typing-under-test" text="Hello" speed={200} />);

    expect(document.querySelector('.typing-under-test')).toHaveAttribute(
      'data-plass-animation',
      'typing'
    );
  });

  it('puts the whole string in the document from the first frame, for a screen reader', async () => {
    const screen = await render(
      <PlAnimateTyping className="typing-under-test" text="Deploying to production" speed={1} />
    );

    await expect.element(screen.getByText('Deploying to production')).toBeInTheDocument();
  });

  it('types it out, one grapheme at a time', async () => {
    await render(
      <PlAnimateTyping className="typing-under-test" text="Hello" speed={400} caret={false} />
    );

    const root = document.querySelector('.typing-under-test');

    await expect.poll(() => visible(root)).toBe('Hello');
  });

  it('counts graphemes rather than code points', async () => {
    await render(
      <PlAnimateTyping className="typing-under-test" text="ab👩‍👩‍👧" speed={400} caret={false} />
    );

    const root = document.querySelector('.typing-under-test');

    // Three graphemes, not nine code points — the family arrives whole rather
    // than being assembled out of parts that mean nothing on their own.
    await expect.poll(() => visible(root)).toBe('ab👩‍👩‍👧');
  });

  it('takes its text from children when there is no text prop', async () => {
    await render(
      <PlAnimateTyping className="typing-under-test" speed={400} caret={false}>
        Hello
      </PlAnimateTyping>
    );

    const root = document.querySelector('.typing-under-test');

    await expect.poll(() => visible(root)).toBe('Hello');
  });

  it('types a new string of the same length again', async () => {
    const screen = await render(
      <PlAnimateTyping className="typing-under-test" text="design" speed={400} caret={false} />
    );

    const root = document.querySelector('.typing-under-test')!;

    await expect.poll(() => visible(root)).toBe('design');

    const seen = new Set<string>();
    const observer = new MutationObserver(() => seen.add(visible(root)));

    observer.observe(root, { childList: true, characterData: true, subtree: true });

    try {
      await screen.rerender(
        <PlAnimateTyping className="typing-under-test" text="deploy" speed={400} caret={false} />
      );

      await expect.poll(() => visible(root)).toBe('deploy');

      // A string with the same number of characters used to appear whole,
      // because the reset watched only how many there were.
      expect([...seen].some((step) => step !== 'deploy' && 'deploy'.startsWith(step))).toBe(true);
    } finally {
      observer.disconnect();
    }
  });

  it('flattens an element among the children to its text', async () => {
    await render(
      <PlAnimateTyping className="typing-under-test" speed={400} caret={false}>
        Ship <strong>faster</strong>
      </PlAnimateTyping>
    );

    const root = document.querySelector('.typing-under-test');

    // The words inside the `<strong>` are typed and read out, and the bold is
    // not kept: there is no honest way to reveal half of an element.
    expect(root?.firstElementChild).toHaveTextContent('Ship faster');
    await expect.poll(() => visible(root)).toBe('Ship faster');
    expect(root?.querySelector('strong')).toBe(null);
  });

  describe('caret', () => {
    it('draws a block after the text', async () => {
      await render(<PlAnimateTyping className="typing-under-test" text="Hi" speed={400} />);

      expect(document.querySelector('.typing-under-test .plass-caret')).toBeInTheDocument();
    });

    it('takes whatever character it was given', async () => {
      await render(
        <PlAnimateTyping className="typing-under-test" text="Hi" speed={400} caretChar="▌" />
      );

      // Drawn from an attribute, as the line is, so it is no part of the
      // page's text.
      const caret = document.querySelector<HTMLElement>('.typing-under-test .plass-caret')!;

      expect(caret.dataset.text).toBe('▌');
      expect(caret).toHaveTextContent('');
    });

    it('draws a caret given as an element as it is', async () => {
      await render(
        <PlAnimateTyping
          className="typing-under-test"
          text="Hi"
          speed={400}
          caretChar={<b className="caret-glyph">_</b>}
        />
      );

      expect(
        document.querySelector('.typing-under-test .plass-caret .caret-glyph')
      ).toBeInTheDocument();
    });

    it('can be turned off', async () => {
      await render(
        <PlAnimateTyping className="typing-under-test" text="Hi" speed={400} caret={false} />
      );

      expect(document.querySelector('.typing-under-test .plass-caret')).toBe(null);
    });
  });

  it('waits empty until it is triggered, rather than showing the whole line first', async () => {
    await render(
      <PlAnimateTyping className="typing-under-test" text="Hello" trigger="manual" caret={false} />
    );

    const root = document.querySelector('.typing-under-test');

    expect(root).toHaveAttribute('data-state', 'paused');
    expect(visible(root)).toBe('');
  });

  it('types once it is played', async () => {
    const screen = await render(
      <PlAnimateTyping
        className="typing-under-test"
        text="Hello"
        speed={400}
        caret={false}
        trigger="manual"
      />
    );

    await screen.rerender(
      <PlAnimateTyping
        className="typing-under-test"
        text="Hello"
        speed={400}
        caret={false}
        trigger="manual"
        play
      />
    );

    const root = document.querySelector('.typing-under-test');

    await expect.poll(() => visible(root)).toBe('Hello');
  });

  it('waits empty again when `play` is turned off, and types the line again when it is back on', async () => {
    const typing = (play: boolean) => (
      <PlAnimateTyping
        className="typing-under-test"
        text="Hello"
        speed={400}
        caret={false}
        trigger="manual"
        play={play}
      />
    );
    const screen = await render(typing(true));
    const root = document.querySelector('.typing-under-test');

    await expect.poll(() => visible(root)).toBe('Hello');

    await screen.rerender(typing(false));

    // Taken back by its trigger, it waits as it did before it was first
    // played, rather than holding the line as a pause does.
    expect(root).toHaveAttribute('data-state', 'paused');
    expect(visible(root)).toBe('');

    await screen.rerender(typing(true));
    await expect.poll(() => visible(root)).toBe('Hello');
  });

  it('deletes the line again before repeating, one grapheme at a time', async () => {
    await render(
      <PlAnimateTyping
        className="typing-under-test"
        text="Hello"
        speed={50}
        eraseSpeed={10}
        hold={20}
        erase
        repeat={2}
        caret={false}
      />
    );

    const root = document.querySelector('.typing-under-test');
    const seen: number[] = [];

    for (let sample = 0; sample < 60; sample += 1) {
      seen.push(visible(root).length);
      await new Promise((resolve) => setTimeout(resolve, 10));
    }

    const full = seen.indexOf(5);
    const shrinking = seen.slice(full).filter((length) => length > 0 && length < 5);

    // Without `erase` the line would clear in one frame, so the only lengths
    // after the full string would be 5 and 0.
    expect(full).toBeGreaterThanOrEqual(0);
    expect(shrinking.length).toBeGreaterThan(0);
  });

  it('plays only the passes it was asked for when it is paused and let go during one', async () => {
    const typing = (paused: boolean) => (
      <PlAnimateTyping
        className="typing-under-test"
        text="Hello"
        speed={20}
        hold={60}
        repeat={2}
        paused={paused}
        caret={false}
      />
    );
    const screen = await render(typing(false));
    const root = document.querySelector('.typing-under-test');
    const drawn = root!.querySelector('[aria-hidden="true"]')!;
    let clears = 0;
    let last = visible(root);
    const observer = new MutationObserver(() => {
      const now = visible(root);

      // A pass ends by clearing the line in one frame, so a clear is a pass.
      if (now === '' && last !== '') {
        clears += 1;
      }

      last = now;
    });

    observer.observe(drawn, { attributes: true, attributeFilter: ['data-text'] });

    try {
      // Partway through the second pass, which is the last one.
      await expect
        .poll(() => clears === 1 && visible(root).length > 0 && visible(root).length < 5)
        .toBe(true);

      await screen.rerender(typing(true));
      await new Promise((resolve) => setTimeout(resolve, 100));
      await screen.rerender(typing(false));

      await expect.poll(() => visible(root)).toBe('Hello');
      // Longer than a hold and a whole pass, so a third would have started.
      await new Promise((resolve) => setTimeout(resolve, 400));
    } finally {
      observer.disconnect();
    }

    expect(clears).toBe(1);
    expect(visible(root)).toBe('Hello');
  });

  it('holds for what was left of the hold before it deletes when it is paused and let go during it', async () => {
    const typing = (paused: boolean) => (
      <PlAnimateTyping
        className="typing-under-test"
        text="Hi"
        speed={100}
        eraseSpeed={100}
        hold={1200}
        erase
        repeat={2}
        paused={paused}
        caret={false}
      />
    );
    const wait = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
    const screen = await render(typing(false));
    const root = document.querySelector('.typing-under-test');

    // Typed out, which is where the hold starts.
    await expect.poll(() => visible(root)).toBe('Hi');
    await wait(600);
    await screen.rerender(typing(true));
    await wait(300);
    await screen.rerender(typing(false));

    const resumed = performance.now();
    const drawn = root!.querySelector('[aria-hidden="true"]')!;
    // The first thing drawn after it was let go, and how long after.
    const first: { after?: number; text?: string } = {};
    const observer = new MutationObserver(() => {
      if (first.after === undefined) {
        first.after = performance.now() - resumed;
        first.text = visible(root);
      }
    });

    observer.observe(drawn, { attributes: true, attributeFilter: ['data-text'] });

    try {
      await expect.poll(() => first.after, { timeout: 3000 }).toBeDefined();
    } finally {
      observer.disconnect();
    }

    // About 600ms of the hold was left. Let go, it used to delete the next
    // character at once; it holds for what was left, rather than the whole
    // 1200ms of it again, and not shortened by the time it was held.
    expect(first.text).toBe('H');
    expect(first.after).toBeGreaterThan(400);
    expect(first.after).toBeLessThan(1000);
  });

  describe('paused and let go during a wait', () => {
    // The typing runs on timeouts and measures what was left of a wait with
    // `performance.now()`, so both run on a clock the test holds.
    beforeEach(() => {
      vi.useFakeTimers({ toFake: ['setTimeout', 'clearTimeout', 'performance'] });
    });

    afterEach(() => {
      vi.useRealTimers();
    });

    /** Moves the clock on by `ms`, and waits for what that renders. */
    function advance(ms: number): Promise<void> {
      return committed(() => {
        vi.advanceTimersByTime(ms);
      });
    }

    /** Pauses it now, holds it for a long while, and lets it go again. */
    async function pauseAndLetGo(
      screen: Awaited<ReturnType<typeof render>>,
      typing: (paused: boolean) => ReactElement
    ): Promise<void> {
      await screen.rerender(typing(true));
      await advance(5000);
      await screen.rerender(typing(false));
    }

    it('waits out only what was left of `delay`', async () => {
      const typing = (paused: boolean) => (
        <PlAnimateTyping
          className="typing-under-test"
          text="Hi"
          delay={1000}
          speed={10}
          paused={paused}
          caret={false}
        />
      );
      const screen = await render(typing(false));
      const root = document.querySelector('.typing-under-test');

      await advance(600);
      await pauseAndLetGo(screen, typing);
      await advance(399);

      // 400ms of the wait was left. It used to wait the whole `delay` again.
      expect(visible(root)).toBe('');

      await advance(1);

      expect(visible(root)).toBe('H');
    });

    it('waits out only what was left of the wait for the next character', async () => {
      const typing = (paused: boolean) => (
        <PlAnimateTyping
          className="typing-under-test"
          text="Hi"
          speed={1}
          paused={paused}
          caret={false}
        />
      );
      const screen = await render(typing(false));
      const root = document.querySelector('.typing-under-test');

      // The first character at once, and the next a second after it.
      await advance(400);

      expect(visible(root)).toBe('H');

      await pauseAndLetGo(screen, typing);
      await advance(599);

      expect(visible(root)).toBe('H');

      await advance(1);

      // 600ms of the wait was left. It used to wait the whole second again.
      expect(visible(root)).toBe('Hi');
    });

    it.each([
      ['erased', true],
      ['cleared', false]
    ])('waits out only what was left of the wait after a pass it %s', async (_, erase) => {
      // Typed a character a second after a 3s `delay` and held for 100ms,
      // and an erased line is deleted at 10ms a character, so the line is
      // gone at 4,110ms when it is erased and at 4,100ms when it is cleared.
      // The next pass types its first character a second after that.
      const typing = (paused: boolean) => (
        <PlAnimateTyping
          className="typing-under-test"
          text="Hi"
          delay={3000}
          speed={1}
          eraseSpeed={100}
          hold={100}
          erase={erase}
          repeat={2}
          paused={paused}
          caret={false}
        />
      );
      const screen = await render(typing(false));
      const root = document.querySelector('.typing-under-test');
      const gone = erase ? 4110 : 4100;

      await advance(gone);

      expect(visible(root)).toBe('');

      await advance(400);
      await pauseAndLetGo(screen, typing);
      await advance(599);

      // 600ms of the wait was left. It used to wait the whole `delay`.
      expect(visible(root)).toBe('');

      await advance(1);

      expect(visible(root)).toBe('H');
    });
  });
});
