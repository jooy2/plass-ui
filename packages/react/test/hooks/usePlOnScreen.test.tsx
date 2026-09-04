import { useRef } from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { usePlOnScreen, type PlOnScreenOptions } from 'plass-ui';

/** A tall page with the watched element a long way down a scrolling panel. */
function Subject({ options, gap = 600 }: { options?: PlOnScreenOptions; gap?: number }) {
  const panel = useRef<HTMLDivElement>(null);
  const target = useRef<HTMLDivElement>(null);
  const seen = usePlOnScreen(target, { root: panel, ...options });

  return (
    <div>
      <span data-testid="seen">{String(seen)}</span>
      <div ref={panel} className="panel-under-test" style={{ height: '200px', overflow: 'auto' }}>
        <div style={{ height: `${gap}px` }} />
        <div ref={target} style={{ height: '40px' }}>
          target
        </div>
        <div style={{ height: '600px' }} />
      </div>
    </div>
  );
}

function seen(): string {
  return document.querySelector('[data-testid="seen"]')!.textContent ?? '';
}

async function scrollPanel(to: number) {
  document.querySelector<HTMLElement>('.panel-under-test')!.scrollTop = to;

  await new Promise((resolve) => setTimeout(resolve, 60));
}

describe('usePlOnScreen', () => {
  it('is false before the element has been seen', async () => {
    await render(<Subject />);

    await expect.poll(() => seen()).toBe('false');
  });

  it('turns true when it arrives', async () => {
    await render(<Subject />);

    await scrollPanel(500);

    await expect.poll(() => seen()).toBe('true');
  });

  it('stays true once it has been seen', async () => {
    await render(<Subject />);

    await scrollPanel(500);
    await expect.poll(() => seen()).toBe('true');

    await scrollPanel(0);

    // The question a caller almost always has is "has this been seen yet".
    await expect.poll(() => seen()).toBe('true');
  });

  it('keeps answering when it was asked to', async () => {
    await render(<Subject options={{ once: false }} />);

    await scrollPanel(500);
    await expect.poll(() => seen()).toBe('true');

    await scrollPanel(0);

    await expect.poll(() => seen()).toBe('false');
  });

  it('counts an element that is still outside when a margin says so', async () => {
    await render(<Subject options={{ rootMargin: '400px' }} />);

    // A screen early, which is what a lazily loaded picture wants.
    await scrollPanel(100);

    await expect.poll(() => seen()).toBe('true');
  });
});
