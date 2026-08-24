import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlSlider } from 'plass-ui';

describe('PlSlider', () => {
  describe('rendering', () => {
    it('renders a slider with the value on it', async () => {
      const screen = await render(<PlSlider label="Volume" defaultValue={40} />);
      const thumb = screen.getByRole('slider').element();

      expect(thumb).toHaveAttribute('aria-valuenow', '40');
    });

    it('names the slider from its label', async () => {
      const screen = await render(<PlSlider label="Volume" defaultValue={40} />);

      await expect.element(screen.getByRole('slider', { name: 'Volume' })).toBeInTheDocument();
    });

    it('renders the description', async () => {
      const screen = await render(
        <PlSlider label="Volume" defaultValue={40} description="Applies to alerts only." />
      );

      await expect.element(screen.getByText('Applies to alerts only.')).toBeInTheDocument();
    });

    it('shows the value beside the label when asked', async () => {
      const screen = await render(<PlSlider label="Volume" defaultValue={40} showValue />);

      await expect.element(screen.getByText('40')).toBeInTheDocument();
    });

    it('formats the value with a function', async () => {
      const screen = await render(
        <PlSlider
          label="Volume"
          defaultValue={40}
          showValue={(formatted) => `${formatted[0]} percent`}
        />
      );

      await expect.element(screen.getByText('40 percent')).toBeInTheDocument();
    });

    it('carries the min, the max and the step through to the control', async () => {
      // Base UI's thumb *is* an `<input type="range">`, so the bounds are the
      // native attributes rather than `aria-value*`.
      const screen = await render(<PlSlider defaultValue={15} min={10} max={20} step={2} />);
      const thumb = screen.getByRole('slider').element();

      expect(thumb).toHaveAttribute('min', '10');
      expect(thumb).toHaveAttribute('max', '20');
      expect(thumb).toHaveAttribute('step', '2');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(<PlSlider value={20} onValueChange={() => {}} />);

      await screen.rerender(<PlSlider value={70} onValueChange={() => {}} />);

      expect(screen.getByRole('slider').element()).toHaveAttribute('aria-valuenow', '70');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<PlSlider className="my-own-class" defaultValue={10} />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('range', () => {
    it('draws one thumb per value in the array', async () => {
      const screen = await render(<PlSlider defaultValue={[20, 60]} />);

      expect(screen.getByRole('slider').elements()).toHaveLength(2);
    });

    it('draws one thumb for a single value', async () => {
      const screen = await render(<PlSlider defaultValue={20} />);

      expect(screen.getByRole('slider').elements()).toHaveLength(1);
    });
  });

  describe('interaction', () => {
    it('steps the value with the arrow keys', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlSlider label="Volume" defaultValue={40} step={5} onValueChange={onValueChange} />
      );
      const thumb = screen.getByRole('slider').element() as HTMLElement;

      thumb.focus();
      await expect.poll(() => document.activeElement).toBe(thumb);
      thumb.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      await expect.poll(() => thumb.getAttribute('aria-valuenow')).toBe('45');
      expect(onValueChange).toHaveBeenCalled();
    });

    it('obeys `value` rather than the key press when controlled', async () => {
      const screen = await render(<PlSlider value={40} onValueChange={() => {}} />);
      const thumb = screen.getByRole('slider').element() as HTMLElement;

      thumb.focus();
      thumb.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      await expect.poll(() => thumb.getAttribute('aria-valuenow')).toBe('40');
    });

    it('disables the control it is dragged by', async () => {
      // The thumb is a native `<input type="range">`, so `disabled` is what
      // actually takes it out of reach — of the pointer, of the keyboard and of
      // the tab order alike.
      const screen = await render(<PlSlider defaultValue={40} disabled />);

      expect(screen.getByRole('slider').element()).toBeDisabled();
    });
  });
});
