import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCarousel } from 'plass-ui';

/** Three slides with something findable in each. */
const slides = [<p key="a">Alpha</p>, <p key="b">Bravo</p>, <p key="c">Charlie</p>];

describe('PlCarousel', () => {
  describe('rendering', () => {
    it('renders a named carousel region', async () => {
      const screen = await render(<PlCarousel label="Gallery">{slides}</PlCarousel>);

      await expect.element(screen.getByRole('region', { name: 'Gallery' })).toBeInTheDocument();
    });

    it('wraps every top-level child in a slide of its own', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      await expect.element(screen.getByRole('group', { name: 'Slide 1 of 3' })).toBeInTheDocument();
      await expect.element(screen.getByRole('group', { name: 'Slide 3 of 3' })).toBeInTheDocument();
    });

    it('keeps every slide in the document, so nothing is unreachable', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      await expect.element(screen.getByText('Alpha')).toBeInTheDocument();
      await expect.element(screen.getByText('Charlie')).toBeInTheDocument();
    });

    it('never hides an off-screen slide from a screen reader', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      // A slide can hold a link, and an `aria-hidden` subtree that is still in
      // the tab order is the exact shape of the bug where a keyboard reader
      // lands somewhere their screen reader refuses to describe.
      expect(screen.getByRole('group', { name: 'Slide 3 of 3' }).element()).not.toHaveAttribute(
        'aria-hidden'
      );
    });

    it('reflects a changed set of slides on re-render', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      await screen.rerender(
        <PlCarousel>
          <p>Delta</p>
        </PlCarousel>
      );

      await expect.element(screen.getByText('Delta')).toBeInTheDocument();
      expect(screen.getByText('Alpha').query()).toBeNull();
    });

    it('names each slide through slideLabel', async () => {
      const screen = await render(
        <PlCarousel slideLabel={(index, count) => `${index}/${count}`}>{slides}</PlCarousel>
      );

      await expect.element(screen.getByRole('group', { name: '2/3' })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlCarousel className="my-own-class">{slides}</PlCarousel>);

      expect(screen.getByRole('region').element()).toHaveClass('my-own-class');
    });
  });

  describe('the chrome', () => {
    it('draws arrows and dots by default', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      await expect
        .element(screen.getByRole('button', { name: 'Previous slide' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Next slide' })).toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toBeInTheDocument();
    });

    it('drops them when it is asked to', async () => {
      const screen = await render(
        <PlCarousel arrows={false} indicators={false}>
          {slides}
        </PlCarousel>
      );

      expect(screen.getByRole('button', { name: 'Next slide' }).query()).toBeNull();
      expect(screen.getByRole('button', { name: 'Slide 2 of 3' }).query()).toBeNull();
    });

    it('has nothing to steer with a single slide', async () => {
      const screen = await render(
        <PlCarousel>
          <p>Only</p>
        </PlCarousel>
      );

      expect(screen.getByRole('button', { name: 'Next slide' }).query()).toBeNull();
    });
  });

  describe('navigation', () => {
    it('moves to the next slide and marks its dot as current', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      await expect
        .element(screen.getByRole('button', { name: 'Slide 1 of 3' }))
        .toHaveAttribute('aria-current', 'true');

      await screen.getByRole('button', { name: 'Next slide' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toHaveAttribute('aria-current', 'true');
    });

    it('jumps straight to a slide from its dot', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<PlCarousel onValueChange={onValueChange}>{slides}</PlCarousel>);

      await screen.getByRole('button', { name: 'Slide 3 of 3' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(2);
    });

    it('wraps at the ends while looping', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<PlCarousel onValueChange={onValueChange}>{slides}</PlCarousel>);

      await screen.getByRole('button', { name: 'Previous slide' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(2);
    });

    it('goes inert at the ends when it does not loop', async () => {
      const screen = await render(<PlCarousel loop={false}>{slides}</PlCarousel>);

      await expect.element(screen.getByRole('button', { name: 'Previous slide' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Next slide' })).toBeEnabled();
    });

    it('honours a controlled value and does not move on its own', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCarousel value={1} onValueChange={onValueChange}>
          {slides}
        </PlCarousel>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toHaveAttribute('aria-current', 'true');

      await screen.getByRole('button', { name: 'Next slide' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(2);
      // The parent said 1 and never said otherwise, so 1 is where it stays.
      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toHaveAttribute('aria-current', 'true');
    });

    it('starts on defaultValue', async () => {
      const screen = await render(<PlCarousel defaultValue={2}>{slides}</PlCarousel>);

      await expect
        .element(screen.getByRole('button', { name: 'Slide 3 of 3' }))
        .toHaveAttribute('aria-current', 'true');
    });
  });

  describe('the surface', () => {
    it('maps color and elevation onto the container slots', async () => {
      const screen = await render(
        <PlCarousel color="success" elevation={2}>
          {slides}
        </PlCarousel>
      );
      const element = screen.getByRole('region').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-line')).toBe('var(--plass-success-line)');
      expect(element.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-2)');
    });

    it('is a scroll container rather than a translated track', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      // Nothing is transformed: the house rule against moving a surface holds
      // here for free, where a translated track would have had to argue for an
      // exception.
      expect(screen.getByRole('region').element().innerHTML).not.toContain('translate-x');
      expect(screen.getByRole('group', { name: 'Carousel' }).element()).toHaveClass('snap-x');
    });
  });
});
