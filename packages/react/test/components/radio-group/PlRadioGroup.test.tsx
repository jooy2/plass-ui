import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlRadio, PlRadioGroup } from 'plass-ui';

function Plans(props: React.ComponentProps<typeof PlRadioGroup>) {
  return (
    <PlRadioGroup label="Plan" {...props}>
      <PlRadio value="starter" label="Starter" />
      <PlRadio value="team" label="Team" description="Shared projects." />
      <PlRadio value="enterprise" label="Enterprise" />
    </PlRadioGroup>
  );
}

describe('PlRadioGroup', () => {
  describe('rendering', () => {
    it('renders one radio per option, named by its label', async () => {
      const screen = await render(<Plans />);

      expect(screen.getByRole('radio').elements()).toHaveLength(3);
      await expect.element(screen.getByRole('radio', { name: 'Starter' })).toBeInTheDocument();
    });

    it('renders the group as a named radiogroup', async () => {
      const screen = await render(<Plans />);

      await expect.element(screen.getByRole('radiogroup', { name: 'Plan' })).toBeInTheDocument();
    });

    it("renders an option's description", async () => {
      const screen = await render(<Plans />);

      await expect.element(screen.getByText('Shared projects.')).toBeInTheDocument();
    });

    it("renders the group's description and error", async () => {
      const screen = await render(<Plans description="Change it any time." error="Pick one." />);

      await expect.element(screen.getByText('Change it any time.')).toBeInTheDocument();
      await expect.element(screen.getByText('Pick one.')).toBeInTheDocument();
    });

    it('starts with nothing chosen', async () => {
      const screen = await render(<Plans />);

      for (const radio of screen.getByRole('radio').elements()) {
        expect(radio).toHaveAttribute('aria-checked', 'false');
      }
    });

    it('honours `defaultValue`', async () => {
      const screen = await render(<Plans defaultValue="team" />);

      expect(screen.getByRole('radio', { name: /Team/ }).element()).toHaveAttribute(
        'aria-checked',
        'true'
      );
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<Plans value="starter" onValueChange={() => {}} />);

      await screen.rerender(<Plans value="enterprise" onValueChange={() => {}} />);

      expect(screen.getByRole('radio', { name: 'Enterprise' }).element()).toHaveAttribute(
        'aria-checked',
        'true'
      );
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<Plans className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  // Nothing loads Tailwind into the test run, so the dot renders at zero size
  // and cannot be clicked directly. Every interaction below goes through the
  // label, which is the path a real user takes anyway.
  describe('choosing', () => {
    it('chooses the option whose label was pressed', async () => {
      const screen = await render(<Plans />);

      await screen.getByText('Team').click();

      expect(screen.getByRole('radio', { name: /Team/ }).element()).toHaveAttribute(
        'aria-checked',
        'true'
      );
    });

    it('clears the option that was chosen before', async () => {
      const screen = await render(<Plans defaultValue="starter" />);

      await screen.getByText('Enterprise').click();

      expect(screen.getByRole('radio', { name: 'Starter' }).element()).toHaveAttribute(
        'aria-checked',
        'false'
      );
    });

    it('reports the new value to `onValueChange`', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Plans onValueChange={onValueChange} />);

      await screen.getByText('Enterprise').click();

      expect(onValueChange).toHaveBeenCalledWith('enterprise', expect.anything());
    });

    it('obeys `value` rather than the click when controlled', async () => {
      const screen = await render(<Plans value="starter" onValueChange={() => {}} />);

      await screen.getByText('Team').click();

      expect(screen.getByRole('radio', { name: 'Starter' }).element()).toHaveAttribute(
        'aria-checked',
        'true'
      );
    });
  });

  describe('states', () => {
    it('disables every option when the group is disabled', async () => {
      const screen = await render(<Plans disabled />);

      for (const radio of screen.getByRole('radio').elements()) {
        expect(radio).toBeDisabled();
      }
    });

    it('disables one option without touching the rest', async () => {
      const screen = await render(
        <PlRadioGroup label="Plan">
          <PlRadio value="starter" label="Starter" disabled />
          <PlRadio value="team" label="Team" />
        </PlRadioGroup>
      );

      expect(screen.getByRole('radio', { name: 'Starter' }).element()).toBeDisabled();
      expect(screen.getByRole('radio', { name: 'Team' }).element()).toBeEnabled();
    });

    it('does not choose when the group is read-only', async () => {
      const screen = await render(<Plans readOnly />);

      await screen.getByText('Team').click();

      expect(screen.getByRole('radio', { name: /Team/ }).element()).toHaveAttribute(
        'aria-checked',
        'false'
      );
    });
  });

  describe('the set decides the look', () => {
    it('gives every dot the size the group was given', async () => {
      const screen = await render(<Plans size="xl" />);

      for (const radio of screen.getByRole('radio').elements()) {
        expect(radio).toHaveClass('size-6');
      }
    });

    it('grows the dot out of the ring rather than switching it on', async () => {
      const screen = await render(<Plans />);
      const radios = screen.getByRole('radio').elements();
      const dot = (radio: Element) => radio.querySelector('span')!;

      // Kept in the document at zero, because a dot that is unmounted cannot
      // shrink back out when another option in the set takes the value.
      expect(dot(radios[0])).toHaveClass('size-0');
      expect(dot(radios[0])).not.toHaveAttribute('data-checked');

      await screen.getByText('Starter').click();

      await vi.waitFor(() => expect(dot(radios[0])).toHaveAttribute('data-checked'));
      expect(dot(radios[0]).className).toContain('transition-property');
    });
  });
});
