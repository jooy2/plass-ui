/**
 * The two overlays that are downloads of their own, and when they are asked for.
 *
 * `PlImage`'s preview and `PlGallery`'s viewer each sit behind `React.lazy`, so
 * a page that offers one pays for it only once a reader reaches for it: the
 * chunk is requested as the pointer or the focus arrives on the opener, and not
 * by a page that merely draws one.
 *
 * What is read is the request itself, from the browser's resource timing. Every
 * test file runs in a page of its own with modules nothing has loaded yet, and
 * each chunk is asked for once in this file, so the first request it sees is
 * the one the test caused.
 */
import { describe, expect, it } from 'vitest';
import { commands } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlGallery, PlImage } from 'plass-ui';

const OK =
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

/*
 * An observer rather than `getEntriesByType`, whose buffer holds 250 entries
 * and is full long before a test runs: the dev server serves every module of
 * the package as a request of its own.
 */
const requested: string[] = [];

new PerformanceObserver((list) => {
  list.getEntries().forEach((entry) => requested.push(entry.name));
}).observe({ type: 'resource' });

const fetched = (module: string) => requested.some((name) => name.includes(`/${module}.`));

/**
 * Long enough for a chunk asked for on the first render to have arrived, which
 * is what the component did before it waited for a reader.
 */
const settle = () => new Promise((done) => setTimeout(done, 500));

describe('the overlay chunks', () => {
  it('fetches a picture’s preview once the pointer arrives on it', async () => {
    await commands.parkPointer();

    const screen = await render(<PlImage src={OK} alt="A portrait" preview />);
    const opener = screen.getByRole('button', { name: 'A portrait — preview' });

    await expect.element(opener).toBeEnabled();
    await settle();
    expect(fetched('PlImagePreview')).toBe(false);

    await opener.hover();

    await expect.poll(() => fetched('PlImagePreview')).toBe(true);
    // Fetched, and still not opened.
    expect(screen.getByRole('dialog').query()).toBeNull();
  });

  it('fetches a gallery’s viewer once the focus arrives on a tile', async () => {
    const screen = await render(
      <PlGallery
        items={[
          { src: OK, alt: 'A harbour' },
          { src: OK, alt: 'A bridge' }
        ]}
        preview
      />
    );
    const tile = screen.getByRole('button', { name: /A bridge/ });

    await expect.element(tile).toBeInTheDocument();
    await settle();
    expect(fetched('PlGalleryViewer')).toBe(false);

    (tile.element() as HTMLElement).focus();

    await expect.poll(() => fetched('PlGalleryViewer')).toBe(true);
    expect(screen.getByRole('dialog').query()).toBeNull();
  });
});
