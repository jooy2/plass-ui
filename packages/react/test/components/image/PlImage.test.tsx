/**
 * The pictures here are `data:` URLs, so nothing in this file depends on a
 * network or on a file on disk — a one-pixel PNG that always loads, and a
 * string that is not an image and therefore always fails.
 */
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlImage } from 'plass-ui';

const OK =
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
const BROKEN = 'data:image/png;base64,not-a-png';

const image = () => document.querySelector('img')!;
const box = (className: string) => document.querySelector(`.${className}`) as HTMLElement;

describe('PlImage', () => {
  describe('the picture', () => {
    it('renders an img with the alt it was given', async () => {
      const screen = await render(<PlImage src={OK} alt="A portrait" />);

      await expect.element(screen.getByRole('img', { name: 'A portrait' })).toBeInTheDocument();
    });

    it('takes an empty alt as an answer', async () => {
      await render(<PlImage src={OK} alt="" />);

      // `alt=""` marks the picture decorative rather than unnamed.
      expect(image().getAttribute('alt')).toBe('');
    });

    it('lazy-loads by default', async () => {
      await render(<PlImage src={OK} alt="A portrait" />);

      expect(image().getAttribute('loading')).toBe('lazy');
    });

    it('takes an eager one when it is asked', async () => {
      await render(<PlImage src={OK} alt="A portrait" loading="eager" />);

      expect(image().getAttribute('loading')).toBe('eager');
    });
  });

  describe('the space it reserves', () => {
    it('holds the proportion it was given', async () => {
      await render(<PlImage src={OK} alt="A portrait" ratio="16 / 9" className="img-under-test" />);

      expect(box('img-under-test').style.aspectRatio).toBe('16 / 9');
    });

    it('holds nothing without one', async () => {
      await render(<PlImage src={OK} alt="A portrait" className="img-under-test" />);

      // Honest rather than helpful: with no ratio there is nothing to reserve,
      // and the box is however tall the picture turns out to be.
      expect(box('img-under-test').style.aspectRatio).toBe('');
    });

    it('clips whatever overflows it', async () => {
      await render(<PlImage src={OK} alt="A portrait" className="img-under-test" />);

      expect(box('img-under-test')).toHaveClass('overflow-hidden');
    });
  });

  describe('while it is loading', () => {
    it('draws a placeholder', async () => {
      await render(<PlImage src={BROKEN} alt="A portrait" placeholder={<span>Loading…</span>} />);

      // Asserted with a `src` that never loads, so the placeholder is still up
      // when the assertion runs whichever browser this is.
      expect(document.body.textContent).toContain('Loading…');
    });

    it('draws none when it is told not to', async () => {
      await render(<PlImage src={BROKEN} alt="A portrait" placeholder={null} />);

      expect(document.querySelector('[aria-busy="true"]')).toBeNull();
    });

    it('keeps the img in the document', async () => {
      await render(<PlImage src={BROKEN} alt="A portrait" />);

      // An `<img>` that is not in the document never loads, so a placeholder
      // that unmounted it would be a picture that never arrives.
      expect(image()).toBeTruthy();
    });
  });

  describe('when it does not arrive', () => {
    it('draws the alt text rather than a broken glyph', async () => {
      const screen = await render(<PlImage src={BROKEN} alt="A portrait" />);

      await expect.element(screen.getByText('A portrait')).toBeInTheDocument();
    });

    it('draws a fallback of its own when it has one', async () => {
      const screen = await render(
        <PlImage src={BROKEN} alt="A portrait" fallback={<span>No photo</span>} />
      );

      await expect.element(screen.getByText('No photo')).toBeInTheDocument();
    });

    it('reports the failure', async () => {
      const onStatusChange = vi.fn();

      await render(<PlImage src={BROKEN} alt="A portrait" onStatusChange={onStatusChange} />);

      await expect.poll(() => onStatusChange.mock.calls).toEqual([['error']]);
    });

    it('reports the arrival', async () => {
      const onStatusChange = vi.fn();

      await render(<PlImage src={OK} alt="A portrait" onStatusChange={onStatusChange} />);

      await expect.poll(() => onStatusChange.mock.calls).toEqual([['loaded']]);
    });

    it('fades the picture in rather than swapping it for the placeholder', async () => {
      await render(<PlImage src={OK} alt="A portrait" />);

      const picture = document.querySelector('img')!;

      expect(picture.className).toContain('transition-property');
      expect(picture.className).toContain(',opacity]');
    });

    it('starts again when the src changes', async () => {
      const onStatusChange = vi.fn();

      const screen = await render(
        <PlImage src={OK} alt="A portrait" onStatusChange={onStatusChange} />
      );

      await expect.poll(() => onStatusChange.mock.calls.length).toBe(1);

      await screen.rerender(<PlImage src={BROKEN} alt="Another" onStatusChange={onStatusChange} />);

      // Without the reset a second picture would inherit the first one's
      // `loaded` and never draw its own failure.
      await expect.poll(() => onStatusChange.mock.calls).toEqual([['loaded'], ['error']]);
    });
  });

  describe('preview', () => {
    it('is not a button unless it is asked to be', async () => {
      await render(<PlImage src={OK} alt="A portrait" />);

      expect(document.querySelector('button')).toBeNull();
    });

    it('names the button after the picture', async () => {
      await render(<PlImage src={OK} alt="A portrait" preview />);

      // Three previews on a page would otherwise be three buttons called
      // "Preview".
      expect(document.querySelector('button')!.getAttribute('aria-label')).toBe(
        'A portrait — preview'
      );
    });

    it('cannot be opened before the picture has arrived', async () => {
      await render(<PlImage src={BROKEN} alt="A portrait" preview />);

      await expect.poll(() => document.querySelector('button')!.disabled).toBe(true);
    });

    it('opens over the page once it has', async () => {
      const screen = await render(<PlImage src={OK} alt="A portrait" preview />);

      await expect.poll(() => document.querySelector('button')!.disabled).toBe(false);

      await screen.getByRole('button').click();

      await expect.poll(() => document.querySelectorAll('img').length).toBe(2);
    });
  });

  describe('caller styling', () => {
    it('keeps a caller-supplied class alongside its own', async () => {
      await render(<PlImage src={OK} alt="A portrait" className="my-own-class" />);

      expect(box('my-own-class')).toHaveClass('relative');
    });

    it('passes native attributes through to the img', async () => {
      await render(<PlImage src={OK} alt="A portrait" width={64} height={64} />);

      expect(image().getAttribute('width')).toBe('64');
    });
  });
});
