import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlChip } from 'plass-ui';

describe('PlChip', () => {
  describe('rendering', () => {
    it('renders its label', async () => {
      const screen = await render(<PlChip>Design</PlChip>);

      await expect.element(screen.getByText('Design')).toBeInTheDocument();
    });

    it('renders no button when it cannot be pressed', async () => {
      const screen = await render(<PlChip>Design</PlChip>);

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('draws the count on its own plate', async () => {
      const screen = await render(<PlChip count={12}>Errors</PlChip>);

      await expect.element(screen.getByText('12')).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<PlChip>Design</PlChip>);

      await screen.rerender(<PlChip>Research</PlChip>);

      await expect.element(screen.getByText('Research')).toBeInTheDocument();
      expect(screen.getByText('Design').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlChip className="my-own-class">Design</PlChip>);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });

    it('forwards unknown props to the shell', async () => {
      const screen = await render(<PlChip data-testid="tag">Design</PlChip>);

      expect(screen.getByTestId('tag').element()).toBeInTheDocument();
    });
  });

  describe('pressing it', () => {
    it('becomes a real button when `onClick` is given', async () => {
      const onClick = vi.fn();
      const screen = await render(<PlChip onClick={onClick}>Design</PlChip>);

      await screen.getByRole('button', { name: 'Design' }).click();

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('reports whether it is chosen', async () => {
      const screen = await render(
        <PlChip selected onClick={() => {}}>
          Design
        </PlChip>
      );

      expect(screen.getByRole('button', { name: 'Design' }).element()).toHaveAttribute(
        'aria-pressed',
        'true'
      );
    });

    it('stops being a button when disabled', async () => {
      const onClick = vi.fn();
      const screen = await render(
        <PlChip disabled onClick={onClick}>
          Design
        </PlChip>
      );

      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('marks a disabled, unpressable chip as such', async () => {
      await render(
        <PlChip disabled className="chip-under-test">
          Design
        </PlChip>
      );

      expect(document.querySelector('.chip-under-test')).toHaveAttribute('aria-disabled', 'true');
    });
  });

  describe('deleting it', () => {
    it('draws no delete button without `onDelete`', async () => {
      const screen = await render(<PlChip>Design</PlChip>);

      expect(screen.getByRole('button', { name: 'Remove' }).query()).toBeNull();
    });

    it('draws one when `onDelete` is given, and calls it', async () => {
      const onDelete = vi.fn();
      const screen = await render(<PlChip onDelete={onDelete}>Design</PlChip>);

      await screen.getByRole('button', { name: 'Remove' }).click();

      expect(onDelete).toHaveBeenCalledTimes(1);
    });

    it('takes a different name for that button', async () => {
      const screen = await render(
        <PlChip onDelete={() => {}} deleteLabel="지우기">
          Design
        </PlChip>
      );

      await expect.element(screen.getByRole('button', { name: '지우기' })).toBeInTheDocument();
    });

    it('keeps the label and the delete button as two separate tab stops', async () => {
      const screen = await render(
        <PlChip onClick={() => {}} onDelete={() => {}}>
          Design
        </PlChip>
      );

      await expect.element(screen.getByRole('button', { name: 'Design' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Remove' })).toBeInTheDocument();
    });

    it('disables the delete button along with the chip', async () => {
      const screen = await render(
        <PlChip disabled onDelete={() => {}}>
          Design
        </PlChip>
      );

      expect(screen.getByRole('button', { name: 'Remove' }).element()).toBeDisabled();
    });
  });
});
