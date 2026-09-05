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
