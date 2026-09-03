import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCheckbox } from 'plass-ui';

describe('PlCheckbox', () => {
  describe('rendering', () => {
    it('renders a checkbox named by its label', async () => {
      const screen = await render(<PlCheckbox label="Email me" />);

      await expect.element(screen.getByRole('checkbox', { name: 'Email me' })).toBeInTheDocument();
    });

    it('starts unchecked', async () => {
      const screen = await render(<PlCheckbox label="Email me" />);

      expect(screen.getByRole('checkbox').element()).toHaveAttribute('aria-checked', 'false');
    });

    it('honours `defaultChecked`', async () => {
      const screen = await render(<PlCheckbox label="Email me" defaultChecked />);

      expect(screen.getByRole('checkbox').element()).toHaveAttribute('aria-checked', 'true');
    });

    it('renders the description and the error', async () => {
      const screen = await render(
        <PlCheckbox label="Email me" description="At most once a week." error="Required." />
      );

      await expect.element(screen.getByText('At most once a week.')).toBeInTheDocument();
      await expect.element(screen.getByText('Required.')).toBeInTheDocument();
    });

    it('marks the checkbox invalid when there is an error', async () => {
      const screen = await render(<PlCheckbox label="Email me" error="Required." />);

      expect(screen.getByRole('checkbox').element()).toHaveAttribute('aria-invalid', 'true');
    });

    it('marks it invalid from `invalid` alone', async () => {
      const screen = await render(<PlCheckbox label="Email me" invalid />);

      expect(screen.getByRole('checkbox').element()).toHaveAttribute('aria-invalid', 'true');
    });

    it('reports the mixed state when indeterminate', async () => {
      const screen = await render(<PlCheckbox label="All" indeterminate />);

      expect(screen.getByRole('checkbox').element()).toHaveAttribute('aria-checked', 'mixed');
    });

    it('draws the tick on instead of swapping it in', async () => {
      const screen = await render(<PlCheckbox label="Email me" />);
      const tick = screen.getByRole('checkbox').element();
      const mark = () => tick.querySelector('span')!;

      // Kept in the document while the box is empty, because a mark that is
      // unmounted cannot travel back out again.
      expect(mark()).toHaveAttribute('data-unchecked');
      expect(mark().querySelector('path')).toHaveAttribute('pathLength', '1');

      await screen.getByRole('checkbox').click();

      await vi.waitFor(() => expect(mark()).toHaveAttribute('data-checked'));
      expect(mark()).not.toHaveAttribute('data-unchecked');
    });

    it('draws the dash on the same way when indeterminate', async () => {
      const screen = await render(<PlCheckbox label="All" indeterminate />);
      const mark = screen.getByRole('checkbox').element().querySelector('span')!;

      expect(mark).toHaveAttribute('data-indeterminate');
      expect(mark).not.toHaveAttribute('data-unchecked');
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<PlCheckbox label="Before" />);

      await screen.rerender(<PlCheckbox label="After" />);

      await expect.element(screen.getByRole('checkbox', { name: 'After' })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlCheckbox label="Email me" className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  // Nothing loads Tailwind into the test run, so the tick renders at zero size
  // and cannot be clicked directly. Every interaction below goes through the
  // label, which is the path a real user takes anyway — and the fact that it
  // works is what proves Base UI's Field wired the two together.
  describe('ticking', () => {
    it('ticks when the label is pressed', async () => {
      const screen = await render(<PlCheckbox label="Email me" />);

      await screen.getByText('Email me').click();

      expect(screen.getByRole('checkbox').element()).toHaveAttribute('aria-checked', 'true');
    });

    it('reports the new state to `onCheckedChange`', async () => {
      const onCheckedChange = vi.fn();
      const screen = await render(
        <PlCheckbox label="Email me" onCheckedChange={onCheckedChange} />
      );

      await screen.getByText('Email me').click();

      expect(onCheckedChange).toHaveBeenCalledWith(true, expect.anything());
    });

    it('obeys `checked` rather than the click when controlled', async () => {
      const screen = await render(
        <PlCheckbox label="Email me" checked={false} onCheckedChange={() => {}} />
      );

      await screen.getByText('Email me').click();

      expect(screen.getByRole('checkbox').element()).toHaveAttribute('aria-checked', 'false');
    });
  });

  describe('states', () => {
    it('disables the control', async () => {
      const screen = await render(<PlCheckbox label="Email me" disabled />);

      expect(screen.getByRole('checkbox').element()).toBeDisabled();
    });

    it('does not tick when read-only', async () => {
      const screen = await render(<PlCheckbox label="Email me" readOnly />);

      await screen.getByText('Email me').click();

      expect(screen.getByRole('checkbox').element()).toHaveAttribute('aria-checked', 'false');
    });
  });

  describe('forms', () => {
    it('submits its value under `name` when ticked', async () => {
      const screen = await render(
        <form
          onSubmit={(event) => {
            event.preventDefault();
          }}
        >
          <PlCheckbox label="Email me" name="marketing" defaultChecked />
          <button type="submit">Save</button>
        </form>
      );

      const form = screen.getByRole('button', { name: 'Save' }).element().closest('form');

      expect(new FormData(form as HTMLFormElement).get('marketing')).toBe('on');
    });
  });
});
