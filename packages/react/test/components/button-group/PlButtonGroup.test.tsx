import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlButtonGroup } from 'plass-ui';

describe('PlButtonGroup', () => {
  describe('rendering', () => {
    it('renders a group around its buttons', async () => {
      const screen = await render(
        <PlButtonGroup>
          <PlButton>Cut</PlButton>
          <PlButton>Copy</PlButton>
        </PlButtonGroup>
      );

      await expect.element(screen.getByRole('group')).toBeInTheDocument();
      expect(screen.getByRole('button').elements()).toHaveLength(2);
    });

    it('runs horizontally by default and vertically when asked', async () => {
      const screen = await render(
        <PlButtonGroup>
          <PlButton>One</PlButton>
        </PlButtonGroup>
      );

      expect(screen.getByRole('group').element()).toHaveClass('flex-row');

      await screen.rerender(
        <PlButtonGroup orientation="vertical">
          <PlButton>One</PlButton>
        </PlButtonGroup>
      );

      expect(screen.getByRole('group').element()).toHaveClass('flex-col');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <PlButtonGroup className="my-own-class">
          <PlButton>One</PlButton>
        </PlButtonGroup>
      );

      expect(screen.getByRole('group').element()).toHaveClass('my-own-class');
    });

    it('passes native attributes through', async () => {
      const screen = await render(
        <PlButtonGroup aria-label="Clipboard">
          <PlButton>Cut</PlButton>
        </PlButtonGroup>
      );

      await expect.element(screen.getByRole('group', { name: 'Clipboard' })).toBeInTheDocument();
    });
  });

  describe('inheritance', () => {
    it('hands its variant, size and color to every button', async () => {
      const screen = await render(
        <PlButtonGroup variant="ghost" size="lg" color="danger">
          <PlButton>Delete</PlButton>
        </PlButtonGroup>
      );

      const button = screen.getByRole('button', { name: 'Delete' }).element();

      // `ghost` at `lg`: no fill, the family in the ink, the 48px control.
      expect(button).toHaveClass('h-12');
      expect(button).toHaveClass('bg-transparent');
      expect(button.getAttribute('style')).toContain('--plass-danger-accent');
    });

    it('lets a button override what the group said', async () => {
      const screen = await render(
        <PlButtonGroup size="lg">
          <PlButton>Inherited</PlButton>
          <PlButton size="sm">Its own</PlButton>
        </PlButtonGroup>
      );

      expect(screen.getByRole('button', { name: 'Inherited' }).element()).toHaveClass('h-12');
      expect(screen.getByRole('button', { name: 'Its own' }).element()).toHaveClass('h-8');
    });

    it('leaves a button on its own defaults when the group says nothing', async () => {
      const screen = await render(
        <PlButtonGroup>
          <PlButton>Save</PlButton>
        </PlButtonGroup>
      );

      expect(screen.getByRole('button', { name: 'Save' }).element()).toHaveClass('h-10');
    });

    it('disables every button at once', async () => {
      const screen = await render(
        <PlButtonGroup disabled>
          <PlButton>Cut</PlButton>
          <PlButton>Copy</PlButton>
        </PlButtonGroup>
      );

      for (const button of screen.getByRole('button').elements()) {
        expect(button).toBeDisabled();
      }
    });

    it('reaches a button that is not a direct child', async () => {
      const screen = await render(
        <PlButtonGroup size="xl">
          <span>
            <PlButton>Nested</PlButton>
          </span>
        </PlButtonGroup>
      );

      expect(screen.getByRole('button', { name: 'Nested' }).element()).toHaveClass('h-14');
    });

    it('reflects a changed group prop on re-render', async () => {
      const screen = await render(
        <PlButtonGroup size="sm">
          <PlButton>Save</PlButton>
        </PlButtonGroup>
      );

      expect(screen.getByRole('button', { name: 'Save' }).element()).toHaveClass('h-8');

      await screen.rerender(
        <PlButtonGroup size="xl">
          <PlButton>Save</PlButton>
        </PlButtonGroup>
      );

      expect(screen.getByRole('button', { name: 'Save' }).element()).toHaveClass('h-14');
    });
  });
});
