/**
 * The pictures here are `data:` URLs, so nothing in this file depends on a
 * network or on a file on disk — a one-pixel PNG that always loads, and a
 * string that is not an image and therefore always fails.
 *
 * Neither of them can be used to hold the component at `loading`. Both settle,
 * and how soon is the browser's business: a failing `data:` URL fires `error`
 * within a task, so on a loaded CI machine the fallback is already up by the
 * time the assertion runs and on a quiet laptop it is not. The three tests that
 * are about the loading state therefore give **no `src` at all**, which is the
 * one picture that genuinely never settles — an `<img>` with no `src` is never
 * fetched, so neither `load` nor `error` ever fires.
 */
import { afterEach, describe, expect, it, vi } from 'vitest';
import * as React from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { render } from 'vitest-browser-react';
import { PlImage, type PlImageRotation } from 'plass-ui';

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

  describe('priority', () => {
    it('asks for nothing early by default', async () => {
      await render(<PlImage src={OK} alt="A portrait" />);

      // HTML attribute names are case-insensitive, so this is the attribute
      // whichever spelling React wrote it under.
      expect(image().getAttribute('fetchpriority')).toBeNull();
    });

    it('fetches the picture a page is judged by early', async () => {
      await render(<PlImage src={OK} alt="A portrait" priority />);

      expect(image().getAttribute('loading')).toBe('eager');
      expect(image().getAttribute('fetchpriority')).toBe('high');
    });

    it('lets an attribute written out win', async () => {
      await render(
        <PlImage src={OK} alt="A portrait" priority loading="lazy" fetchPriority="low" />
      );

      expect(image().getAttribute('loading')).toBe('lazy');
      expect(image().getAttribute('fetchpriority')).toBe('low');
    });

    it('passes the native loading attributes through on their own', async () => {
      await render(<PlImage src={OK} alt="A portrait" decoding="async" fetchPriority="low" />);

      expect(image().getAttribute('decoding')).toBe('async');
      expect(image().getAttribute('fetchpriority')).toBe('low');
    });

    it('asks for a blurred letterbox the same way, so it is the same request', async () => {
      await render(<PlImage src={OK} alt="A portrait" fit="contain" letterbox="blur" priority />);

      const copy = document.querySelector('img[aria-hidden="true"]')!;

      expect(copy.getAttribute('loading')).toBe('eager');
      expect(copy.getAttribute('fetchpriority')).toBe('high');
    });

    it('writes the attribute under the name this React knows, without a warning', async () => {
      const error = vi.spyOn(console, 'error').mockImplementation(() => {});

      await render(<PlImage src={OK} alt="A portrait" priority />);

      expect(error).not.toHaveBeenCalled();
      error.mockRestore();
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

  describe('fit', () => {
    it('covers the box by default', async () => {
      await render(<PlImage src={OK} alt="A portrait" />);

      expect(image()).toHaveClass('object-cover');
    });

    it('scales a picture down without ever enlarging it', async () => {
      await render(<PlImage src={OK} alt="A portrait" fit="scale-down" />);

      expect(image()).toHaveClass('object-scale-down');
    });
  });

  describe('position', () => {
    const placed = () => image().style.objectPosition;

    it('writes nothing until it is asked to', async () => {
      await render(<PlImage src={OK} alt="A portrait" rotate={90} flip="both" />);

      expect(placed()).toBe('');
    });

    it('writes a side, a corner and a pair as percentages', async () => {
      const screen = await render(<PlImage src={OK} alt="A portrait" position="top" />);

      expect(placed()).toBe('50% 0%');

      await screen.rerender(<PlImage src={OK} alt="A portrait" position="bottom right" />);

      expect(placed()).toBe('100% 100%');

      await screen.rerender(<PlImage src={OK} alt="A portrait" position="30% 20%" />);

      expect(placed()).toBe('30% 20%');
    });

    it('keeps the top of what is shown through a half turn', async () => {
      await render(<PlImage src={OK} alt="A portrait" position="top" rotate={180} />);

      expect(placed()).toBe('50% 100%');
    });

    it('keeps the top of what is shown through a quarter turn', async () => {
      await render(<PlImage src={OK} alt="A portrait" position="top" rotate={90} />);

      // The element's left edge is what lies along the top of the screen.
      expect(placed()).toBe('0% 50%');
    });

    it('keeps the side it names through a mirror', async () => {
      await render(<PlImage src={OK} alt="A portrait" position="left" flip="horizontal" />);

      expect(placed()).toBe('100% 50%');
    });

    it('passes a value it cannot read straight through', async () => {
      await render(<PlImage src={OK} alt="A portrait" position="10px 20px" rotate={90} />);

      expect(placed()).toBe('10px 20px');
    });
  });

  describe('letterbox', () => {
    const picture = () => document.querySelector('img:not([aria-hidden])') as HTMLImageElement;
    const copies = () => document.querySelectorAll<HTMLImageElement>('img[aria-hidden="true"]');

    it('fills nothing until it is asked to', async () => {
      await render(<PlImage src={OK} alt="A portrait" fit="contain" className="img-under-test" />);

      expect(box('img-under-test').style.background).toBe('');
      expect(copies()).toHaveLength(0);
    });

    it('paints a colour behind the picture', async () => {
      await render(
        <PlImage
          src={OK}
          alt="A portrait"
          fit="contain"
          letterbox="rgb(16, 20, 24)"
          className="img-under-test"
        />
      );

      expect(box('img-under-test').style.background).toContain('rgb(16, 20, 24)');
      expect(copies()).toHaveLength(0);
    });

    it('draws one hidden copy of the picture for blur', async () => {
      await render(<PlImage src={OK} alt="A portrait" fit="contain" letterbox="blur" />);

      expect(copies()).toHaveLength(1);

      const copy = copies()[0];

      // Nothing to read out, nothing to drag, and nothing a right-click lands on.
      expect(copy.getAttribute('alt')).toBe('');
      expect(copy.getAttribute('draggable')).toBe('false');
      expect(copy).toHaveClass('pointer-events-none', 'select-none', 'object-cover');
      expect(copy.style.filter).toBe('blur(24px)');
      // Grown past the box by two radii, so the soft edge of the blur is clipped.
      expect([copy.style.top, copy.style.left, copy.style.width]).toEqual([
        '-48px',
        '-48px',
        'calc(100% + 96px)'
      ]);
      // Before the picture, and the picture positioned so it paints over it.
      expect(copy.nextElementSibling).toBe(picture());
      expect(picture()).toHaveClass('relative');
    });

    it('loads the copy from exactly what the picture loads from', async () => {
      await render(
        <PlImage
          src={OK}
          srcSet={`${OK} 1x`}
          sizes="50vw"
          alt="A portrait"
          fit="scale-down"
          letterbox="blur"
          loading="eager"
          decoding="async"
          crossOrigin="anonymous"
          referrerPolicy="no-referrer"
        />
      );

      const copy = copies()[0];

      for (const name of [
        'src',
        'srcset',
        'sizes',
        'loading',
        'decoding',
        'crossorigin',
        'referrerpolicy'
      ]) {
        expect(copy.getAttribute(name)).toBe(picture().getAttribute(name));
      }
    });

    it('turns, mirrors, places and tints the copy the way the picture is', async () => {
      await render(
        <PlImage
          src={OK}
          alt="A portrait"
          fit="none"
          letterbox="blur"
          rotate={90}
          flip="horizontal"
          position="top"
          filter="grayscale"
        />
      );

      const copy = copies()[0];

      expect(copy.style.rotate).toBe(picture().style.rotate);
      expect(copy.style.scale).toBe(picture().style.scale);
      expect(copy.style.objectPosition).toBe(picture().style.objectPosition);
      expect(copy.style.filter).toBe('grayscale(1) blur(24px)');
      expect([copy.style.width, copy.style.height]).toEqual([
        'calc(100cqh + 96px)',
        'calc(100cqw + 96px)'
      ]);
    });

    it('draws no copy under a fit that leaves no space', async () => {
      const screen = await render(<PlImage src={OK} alt="A portrait" letterbox="blur" />);

      expect(copies()).toHaveLength(0);

      await screen.rerender(<PlImage src={OK} alt="A portrait" fit="fill" letterbox="blur" />);

      expect(copies()).toHaveLength(0);
    });

    it('fades the copy in with the picture', async () => {
      await render(<PlImage alt="A portrait" fit="contain" letterbox="blur" />);

      expect(copies()[0]).toHaveClass('opacity-0');
    });
  });

  describe('a lone width or height', () => {
    it('sizes the box to a lone height, across the width it is given', async () => {
      await render(<PlImage src={OK} alt="A portrait" height={200} className="img-under-test" />);

      const style = box('img-under-test').style;

      expect(style.height).toBe('200px');
      expect(style.width).toBe('');
      expect(style.aspectRatio).toBe('');
    });

    it('sizes the box to a lone width, never wider than its container', async () => {
      await render(<PlImage src={OK} alt="A portrait" width={320} className="img-under-test" />);

      const style = box('img-under-test').style;

      expect([style.width, style.maxWidth, style.height]).toEqual(['320px', '100%', '']);
    });

    it('reads a string of digits as pixels and a length as written', async () => {
      const screen = await render(
        <PlImage src={OK} alt="A portrait" height="180" className="img-under-test" />
      );

      expect(box('img-under-test').style.height).toBe('180px');

      await screen.rerender(
        <PlImage src={OK} alt="A portrait" height="12rem" className="img-under-test" />
      );

      expect(box('img-under-test').style.height).toBe('12rem');
    });

    it('takes the width from a ratio beside a lone height', async () => {
      await render(
        <PlImage src={OK} alt="A portrait" height={160} ratio="3 / 2" className="img-under-test" />
      );

      const style = box('img-under-test').style;

      expect([style.height, style.width, style.maxWidth, style.aspectRatio]).toEqual([
        '160px',
        'auto',
        '100%',
        '3 / 2'
      ]);
    });

    it('leaves the box alone when both are given', async () => {
      await render(
        <PlImage src={OK} alt="A portrait" width={1200} height={800} className="img-under-test" />
      );

      // Together they describe the file, which the `<img>` already reserves.
      const style = box('img-under-test').style;

      expect([style.width, style.height]).toEqual(['', '']);
      expect([image().getAttribute('width'), image().getAttribute('height')]).toEqual([
        '1200',
        '800'
      ]);
    });

    it('still hands a lone one to the img', async () => {
      await render(<PlImage src={OK} alt="A portrait" height={200} />);

      expect(image().getAttribute('height')).toBe('200');
    });

    it('narrows a preview’s button to the box rather than stretching it past', async () => {
      const screen = await render(<PlImage src={OK} alt="A portrait" width={240} preview />);

      // The button is the box, so the focus ring is drawn round the picture.
      expect(document.querySelector('button')!.style.width).toBe('240px');

      await screen.rerender(<PlImage src={OK} alt="A portrait" height={120} ratio="1" preview />);

      expect(document.querySelector('button')!.style.width).toBe('auto');
    });

    it('keeps a turned file’s shape off a box a lone height has fixed', async () => {
      const tall = `data:image/svg+xml,${encodeURIComponent(
        '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="80"></svg>'
      )}`;
      const onStatusChange = vi.fn();

      await render(
        <PlImage
          src={tall}
          alt="A portrait"
          height={200}
          rotate={90}
          onStatusChange={onStatusChange}
          className="img-under-test"
        />
      );

      await expect.poll(() => onStatusChange.mock.calls).toEqual([['loaded']]);

      // Written as well, the file's shape would work the width out again.
      expect(box('img-under-test').style.aspectRatio).toBe('');
      expect(box('img-under-test').style.height).toBe('200px');
    });
  });

  describe('while it is loading', () => {
    it('draws a placeholder', async () => {
      await render(<PlImage alt="A portrait" placeholder={<span>Loading…</span>} />);

      expect(document.body.textContent).toContain('Loading…');
    });

    it('draws the skeleton when it is given no placeholder of its own', async () => {
      await render(<PlImage alt="A portrait" />);

      // The default, and the thing `placeholder={null}` turns off below. The
      // skeleton is unlabelled scenery, so it is `aria-hidden` and has no role
      // to ask for — its own sweep class is what says it is there.
      expect(document.querySelector('.plass-skeleton')).not.toBeNull();
    });

    it('draws none when it is told not to', async () => {
      await render(<PlImage alt="A portrait" placeholder={null} />);

      expect(document.querySelector('.plass-skeleton')).toBeNull();
    });

    it('keeps the img in the document', async () => {
      await render(<PlImage alt="A portrait" />);

      // An `<img>` that is not in the document never loads, so a placeholder
      // that unmounted it would be a picture that never arrives.
      expect(image()).toBeTruthy();
    });
  });

  describe('a picture placeholder', () => {
    const TINY = `data:image/svg+xml,${encodeURIComponent(
      '<svg xmlns="http://www.w3.org/2000/svg" width="3" height="2"></svg>'
    )}`;
    const standIn = () =>
      document.querySelector('img[aria-hidden="true"]') as HTMLImageElement | null;
    const picture = () => document.querySelector('img:not([aria-hidden])') as HTMLImageElement;

    it('stands in for the picture instead of the skeleton', async () => {
      await render(<PlImage alt="A portrait" ratio="3 / 2" placeholder={{ src: TINY }} />);

      expect(standIn()!.getAttribute('src')).toBe(TINY);
      expect(standIn()!.getAttribute('alt')).toBe('');
      expect(standIn()!.getAttribute('draggable')).toBe('false');
      expect(standIn()).toHaveClass('pointer-events-none', 'object-cover');
      expect(document.querySelector('.plass-skeleton')).toBeNull();
      // Under the picture, which is positioned so it paints over it.
      expect(standIn()!.nextElementSibling).toBe(picture());
      expect(picture()).toHaveClass('relative');
    });

    it('is not taken for a node of the caller’s own', async () => {
      await render(<PlImage alt="A portrait" placeholder={<span>Loading…</span>} />);

      expect(standIn()).toBeNull();
      expect(document.body.textContent).toContain('Loading…');
    });

    it('blurs by 20 pixels for true, by a number for a number, and grows by two of them', async () => {
      const screen = await render(
        <PlImage alt="A portrait" ratio="1" placeholder={{ src: TINY, blur: true }} />
      );

      expect(standIn()!.style.filter).toBe('blur(20px)');
      expect([standIn()!.style.top, standIn()!.style.width]).toEqual([
        '-40px',
        'calc(100% + 80px)'
      ]);

      await screen.rerender(
        <PlImage alt="A portrait" ratio="1" placeholder={{ src: TINY, blur: 6 }} />
      );

      expect(standIn()!.style.filter).toBe('blur(6px)');

      await screen.rerender(<PlImage alt="A portrait" ratio="1" placeholder={{ src: TINY }} />);

      expect(standIn()!.style.filter).toBe('');
      expect(standIn()!.style.width).toBe('100%');
    });

    it('is fitted, placed, turned and mirrored the way the picture is', async () => {
      await render(
        <PlImage
          alt="A portrait"
          ratio="1"
          fit="contain"
          position="top"
          rotate={270}
          flip="vertical"
          placeholder={{ src: TINY }}
        />
      );

      expect(standIn()).toHaveClass('object-contain');
      expect(standIn()!.style.objectPosition).toBe(picture().style.objectPosition);
      expect(standIn()!.style.rotate).toBe(picture().style.rotate);
      expect(standIn()!.style.scale).toBe(picture().style.scale);
      expect(standIn()!.style.width).toBe('100cqh');
    });

    it('shows a Blob through an object URL it releases on unmount', async () => {
      const revoke = vi.spyOn(URL, 'revokeObjectURL');
      const blob = new Blob(['<svg xmlns="http://www.w3.org/2000/svg" width="3" height="2"/>'], {
        type: 'image/svg+xml'
      });

      const screen = await render(
        <PlImage alt="A portrait" ratio="3 / 2" placeholder={{ src: blob }} />
      );

      await expect.poll(() => standIn()?.getAttribute('src') ?? '').toMatch(/^blob:/);

      const url = standIn()!.getAttribute('src')!;

      await screen.unmount();

      expect(revoke).toHaveBeenCalledWith(url);
      revoke.mockRestore();
    });

    it('stays until the picture has faded in over it, then goes in one step', async () => {
      await render(<PlImage src={OK} alt="A portrait" ratio="1" placeholder={{ src: TINY }} />);

      await expect.poll(() => picture().className).toContain('opacity-100');

      // Opaque for as long as the fade takes, then gone without a cross-fade.
      expect(standIn()!.style.opacity).toBe('0');
      expect(standIn()!.style.transition).toBe('opacity 0ms linear var(--plass-duration)');
    });

    it('is opaque while the picture is on its way', async () => {
      await render(<PlImage alt="A portrait" ratio="1" placeholder={{ src: TINY }} />);

      expect(standIn()!.style.opacity).toBe('');
    });

    it('is taken away when the picture does not arrive', async () => {
      const screen = await render(
        <PlImage src={BROKEN} alt="A portrait" ratio="1" placeholder={{ src: TINY }} />
      );

      await expect.element(screen.getByText('A portrait')).toBeInTheDocument();

      expect(standIn()).toBeNull();
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

    it('takes the width it is given rather than the width of its content', async () => {
      await render(<PlImage alt="A portrait" ratio="1" preview />);

      // A block `<button>` still shrinks to its content, and before the file
      // arrives that content has no width, so the ratio would reserve nothing.
      expect(document.querySelector('button')).toHaveClass('w-full');
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

  describe('rotate', () => {
    /** A file with a width and a height and no network behind it. */
    const sized = (width: number, height: number) =>
      `data:image/svg+xml,${encodeURIComponent(
        `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}"></svg>`
      )}`;

    it('writes nothing new until it is asked to', async () => {
      await render(<PlImage src={OK} alt="A portrait" className="img-under-test" />);

      expect(image().getAttribute('style')).toBeNull();
      expect(box('img-under-test').style.containerType).toBe('');
    });

    it('turns with the rotate property and leaves transform alone', async () => {
      await render(<PlImage src={OK} alt="A portrait" rotate={180} className="img-under-test" />);

      // A `transform` written inline would silently beat a hover effect or a
      // class of the caller's own.
      expect(image().style.rotate).toBe('180deg');
      expect(image().style.transform).toBe('');
    });

    it('keeps a half turn in the flow', async () => {
      await render(<PlImage src={OK} alt="A portrait" rotate={180} className="img-under-test" />);

      // Upside down is the same footprint, so nothing has to be laid out again.
      expect(image().style.position).toBe('');
      expect(box('img-under-test').style.containerType).toBe('');
    });

    it('takes any other number to the nearest quarter', async () => {
      const screen = await render(
        <PlImage src={OK} alt="A portrait" rotate={-90 as PlImageRotation} />
      );

      expect(image().style.rotate).toBe('270deg');

      await screen.rerender(<PlImage src={OK} alt="A portrait" rotate={450 as PlImageRotation} />);

      expect(image().style.rotate).toBe('90deg');

      await screen.rerender(<PlImage src={OK} alt="A portrait" rotate={NaN as PlImageRotation} />);

      expect(image().style.rotate).toBe('');
    });

    it('lays a quarter turn out at the box turned on its side', async () => {
      await render(<PlImage src={OK} alt="A portrait" rotate={90} className="img-under-test" />);

      const style = image().style;

      // The box's height by its width, centred and turned into place, which is
      // what lets `object-fit` fit the turned picture to the box.
      expect([style.width, style.height]).toEqual(['100cqh', '100cqw']);
      expect([style.position, style.top, style.left, style.translate]).toEqual([
        'absolute',
        '50%',
        '50%',
        '-50% -50%'
      ]);
      // A reset caps an `<img>` at its parent's width, which on a tall box is
      // shorter than the turned picture.
      expect(style.maxWidth).toBe('none');
      expect(box('img-under-test').style.containerType).toBe('size');
    });

    it('reserves the turned shape of the dimensions it was given', async () => {
      await render(
        <PlImage
          src={OK}
          alt="A portrait"
          width={1200}
          height={800}
          rotate={90}
          className="img-under-test"
        />
      );

      expect(box('img-under-test').style.aspectRatio).toBe('800 / 1200');
    });

    it('keeps a ratio of the caller’s own', async () => {
      await render(
        <PlImage
          src={OK}
          alt="A portrait"
          width={1200}
          height={800}
          ratio="16 / 9"
          rotate={270}
          className="img-under-test"
        />
      );

      // The ratio is the layout's shape, and `fit` decides how the turned
      // picture fills it.
      expect(box('img-under-test').style.aspectRatio).toBe('16 / 9');
    });

    it('takes the turned shape from the file when nothing was declared', async () => {
      await render(
        <PlImage src={sized(120, 80)} alt="A portrait" rotate={90} className="img-under-test" />
      );

      await expect.poll(() => box('img-under-test').style.aspectRatio).toBe('80 / 120');
    });

    it('opens the preview turned, in a box of the turned shape', async () => {
      const screen = await render(
        <PlImage src={sized(120, 80)} alt="A portrait" rotate={90} preview />
      );

      await expect.poll(() => document.querySelector('button')!.disabled).toBe(false);
      await screen.getByRole('button').click();
      await expect.poll(() => document.querySelectorAll('img').length).toBe(2);

      const opened = [...document.querySelectorAll('img')].at(-1)!;
      const frame = opened.parentElement!;

      expect(opened.style.rotate).toBe('90deg');
      expect(opened.style.width).toBe('100cqh');
      expect(frame.style.aspectRatio).toBe('80 / 120');
      expect(frame.style.containerType).toBe('size');
      expect(frame.style.width).toContain('80px');
    });
  });

  describe('flip', () => {
    /**
     * The mirror as two numbers across and down. A browser writes a uniform
     * `scale: -1 -1` back as `-1`, so one number is both.
     */
    const mirror = () => {
      const [x, y = x] = image().style.scale.split(' ');

      return x === undefined || x === '' ? null : [x, y];
    };

    it('mirrors nothing until it is asked to', async () => {
      await render(<PlImage src={OK} alt="A portrait" />);

      expect(mirror()).toBeNull();
    });

    it('mirrors along the axis it names', async () => {
      const screen = await render(<PlImage src={OK} alt="A portrait" flip="horizontal" />);

      expect(mirror()).toEqual(['-1', '1']);

      await screen.rerender(<PlImage src={OK} alt="A portrait" flip="vertical" />);

      expect(mirror()).toEqual(['1', '-1']);

      await screen.rerender(<PlImage src={OK} alt="A portrait" flip="both" />);

      expect(mirror()).toEqual(['-1', '-1']);
      expect(image().style.transform).toBe('');
    });

    it('swaps the axes on a quarter turn, so the mirror lands on the screen’s', async () => {
      const screen = await render(
        <PlImage src={OK} alt="A portrait" flip="horizontal" rotate={90} />
      );

      // `scale` acts on the element before `rotate` turns it, so left and right
      // on the screen are the element's top and bottom.
      expect(mirror()).toEqual(['1', '-1']);

      await screen.rerender(<PlImage src={OK} alt="A portrait" flip="vertical" rotate={270} />);

      expect(mirror()).toEqual(['-1', '1']);

      await screen.rerender(<PlImage src={OK} alt="A portrait" flip="horizontal" rotate={180} />);

      expect(mirror()).toEqual(['-1', '1']);
    });

    it('opens the preview mirrored', async () => {
      const screen = await render(
        <PlImage src={OK} alt="A portrait" flip="vertical" rotate={90} preview />
      );

      await expect.poll(() => document.querySelector('button')!.disabled).toBe(false);
      await screen.getByRole('button').click();
      await expect.poll(() => document.querySelectorAll('img').length).toBe(2);

      const opened = [...document.querySelectorAll('img')].at(-1)!;

      expect(opened.style.scale).toBe('-1 1');
      expect(opened.style.rotate).toBe('90deg');
    });
  });

  describe('filter', () => {
    it('draws nothing of its own until it is asked to', async () => {
      await render(<PlImage src={OK} alt="A portrait" />);

      expect(image().style.getPropertyValue('--p-filter')).toBe('');
      expect(image().className).not.toContain('--p-filter');
    });

    it('resolves a named treatment to the CSS it stands for', async () => {
      await render(<PlImage src={OK} alt="A portrait" filter="grayscale" />);

      expect(image().style.getPropertyValue('--p-filter')).toBe('grayscale(1)');
    });

    it('passes a chain of its own straight through', async () => {
      // Anything that is not one of the names is CSS, which is what makes the
      // escape hatch free — there is nothing to parse and nothing to allow.
      await render(<PlImage src={OK} alt="A portrait" filter="blur(2px) hue-rotate(20deg)" />);

      expect(image().style.getPropertyValue('--p-filter')).toBe('blur(2px) hue-rotate(20deg)');
    });

    it('travels on the same transition as the picture’s own fade', async () => {
      await render(<PlImage src={OK} alt="A portrait" filter="sepia" />);

      // A treatment swapped on hover has to move at the pace the fade moves at,
      // or it snaps while the fade is still going.
      expect(image().className).toContain('[filter:var(--p-filter,none)]');
      expect(image().className).toContain('filter,opacity');
    });

    it('changes on a re-render', async () => {
      const screen = await render(<PlImage src={OK} alt="A portrait" filter="sepia" />);

      await screen.rerender(<PlImage src={OK} alt="A portrait" filter="dim" />);

      expect(image().style.getPropertyValue('--p-filter')).toBe('brightness(0.82)');
    });
  });

  describe('watermark', () => {
    // Scoped past the skeleton, which is `aria-hidden` as well and has every
    // right to be — it is a placeholder, not something to read out either.
    const mark = () =>
      document.querySelector('span[aria-hidden="true"].pointer-events-none') as HTMLElement | null;

    it('draws nothing until it is asked to', async () => {
      await render(<PlImage src={OK} alt="A portrait" />);

      expect(mark()).toBeNull();
    });

    it('takes a bare string as the text, in a corner', async () => {
      await render(<PlImage src={OK} alt="A portrait" watermark="© Ada & Co" />);

      await expect.poll(() => mark()?.textContent).toBe('© Ada & Co');
    });

    it('is off the accessibility tree and takes no pointer', async () => {
      await render(<PlImage src={OK} alt="A portrait" watermark="© Ada & Co" />);

      await expect.poll(() => mark()).not.toBeNull();

      // A watermark is a claim about the file, not something the page is telling
      // a reader. `alt` is where a picture says what it is.
      expect(mark()).toHaveAttribute('aria-hidden', 'true');
      expect(mark()!.className).toContain('pointer-events-none');
    });

    it('waits for the picture before it stamps it', async () => {
      // A stamp over a skeleton is a claim about a file that has not arrived.
      await render(<PlImage alt="A portrait" watermark="© Ada & Co" />);

      expect(mark()).toBeNull();
    });

    it('tiles as one repeating background rather than a wall of elements', async () => {
      await render(
        <PlImage src={OK} alt="A portrait" watermark={{ text: 'PROOF', placement: 'tile' }} />
      );

      await expect.poll(() => mark()).not.toBeNull();

      const layer = mark()!.firstElementChild as HTMLElement;

      expect(layer.style.backgroundRepeat).toBe('repeat');
      expect(layer.style.backgroundImage).toContain('data:image/svg+xml');
      // Turned as one layer: turning each copy inside a straight grid leaves the
      // grid's own lines showing through.
      expect(layer.style.transform).toBe('rotate(-24deg)');
    });

    it('builds a tile the browser can actually decode, punctuation included', async () => {
      await render(
        <PlImage
          src={OK}
          alt="A portrait"
          watermark={{ text: `Ada & Co <2026> "proof"`, placement: 'tile' }}
        />
      );

      await expect.poll(() => mark()).not.toBeNull();

      const layer = mark()!.firstElementChild as HTMLElement;
      const uri = layer.style.backgroundImage.replace(/^url\(["']?/, '').replace(/["']?\)$/, '');

      // An unescaped `&` is a parse error, and a parse error is an empty tile.
      const decoded = await new Promise<boolean>((done) => {
        const probe = new Image();

        probe.onload = () => done(probe.naturalWidth > 0);
        probe.onerror = () => done(false);
        probe.src = uri;
      });

      expect(decoded).toBe(true);
    });

    it('follows the picture into the preview', async () => {
      const screen = await render(
        <PlImage src={OK} alt="A portrait" preview watermark="© Ada & Co" />
      );

      await expect.poll(() => document.querySelector('button')!.disabled).toBe(false);
      await screen.getByRole('button').click();
      await expect.poll(() => document.querySelectorAll('img').length).toBe(2);

      // A mark that comes off when the picture is opened large has marked the
      // copy nobody wanted.
      await expect
        .poll(
          () => document.querySelectorAll('span[aria-hidden="true"].pointer-events-none').length
        )
        .toBe(2);
    });
  });

  describe('protect', () => {
    it('leaves the picture alone until it is asked', async () => {
      await render(<PlImage src={OK} alt="A portrait" />);

      expect(image().getAttribute('draggable')).toBeNull();
      expect(image().className).not.toContain('select-none');
    });

    it('refuses the context menu, the drag and the selection', async () => {
      await render(<PlImage src={OK} alt="A portrait" protect />);

      const menu = new MouseEvent('contextmenu', { bubbles: true, cancelable: true });
      const drag = new Event('dragstart', { bubbles: true, cancelable: true });

      image().dispatchEvent(menu);
      image().dispatchEvent(drag);

      expect(menu.defaultPrevented).toBe(true);
      expect(drag.defaultPrevented).toBe(true);
      expect(image().getAttribute('draggable')).toBe('false');
      expect(image().className).toContain('select-none');
    });

    it('refuses the long-press callout too', async () => {
      await render(<PlImage src={OK} alt="A portrait" protect />);

      // On iOS the long press *is* the context menu. A picture that refuses the
      // right-click on a desktop and offers Save on a phone has refused nothing.
      expect(image().className).toContain('[-webkit-touch-callout:none]');
    });

    it('is not turned off by a handler of the caller’s own', async () => {
      const onContextMenu = vi.fn();

      await render(<PlImage src={OK} alt="A portrait" protect onContextMenu={onContextMenu} />);

      const menu = new MouseEvent('contextmenu', { bubbles: true, cancelable: true });

      image().dispatchEvent(menu);

      expect(menu.defaultPrevented).toBe(true);
    });

    it('follows the picture into the preview', async () => {
      const screen = await render(<PlImage src={OK} alt="A portrait" preview protect />);

      await expect.poll(() => document.querySelector('button')!.disabled).toBe(false);
      await screen.getByRole('button').click();
      await expect.poll(() => document.querySelectorAll('img').length).toBe(2);

      // A refusal that comes off the moment the picture is opened large is no
      // refusal — large is the copy somebody wanted in the first place.
      const opened = [...document.querySelectorAll('img')].at(-1)!;

      expect(opened.getAttribute('draggable')).toBe('false');
      expect(opened.className).toContain('[-webkit-touch-callout:none]');
    });
  });

  describe('a picture that was already decoded', () => {
    /*
     * The case `load` cannot cover. A file that is in the cache, or one a server
     * rendered so the browser started fetching it while parsing the HTML, can
     * finish before React attaches a single handler — and an event nobody was
     * listening for is an event that did not happen.
     *
     * Hydration is where it is reproducible rather than merely likely: the
     * markup is in the document and the picture is decoded off it *before*
     * React runs at all, so the ordering is settled rather than raced.
     */
    /*
     * A picture no run of this file has fetched before.
     *
     * The cache is what makes this case hard to write rather than hard to fix:
     * a file an earlier test already pulled is `complete` the instant the markup
     * is parsed, while its `load` is still a task waiting its turn — so React
     * gets handed the event after all and the test passes for the wrong reason.
     * A URL nothing has seen has to be fetched, which is what makes the event
     * something the test can *watch* rather than guess at.
     */
    let servedCount = 0;
    const hosts: HTMLElement[] = [];

    // Swept up here rather than at the end of each test, so a failing assertion
    // does not leave a stray `<img>` for the next test's `document.querySelector`
    // to find.
    afterEach(() => {
      hosts.splice(0).forEach((host) => host.remove());
    });

    function freshPicture() {
      servedCount += 1;

      const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${servedCount}" height="8"></svg>`;

      return `data:image/svg+xml,${encodeURIComponent(svg)}`;
    }

    /**
     * Puts the server's markup in the document and does not come back until the
     * picture off it has both decoded and spent its `load` event — which is the
     * state a cached or server-rendered file reaches before React runs.
     */
    async function serveAndDecode(src: string, markup: string) {
      const host = document.createElement('div');

      document.body.append(host);
      hosts.push(host);
      host.innerHTML = markup;

      const served = host.querySelector('img')!;

      // The premise of the test: the event fires while nothing is listening for
      // it but this line.
      expect(served.complete).toBe(false);
      await new Promise((done) => served.addEventListener('load', done, { once: true }));
      await new Promise((done) => setTimeout(done, 0));

      expect(served.complete).toBe(true);
      expect(served.naturalWidth).toBeGreaterThan(0);
      expect(served.getAttribute('src')).toBe(src);

      return host;
    }

    it('is loaded when React arrives after the load event', async () => {
      const src = freshPicture();
      const host = await serveAndDecode(
        src,
        renderToString(<PlImage src={src} alt="A portrait" />)
      );

      await React.act(async () => {
        hydrateRoot(host, <PlImage src={src} alt="A portrait" />);
      });

      await expect.poll(() => host.querySelector('img')!.className).toContain('opacity-100');
    });

    it('reports the status it found rather than staying silent', async () => {
      const onStatusChange = vi.fn();
      const src = freshPicture();
      const host = await serveAndDecode(
        src,
        renderToString(<PlImage src={src} alt="A portrait" />)
      );

      await React.act(async () => {
        hydrateRoot(host, <PlImage src={src} alt="A portrait" onStatusChange={onStatusChange} />);
      });

      await expect.poll(() => onStatusChange.mock.calls).toEqual([['loaded']]);
    });

    it('leaves a picture with no src alone', async () => {
      // An `<img>` that was never given a `src` is `complete` too, and it has
      // not failed — it has not been asked for anything.
      await render(<PlImage alt="A portrait" />);

      expect(image().complete).toBe(true);
      expect(image().className).toContain('opacity-0');
      expect(document.querySelector('.plass-skeleton')).toBeInTheDocument();
    });
  });

  describe('caller styling', () => {
    it('hands the img back through a forwarded ref', async () => {
      // The component keeps a ref of its own to ask the element how it got on,
      // so the caller's has to survive being merged with it.
      const seen = vi.fn();

      await render(<PlImage src={OK} alt="A portrait" ref={seen} />);

      expect(seen).toHaveBeenCalledWith(image());
    });

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
