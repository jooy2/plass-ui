/**
 * What `lazyPart` does when its chunk cannot be had: tries once more, and then
 * renders nothing and says so, rather than throwing to an error boundary.
 *
 * The loaders here are functions that fail as often as a test asks, which is
 * what makes the retry testable in every engine. A real module that failed is
 * remembered by Chromium for the life of the page, so the second try of a real
 * `import()` there fails without a request; `test/package/lazy-failures.test.tsx`
 * is the same question asked of the four components, over a real network.
 */
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import * as React from 'react';
import { lazyPart } from '../../src/internal/lazy';

function Greeting({ name }: { name: string }) {
  return <p data-testid="greeting">Hello, {name}</p>;
}

/** A loader that fails its first `failures` calls and then hands over `Greeting`. */
function flaky(failures: number) {
  let calls = 0;

  return vi.fn(async () => {
    calls += 1;

    if (calls <= failures) {
      throw new TypeError('Failed to fetch dynamically imported module');
    }

    return Greeting;
  });
}

/** What reaches a boundary, if anything does. */
class Boundary extends React.Component<
  { onError: (error: unknown) => void; children: React.ReactNode },
  { failed: boolean }
> {
  state = { failed: false };

  static getDerivedStateFromError() {
    return { failed: true };
  }

  componentDidCatch(error: unknown) {
    this.props.onError(error);
  }

  render() {
    return this.state.failed ? <p>Boundary</p> : this.props.children;
  }
}

function Page({
  Part,
  onError,
  onUnavailable,
  show = true
}: {
  Part: ReturnType<typeof lazyPart<{ name: string }>>;
  onError: (error: unknown) => void;
  onUnavailable?: () => void;
  show?: boolean;
}) {
  return (
    <Boundary onError={onError}>
      <p data-testid="page">The page</p>
      {show ? (
        <React.Suspense fallback={<p data-testid="waiting">Waiting</p>}>
          <Part name="Ada" onUnavailable={onUnavailable} />
        </React.Suspense>
      ) : null}
    </Boundary>
  );
}

describe('lazyPart', () => {
  it('renders what the loader hands over, without the prop it adds', async () => {
    const load = flaky(0);
    const Part = lazyPart(load);
    const onUnavailable = vi.fn();

    const screen = await render(
      <Page Part={Part} onError={vi.fn()} onUnavailable={onUnavailable} />
    );

    await expect.element(screen.getByTestId('greeting')).toHaveTextContent('Hello, Ada');
    expect(load).toHaveBeenCalledTimes(1);
    expect(onUnavailable).not.toHaveBeenCalled();
  });

  it('tries a second time when the first fails, and opens normally', async () => {
    const load = flaky(1);
    const Part = lazyPart(load);
    const onUnavailable = vi.fn();
    const onError = vi.fn();

    const screen = await render(
      <Page Part={Part} onError={onError} onUnavailable={onUnavailable} />
    );

    await expect.element(screen.getByTestId('greeting')).toHaveTextContent('Hello, Ada');
    expect(load).toHaveBeenCalledTimes(2);
    expect(onUnavailable).not.toHaveBeenCalled();
    expect(onError).not.toHaveBeenCalled();
  });

  it('steps back after a second failure, leaving the page and the boundary alone', async () => {
    const load = flaky(2);
    const Part = lazyPart(load);
    const onUnavailable = vi.fn();
    const onError = vi.fn();

    const screen = await render(
      <Page Part={Part} onError={onError} onUnavailable={onUnavailable} />
    );

    await expect.poll(() => onUnavailable.mock.calls.length).toBe(1);

    expect(load).toHaveBeenCalledTimes(2);
    expect(onError).not.toHaveBeenCalled();
    await expect.element(screen.getByTestId('page')).toBeVisible();
    expect(screen.getByTestId('greeting').query()).toBeNull();
    expect(screen.getByTestId('waiting').query()).toBeNull();
    expect(screen.getByText('Boundary').query()).toBeNull();
  });

  it('tries again on the next mount after it has stepped back', async () => {
    const load = flaky(2);
    const Part = lazyPart(load);
    const onUnavailable = vi.fn();
    const onError = vi.fn();

    const screen = await render(
      <Page Part={Part} onError={onError} onUnavailable={onUnavailable} />
    );

    await expect.poll(() => onUnavailable.mock.calls.length).toBe(1);

    // Its owner takes it away, as the four components do, and asks again.
    await screen.rerender(
      <Page Part={Part} onError={onError} onUnavailable={onUnavailable} show={false} />
    );
    await screen.rerender(<Page Part={Part} onError={onError} onUnavailable={onUnavailable} />);

    await expect.element(screen.getByTestId('greeting')).toHaveTextContent('Hello, Ada');
    expect(load).toHaveBeenCalledTimes(3);
    expect(onUnavailable).toHaveBeenCalledTimes(1);
    expect(onError).not.toHaveBeenCalled();
  });

  it('does not try again while the part that failed is still mounted', async () => {
    const load = flaky(Infinity);
    const Part = lazyPart(load);
    const onUnavailable = vi.fn();

    const screen = await render(
      <Page Part={Part} onError={vi.fn()} onUnavailable={onUnavailable} />
    );

    await expect.poll(() => onUnavailable.mock.calls.length).toBe(1);

    // A render of the same mount is not a new attempt, so an owner that is slow
    // to take it away does not set off a loop of downloads.
    await screen.rerender(<Page Part={Part} onError={vi.fn()} onUnavailable={onUnavailable} />);
    await new Promise((done) => setTimeout(done, 50));

    expect(load).toHaveBeenCalledTimes(2);
    expect(onUnavailable).toHaveBeenCalledTimes(1);
  });

  it('says it is unavailable once under StrictMode, which runs every effect twice', async () => {
    const load = flaky(2);
    const Part = lazyPart(load);
    const onUnavailable = vi.fn();
    const onError = vi.fn();

    const screen = await render(
      <React.StrictMode>
        <Page Part={Part} onError={onError} onUnavailable={onUnavailable} />
      </React.StrictMode>
    );

    await expect.poll(() => onUnavailable.mock.calls.length).toBe(1);
    await new Promise((done) => setTimeout(done, 50));

    expect(onUnavailable).toHaveBeenCalledTimes(1);
    expect(load).toHaveBeenCalledTimes(2);
    expect(onError).not.toHaveBeenCalled();
    await expect.element(screen.getByTestId('page')).toBeVisible();
  });

  it('shares one download between a preload and a render', async () => {
    const load = flaky(0);
    const Part = lazyPart(load);

    Part.preload();
    Part.preload();

    const screen = await render(<Page Part={Part} onError={vi.fn()} />);

    await expect.element(screen.getByTestId('greeting')).toBeVisible();
    expect(load).toHaveBeenCalledTimes(1);
  });

  it('keeps a failed preload quiet, and lets the render try again', async () => {
    const load = flaky(2);
    const Part = lazyPart(load);
    const rejections = vi.fn();

    window.addEventListener('unhandledrejection', rejections);

    try {
      Part.preload();
      await expect.poll(() => load.mock.calls.length).toBe(2);
      await new Promise((done) => setTimeout(done, 50));

      const screen = await render(<Page Part={Part} onError={vi.fn()} />);

      await expect.element(screen.getByTestId('greeting')).toBeVisible();
      expect(load).toHaveBeenCalledTimes(3);
      expect(rejections).not.toHaveBeenCalled();
    } finally {
      window.removeEventListener('unhandledrejection', rejections);
    }
  });
});
