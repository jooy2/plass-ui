import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAlert } from 'plass-ui';

describe('PlAlert', () => {
  describe('rendering', () => {
    it('renders its message', async () => {
      const screen = await render(<PlAlert>The build finished.</PlAlert>);

      await expect.element(screen.getByText('The build finished.')).toBeInTheDocument();
    });

    it('renders the title above the message', async () => {
      const screen = await render(<PlAlert title="Build failed">Two tests are red.</PlAlert>);

      await expect.element(screen.getByText('Build failed')).toBeInTheDocument();
      await expect.element(screen.getByText('Two tests are red.')).toBeInTheDocument();
    });

    it('reflects a changed message on re-render', async () => {
      const screen = await render(<PlAlert>Before</PlAlert>);

      await screen.rerender(<PlAlert>After</PlAlert>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlAlert className="my-own-class">Note</PlAlert>);

      expect(screen.getByRole('status').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(<PlAlert data-testid="banner">Note</PlAlert>);

      expect(screen.getByRole('status').element()).toHaveAttribute('data-testid', 'banner');
    });
  });

  describe('the glyph', () => {
    it('draws the severity glyph by default', async () => {
      await render(<PlAlert className="alert-under-test">Note</PlAlert>);

      expect(document.querySelector('.alert-under-test svg')).not.toBeNull();
    });

    it('draws nothing when `icon` is false', async () => {
      await render(
        <PlAlert className="alert-under-test" icon={false}>
          Note
        </PlAlert>
      );

      expect(document.querySelector('.alert-under-test svg')).toBeNull();
    });

    it('takes a glyph of its own', async () => {
      const screen = await render(<PlAlert icon={<span>★</span>}>Note</PlAlert>);

      await expect.element(screen.getByText('★')).toBeInTheDocument();
    });
  });

  describe('the live region', () => {
    it('waits for a pause on the calm severities', async () => {
      const screen = await render(<PlAlert color="success">Saved.</PlAlert>);

      await expect.element(screen.getByRole('status')).toBeInTheDocument();
    });

    it('interrupts on warning and danger', async () => {
      const screen = await render(<PlAlert color="danger">Deleting failed.</PlAlert>);

      await expect.element(screen.getByRole('alert')).toBeInTheDocument();
    });

    it('lets a caller override the role', async () => {
      const screen = await render(<PlAlert role="note">A note.</PlAlert>);

      expect(screen.getByRole('status').query()).toBeNull();
      await expect.element(screen.getByRole('note')).toBeInTheDocument();
    });
  });

  describe('the action and the dismiss button', () => {
    it('renders the action', async () => {
      const screen = await render(
        <PlAlert action={<button type="button">Retry</button>}>It failed.</PlAlert>
      );

      await expect.element(screen.getByRole('button', { name: 'Retry' })).toBeInTheDocument();
    });

    it('draws no dismiss button without `onClose`', async () => {
      const screen = await render(<PlAlert>Note</PlAlert>);

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('draws one when `onClose` is given, and calls it', async () => {
      const onClose = vi.fn();
      const screen = await render(<PlAlert onClose={onClose}>Note</PlAlert>);

      await screen.getByRole('button', { name: 'Dismiss' }).click();

      expect(onClose).toHaveBeenCalledTimes(1);
    });

    it('takes a different name for that button', async () => {
      const screen = await render(
        <PlAlert onClose={() => {}} closeLabel="닫기">
          Note
        </PlAlert>
      );

      await expect.element(screen.getByRole('button', { name: '닫기' })).toBeInTheDocument();
    });
  });
});
