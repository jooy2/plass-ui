import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlSwitch } from 'plass-ui';

describe('PlSwitch', () => {
  describe('rendering', () => {
    it('renders a switch named by its label', async () => {
      const screen = await render(<PlSwitch label="Dark mode" />);

      await expect.element(screen.getByRole('switch', { name: 'Dark mode' })).toBeInTheDocument();
    });

    it('starts off', async () => {
      const screen = await render(<PlSwitch label="Dark mode" />);

      expect(screen.getByRole('switch').element()).toHaveAttribute('aria-checked', 'false');
    });

    it('honours `defaultChecked`', async () => {
      const screen = await render(<PlSwitch label="Dark mode" defaultChecked />);

      expect(screen.getByRole('switch').element()).toHaveAttribute('aria-checked', 'true');
    });

    it('renders the description and the error', async () => {
      const screen = await render(
        <PlSwitch label="Dark mode" description="Follows the system." error="Not available yet." />
      );

      await expect.element(screen.getByText('Follows the system.')).toBeInTheDocument();
      await expect.element(screen.getByText('Not available yet.')).toBeInTheDocument();
    });

    it('marks it invalid when there is an error', async () => {
      const screen = await render(<PlSwitch label="Dark mode" error="Not available yet." />);

      expect(screen.getByRole('switch').element()).toHaveAttribute('aria-invalid', 'true');
    });

    it('puts the label before the track when asked', async () => {
      const screen = await render(
        <PlSwitch className="switch-under-test" label="Dark mode" labelPlacement="start" />
      );
      const row = document.querySelector('.switch-under-test > div') as HTMLElement;
      const track = screen.getByRole('switch').element();

      // The label's column comes first in the DOM, so the track is last.
      expect(row.lastElementChild?.contains(track)).toBe(true);
    });

    it('puts the track first by default', async () => {
      const screen = await render(<PlSwitch className="switch-under-test" label="Dark mode" />);
      const row = document.querySelector('.switch-under-test > div') as HTMLElement;
      const track = screen.getByRole('switch').element();

      expect(row.firstElementChild?.contains(track)).toBe(true);
    });

    it('reflects a changed state on re-render', async () => {
      const screen = await render(
        <PlSwitch label="Dark mode" checked={false} onCheckedChange={() => {}} />
      );

      await screen.rerender(<PlSwitch label="Dark mode" checked onCheckedChange={() => {}} />);

      expect(screen.getByRole('switch').element()).toHaveAttribute('aria-checked', 'true');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlSwitch label="Dark mode" className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  // Nothing loads Tailwind into the test run, so the track renders at zero size
  // and cannot be clicked directly. Every interaction below goes through the
  // label, which is the path a real user takes anyway.
  describe('naming', () => {
    it('names the switch with an `aria-label` when there is no visible label', async () => {
      const screen = await render(<PlSwitch aria-label="Wi-Fi" />);

      await expect
        .element(screen.getByRole('switch', { name: 'Wi-Fi', exact: true }))
        .toBeInTheDocument();
    });

    it("names the switch with an `aria-label` in a visible label's place", async () => {
      const screen = await render(<PlSwitch label="Wi-Fi" aria-label="Wi-Fi on this device" />);

      await expect
        .element(screen.getByRole('switch', { name: 'Wi-Fi on this device', exact: true }))
        .toBeInTheDocument();
    });

    it("points the switch at the caller's element with an `aria-labelledby`, over a label and an `aria-label`", async () => {
      const screen = await render(
        <>
          <span id="switch-heading">Wireless</span>
          <PlSwitch
            label="Wi-Fi"
            aria-label="Wi-Fi on this device"
            aria-labelledby="switch-heading"
          />
        </>
      );

      await expect
        .element(screen.getByRole('switch', { name: 'Wireless', exact: true }))
        .toBeInTheDocument();
    });
  });

  describe('flipping', () => {
    it('turns on when the label is pressed', async () => {
      const screen = await render(<PlSwitch label="Dark mode" />);

      await screen.getByText('Dark mode').click();

      expect(screen.getByRole('switch').element()).toHaveAttribute('aria-checked', 'true');
    });

    it('reports the new state to `onCheckedChange`', async () => {
      const onCheckedChange = vi.fn();
      const screen = await render(<PlSwitch label="Dark mode" onCheckedChange={onCheckedChange} />);

      await screen.getByText('Dark mode').click();

      expect(onCheckedChange).toHaveBeenCalledWith(true, expect.anything());
    });

    it('obeys `checked` rather than the press when controlled', async () => {
      const screen = await render(
        <PlSwitch label="Dark mode" checked={false} onCheckedChange={() => {}} />
      );

      await screen.getByText('Dark mode').click();

      expect(screen.getByRole('switch').element()).toHaveAttribute('aria-checked', 'false');
    });
  });

  describe('states', () => {
    it('disables the control', async () => {
      const screen = await render(<PlSwitch label="Dark mode" disabled />);

      expect(screen.getByRole('switch').element()).toBeDisabled();
    });

    it('does not flip when read-only', async () => {
      const screen = await render(<PlSwitch label="Dark mode" readOnly />);

      await screen.getByText('Dark mode').click();

      expect(screen.getByRole('switch').element()).toHaveAttribute('aria-checked', 'false');
    });
  });

  describe('sizing', () => {
    it('takes the track dimensions off the size ladder', async () => {
      const screen = await render(<PlSwitch label="Dark mode" size="lg" />);

      expect(screen.getByRole('switch').element()).toHaveClass('h-6', 'w-11');
    });
  });
});
