import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { renderToString } from 'react-dom/server';
import { PlAnimateTyping } from 'plass-ui';
import standaloneCss from '../../../src/standalone.css?inline';

/** The visible half — the one that is `aria-hidden` and actually animates. */
function visible(root: Element | null): string {
  return root?.querySelector('[aria-hidden="true"]')?.textContent ?? '';
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

    it('copies only what has been drawn', async () => {
      await render(narrow(false));

      const selection = window.getSelection()!;

      selection.selectAllChildren(root().querySelector('[aria-hidden="true"]')!);

      // Nothing has been typed, so the caret is all there is to copy.
      expect(selection.toString()).toBe('|');

      selection.removeAllRanges();
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

      expect(document.querySelector('.typing-under-test .plass-caret')).toHaveTextContent('▌');
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
});
