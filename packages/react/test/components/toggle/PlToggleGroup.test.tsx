import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlToggle, PlToggleGroup } from 'plass-ui';

describe('PlToggleGroup', () => {
  describe('the set', () => {
    it('turns the last one off when a second goes on', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlToggleGroup defaultValue={['left']} onValueChange={onValueChange}>
          <PlToggle value="left">Left</PlToggle>
          <PlToggle value="center">Center</PlToggle>
        </PlToggleGroup>
      );

      await screen.getByRole('button', { name: 'Center' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(['center']);
      await expect
        .element(screen.getByRole('button', { name: 'Left' }))
        .toHaveAttribute('aria-pressed', 'false');
    });

    it('keeps both on when more than one is allowed', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlToggleGroup multiple defaultValue={['bold']} onValueChange={onValueChange}>
          <PlToggle value="bold">Bold</PlToggle>
          <PlToggle value="italic">Italic</PlToggle>
        </PlToggleGroup>
      );

      await screen.getByRole('button', { name: 'Italic' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(['bold', 'italic']);
      await expect
        .element(screen.getByRole('button', { name: 'Bold' }))
        .toHaveAttribute('aria-pressed', 'true');
    });

    it('reports an array in both cases', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlToggleGroup onValueChange={onValueChange}>
          <PlToggle value="bold">Bold</PlToggle>
        </PlToggleGroup>
      );

      await screen.getByRole('button').click();

      expect(Array.isArray(onValueChange.mock.calls[0][0])).toBe(true);
    });

    it('answers with what a controlled set is given', async () => {
      const onValueChange = vi.fn();

      const screen = await render(
        <PlToggleGroup value={[]} onValueChange={onValueChange}>
          <PlToggle value="bold">Bold</PlToggle>
        </PlToggleGroup>
      );

      await screen.getByRole('button').click();

      expect(onValueChange).toHaveBeenCalledWith(['bold']);
      await expect.element(screen.getByRole('button')).toHaveAttribute('aria-pressed', 'false');
    });

    it('disables every toggle at once', async () => {
      const screen = await render(
        <PlToggleGroup disabled>
          <PlToggle value="bold">Bold</PlToggle>
          <PlToggle value="italic">Italic</PlToggle>
        </PlToggleGroup>
      );

      for (const toggle of screen.getByRole('button').elements()) {
        expect(toggle).toBeDisabled();
      }
    });
  });

  describe('the axes', () => {
    it('sets them once for the whole set', async () => {
      const screen = await render(
        <PlToggleGroup size="lg" variant="solid">
          <PlToggle value="bold">Bold</PlToggle>
        </PlToggleGroup>
      );

      expect(screen.getByRole('button').element()).toHaveClass('h-12');
    });

    it('leaves a toggle its own default when the group says nothing', async () => {
      const screen = await render(
        <PlToggleGroup>
          <PlToggle value="bold">Bold</PlToggle>
        </PlToggleGroup>
      );

      // `glass` is a PlToggle's own default, and the group did not override it.
      expect(screen.getByRole('button').element()).toHaveClass('border');
    });
  });

  describe('the run', () => {
    it('squares off the corners that face a neighbour', async () => {
      const screen = await render(
        <PlToggleGroup data-testid="set">
          <PlToggle value="a">A</PlToggle>
          <PlToggle value="b">B</PlToggle>
        </PlToggleGroup>
      );

      expect(screen.getByTestId('set').element()).toHaveClass(
        '[&>*:not(:first-child)]:rounded-s-none'
      );
    });

    it('overlaps the hairlines on glass and leaves solid alone', async () => {
      const screen = await render(
        <PlToggleGroup data-testid="set">
          <PlToggle value="a">A</PlToggle>
        </PlToggleGroup>
      );

      expect(screen.getByTestId('set').element()).toHaveClass('[&>*:not(:first-child)]:-ms-px');

      await screen.rerender(
        <PlToggleGroup data-testid="set" variant="solid">
          <PlToggle value="a">A</PlToggle>
        </PlToggleGroup>
      );

      expect(screen.getByTestId('set').element()).not.toHaveClass('[&>*:not(:first-child)]:-ms-px');
    });

    it('runs the other way when it is told to', async () => {
      const screen = await render(
        <PlToggleGroup data-testid="set" orientation="vertical">
          <PlToggle value="a">A</PlToggle>
        </PlToggleGroup>
      );

      const set = screen.getByTestId('set').element();

      expect(set).toHaveClass('flex-col');
      expect(set).toHaveClass('[&>*:not(:first-child)]:rounded-t-none');
    });

    it('divides the width evenly when it is stretched', async () => {
      const screen = await render(
        <PlToggleGroup data-testid="set" fullWidth>
          <PlToggle value="a">A</PlToggle>
        </PlToggleGroup>
      );

      expect(screen.getByTestId('set').element()).toHaveClass('[&>*]:flex-1');
    });
  });

  describe('the keyboard', () => {
    it('is one tab stop with the arrow keys inside it', async () => {
      const screen = await render(
        <PlToggleGroup>
          <PlToggle value="a">A</PlToggle>
          <PlToggle value="b">B</PlToggle>
        </PlToggleGroup>
      );

      const [first, second] = screen.getByRole('button').elements();

      // Base UI's roving tab index: one of the set is reachable by Tab and the
      // rest are reached with the arrow keys.
      expect(first).toHaveAttribute('tabindex', '0');
      expect(second).toHaveAttribute('tabindex', '-1');
    });
  });
});
