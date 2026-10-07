/**
 * What the four components with a part behind `import()` do when that part's
 * chunk cannot be fetched: a dropped connection, or a deploy that replaced the
 * chunk under a page that was already open.
 *
 * The network is made to fail rather than the loader replaced, through the
 * `failRequests` command: what is under test is the real `import()` each
 * component makes and what it does when that rejects. Each part has one test
 * of its own here and is never asked for by another, because Chromium remembers
 * a module whose fetch failed for the rest of the page's life, so a part that
 * fails once there fails every time after. That is also why a chunk that fails
 * once and then arrives cannot be staged through the network: the retry itself
 * is `lazyPart`'s, and `test/internal/lazy.test.tsx` covers it in every engine
 * with a loader that fails as often as it is told to.
 *
 * The components are imported from their own modules rather than from
 * `plass-ui`, which is the one exception to the suite's rule and the reason for
 * it: the package's entry exports `PlModal` and `PlDrawer` themselves, so
 * loading it would load both chunks before any test could fail them.
 */
import * as React from 'react';
import { describe, expect, it, vi } from 'vitest';
import { commands } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlButton } from '../../src/components/button/PlButton';
import { PlConfirmProvider, usePlConfirm } from '../../src/components/confirm/PlConfirmProvider';
import { PlGallery } from '../../src/components/gallery/PlGallery';
import { PlHeader } from '../../src/components/header/PlHeader';
import { PlImage } from '../../src/components/image/PlImage';
import { PlPageLayout } from '../../src/components/page-layout/PlPageLayout';
import { PlSidebar } from '../../src/components/sidebar/PlSidebar';
import { PlSidebarTrigger } from '../../src/components/sidebar/PlSidebarTrigger';

const OK =
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

/** What reaches a boundary, if anything does. */
class Boundary extends React.Component<
  { onError: (error: unknown) => void; children: React.ReactNode },
  { failed: boolean }
> {
  state = { failed: false };

  static getDerivedStateFromError() {
    return { failed: true };
  }

  componentDidCatch(error: unknown) {
    this.props.onError(error);
  }

  render() {
    return this.state.failed ? <p>Boundary</p> : this.props.children;
  }
}

/** Runs `test` with every request for `module` failing, and lets them through after. */
async function offline(module: string, test: () => Promise<void>): Promise<void> {
  const pattern = `**/${module}.tsx*`;

  await commands.failRequests(pattern);

  try {
    await test();
  } finally {
    await commands.allowRequests(pattern);
  }
}

/**
 * Long enough for both tries to have failed, and for a failure nobody caught to
 * have reached the boundary: React keeps a boundary's fallback on screen for at
 * least 300 ms, which holds such a failure back by as much.
 */
const settle = () => new Promise((done) => setTimeout(done, 1000));

describe('a part whose chunk cannot be fetched', () => {
  it('answers a question as Escape would, and the next one too', async () => {
    await offline('components/modal/PlModal', async () => {
      const answers: unknown[] = [];
      const onError = vi.fn();

      function Asker() {
        const { confirm, alert } = usePlConfirm();

        return (
          <>
            <PlButton onClick={async () => answers.push(await confirm({ title: 'Delete?' }))}>
              Delete
            </PlButton>
            <PlButton onClick={async () => answers.push(await alert({ title: 'Saved.' }))}>
              Tell me
            </PlButton>
          </>
        );
      }

      const screen = await render(
        <Boundary onError={onError}>
          <PlConfirmProvider>
            <Asker />
          </PlConfirmProvider>
        </Boundary>
      );

      await screen.getByRole('button', { name: 'Delete' }).click();
      await expect.poll(() => answers).toEqual([false]);

      // The next question is the next try, and is answered the same way.
      await screen.getByRole('button', { name: 'Tell me' }).click();
      await expect.poll(() => answers).toEqual([false, undefined]);

      expect(onError).not.toHaveBeenCalled();
      expect(document.querySelector('[role="alertdialog"]')).toBeNull();
      await expect.element(screen.getByRole('button', { name: 'Delete' })).toBeEnabled();
    });
  });

  it('leaves a collapsed sidebar closed and its column in place', async () => {
    await offline('components/drawer/PlDrawer', async () => {
      const onError = vi.fn();
      const onSidebarOpenChange = vi.fn();

      // The browser the suite runs in is narrower than `md`, so the sidebar
      // has collapsed and asks for its drawer straight away.
      const screen = await render(
        <Boundary onError={onError}>
          <PlPageLayout
            onSidebarOpenChange={onSidebarOpenChange}
            header={<PlHeader brand={<PlSidebarTrigger data-testid="trigger" />} />}
            sidebar={
              <PlSidebar keepMounted>
                <a href="/docs">Docs</a>
              </PlSidebar>
            }
          >
            Body
          </PlPageLayout>
        </Boundary>
      );

      await settle();
      (screen.getByTestId('trigger').element() as HTMLElement).click();

      // Opened, then closed again once the second try has failed, with nothing
      // drawn in between.
      await expect.poll(() => onSidebarOpenChange.mock.calls).toEqual([[true], [false]]);
      await expect
        .poll(() => screen.getByTestId('trigger').element().getAttribute('aria-expanded'))
        .toBe('false');
      expect(document.querySelector('[role="dialog"]')).toBeNull();
      expect(onError).not.toHaveBeenCalled();
      // The column the server sent is still there, and so is the link in it.
      expect(document.querySelector('aside a[href="/docs"]')).not.toBeNull();
    });
  });

  it('opens no preview of a picture, and leaves the picture to be pressed again', async () => {
    await offline('components/image/PlImagePreview', async () => {
      const onError = vi.fn();
      const screen = await render(
        <Boundary onError={onError}>
          <PlImage src={OK} alt="A portrait" preview />
        </Boundary>
      );
      const opener = screen.getByRole('button', { name: 'A portrait — preview' });

      await expect.element(opener).toBeEnabled();
      await opener.click();
      await settle();

      expect(document.querySelector('[role="dialog"]')).toBeNull();
      expect(onError).not.toHaveBeenCalled();
      await expect.element(opener).toBeEnabled();

      await opener.click();
      await settle();

      expect(document.querySelector('[role="dialog"]')).toBeNull();
      expect(onError).not.toHaveBeenCalled();
    });
  });

  it('opens no viewer from a gallery, and leaves its tiles to be pressed again', async () => {
    await offline('components/gallery/PlGalleryViewer', async () => {
      const onError = vi.fn();
      const onItemSelect = vi.fn();
      const screen = await render(
        <Boundary onError={onError}>
          <PlGallery
            items={[
              { src: OK, alt: 'A harbour' },
              { src: OK, alt: 'A bridge' }
            ]}
            preview
            onItemSelect={onItemSelect}
          />
        </Boundary>
      );
      const tile = screen.getByRole('button', { name: /A bridge/ });

      await expect.element(tile).toBeInTheDocument();
      (tile.element() as HTMLElement).click();
      await settle();

      expect(onItemSelect).toHaveBeenCalledTimes(1);
      expect(document.querySelector('[role="dialog"]')).toBeNull();
      expect(onError).not.toHaveBeenCalled();

      (tile.element() as HTMLElement).click();
      await settle();

      expect(onItemSelect).toHaveBeenCalledTimes(2);
      expect(document.querySelector('[role="dialog"]')).toBeNull();
      expect(onError).not.toHaveBeenCalled();
    });
  });
});
