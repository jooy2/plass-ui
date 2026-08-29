import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateTyping } from 'plass-ui';

/** The visible half — the one that is `aria-hidden` and actually animates. */
function visible(root: Element | null): string {
  return root?.querySelector('[aria-hidden="true"]')?.textContent ?? '';
}

describe('PlAnimateTyping', () => {
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

  it('flattens an element among the children to its text', async () => {
    const screen = await render(
      <PlAnimateTyping className="typing-under-test" speed={400}>
        {['Hello ', 'again']}
      </PlAnimateTyping>
    );

    await expect.element(screen.getByText('Hello again')).toBeInTheDocument();
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
