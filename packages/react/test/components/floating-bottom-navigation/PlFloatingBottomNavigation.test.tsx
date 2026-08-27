import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlFloatingBottomNavigation, PlFloatingBottomNavigationItem } from 'plass-ui';

const glyph = <svg viewBox="0 0 24 24" data-testid="glyph" />;

describe('PlFloatingBottomNavigation', () => {
  describe('the bar', () => {
    it('is a nav rather than a tab list', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation label="Main">
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      await expect.element(screen.getByRole('navigation', { name: 'Main' })).toBeInTheDocument();
      expect(screen.getByRole('tablist').query()).toBeNull();
    });

    it('floats clear of the bottom edge', async () => {
      await render(<PlFloatingBottomNavigation className="bar-under-test" />);

      const element = document.querySelector('.bar-under-test');

      expect(element).toHaveClass('fixed');
      expect(element).toHaveClass('pb-[calc(env(safe-area-inset-bottom)+1rem)]');
    });

    it('takes the gap without the home indicator when it is asked to', async () => {
      await render(<PlFloatingBottomNavigation className="bar-under-test" safeArea={false} />);

      expect(document.querySelector('.bar-under-test')).toHaveClass('pb-4');
    });

    it('lets the page through the strip it spans', async () => {
      await render(<PlFloatingBottomNavigation className="bar-under-test" />);

      // The band across the bottom of the window must not swallow presses; only
      // the capsule takes them back.
      expect(document.querySelector('.bar-under-test')).toHaveClass('pointer-events-none');
      expect(document.querySelector('.bar-under-test > div')).toHaveClass('pointer-events-auto');
    });

    it('takes no presses of its own when it is in the flow', async () => {
      await render(<PlFloatingBottomNavigation className="bar-under-test" position="static" />);

      expect(document.querySelector('.bar-under-test')).not.toHaveClass('pointer-events-none');
    });

    it('is a capsule', async () => {
      await render(<PlFloatingBottomNavigation className="bar-under-test" />);

      expect(document.querySelector('.bar-under-test > div')).toHaveClass('rounded-full');
    });

    it('lifts off the page rather than lying flat on it', async () => {
      await render(<PlFloatingBottomNavigation className="bar-under-test" />);

      const element = document.querySelector<HTMLElement>('.bar-under-test');

      expect(element?.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-2)');
    });
  });

  describe('a destination', () => {
    it('is a disc', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation>
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      const element = screen.getByRole('button', { name: 'Home' }).element();

      expect(element).toHaveClass('rounded-full');
      expect(element).toHaveClass('h-10');
      expect(element).toHaveClass('w-10');
    });

    it('is named by words that are never drawn', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation>
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      await expect.element(screen.getByRole('button', { name: 'Home' })).toBeInTheDocument();
      // A clipped box: invisible to a sighted reader, present to every other
      // kind.
      expect(screen.getByText('Home').element()).toHaveClass('absolute');
    });

    it('draws the glyph it was given', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation>
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      expect(screen.getByTestId('glyph').element()).toBeInTheDocument();
    });

    it('takes the on-fill ink once it is the one you are on, and no fill of its own', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation value="home">
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      const current = screen.getByRole('button', { name: 'Home' }).element();

      expect(current).toHaveClass('text-(--p-on-solid)');
      // The gradient belongs to the key, which travels. A disc that drew one of
      // its own would be a second key appearing where the first had just left.
      expect(current).not.toHaveClass('[background-image:var(--p-fill)]');
      expect(screen.getByRole('button', { name: 'Search' }).element()).toHaveClass(
        'text-(--plass-muted-fg)'
      );
    });

    it('says which destination the reader is on, and never says pressed', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation value="home">
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      const element = screen.getByRole('button', { name: 'Home' }).element();

      expect(element).toHaveAttribute('aria-current', 'page');
      expect(element).not.toHaveAttribute('aria-pressed');
    });

    it('is a real link when it has somewhere to go', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation>
          <PlFloatingBottomNavigationItem value="home" href="/home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      expect(screen.getByRole('link', { name: 'Home' }).element()).toHaveAttribute('href', '/home');
    });
  });

  describe('choosing', () => {
    it('reports the destination that was pressed', async () => {
      const change = vi.fn();
      const screen = await render(
        <PlFloatingBottomNavigation onValueChange={change}>
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      expect(change).toHaveBeenCalledWith('search');
    });

    it('moves on its own when nobody is holding the value', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation defaultValue="home">
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      expect(screen.getByRole('button', { name: 'Search' }).element()).toHaveAttribute(
        'aria-current',
        'page'
      );
    });

    it('does not answer while a destination is unavailable', async () => {
      const change = vi.fn();
      const screen = await render(
        <PlFloatingBottomNavigation onValueChange={change}>
          <PlFloatingBottomNavigationItem value="home" icon={glyph} disabled>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      expect(screen.getByRole('button', { name: 'Home' }).element()).toBeDisabled();
      expect(change).not.toHaveBeenCalled();
    });

    it('goes unavailable with the whole bar', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation disabled>
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      expect(screen.getByRole('button', { name: 'Home' }).element()).toBeDisabled();
    });
  });

  describe('the key', () => {
    /** The one element in the capsule that is not a destination. */
    const keyOf = () =>
      document.querySelector<HTMLElement>('.bar-under-test > div > span[aria-hidden="true"]');

    it('carries the slots a container never gets', async () => {
      await render(<PlFloatingBottomNavigation className="bar-under-test" />);

      const element = document.querySelector<HTMLElement>('.bar-under-test');

      // A container's slot set is deliberately undyed, and the key is made of
      // all three of the slots it leaves out — so a bar reading it would draw a
      // `background-image` of nothing.
      expect(element?.style.getPropertyValue('--p-fill')).toBe('var(--plass-primary-fill)');
      expect(element?.style.getPropertyValue('--p-on-solid')).toBe('var(--plass-primary-on-solid)');
      expect(element?.style.getPropertyValue('--p-lift')).not.toBe('');
    });

    it('is not drawn while no destination is current', async () => {
      await render(
        <PlFloatingBottomNavigation className="bar-under-test">
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      expect(keyOf()).toBeNull();
    });

    it('is one element measured off the disc it is under', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation className="bar-under-test" value="home">
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      const element = keyOf();
      const disc = screen.getByRole('button', { name: 'Home' }).element() as HTMLElement;

      expect(
        document.querySelectorAll('.bar-under-test > div > span[aria-hidden="true"]')
      ).toHaveLength(1);
      expect(element?.style.getPropertyValue('--p-disc-x')).toBe(`${disc.offsetLeft}px`);
      expect(element?.style.getPropertyValue('--p-disc-w')).toBe(`${disc.offsetWidth}px`);
      expect(element?.style.getPropertyValue('--p-disc-h')).toBe(`${disc.offsetHeight}px`);
    });

    it('travels to the destination that was pressed rather than being redrawn', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation className="bar-under-test" defaultValue="home">
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      const before = keyOf();

      await screen.getByRole('button', { name: 'Search' }).click();

      const after = keyOf();
      const disc = screen.getByRole('button', { name: 'Search' }).element() as HTMLElement;

      // The same node, moved. Two nodes cross-fading would be two objects.
      expect(after).toBe(before);
      expect(after?.style.getPropertyValue('--p-disc-x')).toBe(`${disc.offsetLeft}px`);
    });

    it('is placed instantly on the first paint and eased from then on', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation className="bar-under-test" defaultValue="home">
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      // `data-ready` is set once the first placement has been committed, and it
      // is what turns the duration on — the first destination appears under its
      // disc rather than flying in from the left edge of the capsule.
      expect(keyOf()).toHaveAttribute('data-ready');

      await screen.getByRole('button', { name: 'Search' }).click();

      expect(keyOf()).toHaveAttribute('data-ready');
    });

    it('goes out with the destination it is under', async () => {
      await render(
        <PlFloatingBottomNavigation className="bar-under-test" value="home">
          <PlFloatingBottomNavigationItem value="home" icon={glyph} disabled>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      expect(keyOf()).toHaveAttribute('data-quiet');
    });
  });
});
