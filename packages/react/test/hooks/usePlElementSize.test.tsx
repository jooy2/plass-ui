import { useRef } from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { usePlElementSize } from 'plass-ui';

function Subject({ width, height }: { width: number; height: number }) {
  const box = useRef<HTMLDivElement>(null);
  const size = usePlElementSize(box);

  return (
    <div>
      <div ref={box} style={{ width: `${width}px`, height: `${height}px`, padding: '10px' }} />
      <span data-testid="size">{size ? `${size.width}x${size.height}` : 'null'}</span>
    </div>
  );
}

function Unmounted() {
  const box = useRef<HTMLDivElement>(null);
  const size = usePlElementSize(box);

  return <span data-testid="size">{size ? 'measured' : 'null'}</span>;
}

/** The last one rendered: the resize test draws a second subject beside the first. */
function reported(): string {
  const all = document.querySelectorAll('[data-testid="size"]');

  return all[all.length - 1].textContent ?? '';
}

describe('usePlElementSize', () => {
  it('measures the element it was pointed at', async () => {
    await render(<Subject width={200} height={80} />);

    // `width: 200px` is the content width, and the 10px padding sits outside
    // it: the border box is 220 × 100 and the content box is what was asked for.
    await expect.poll(() => reported()).toBe('200x80');
  });

  it('reports the content box rather than the border box', async () => {
    await render(<Subject width={200} height={80} />);

    // A hand-written version nearly always reports this number instead, and it
    // is the wrong one for the question that made somebody measure at all.
    await expect.poll(() => reported()).not.toBe('220x100');
  });

  it('follows the element when it changes size', async () => {
    await render(<Subject width={200} height={80} />);

    await expect.poll(() => reported()).toBe('200x80');

    await render(<Subject width={300} height={120} />);

    await expect.poll(() => reported()).toBe('300x120');
  });

  it('says nothing rather than zero when there is nothing to measure', async () => {
    await render(<Unmounted />);

    // Guessing `0` would let a caller divide by it.
    expect(reported()).toBe('null');
  });
});
