import { useRef } from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { usePlDisclosure } from 'plass-ui';

/**
 * Renders the hook and keeps a note of whether each callback is the same object
 * it was on the render before — which is the thing the hook exists for.
 */
function Subject({ initial }: { initial?: boolean }) {
  const disclosure = usePlDisclosure(initial);
  const first = useRef(disclosure.onOpen);
  const stable = first.current === disclosure.onOpen;

  return (
    <div>
      <span data-testid="open">{String(disclosure.open)}</span>
      <span data-testid="stable">{String(stable)}</span>
      <button type="button" onClick={disclosure.onOpen}>
        open
      </button>
      <button type="button" onClick={disclosure.onClose}>
        close
      </button>
      <button type="button" onClick={disclosure.onToggle}>
        toggle
      </button>
      <button type="button" onClick={() => disclosure.setOpen(true)}>
        set
      </button>
    </div>
  );
}

function open(): string {
  return document.querySelector('[data-testid="open"]')!.textContent ?? '';
}

function press(label: string) {
  const button = Array.from(document.querySelectorAll('button')).find(
    (one) => one.textContent === label
  )!;

  button.click();
}

describe('usePlDisclosure', () => {
  it('starts closed', async () => {
    await render(<Subject />);

    expect(open()).toBe('false');
  });

  it('starts open when it was told to', async () => {
    await render(<Subject initial />);

    expect(open()).toBe('true');
  });

  it('opens, closes and turns round', async () => {
    await render(<Subject />);

    press('open');
    await expect.poll(() => open()).toBe('true');

    press('close');
    await expect.poll(() => open()).toBe('false');

    press('toggle');
    await expect.poll(() => open()).toBe('true');

    press('toggle');
    await expect.poll(() => open()).toBe('false');
  });

  it('takes a value for the caller who already has one', async () => {
    await render(<Subject />);

    press('set');

    await expect.poll(() => open()).toBe('true');
  });

  it('hands back the same callbacks after the value has changed', async () => {
    await render(<Subject />);

    press('toggle');
    await expect.poll(() => open()).toBe('true');

    // The reason it is a hook rather than a snippet: an inline
    // `() => setOpen(false)` handed to a memoised trigger defeats the memo.
    expect(document.querySelector('[data-testid="stable"]')!.textContent).toBe('true');
  });
});
