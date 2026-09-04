import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAppLogo } from 'plass-ui';

const MARK = 'data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22/%3E';

function logo(): HTMLElement {
  return document.querySelector<HTMLElement>('.logo-under-test')!;
}

/** The box the artwork sits in, plate or not. */
function frame(): HTMLElement {
  return logo().firstElementChild as HTMLElement;
}

describe('PlAppLogo', () => {
  describe('the framing', () => {
    it('draws the artwork as it was given', async () => {
      await render(<PlAppLogo className="logo-under-test" src={MARK} alt="Acme" />);

      // No plate and no crop: the height is set and the width follows, which is
      // what a wordmark needs and what a square would destroy.
      expect(frame().classList.contains('h-8')).toBe(true);
      expect(frame().querySelector('img')!.classList.contains('w-auto')).toBe(true);
    });

    it('puts it on a tile when it was asked to', async () => {
      await render(<PlAppLogo className="logo-under-test" shape="plate" src={MARK} alt="Acme" />);

      expect(frame().classList.contains('size-8')).toBe(true);
      expect(frame().className).toContain('rounded-(--plass-radius-md)');
    });

    it('rounds the tile all the way for a disc', async () => {
      await render(<PlAppLogo className="logo-under-test" shape="circle" src={MARK} alt="Acme" />);

      expect(frame().classList.contains('rounded-full')).toBe(true);
    });

    it('insets the artwork inside a tile rather than filling it', async () => {
      await render(<PlAppLogo className="logo-under-test" shape="plate" src={MARK} alt="Acme" />);

      const picture = frame().querySelector('img')!;

      expect(picture.classList.contains('size-[70%]')).toBe(true);
      expect(picture.classList.contains('object-contain')).toBe(true);
    });

    it('takes the family and the material on the tile only', async () => {
      await render(
        <PlAppLogo className="logo-under-test" shape="plate" variant="ghost" color="success">
          <svg viewBox="0 0 16 16" />
        </PlAppLogo>
      );

      expect(frame().classList.contains('bg-(--p-soft)')).toBe(true);
      expect(logo().style.getPropertyValue('--p-soft')).toBe('var(--plass-success-soft)');
    });
  });

  describe('the words', () => {
    it('sets the name beside the mark', async () => {
      const screen = await render(
        <PlAppLogo className="logo-under-test" src={MARK} name="Acme" description="Staging" />
      );

      await expect.element(screen.getByText('Acme')).toBeInTheDocument();
      await expect.element(screen.getByText('Staging')).toBeInTheDocument();
    });

    it('draws none of that when it was given none', async () => {
      await render(<PlAppLogo className="logo-under-test" src={MARK} alt="Acme" />);

      expect(logo().children.length).toBe(1);
    });
  });

  describe('accessibility', () => {
    it('hides the mark once the name says it', async () => {
      await render(<PlAppLogo className="logo-under-test" src={MARK} name="Acme" />);

      // A wordmark beside a picture of the wordmark is a screen reader reading
      // the product's name twice.
      expect(frame().getAttribute('aria-hidden')).toBe('true');
    });

    it('leaves the mark to speak when there is no name', async () => {
      await render(<PlAppLogo className="logo-under-test" src={MARK} alt="Acme" />);

      expect(frame().getAttribute('aria-hidden')).toBeNull();
      expect(frame().querySelector('img')!.alt).toBe('Acme');
    });

    it('marks a picture decorative unless it was given words', async () => {
      await render(<PlAppLogo className="logo-under-test" src={MARK} />);

      // An empty alt is a real answer: it says the picture carries nothing the
      // text does not.
      expect(frame().querySelector('img')!.alt).toBe('');
    });

    it('becomes a link when it is handed one', async () => {
      const screen = await render(
        <PlAppLogo className="logo-under-test" src={MARK} name="Acme" render={<a href="/" />} />
      );

      await expect.element(screen.getByRole('link')).toHaveAttribute('href', '/');
    });
  });
});
