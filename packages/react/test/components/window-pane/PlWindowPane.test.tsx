import { describe, expect, it, vi } from 'vitest';
import { PlWindowPane } from 'plass-ui';
import { render } from 'vitest-browser-react';

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

  describe('the buttons', () => {
    it('closes the window, which renders nothing', async () => {
      const screen = await render(<PlWindowPane title="Notes">Body</PlWindowPane>);

      await screen.getByRole('button', { name: 'Close' }).click();

      await expect.poll(() => screen.getByText('Body').query()).toBeNull();
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
