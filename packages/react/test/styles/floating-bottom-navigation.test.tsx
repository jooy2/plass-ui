/**
 * Where a `PlFloatingBottomNavigation`'s key is drawn and when it travels, which
 * only the stylesheet can answer.
 *
 * The key is measured off the current disc and placed with `left`, `top`,
 * `width` and `height`, eased once its first placement has been drawn. These
 * load `src/standalone.css` the way `segmented-button.test.tsx` does and record
 * the transitions that actually start: none for the first placement or for a
 * capsule that changes size under the key, one for a new destination.
 */
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { commands } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlFloatingBottomNavigation, PlFloatingBottomNavigationItem } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

let sheet: HTMLStyleElement;
let recording: AbortController;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

beforeEach(async () => {
  await commands.parkPointer();
  await emulateMedia({ reducedMotion: 'no-preference' });
  recording = new AbortController();
});

afterEach(() => {
  recording.abort();
});

const glyph = <svg viewBox="0 0 24 24" />;

function Bar(props: React.ComponentProps<typeof PlFloatingBottomNavigation>) {
  return (
    <PlFloatingBottomNavigation label="Main" position="static" {...props}>
      <PlFloatingBottomNavigationItem value="home" icon={glyph}>
        Home
      </PlFloatingBottomNavigationItem>
      <PlFloatingBottomNavigationItem value="search" icon={glyph}>
        Search
      </PlFloatingBottomNavigationItem>
      <PlFloatingBottomNavigationItem value="profile" icon={glyph}>
        Profile
      </PlFloatingBottomNavigationItem>
    </PlFloatingBottomNavigation>
  );
}

/** The key riding in the capsule. */
function keyOf(): HTMLElement {
  return document.querySelector<HTMLElement>('nav > div > span[aria-hidden="true"]') as HTMLElement;
}

/** The disc named `name`. */
function disc(name: string): HTMLElement {
  return [...document.querySelectorAll<HTMLElement>('[data-disc]')].find(
    (one) => one.textContent === name
  ) as HTMLElement;
}

/**
 * Every box property a transition starts on the key from here on, as it
 * starts. Recorded from the page, since the key can be mounted after this.
 */
function recordTravel(): string[] {
  const travel: string[] = [];

  document.addEventListener(
    'transitionrun',
    (raw) => {
      const event = raw as TransitionEvent;

      if (
        event.target === keyOf() &&
        ['left', 'top', 'width', 'height'].includes(event.propertyName)
      ) {
        travel.push(event.propertyName);
      }
    },
    { signal: recording.signal }
  );

  return travel;
}

/** Waits until the key has its duration back on. */
async function ready(): Promise<void> {
  await expect.poll(() => keyOf()?.hasAttribute('data-ready')).toBe(true);
}

/** Two frames, which is where a transition the last change started would run. */
async function frames(): Promise<void> {
  for (let step = 0; step < 2; step += 1) {
    await new Promise((resolve) => requestAnimationFrame(resolve));
  }
}

/** That the key covers the disc named `name`, to within a pixel. */
function expectUnder(name: string): void {
  const key = keyOf().getBoundingClientRect();
  const box = disc(name).getBoundingClientRect();

  for (const side of ['left', 'top', 'width', 'height'] as const) {
    expect(Math.abs(key[side] - box[side]), side).toBeLessThanOrEqual(1);
  }
}

describe('the floating bottom navigation key', () => {
  it('starts under the current disc without travelling there', async () => {
    const travel = recordTravel();

    await render(<Bar defaultValue="search" />);
    await ready();
    await frames();

    expect(travel).toEqual([]);
    expectUnder('Search');
  });

  it('slides to the destination pressed next', async () => {
    const travel = recordTravel();
    const screen = await render(<Bar defaultValue="home" />);

    await ready();
    await screen.getByRole('button', { name: 'Profile' }).click();
    await expect.poll(() => travel).toContain('left');
    await Promise.all(
      keyOf()
        .getAnimations()
        .map((one) => one.finished)
    );

    expectUnder('Profile');
  });

  it('keeps up with a capsule that changes size rather than trailing it', async () => {
    const travel = recordTravel();
    const wider = document.createElement('style');

    await render(<Bar defaultValue="profile" />);
    await ready();

    const before = keyOf().getBoundingClientRect().width;

    // Nothing React renders changes: only the observer on the capsule can
    // tell the key to move.
    wider.textContent = 'nav [data-disc] { width: 4.5rem; }';
    document.head.append(wider);

    try {
      await expect.poll(() => keyOf().getBoundingClientRect().width).toBeGreaterThan(before);
      await ready();
      await frames();

      expect(travel).toEqual([]);
      expectUnder('Profile');
    } finally {
      wider.remove();
    }
  });
});
