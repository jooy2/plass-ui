import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlPane, PlPanes } from 'plass-ui';

/**
 * The `flex` shorthand each pane ended up with.
 *
 * The browser normalises what the component writes — `calc((100% - 8px) * 0.5)`
 * comes back as `calc(50% - 4px)` — so these are the resolved forms rather than
 * the ones in the source.
 */
function bases(): string[] {
  return Array.from(
    document.querySelectorAll<HTMLElement>('.split-under-test > div:not([role="separator"])')
  ).map((element) => element.style.flex);
}

/** Every handle between the panes, in order. */
function handles(): HTMLElement[] {
  return Array.from(document.querySelectorAll<HTMLElement>('[role="separator"]'));
}

/** A split of a stated width, so a percentage means a number of pixels. */
function Split({ children, width = 400 }: { children: React.ReactNode; width?: number }) {
  return (
    <div style={{ width: `${width}px`, height: '200px' }}>
      <PlPanes className="split-under-test">{children}</PlPanes>
    </div>
  );
}

describe('PlPanes', () => {
  describe('the split', () => {
    it('puts a handle between every pair of panes and none at the ends', async () => {
      await render(
        <Split>
          <PlPane>One</PlPane>
          <PlPane>Two</PlPane>
          <PlPane>Three</PlPane>
        </Split>
      );

      expect(handles()).toHaveLength(2);
    });

    it('needs no handle at all for one pane', async () => {
      await render(
        <Split>
          <PlPane>Only</PlPane>
        </Split>
      );

      expect(handles()).toHaveLength(0);
    });

    it('splits what is left over evenly between the panes that named nothing', async () => {
      await render(
        <Split>
          <PlPane>One</PlPane>
          <PlPane>Two</PlPane>
        </Split>
      );

      const [first, second] = bases();

      expect(first).toBe(second);
      expect(first).toBe('0 0 calc(50% - 4px)');
    });

    it('turns a length into a share of the space', async () => {
      await render(
        <Split width={408}>
          <PlPane defaultSize="100px">Sidebar</PlPane>
          <PlPane>Body</PlPane>
        </Split>
      );

      // 408 less the 8px handle is 400, so 100px is a quarter of it.
      expect(bases()[0]).toBe('0 0 calc(25% - 2px)');
    });

    it('reads a bare number as a percentage', async () => {
      await render(
        <Split>
          <PlPane defaultSize={25}>Sidebar</PlPane>
          <PlPane>Body</PlPane>
        </Split>
      );

      expect(bases()[0]).toBe('0 0 calc(25% - 2px)');
    });

    it('leaves the gutters out of what the panes divide', async () => {
      await render(
        <Split>
          <PlPane>One</PlPane>
          <PlPane>Two</PlPane>
        </Split>
      );

      // One handle at `md` is 8px, and it comes off the top before the panes
      // divide what is left: half of `100% - 8px` is `50% - 4px`.
      expect(bases()[0]).toBe('0 0 calc(50% - 4px)');
    });

    it('stacks the panes when it is told to', async () => {
      await render(
        <div style={{ width: '400px', height: '200px' }}>
          <PlPanes className="split-under-test" orientation="vertical">
            <PlPane>One</PlPane>
            <PlPane>Two</PlPane>
          </PlPanes>
        </div>
      );

      expect(document.querySelector('.split-under-test')).toHaveClass('flex-col');
      expect(handles()[0]).toHaveAttribute('aria-orientation', 'horizontal');
    });
  });

  describe('a handle', () => {
    it('is a separator that says how far along it is', async () => {
      await render(
        <Split>
          <PlPane defaultSize={30}>One</PlPane>
          <PlPane>Two</PlPane>
        </Split>
      );

      const handle = handles()[0];

      expect(handle).toHaveAttribute('aria-orientation', 'vertical');
      expect(handle).toHaveAttribute('aria-valuenow', '30');
      expect(handle).toHaveAttribute('aria-valuemin', '0');
      expect(handle).toHaveAttribute('aria-valuemax', '100');
    });

    it('is a tab stop while it can be dragged', async () => {
      await render(
        <Split>
          <PlPane>One</PlPane>
          <PlPane>Two</PlPane>
        </Split>
      );

      expect(handles()[0]).toHaveAttribute('tabindex', '0');
    });

    it('leaves the tab order when the split is a layout rather than a control', async () => {
      await render(
        <div style={{ width: '400px', height: '200px' }}>
          <PlPanes className="split-under-test" resizable={false}>
            <PlPane>One</PlPane>
            <PlPane>Two</PlPane>
          </PlPanes>
        </div>
      );

      const handle = handles()[0];

      expect(handle).toHaveAttribute('tabindex', '-1');
      expect(handle).toHaveAttribute('aria-disabled', 'true');
    });

    it('is a track rather than a one-pixel line', async () => {
      await render(
        <Split>
          <PlPane>One</PlPane>
          <PlPane>Two</PlPane>
        </Split>
      );

      // What is drawn is a hairline; what can be grabbed is the track around
      // it. The width itself is the stylesheet's, and this file runs with none.
      expect(handles()[0]).toHaveClass('basis-2');
    });
  });

  describe('the keyboard', () => {
    it('moves the boundary with the arrow keys', async () => {
      await render(
        <Split>
          <PlPane>One</PlPane>
          <PlPane>Two</PlPane>
        </Split>
      );

      const before = bases()[0];

      handles()[0].focus();
      await userPress('ArrowRight');

      expect(bases()[0]).not.toBe(before);
    });

    it('reports the settled split, because a key press is a whole gesture', async () => {
      const settled = vi.fn();
      await render(
        <div style={{ width: '400px', height: '200px' }}>
          <PlPanes className="split-under-test" onResizeEnd={settled}>
            <PlPane>One</PlPane>
            <PlPane>Two</PlPane>
          </PlPanes>
        </div>
      );

      handles()[0].focus();
      await userPress('ArrowRight');

      expect(settled).toHaveBeenCalledOnce();
      expect(settled.mock.calls[0][0]).toHaveLength(2);
    });

    it('never drags a pane past its minimum', async () => {
      await render(
        <Split>
          <PlPane minSize="50%">One</PlPane>
          <PlPane>Two</PlPane>
        </Split>
      );

      handles()[0].focus();

      for (let press = 0; press < 20; press++) {
        await userPress('ArrowLeft');
      }

      // Held at the floor rather than dragged through it.
      expect(bases()[0]).toBe('0 0 calc(50% - 4px)');
    });
  });

  describe('a pane', () => {
    it('draws no surface of its own', async () => {
      await render(
        <Split>
          <PlPane className="pane-under-test">One</PlPane>
          <PlPane>Two</PlPane>
        </Split>
      );

      const element = document.querySelector('.pane-under-test');

      expect(element?.className).not.toMatch(/bg-/);
      expect(element).toHaveClass('overflow-auto');
    });

    it('renders what it was given', async () => {
      const screen = await render(
        <Split>
          <PlPane>
            <span>Inside</span>
          </PlPane>
          <PlPane>Two</PlPane>
        </Split>
      );

      await expect.element(screen.getByText('Inside')).toBeInTheDocument();
    });

    it('keeps its sizing props off the DOM', async () => {
      await render(
        <Split>
          <PlPane className="pane-under-test" defaultSize={30} minSize="10%" maxSize="90%">
            One
          </PlPane>
          <PlPane>Two</PlPane>
        </Split>
      );

      const element = document.querySelector('.pane-under-test');

      expect(element).not.toHaveAttribute('defaultsize');
      expect(element).not.toHaveAttribute('minsize');
    });
  });
});

/** A key press on whatever currently holds focus. */
async function userPress(key: string): Promise<void> {
  const element = document.activeElement as HTMLElement | null;

  element?.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true }));

  await new Promise((resolve) => setTimeout(resolve, 0));
}
