import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlBottomNavigation, PlBottomNavigationItem } from 'plass-ui';

const glyph = <svg viewBox="0 0 24 24" data-testid="glyph" />;

describe('PlBottomNavigation', () => {
  describe('the bar', () => {
    it('is a nav rather than a tab list', async () => {
      const screen = await render(
        <PlBottomNavigation label="Main">
          <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      await expect.element(screen.getByRole('navigation', { name: 'Main' })).toBeInTheDocument();
      expect(screen.getByRole('tablist').query()).toBeNull();
    });

    it('is held against the bottom of the window by default', async () => {
      await render(<PlBottomNavigation className="bar-under-test" />);

      expect(document.querySelector('.bar-under-test')).toHaveClass('fixed');
    });

    it('sits in the flow when it is told to', async () => {
      await render(<PlBottomNavigation className="bar-under-test" position="static" />);

      const element = document.querySelector('.bar-under-test');

      expect(element).not.toHaveClass('fixed');
      // In the flow it is an ordinary sheet, so it takes corners.
      expect(element).toHaveClass('rounded-(--plass-radius-md)');
    });

    it('draws a hairline against the content it is over', async () => {
      await render(<PlBottomNavigation className="bar-under-test" />);

      expect(document.querySelector('.bar-under-test')).toHaveClass('border-t');
    });

    it('gives the hairline up when it is asked to', async () => {
      await render(<PlBottomNavigation className="bar-under-test" divider={false} />);

      expect(document.querySelector('.bar-under-test')).not.toHaveClass('border-t');
    });

    it('keeps clear of the home indicator', async () => {
      await render(<PlBottomNavigation className="bar-under-test" />);

      expect(document.querySelector('.bar-under-test')).toHaveClass(
        'pb-[env(safe-area-inset-bottom)]'
      );
    });
  });

  describe('choosing', () => {
    it('reports the destination that was pressed', async () => {
      const change = vi.fn();
      const screen = await render(
        <PlBottomNavigation onValueChange={change}>
          <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
          <PlBottomNavigationItem value="search">Search</PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      expect(change).toHaveBeenCalledWith('search');
    });

    it('moves on its own when nobody is holding the value', async () => {
      const screen = await render(
        <PlBottomNavigation defaultValue="home">
          <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
          <PlBottomNavigationItem value="search">Search</PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      expect(screen.getByRole('button', { name: 'Search' }).element()).toHaveAttribute(
        'aria-current',
        'page'
      );
    });

    it('stays where it was told to when somebody is', async () => {
      const screen = await render(
        <PlBottomNavigation value="home">
          <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
          <PlBottomNavigationItem value="search">Search</PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      await screen.getByRole('button', { name: 'Search' }).click();

      expect(screen.getByRole('button', { name: 'Home' }).element()).toHaveAttribute(
        'aria-current',
        'page'
      );
    });

    it('says which destination the reader is on, and never says pressed', async () => {
      const screen = await render(
        <PlBottomNavigation value="home">
          <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      const element = screen.getByRole('button', { name: 'Home' }).element();

      expect(element).toHaveAttribute('aria-current', 'page');
      expect(element).not.toHaveAttribute('aria-pressed');
    });
  });

  describe('an item', () => {
    it('is a button with nothing to navigate to', async () => {
      const screen = await render(
        <PlBottomNavigation>
          <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      expect(screen.getByRole('button', { name: 'Home' }).element().tagName).toBe('BUTTON');
    });

    it('is a real link when it has somewhere to go', async () => {
      const screen = await render(
        <PlBottomNavigation>
          <PlBottomNavigationItem value="home" href="/home">
            Home
          </PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      const element = screen.getByRole('link', { name: 'Home' }).element();

      expect(element.tagName).toBe('A');
      expect(element).toHaveAttribute('href', '/home');
    });

    it('draws the glyph it was given', async () => {
      const screen = await render(
        <PlBottomNavigation>
          <PlBottomNavigationItem value="home" icon={glyph}>
            Home
          </PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      expect(screen.getByTestId('glyph').element()).toBeInTheDocument();
    });

    it('does not answer while it is unavailable', async () => {
      const change = vi.fn();
      const screen = await render(
        <PlBottomNavigation onValueChange={change}>
          <PlBottomNavigationItem value="home" disabled>
            Home
          </PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      expect(screen.getByRole('button', { name: 'Home' }).element()).toBeDisabled();
      expect(change).not.toHaveBeenCalled();
    });

    it('goes unavailable with the whole bar', async () => {
      const screen = await render(
        <PlBottomNavigation disabled>
          <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      expect(screen.getByRole('button', { name: 'Home' }).element()).toBeDisabled();
    });

    it('drops the href on a disabled link rather than leaving a live one', async () => {
      const screen = await render(
        <PlBottomNavigation>
          <PlBottomNavigationItem value="home" href="/home" disabled>
            Home
          </PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      const element = screen.getByText('Home').element().closest('a');

      expect(element).not.toHaveAttribute('href');
      expect(element).toHaveAttribute('aria-disabled', 'true');
    });
  });

  describe('labels', () => {
    it('names every destination by default', async () => {
      const screen = await render(
        <PlBottomNavigation>
          <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
          <PlBottomNavigationItem value="search">Search</PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      expect(screen.getByText('Home').element()).not.toHaveClass('absolute');
      expect(screen.getByText('Search').element()).not.toHaveClass('absolute');
    });

    it('draws only the current one when it is asked to', async () => {
      const screen = await render(
        <PlBottomNavigation labels="selected" value="home">
          <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
          <PlBottomNavigationItem value="search">Search</PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      expect(screen.getByText('Home').element()).not.toHaveClass('absolute');
      // Undrawn, but still in the document — a glyph on its own has no name.
      expect(screen.getByText('Search').element()).toHaveClass('absolute');
    });

    it('keeps every name readable with none of them drawn', async () => {
      const screen = await render(
        <PlBottomNavigation labels="none">
          <PlBottomNavigationItem value="home">Home</PlBottomNavigationItem>
        </PlBottomNavigation>
      );

      await expect.element(screen.getByRole('button', { name: 'Home' })).toBeInTheDocument();
      expect(screen.getByText('Home').element()).toHaveClass('absolute');
    });
  });
});
