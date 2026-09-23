import { describe, expect, it, vi } from 'vitest';
import * as React from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { PlMockup } from 'plass-ui';
import { render } from 'vitest-browser-react';

/** The glass, which is what everything else is measured against. */
function glass(container: Element): HTMLElement {
  return container.querySelector('.plass-mockup-screen') as HTMLElement;
}

describe('PlMockup', () => {
  describe('the screen', () => {
    it('lays the screen out at the device own resolution', async () => {
      const screen = await render(<PlMockup device="mobile" width={200} />);

      await expect.poll(() => glass(screen.container)).not.toBeNull();

      // An `md` phone is 390 by 844, whatever the mockup measures on the page.
      const box = glass(screen.container);

      expect(box.style.width).toBe('390px');
      expect(box.style.height).toBe('844px');
    });

    it('climbs a ladder of real machines rather than of control heights', async () => {
      const screen = await render(<PlMockup device="mobile" size="xs" width={200} />);

      await expect.poll(() => glass(screen.container)).not.toBeNull();
      expect(glass(screen.container).style.width).toBe('320px');

      await screen.rerender(<PlMockup device="mobile" size="xl" width={200} />);

      await expect.poll(() => glass(screen.container).style.width).toBe('430px');
    });

    it('takes a resolution of its own over the ladder', async () => {
      const screen = await render(
        <PlMockup device="desktop" resolution={{ width: 1200, height: 700 }} width={300} />
      );

      await expect.poll(() => glass(screen.container)).not.toBeNull();
      expect(glass(screen.container).style.width).toBe('1200px');
    });

    it('turns the screen with the device', async () => {
      const screen = await render(<PlMockup device="mobile" orientation="landscape" width={300} />);

      await expect.poll(() => glass(screen.container)).not.toBeNull();

      const box = glass(screen.container);

      expect(box.style.width).toBe('844px');
      expect(box.style.height).toBe('390px');
    });

    it('leaves a desktop where it is, because its stand does not turn', async () => {
      const screen = await render(
        <PlMockup device="desktop" orientation="landscape" width={300} />
      );

      await expect.poll(() => glass(screen.container)).not.toBeNull();
      expect(glass(screen.container).style.width).toBe('1440px');
    });

    it('puts the content on the screen', async () => {
      const screen = await render(
        <PlMockup device="mobile" width={200}>
          <p>Hello from the phone</p>
        </PlMockup>
      );

      await expect.element(screen.getByText('Hello from the phone')).toBeInTheDocument();
    });
  });

  describe('the system', () => {
    it('draws the clock the caller gave it', async () => {
      const screen = await render(<PlMockup device="mobile" time="11:11" width={200} />);

      await expect.element(screen.getByText('11:11')).toBeInTheDocument();
    });

    it('draws no bars at all when systemUi is off', async () => {
      const screen = await render(
        <PlMockup device="mobile" systemUi={false} time="11:11" width={200} />
      );

      await expect.poll(() => glass(screen.container)).not.toBeNull();
      expect(screen.getByText('11:11').query()).toBeNull();
    });

    it('falls back to a system the device actually runs', async () => {
      // `windows` is not a phone system, so an iOS status bar is drawn instead.
      const screen = await render(
        <PlMockup device="mobile" os="windows" time="11:11" width={200} />
      );

      await expect.element(screen.getByText('11:11')).toBeInTheDocument();

      const bar = screen.getByText('11:11').element().parentElement as HTMLElement;

      // iOS puts the clock on the leading end of a bar that also carries the
      // status glyphs; Windows has no top bar at all.
      expect(bar.querySelectorAll('svg').length).toBe(3);
    });

    it('reads ios on a tablet as the Apple one rather than starting over', async () => {
      const screen = await render(<PlMockup device="tablet" os="ios" width={300} />);

      await expect.poll(() => glass(screen.container)).not.toBeNull();
      // iPadOS, so the home indicator is the wide one.
      expect(glass(screen.container).style.width).toBe('820px');
    });
  });

  describe('the hardware', () => {
    it('cuts a hole in the glass on a phone', async () => {
      const screen = await render(<PlMockup device="mobile" width={200} />);

      await expect
        .poll(() => screen.container.querySelector('.plass-mockup-cutout'))
        .not.toBeNull();
    });

    it('cuts none on a desktop', async () => {
      const screen = await render(<PlMockup device="desktop" width={300} />);

      await expect.poll(() => glass(screen.container)).not.toBeNull();
      expect(screen.container.querySelector('.plass-mockup-cutout')).toBeNull();
    });

    it('takes the cut-out the caller asked for', async () => {
      const screen = await render(<PlMockup device="desktop" notch="punch-hole" width={300} />);

      await expect
        .poll(() => screen.container.querySelector('.plass-mockup-cutout'))
        .not.toBeNull();
    });

    it('leaves the screen on its own with no bezel', async () => {
      const screen = await render(<PlMockup device="mobile" bezel="none" width={200} />);

      await expect.poll(() => glass(screen.container)).not.toBeNull();

      // No hardware means the frame is the screen, so nothing is inset.
      const shell = glass(screen.container).parentElement as HTMLElement;

      expect(shell.style.paddingInline).toBe('0px');
    });
  });

  describe('rendering', () => {
    it('renders something else on request', async () => {
      const screen = await render(<PlMockup device="mobile" render={<figure />} width={200} />);

      await expect.poll(() => screen.container.querySelector('figure')).not.toBeNull();
    });

    it('keeps the device proportion so a row of them lines up', async () => {
      const screen = await render(<PlMockup device="mobile" width={200} />);

      await expect.poll(() => screen.container.querySelector('.plass-mockup')).not.toBeNull();

      const host = screen.container.querySelector('.plass-mockup') as HTMLElement;

      // 390 + 13 either side, over 844 + 13 top and bottom.
      expect(host.style.aspectRatio).toBe('416 / 870');
    });
  });

  // A `md` phone is 416 by 870 with its bezel, so every size here is half of it.
  describe('on the server', () => {
    it('draws a device whose width is a number at its scale, rather than hiding it', () => {
      const html = renderToString(<PlMockup device="mobile" width={208} />);

      expect(html).not.toContain('visibility:hidden');
      expect(html).toContain('transform:scale(0.5)');
    });

    it('takes the scale from a height that is a number on its own', () => {
      const html = renderToString(<PlMockup device="mobile" height={435} />);

      expect(html).not.toContain('visibility:hidden');
      expect(html).toContain('transform:scale(0.5)');
    });

    it('takes the smaller of the two when both are numbers', () => {
      const html = renderToString(<PlMockup device="mobile" width={416} height={435} />);

      expect(html).toContain('transform:scale(0.5)');
    });

    it('still waits for a measurement when the size is a CSS length', () => {
      expect(renderToString(<PlMockup device="mobile" />)).toContain('visibility:hidden');
      expect(renderToString(<PlMockup device="mobile" width="50%" />)).toContain(
        'visibility:hidden'
      );
      expect(renderToString(<PlMockup device="mobile" width={208} height="50vh" />)).toContain(
        'visibility:hidden'
      );
    });

    it('hydrates the scale it drew without a mismatch', async () => {
      const element = <PlMockup device="mobile" width={208} className="mockup-under-test" />;
      const host = document.createElement('div');
      const onRecoverableError = vi.fn();

      host.innerHTML = renderToString(element);
      document.body.append(host);

      let root: ReturnType<typeof hydrateRoot> | undefined;

      try {
        await React.act(async () => {
          root = hydrateRoot(host, element, { onRecoverableError });
        });

        const inner = host.querySelector('.mockup-under-test > div') as HTMLElement;

        expect(onRecoverableError).not.toHaveBeenCalled();
        expect(inner.style.visibility).toBe('');
        await expect
          .poll(() => (inner.firstElementChild as HTMLElement).style.transform)
          .toBe('scale(0.5)');
      } finally {
        await React.act(async () => root?.unmount());
        host.remove();
      }
    });
  });
});
