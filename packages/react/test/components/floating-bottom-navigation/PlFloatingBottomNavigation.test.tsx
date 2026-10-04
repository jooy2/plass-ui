import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlFloatingBottomNavigation, PlFloatingBottomNavigationItem } from 'plass-ui';
import { RouterLink } from '../../support/router';

const glyph = <svg viewBox="0 0 24 24" data-testid="glyph" />;

/** Waits out `count` frames. */
async function frames(count: number): Promise<void> {
  for (let step = 0; step < count; step += 1) {
    await new Promise((resolve) => requestAnimationFrame(resolve));
  }
}

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

  describe('the room it takes', () => {
    const published = () =>
      document.documentElement.style.getPropertyValue('--plass-bottom-navigation-height');

    it('publishes the height of the whole strip on the root while it is fixed', async () => {
      const screen = await render(<PlFloatingBottomNavigation className="bar-under-test" />);
      const bar = document.querySelector<HTMLElement>('.bar-under-test')!;

      // The strip and not the capsule: the gap under it is over the page too.
      expect(published()).toBe(`${bar.getBoundingClientRect().height}px`);

      await screen.unmount();

      expect(published()).toBe('');
    });

    it('publishes nothing while it is in the flow', async () => {
      await render(<PlFloatingBottomNavigation position="static" />);

      expect(published()).toBe('');
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

    it("draws its link on the element `render` gives it, with the disc's own marks", async () => {
      const ref = React.createRef<HTMLElement>();
      const screen = await render(
        <PlFloatingBottomNavigation value="home">
          <PlFloatingBottomNavigationItem
            ref={ref}
            value="home"
            icon={glyph}
            render={<RouterLink href="/home" />}
          >
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      const link = screen.getByRole('link', { name: 'Home' }).element();

      expect(link).toHaveAttribute('data-router');
      expect(link).toHaveAttribute('href', '/home');
      expect(link).toHaveAttribute('aria-current', 'page');
      // The hooks the key is measured from.
      expect(link).toHaveAttribute('data-disc');
      expect(link).toHaveAttribute('data-current');
      expect(link).toHaveClass('rounded-full', 'text-(--p-on-solid)');
      expect(ref.current).toBe(link);
    });

    it("leaves a disabled disc's `render` out rather than leaving a live link", async () => {
      const screen = await render(
        <PlFloatingBottomNavigation>
          <PlFloatingBottomNavigationItem
            value="home"
            icon={glyph}
            disabled
            render={<RouterLink href="/home" />}
          >
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      const element = screen.getByText('Home').element().closest('a');

      expect(element).not.toHaveAttribute('data-router');
      expect(element).not.toHaveAttribute('href');
      expect(element).toHaveAttribute('aria-disabled', 'true');
      expect(element).toHaveAttribute('data-disabled');
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

    it('hides the key when the value names no destination', async () => {
      const bar = (value: string) => (
        <PlFloatingBottomNavigation value={value}>
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      const screen = await render(bar('home'));
      const key = () =>
        document.querySelector<HTMLElement>(
          'span[aria-hidden="true"].pointer-events-none.absolute'
        );

      expect(key()?.hidden).toBe(false);

      await screen.rerender(bar('profile'));

      expect(screen.getByRole('button', { name: 'Home' }).element()).not.toHaveAttribute(
        'aria-current'
      );
      expect(key()?.hidden).toBe(true);

      await screen.rerender(bar('search'));

      expect(key()?.hidden).toBe(false);
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

    it("travels to a router's link followed from the keyboard", async () => {
      const change = vi.fn();
      const onNavigate = vi.fn();
      const screen = await render(
        <PlFloatingBottomNavigation
          className="bar-under-test"
          defaultValue="home"
          onValueChange={change}
        >
          <PlFloatingBottomNavigationItem
            value="home"
            icon={glyph}
            render={<RouterLink href="/home" />}
          >
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem
            value="search"
            icon={glyph}
            render={<RouterLink href="/search" onNavigate={onNavigate} />}
          >
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      const search = screen.getByRole('link', { name: 'Search' });

      (search.element() as HTMLElement).focus();
      await expect.element(search).toHaveFocus();
      await userEvent.keyboard('{Enter}');

      expect(change).toHaveBeenCalledWith('search');
      expect(onNavigate).toHaveBeenCalledWith('/search');
      await expect
        .poll(() => keyOf()?.style.getPropertyValue('--p-disc-x'))
        .toBe(`${(search.element() as HTMLElement).offsetLeft}px`);
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

      // `data-ready` is set in the frame after the first placement, and it is
      // what turns the duration on — the first destination appears under its
      // disc rather than flying in from the left edge of the capsule.
      await expect.poll(() => keyOf()?.hasAttribute('data-ready')).toBe(true);

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

    it('goes out when the destination it is under is made unavailable', async () => {
      const bar = (unavailable: boolean) => (
        <PlFloatingBottomNavigation className="bar-under-test" value="home">
          <PlFloatingBottomNavigationItem value="home" icon={glyph} disabled={unavailable}>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );
      const screen = await render(bar(false));

      expect(keyOf()).not.toHaveAttribute('data-quiet');

      await screen.rerender(bar(true));

      expect(keyOf()).toHaveAttribute('data-quiet');
    });

    it('does not measure again when a parent renders it again with nothing changed', async () => {
      const bar = () => (
        <PlFloatingBottomNavigation className="bar-under-test" value="home">
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );
      const screen = await render(bar());

      // The observer's first report measures once more, a frame after the bar
      // is mounted.
      await frames(3);

      const reads = vi.spyOn(HTMLElement.prototype, 'offsetLeft', 'get');

      try {
        // The same items, as new elements: that is what a parent rendering
        // again hands the bar, and each one used to read the layout back.
        await screen.rerender(bar());
        await frames(2);

        expect(
          reads.mock.contexts.filter((element) =>
            (element as HTMLElement).hasAttribute('data-disc')
          )
        ).toEqual([]);
      } finally {
        reads.mockRestore();
      }
    });

    it('measures again when the current destination moves among the others', async () => {
      const screen = await render(
        <PlFloatingBottomNavigation className="bar-under-test" value="search">
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      // Search goes first: nothing is resized, and the current disc stands
      // somewhere else.
      await screen.rerender(
        <PlFloatingBottomNavigation className="bar-under-test" value="search">
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );

      const disc = screen.getByRole('button', { name: 'Search' }).element() as HTMLElement;

      expect(keyOf()?.style.getPropertyValue('--p-disc-x')).toBe(`${disc.offsetLeft}px`);
    });

    it('measures again when a style moves the current destination without resizing the bar', async () => {
      const bar = (width: number) => (
        <PlFloatingBottomNavigation className="bar-under-test" value="search">
          <PlFloatingBottomNavigationItem value="home" icon={glyph} style={{ width }}>
            Home
          </PlFloatingBottomNavigationItem>
          <PlFloatingBottomNavigationItem value="search" icon={glyph}>
            Search
          </PlFloatingBottomNavigationItem>
        </PlFloatingBottomNavigation>
      );
      const screen = await render(bar(40));
      const before = keyOf()?.style.getPropertyValue('--p-disc-x');

      // Home grows inside a capsule that stays as wide as it was, so the
      // observer on the capsule has nothing to report, and Search stands
      // somewhere else.
      await screen.rerender(bar(90));

      const disc = screen.getByRole('button', { name: 'Search' }).element() as HTMLElement;

      expect(`${disc.offsetLeft}px`).not.toBe(before);
      expect(keyOf()?.style.getPropertyValue('--p-disc-x')).toBe(`${disc.offsetLeft}px`);
    });
  });
});
