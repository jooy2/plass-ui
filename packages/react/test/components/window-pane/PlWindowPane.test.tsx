import { describe, expect, it, vi } from 'vitest';
import { PlWindowPane } from 'plass-ui';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { press } from '../../support/keys';
import { moveMouseOntoPage } from '../../support/pointer';

describe('PlWindowPane', () => {
  describe('rendering', () => {
    it('names the window after its title', async () => {
      const screen = await render(<PlWindowPane title="Notes">Body</PlWindowPane>);

      await expect.element(screen.getByRole('group', { name: 'Notes' })).toBeInTheDocument();
      await expect.element(screen.getByText('Body')).toBeInTheDocument();
    });

    it('draws the three buttons as real buttons with real names', async () => {
      const screen = await render(<PlWindowPane title="Notes" />);

      for (const name of ['Minimize', 'Maximize', 'Close']) {
        await expect.element(screen.getByRole('button', { name })).toBeInTheDocument();
      }
    });

    it('draws only the buttons it was given', async () => {
      const screen = await render(<PlWindowPane title="Notes" controls={['close']} />);

      await expect.element(screen.getByRole('button', { name: 'Close' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Minimize' }).query()).toBeNull();
    });

    it('draws none at all when asked', async () => {
      const screen = await render(<PlWindowPane title="Notes" controls={false} />);

      await expect.element(screen.getByRole('group', { name: 'Notes' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Close' }).query()).toBeNull();
    });

    it('takes an icon and actions in the bar', async () => {
      const screen = await render(
        <PlWindowPane title="Notes" icon={<span>◆</span>} actions={<button>Share</button>} />
      );

      await expect.element(screen.getByText('◆')).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Share' })).toBeInTheDocument();
    });

    it('takes every system it names', async () => {
      const screen = await render(<PlWindowPane title="Notes" os="macos" />);

      await expect.element(screen.getByRole('group', { name: 'Notes' })).toBeInTheDocument();

      for (const os of [
        'macosx',
        'windows11',
        'windows10',
        'windows8',
        'windows7',
        'windowsxp',
        'linux'
      ] as const) {
        await screen.rerender(<PlWindowPane title="Notes" os={os} />);
        await expect.element(screen.getByRole('group', { name: 'Notes' })).toBeInTheDocument();
      }
    });
  });

  describe('dragging', () => {
    it("keeps a finger's drag on the bar only while the bar moves the window", async () => {
      const screen = await render(
        <PlWindowPane title="Notes" draggable>
          Body
        </PlWindowPane>
      );
      const bar = () => screen.getByText('Notes').element().closest('.select-none');

      expect(bar()).toHaveClass('touch-none');

      await screen.getByRole('button', { name: 'Maximize' }).click();

      await expect.poll(() => bar()?.classList.contains('touch-none')).toBe(false);
    });

    it('gives the selection back and reports nothing when it goes away in the middle of a drag', async () => {
      const onOffsetChange = vi.fn();
      const screen = await render(
        <PlWindowPane title="Notes" draggable onOffsetChange={onOffsetChange}>
          Body
        </PlWindowPane>
      );

      const bar = screen.getByText('Notes').element().closest<HTMLElement>('.select-none')!;
      const pointerId = await moveMouseOntoPage();
      const selection = () => document.body.style.getPropertyValue('-webkit-user-select');

      document.body.style.setProperty('-webkit-user-select', 'text');

      try {
        bar.dispatchEvent(
          new PointerEvent('pointerdown', {
            bubbles: true,
            pointerType: 'mouse',
            pointerId,
            button: 0,
            buttons: 1,
            clientX: 100,
            clientY: 10
          })
        );

        expect(bar).toHaveAttribute('data-dragging', 'true');
        expect(selection()).toBe('none');

        // No `pointerup` is coming: the window is gone before the button is.
        await screen.unmount();

        expect(selection()).toBe('text');

        // A move that reaches the bar it left behind moves nothing.
        bar.dispatchEvent(
          new PointerEvent('pointermove', {
            bubbles: true,
            pointerType: 'mouse',
            pointerId,
            buttons: 1,
            clientX: 140,
            clientY: 30
          })
        );

        expect(onOffsetChange).not.toHaveBeenCalled();
      } finally {
        document.body.style.removeProperty('-webkit-user-select');
      }
    });
  });

  describe('moving from the keyboard', () => {
    /** The window itself, which is what `offset` moves. */
    const pane = (screen: { container: HTMLElement }) =>
      screen.container.querySelector<HTMLElement>('.plass-window')!;

    /**
     * One task, so the render a key press asked for has landed before the next
     * press reads the window's offset. Two presses a reader makes are two tasks
     * anyway; two dispatched back to back are not.
     */
    const settle = () => new Promise((resolve) => setTimeout(resolve, 0));

    it('offers the bar to the keyboard only while the bar drags', async () => {
      const screen = await render(<PlWindowPane title="Notes">Body</PlWindowPane>);

      await expect.element(screen.getByRole('group', { name: 'Notes' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Move window' }).query()).toBeNull();

      await screen.rerender(
        <PlWindowPane title="Notes" draggable>
          Body
        </PlWindowPane>
      );

      const handle = screen.getByRole('button', { name: 'Move window' });

      await expect.element(handle).toHaveAttribute('tabindex', '0');
      // First in the window, ahead of the three buttons in the same bar.
      expect(
        handle
          .element()
          .compareDocumentPosition(screen.getByRole('button', { name: 'Close' }).element()) &
          Node.DOCUMENT_POSITION_FOLLOWING
      ).toBeTruthy();

      // A maximized window fills what holds it and has nowhere to go.
      await screen.rerender(
        <PlWindowPane title="Notes" draggable maximized>
          Body
        </PlWindowPane>
      );

      await expect
        .poll(() => screen.getByRole('button', { name: 'Move window' }).query())
        .toBeNull();
    });

    it('takes its name from moveLabel', async () => {
      const screen = await render(<PlWindowPane title="Notes" draggable moveLabel="Drag Notes" />);

      await expect.element(screen.getByRole('button', { name: 'Drag Notes' })).toBeInTheDocument();
    });

    it('moves a step for each arrow key, and four steps with Shift', async () => {
      const onOffsetChange = vi.fn();
      const screen = await render(
        <PlWindowPane
          title="Notes"
          draggable
          position="fixed"
          width={200}
          defaultOffset={{ x: 40, y: 40 }}
          onOffsetChange={onOffsetChange}
        >
          Body
        </PlWindowPane>
      );

      const handle = screen.getByRole('button', { name: 'Move window' }).element();

      handle.focus();
      press(handle, 'ArrowRight');

      await expect.poll(() => pane(screen).style.left).toBe('56px');
      expect(onOffsetChange).toHaveBeenLastCalledWith({ x: 56, y: 40 });

      press(handle, 'ArrowDown', { shiftKey: true });

      await expect.poll(() => pane(screen).style.top).toBe('104px');

      press(handle, 'ArrowLeft');
      await settle();
      press(handle, 'ArrowUp');

      await expect.poll(() => onOffsetChange.mock.lastCall?.[0]).toEqual({ x: 40, y: 88 });
    });

    it('leaves a key it does not move by to the page', async () => {
      const onOffsetChange = vi.fn();
      const screen = await render(
        <PlWindowPane title="Notes" draggable position="fixed" onOffsetChange={onOffsetChange}>
          Body
        </PlWindowPane>
      );

      const handle = screen.getByRole('button', { name: 'Move window' }).element();
      const event = new KeyboardEvent('keydown', {
        key: 'ArrowRight',
        ctrlKey: true,
        bubbles: true,
        cancelable: true
      });

      handle.focus();
      handle.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(false);
      expect(onOffsetChange).not.toHaveBeenCalled();
    });

    it('stops where the title bar would leave the screen', async () => {
      const onOffsetChange = vi.fn();
      const view = document.documentElement.clientWidth;
      const screen = await render(
        <PlWindowPane
          title="Notes"
          draggable
          position="fixed"
          width={200}
          defaultOffset={{ x: 0, y: 0 }}
          onOffsetChange={onOffsetChange}
        >
          Body
        </PlWindowPane>
      );

      const handle = screen.getByRole('button', { name: 'Move window' }).element();

      handle.focus();

      // Already against the top and the left edges, so these move nothing.
      press(handle, 'ArrowLeft');
      press(handle, 'ArrowUp', { shiftKey: true });

      expect(onOffsetChange).not.toHaveBeenCalled();

      // As far to the right as it can go, and then no further.
      for (let presses = 0; presses < Math.ceil(view / 64) + 2; presses += 1) {
        press(handle, 'ArrowRight', { shiftKey: true });
        await settle();
      }

      await expect.poll(() => pane(screen).getBoundingClientRect().right).toBeCloseTo(view, 0);
      expect(onOffsetChange.mock.lastCall?.[0].x).toBeCloseTo(
        view - pane(screen).getBoundingClientRect().width,
        0
      );
    });

    it('moves the way the arrow points under RTL', async () => {
      const screen = await render(
        <div dir="rtl">
          <PlWindowPane
            title="Notes"
            draggable
            position="fixed"
            width={200}
            defaultOffset={{ x: 40, y: 40 }}
          >
            Body
          </PlWindowPane>
        </div>
      );

      const handle = screen.getByRole('button', { name: 'Move window' }).element();
      const before = pane(screen).getBoundingClientRect().left;

      handle.focus();
      press(handle, 'ArrowRight');

      await expect
        .poll(() => pane(screen).getBoundingClientRect().left)
        .toBeCloseTo(before + 16, 0);

      press(handle, 'ArrowLeft');

      await expect.poll(() => pane(screen).getBoundingClientRect().left).toBeCloseTo(before, 0);
    });

    it('reports rather than moves when the offset is controlled', async () => {
      const onOffsetChange = vi.fn();
      const screen = await render(
        <PlWindowPane
          title="Notes"
          draggable
          position="fixed"
          offset={{ x: 40, y: 40 }}
          onOffsetChange={onOffsetChange}
        >
          Body
        </PlWindowPane>
      );

      const handle = screen.getByRole('button', { name: 'Move window' }).element();

      handle.focus();
      press(handle, 'ArrowRight');

      expect(onOffsetChange).toHaveBeenCalledWith({ x: 56, y: 40 });
      // Still where the caller put it, because the caller holds the offset.
      expect(pane(screen).style.left).toBe('40px');
    });
  });

  describe('the buttons', () => {
    it('closes the window, which renders nothing', async () => {
      const screen = await render(<PlWindowPane title="Notes">Body</PlWindowPane>);

      await screen.getByRole('button', { name: 'Close' }).click();

      await expect.poll(() => screen.getByText('Body').query()).toBeNull();
    });

    it('hands the focus back to where it came from when the window closes', async () => {
      const screen = await render(
        <>
          <button type="button">Open notes</button>
          <PlWindowPane title="Notes">Body</PlWindowPane>
        </>
      );

      const opener = screen.getByRole('button', { name: 'Open notes' }).element() as HTMLElement;
      const close = screen.getByRole('button', { name: 'Close' }).element() as HTMLElement;

      // Focus arrives in the window from the button before it, as a Tab would
      // bring it, and is pressed from there. A window on its way out is `inert`,
      // and without somewhere to go the focus falls to the top of the document.
      opener.focus();
      close.focus();
      close.click();

      await expect.poll(() => document.activeElement).toBe(opener);
    });

    it('finds the next thing on the page when where it came from is gone', async () => {
      const screen = await render(
        <>
          <PlWindowPane title="Notes">Body</PlWindowPane>
          <button type="button">After</button>
        </>
      );

      const close = screen.getByRole('button', { name: 'Close' }).element() as HTMLElement;
      const after = screen.getByRole('button', { name: 'After' }).element() as HTMLElement;

      // Focused straight onto the button, so there is no element it came from.
      close.focus();
      close.click();

      await expect.poll(() => document.activeElement).toBe(after);
    });

    it('rolls the window up to its bar rather than sending it anywhere', async () => {
      const screen = await render(
        <PlWindowPane title="Notes">
          <p>Body</p>
        </PlWindowPane>
      );

      const body = screen.getByText('Body').element().parentElement as HTMLElement;

      expect(body).not.toHaveAttribute('inert');

      await screen.getByRole('button', { name: 'Minimize' }).click();

      // The bar stays where it is — a page has nowhere to send a window — and
      // what is under it is put out of reach rather than taken away.
      await expect.poll(() => body.hasAttribute('inert')).toBe(true);
      await expect.element(screen.getByRole('group', { name: 'Notes' })).toBeInTheDocument();
    });

    it('offers to restore once it is maximized', async () => {
      const screen = await render(<PlWindowPane title="Notes">Body</PlWindowPane>);

      await screen.getByRole('button', { name: 'Maximize' }).click();

      await expect.element(screen.getByRole('button', { name: 'Restore' })).toBeInTheDocument();
    });

    it('leaves a double click on `actions` to the action rather than maximizing', async () => {
      const onShare = vi.fn();
      const onMaximizedChange = vi.fn();
      const screen = await render(
        <PlWindowPane
          os="windows11"
          title="Notes"
          actions={<button onClick={onShare}>Share</button>}
          onMaximizedChange={onMaximizedChange}
        >
          Body
        </PlWindowPane>
      );

      await userEvent.dblClick(screen.getByRole('button', { name: 'Share' }));

      // Pressed twice, as it was, and the window stays the size it was.
      expect(onShare).toHaveBeenCalledTimes(2);
      expect(onMaximizedChange).not.toHaveBeenCalled();
      await expect.element(screen.getByRole('button', { name: 'Maximize' })).toBeInTheDocument();

      // The same gesture on the bar itself still maximizes, so the one above was
      // delivered and turned away rather than never sent.
      await userEvent.dblClick(screen.getByText('Notes'));

      expect(onMaximizedChange).toHaveBeenCalledWith(true);
      await expect.element(screen.getByRole('button', { name: 'Restore' })).toBeInTheDocument();
    });

    it('tells the caller rather than deciding when it is controlled', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(
        <PlWindowPane title="Notes" open onOpenChange={onOpenChange}>
          Body
        </PlWindowPane>
      );

      await screen.getByRole('button', { name: 'Close' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(false);
      // Still open, because the caller holds the state.
      await expect.element(screen.getByText('Body')).toBeInTheDocument();
    });

    it('renders nothing when it is closed', async () => {
      const screen = await render(
        <PlWindowPane title="Notes" open={false}>
          Body
        </PlWindowPane>
      );

      await expect.poll(() => screen.getByText('Body').query()).toBeNull();
    });
  });

  describe('the labels', () => {
    it('takes an override for each button', async () => {
      const screen = await render(
        <PlWindowPane
          title="Notes"
          minimizeLabel="Roll up"
          maximizeLabel="Fill"
          closeLabel="Dismiss"
        />
      );

      for (const name of ['Roll up', 'Fill', 'Dismiss']) {
        await expect.element(screen.getByRole('button', { name })).toBeInTheDocument();
      }
    });
  });

  describe('resizing', () => {
    it('draws no handles unless it is resizable', async () => {
      const screen = await render(<PlWindowPane title="Notes" />);

      await expect.element(screen.getByRole('group', { name: 'Notes' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Resize window' }).query()).toBeNull();
    });

    it('gives one corner a name and a keyboard path', async () => {
      const screen = await render(<PlWindowPane title="Notes" resizable width={300} />);

      // One of the eight is reachable without a pointer, and it is the corner
      // that changes both axes at once. Eight tab stops around every window
      // would cost a keyboard reader more than the seven extra directions are
      // worth; the other seven are pointer-only and hidden.
      await expect
        .element(screen.getByRole('button', { name: 'Resize window' }))
        .toBeInTheDocument();
      expect(screen.container.querySelectorAll('[aria-hidden="true"].touch-none').length).toBe(7);
    });
  });
});
