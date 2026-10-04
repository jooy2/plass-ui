/**
 * What the glass is for a reader who has asked for less transparency, which
 * only the stylesheet decides.
 *
 * For that reader every sheet is opaque and unblurred, in the colours of the
 * theme it is in, and keeps its edge, its shadow and its focus ring. Nothing
 * here is visible without the real CSS, so `src/standalone.css` is loaded the
 * way `toast.test.tsx` loads it. What is asserted is the mechanism — whether
 * there is a blur, whether the fill lets anything through, which side of its
 * own ink a sheet is on — and never a shade.
 *
 * Only Chromium can be put in the mode (`emulateReducedTransparency`), and it is
 * the only engine that reads it, so the tests of the mode run there. The test
 * of what everybody else sees runs everywhere.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { server, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlButton, PlCard, PlOverlay, PlPopover, PlWindowPane } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia, emulateReducedTransparency } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

afterEach(async () => {
  if (server.browser === 'chromium') {
    // Back to an explicit no-preference rather than to `null`: `null` hands
    // the answer to the runner's own system, which is `reduce` on CI's macOS.
    await emulateReducedTransparency('no-preference');
  }

  await emulateMedia({ colorScheme: 'light' });
});

/** The alpha of a computed colour, in any of the forms an engine writes one. */
function alpha(value: string): number {
  const slash = value.match(/\/\s*([\d.]+)(%?)\s*\)$/);

  if (slash) {
    return Number(slash[1]) / (slash[2] ? 100 : 1);
  }

  const rgba = value.match(/^rgba\((?:[^,]+,){3}\s*([\d.]+)\)$/);

  return rgba ? Number(rgba[1]) : value === 'transparent' ? 0 : 1;
}

/** The relative luminance of an opaque `rgb()` or `color(srgb …)` colour. */
function luminance(value: string): number {
  const numbers = (value.match(/[\d.]+/g) ?? []).map(Number);
  const channels = value.startsWith('color(')
    ? numbers.slice(0, 3)
    : numbers.slice(0, 3).map((channel) => channel / 255);
  const [r, g, b] = channels.map((channel) =>
    channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055) ** 2.4
  );

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/**
 * The computed style, with every transition under way landed first: a fill
 * that eases is otherwise read halfway between the two answers, and nothing
 * here is about the easing. `getAnimations` brings the style up to date before
 * it answers, so a change the mode has only just made is among them.
 */
function style(element: Element): CSSStyleDeclaration {
  for (const animation of document.getAnimations()) {
    if (animation instanceof CSSTransition) {
      animation.finish();
    }
  }

  return getComputedStyle(element);
}

/** A sheet, a glass key and a popup: the three ways a surface is glass. */
async function glassSurfaces(): Promise<HTMLElement[]> {
  const screen = await render(
    <div>
      <PlCard className="card-under-test">Card</PlCard>
      <PlButton variant="glass">Go</PlButton>
      <PlPopover open trigger={<PlButton>Help</PlButton>} title="Rates">
        Body
      </PlPopover>
    </div>
  );

  await expect.element(screen.getByText('Rates')).toBeInTheDocument();

  return [
    document.querySelector<HTMLElement>('.card-under-test')!,
    screen.getByRole('button', { name: 'Go' }).element() as HTMLElement,
    document.querySelector<HTMLElement>('[role="dialog"]')!
  ];
}

const emulated = it.runIf(server.browser === 'chromium');

describe('glass for everybody else', () => {
  it('is blurred and lets the page through', async () => {
    for (const surface of await glassSurfaces()) {
      expect(style(surface).backdropFilter).not.toBe('none');
      expect(alpha(style(surface).backgroundColor)).toBeLessThan(1);
    }
  });

  it('takes the glass tone of an overlay through a blur', async () => {
    await render(
      <PlOverlay open tone="glass" classNames={{ backdrop: 'backdrop-under-test' }}>
        Saving
      </PlOverlay>
    );

    const backdrop = document.querySelector<HTMLElement>('.backdrop-under-test')!;

    expect(style(backdrop).backdropFilter).not.toBe('none');
    expect(alpha(style(backdrop).backgroundColor)).toBeLessThan(1);
    expect(style(backdrop).backgroundImage).toBe('none');
  });
});

describe('glass for a reader who has asked for less transparency', () => {
  emulated('is opaque and has no blur', async () => {
    const surfaces = await glassSurfaces();

    await emulateReducedTransparency('reduce');

    for (const surface of surfaces) {
      expect(style(surface).backdropFilter).toBe('none');
      expect(alpha(style(surface).backgroundColor)).toBe(1);
    }
  });

  emulated('stays opaque when the pointer engages a key', async () => {
    const screen = await render(<PlButton variant="glass">Go</PlButton>);
    const button = screen.getByRole('button').element() as HTMLElement;

    await emulateReducedTransparency('reduce');
    await screen.getByRole('button').hover();

    expect(alpha(style(button).backgroundColor)).toBe(1);
  });

  emulated('keeps its edge, its shadow and its focus ring', async () => {
    const screen = await render(<PlButton variant="glass">Go</PlButton>);
    const button = screen.getByRole('button').element() as HTMLElement;

    await userEvent.tab();
    await expect.poll(() => document.activeElement).toBe(button);

    const read = () => ({
      edge: style(button).borderTopColor,
      edgeWidth: style(button).borderTopWidth,
      shadow: style(button).boxShadow,
      ring: style(button).outline
    });
    const before = read();

    await emulateReducedTransparency('reduce');

    expect(read()).toEqual(before);
    expect(before.shadow).not.toBe('none');
    expect(before.ring).not.toMatch(/none/);
  });

  describe('in the theme it is in', () => {
    /** Whether the card's fill is opaque, unblurred and the right side of its ink. */
    const sitsIn = (theme: 'light' | 'dark') => {
      const card = document.querySelector<HTMLElement>('.card-under-test')!;
      const fill = style(card).backgroundColor;
      const ink = style(card).color;

      expect(style(card).backdropFilter).toBe('none');
      expect(alpha(fill)).toBe(1);

      if (theme === 'dark') {
        expect(luminance(fill)).toBeLessThan(luminance(ink));
      } else {
        expect(luminance(fill)).toBeGreaterThan(luminance(ink));
      }
    };

    emulated('is dark under a dark class', async () => {
      await render(
        <div className="dark">
          <PlCard className="card-under-test">Card</PlCard>
        </div>
      );
      await emulateReducedTransparency('reduce');

      sitsIn('dark');
    });

    emulated('is dark under a dark theme attribute', async () => {
      await render(
        <div data-theme="dark">
          <PlCard className="card-under-test">Card</PlCard>
        </div>
      );
      await emulateReducedTransparency('reduce');

      sitsIn('dark');
    });

    emulated('is dark on a system set to dark', async () => {
      await render(<PlCard className="card-under-test">Card</PlCard>);
      await emulateReducedTransparency('reduce');
      await emulateMedia({ colorScheme: 'dark' });

      // Playwright's colour scheme and this override are set through two
      // sessions; the second call must not have taken the first one away.
      expect(window.matchMedia('(prefers-reduced-transparency: reduce)').matches).toBe(true);
      sitsIn('dark');
    });

    emulated('is light under a light theme inside a dark one', async () => {
      await render(
        <div className="dark">
          <div data-theme="light">
            <PlCard className="card-under-test">Card</PlCard>
          </div>
        </div>
      );
      await emulateReducedTransparency('reduce');

      sitsIn('light');
    });
  });

  emulated('turns the glass tone of an overlay into an opaque sheet', async () => {
    await render(
      <PlOverlay open tone="glass" classNames={{ backdrop: 'backdrop-under-test' }}>
        Saving
      </PlOverlay>
    );
    await emulateReducedTransparency('reduce');

    const backdrop = document.querySelector<HTMLElement>('.backdrop-under-test')!;

    expect(style(backdrop).backdropFilter).toBe('none');
    expect(alpha(style(backdrop).backgroundColor)).toBe(1);
    // The overlay's own dim is still laid over that sheet.
    expect(style(backdrop).backgroundImage).toMatch(/^linear-gradient/);
  });

  describe('on a window', () => {
    /** The element whose inline fill reads the given slot. */
    const paintedWith = (root: Element, slot: string) =>
      [...root.querySelectorAll<HTMLElement>('*')].find(
        (element) => element.style.backgroundColor === `var(${slot})`
      )!;

    emulated('takes no notice of the transparency it was given', async () => {
      await render(
        <PlWindowPane os="macos" title="Notes" transparency={0.5}>
          <p>Body</p>
        </PlWindowPane>
      );

      const root = document.querySelector<HTMLElement>('.plass-window')!;
      const bar = paintedWith(root, '--p-window-bar');
      const body = paintedWith(root, '--p-window-body');

      expect(alpha(style(bar).backgroundColor)).toBeLessThan(1);
      expect(alpha(style(body).backgroundColor)).toBeLessThan(1);

      await emulateReducedTransparency('reduce');

      expect(style(root).backdropFilter).toBe('none');
      expect(alpha(style(bar).backgroundColor)).toBe(1);
      expect(alpha(style(body).backgroundColor)).toBe(1);
    });

    emulated('lays the glass of a chrome made of it over the surface', async () => {
      await render(
        <PlWindowPane os="windows7" title="Notes">
          <p>Body</p>
        </PlWindowPane>
      );

      const root = document.querySelector<HTMLElement>('.plass-window')!;

      expect(style(root).backdropFilter).not.toBe('none');
      expect(style(root).backgroundImage).toBe('none');

      await emulateReducedTransparency('reduce');

      expect(style(root).backdropFilter).toBe('none');

      // Two layers over the band colour, and the one at the bottom lets
      // nothing through.
      const image = style(root).backgroundImage;
      const bottom = image.slice(image.lastIndexOf('linear-gradient('));

      expect(image.match(/linear-gradient\(/g)).toHaveLength(2);
      expect(alpha(bottom.match(/^linear-gradient\(((?:rgba?|color)\([^)]*\))/)![1])).toBe(1);
    });
  });
});
