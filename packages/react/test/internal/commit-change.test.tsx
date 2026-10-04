/**
 * When `useCommitChange` calls back: on the first commit, and on a later one
 * only when it changed a dependency, the markup under the element or the
 * direction above it. A parent rendering again with nothing changed is the case
 * it exists for, and it has to cost nothing.
 */
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import * as React from 'react';
import { useCommitChange } from '../../src/internal/commit-change';
import { committed } from '../support/timing';

interface BoxProps {
  size?: string;
  onChange: () => void;
  children?: React.ReactNode;
}

function Box({ size = 'md', onChange, children }: BoxProps) {
  const ref = React.useRef<HTMLDivElement>(null);

  useCommitChange(ref, [size], onChange);

  return <div ref={ref}>{children}</div>;
}

/** A child that changes its own text, in a commit the box takes no part in. */
function Ticker({ tickRef }: { tickRef: React.RefObject<(() => void) | null> }) {
  const [count, setCount] = React.useState(0);

  React.useEffect(() => {
    tickRef.current = () => setCount((value) => value + 1);
  }, [tickRef]);

  return <span>{count}</span>;
}

describe('useCommitChange', () => {
  it('calls back on the first commit', async () => {
    const onChange = vi.fn();

    await render(<Box onChange={onChange} />);

    expect(onChange).toHaveBeenCalledTimes(1);
  });

  it('does not call back when a parent renders again with nothing changed', async () => {
    const onChange = vi.fn();
    const screen = await render(
      <Box onChange={onChange}>
        <span className="one">One</span>
      </Box>
    );

    await screen.rerender(
      <Box onChange={onChange}>
        <span className="one">One</span>
      </Box>
    );

    expect(onChange).toHaveBeenCalledTimes(1);
  });

  it('calls back when a dependency changes', async () => {
    const onChange = vi.fn();
    const screen = await render(<Box onChange={onChange} />);

    await screen.rerender(<Box size="lg" onChange={onChange} />);

    expect(onChange).toHaveBeenCalledTimes(2);
  });

  it('calls back when the commit adds, removes or moves a child', async () => {
    const onChange = vi.fn();
    const box = (names: string[]) => (
      <Box onChange={onChange}>
        {names.map((name) => (
          <span key={name}>{name}</span>
        ))}
      </Box>
    );
    const screen = await render(box(['One', 'Two']));

    await screen.rerender(box(['Two', 'One']));
    expect(onChange).toHaveBeenCalledTimes(2);

    await screen.rerender(box(['Two', 'One', 'Three']));
    expect(onChange).toHaveBeenCalledTimes(3);

    await screen.rerender(box(['One', 'Three']));
    expect(onChange).toHaveBeenCalledTimes(4);
  });

  it('calls back when the commit edits a child’s text or class', async () => {
    const onChange = vi.fn();
    const box = (text: string, className: string) => (
      <Box onChange={onChange}>
        <span className={className}>{text}</span>
      </Box>
    );
    const screen = await render(box('One', 'a'));

    await screen.rerender(box('Uno', 'a'));
    expect(onChange).toHaveBeenCalledTimes(2);

    await screen.rerender(box('Uno', 'b'));
    expect(onChange).toHaveBeenCalledTimes(3);
  });

  it('calls back when the direction above it turns over in the commit', async () => {
    const onChange = vi.fn();
    const page = (dir: string) => (
      <div dir={dir}>
        <Box onChange={onChange}>
          <span>One</span>
        </Box>
      </div>
    );
    const screen = await render(page('ltr'));

    await screen.rerender(page('rtl'));

    expect(onChange).toHaveBeenCalledTimes(2);
  });

  it('leaves a child that changes itself to the commit it makes', async () => {
    const onChange = vi.fn();
    const tickRef: React.RefObject<(() => void) | null> = { current: null };

    await render(
      <Box onChange={onChange}>
        <Ticker tickRef={tickRef} />
      </Box>
    );

    await committed(() => tickRef.current?.());
    await expect.poll(() => document.body.textContent).toContain('1');

    expect(onChange).toHaveBeenCalledTimes(1);
  });

  it('does not count a record the last commit left behind against the next one', async () => {
    const onChange = vi.fn();
    const tickRef: React.RefObject<(() => void) | null> = { current: null };
    const box = (size: string) => (
      <Box size={size} onChange={onChange}>
        <Ticker tickRef={tickRef} />
      </Box>
    );
    const screen = await render(box('md'));

    // The child edits its own text, which the browser delivers to nobody
    // before the box renders again.
    await committed(() => tickRef.current?.());
    await new Promise((resolve) => setTimeout(resolve, 0));
    await screen.rerender(box('md'));

    expect(onChange).toHaveBeenCalledTimes(1);
  });
});
