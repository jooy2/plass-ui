import { useRef } from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { usePlElementSize } from 'plass-ui';

function Subject({ width, height }: { width: number; height: number }) {
  const box = useRef<HTMLDivElement>(null);
  const size = usePlElementSize(box);

  return (
    <div>
      <div
        ref={box}
        data-testid="box"
        style={{ width: `${width}px`, height: `${height}px`, padding: '10px' }}
      />
      <span data-testid="size">{size ? `${size.width}x${size.height}` : 'null'}</span>
    </div>
  );
}

function Unmounted() {
  const box = useRef<HTMLDivElement>(null);
  const size = usePlElementSize(box);

  return <span data-testid="size">{size ? 'measured' : 'null'}</span>;
}

function Late({ ready }: { ready: boolean }) {
  const box = useRef<HTMLDivElement>(null);
  const size = usePlElementSize(box);

  return (
    <div>
      {ready ? <div ref={box} style={{ width: '120px', height: '30px' }} /> : <span>Loading</span>}
      <span data-testid="size">{size ? `${size.width}x${size.height}` : 'null'}</span>
    </div>
  );
}

/** What the subject says the hook last reported. */
function reported(): string {
  return document.querySelector('[data-testid="size"]')?.textContent ?? '';
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

    const box = document.querySelector<HTMLElement>('[data-testid="box"]')!;

    // Written straight onto the element, so nothing renders again and the
    // measurement taken on mount is not taken a second time: only the observer
    // can carry the new size back to the same output.
    box.style.width = '300px';
    box.style.height = '120px';

    await expect.poll(() => reported()).toBe('300x120');
  });

  it('measures an element that is attached after the first render', async () => {
    const screen = await render(<Late ready={false} />);

    expect(reported()).toBe('null');

    await screen.rerender(<Late ready />);

    await expect.poll(() => reported()).toBe('120x30');

    await screen.rerender(<Late ready={false} />);

    await expect.poll(() => reported()).toBe('null');
  });

  it('says nothing rather than zero when there is nothing to measure', async () => {
    await render(<Unmounted />);

    // Guessing `0` would let a caller divide by it.
    expect(reported()).toBe('null');
  });
});
