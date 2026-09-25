/**
 * That a fill which comes and goes with a state fades, which only the
 * stylesheet can answer.
 *
 * No browser eases a gradient to or from `none`, so a tick, a radio's ring, a
 * switch's track and a chosen day paint theirs on a layer of their own,
 * `.plass-fill`'s `::before`, and fade its opacity. Written on the element
 * itself, the gradient arrived in one frame and left in one, and a class-list
 * assertion cannot tell the two apart, so this file loads `src/standalone.css`
 * the way `card.test.tsx` does and records the transitions that actually run.
 *
 * No duration is asserted, only that the layer eases between off and on, and
 * that under reduced motion it does not.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCheckbox, PlDatePicker, PlRadio, PlRadioGroup, PlSwitch } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { fullDate } from '../support/dates';
import { emulateMedia } from '../support/media';

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
  await emulateMedia({ reducedMotion: 'no-preference' });
});

interface Fade {
  from: number;
  to: number;
}

/**
 * Every fade the element's fill layer starts, as the opacities its transition
 * runs between. Read on `transitionrun`, from the transition's own keyframes,
 * so nothing has to sample a frame.
 */
function recordFades(element: Element): Fade[] {
  const fades: Fade[] = [];

  element.addEventListener('transitionrun', (raw) => {
    const event = raw as TransitionEvent;

    if (event.pseudoElement !== '::before' || event.propertyName !== 'opacity') {
      return;
    }

    const run = element
      .getAnimations({ subtree: true })
      .find(
        (one) =>
          one instanceof CSSTransition &&
          one.transitionProperty === 'opacity' &&
          (one.effect as KeyframeEffect).pseudoElement === '::before'
      );
    const frames = (run?.effect as KeyframeEffect | undefined)?.getKeyframes() ?? [];

    fades.push({ from: Number(frames[0]?.opacity), to: Number(frames.at(-1)?.opacity) });
  });

  return fades;
}

/** The fill layer as the browser resolved it. */
function layerOf(element: Element): CSSStyleDeclaration {
  return getComputedStyle(element, '::before');
}

/** That the element paints no gradient of its own, which would arrive at once. */
function expectLayerOnly(element: Element): void {
  expect(layerOf(element).content).toBe('""');
  expect(layerOf(element).backgroundImage).toContain('linear-gradient');
  expect(getComputedStyle(element).backgroundImage).toBe('none');
}

/** Two frames, which is where a transition the last change started would run. */
async function frames(): Promise<void> {
  for (let step = 0; step < 2; step += 1) {
    await new Promise((resolve) => requestAnimationFrame(resolve));
  }
}

/** Waits out whatever the last change set easing, so a value is read settled. */
async function settle(element: Element): Promise<void> {
  await Promise.all(element.getAnimations({ subtree: true }).map((one) => one.finished));
}

describe('a fill that comes and goes with a state', () => {
  it('fades a checkbox’s gradient in and out', async () => {
    const screen = await render(<PlCheckbox label="Remember me" />);
    const tick = screen.getByRole('checkbox').element();
    const fades = recordFades(tick);

    expectLayerOnly(tick);
    expect(Number(layerOf(tick).opacity)).toBe(0);

    await screen.getByText('Remember me').click();
    await expect.element(screen.getByRole('checkbox')).toBeChecked();
    await expect.poll(() => fades).toEqual([{ from: 0, to: 1 }]);
    await settle(tick);

    expectLayerOnly(tick);
    expect(Number(layerOf(tick).opacity)).toBe(1);

    await screen.getByText('Remember me').click();
    await expect.element(screen.getByRole('checkbox')).not.toBeChecked();
    await expect
      .poll(() => fades)
      .toEqual([
        { from: 0, to: 1 },
        { from: 1, to: 0 }
      ]);
  });

  it('fades a half-set checkbox’s gradient in as well', async () => {
    const screen = await render(<PlCheckbox label="Everything" indeterminate />);
    const tick = screen.getByRole('checkbox').element();

    expectLayerOnly(tick);
    expect(Number(layerOf(tick).opacity)).toBe(1);
  });

  it('fades a radio’s gradient from the option it leaves to the one it takes', async () => {
    const screen = await render(
      <PlRadioGroup label="Plan" defaultValue="free">
        <PlRadio value="free" label="Free" />
        <PlRadio value="pro" label="Pro" />
      </PlRadioGroup>
    );
    const [free, pro] = screen.getByRole('radio').elements();
    const left = recordFades(free);
    const taken = recordFades(pro);

    expectLayerOnly(free);
    expect(Number(layerOf(free).opacity)).toBe(1);
    expect(Number(layerOf(pro).opacity)).toBe(0);

    await screen.getByText('Pro').click();
    await expect.element(screen.getByRole('radio', { name: 'Pro' })).toBeChecked();
    await expect.poll(() => taken).toEqual([{ from: 0, to: 1 }]);
    await expect.poll(() => left).toEqual([{ from: 1, to: 0 }]);
  });

  it('fades a switch’s gradient in under its thumb', async () => {
    const screen = await render(<PlSwitch label="Wi-Fi" />);
    const track = screen.getByRole('switch').element();
    const fades = recordFades(track);

    expectLayerOnly(track);

    await screen.getByText('Wi-Fi').click();
    await expect.element(screen.getByRole('switch')).toBeChecked();
    await expect.poll(() => fades).toEqual([{ from: 0, to: 1 }]);

    // Under the thumb, which is positioned after it in the same box.
    expect(layerOf(track).zIndex).toBe('-1');
    expect(getComputedStyle(track).isolation).toBe('isolate');
  });

  it('fades a chosen day in as the choice moves to it', async () => {
    const july15 = new Date(2026, 6, 15);
    const july18 = new Date(2026, 6, 18);
    const screen = await render(
      <PlDatePicker locale="en-GB" defaultValue={july15} defaultOpen closeOnSelect={false} />
    );

    await expect
      .element(screen.getByRole('gridcell', { name: fullDate(july18) }))
      .toBeInTheDocument();

    const before = screen.getByRole('gridcell', { name: fullDate(july15) }).element();
    const after = screen.getByRole('gridcell', { name: fullDate(july18) }).element();
    const left = recordFades(before);
    const taken = recordFades(after);

    expectLayerOnly(before);
    expect(Number(layerOf(before).opacity)).toBe(1);

    await screen.getByRole('gridcell', { name: fullDate(july18) }).click();
    await expect
      .element(screen.getByRole('gridcell', { name: fullDate(july18) }))
      .toHaveAttribute('aria-selected', 'true');
    await expect.poll(() => taken).toEqual([{ from: 0, to: 1 }]);
    await expect.poll(() => left).toEqual([{ from: 1, to: 0 }]);
  });

  it('puts the gradient on at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    const screen = await render(<PlCheckbox label="Remember me" />);
    const tick = screen.getByRole('checkbox').element();
    const fades = recordFades(tick);

    await screen.getByText('Remember me').click();
    await expect.element(screen.getByRole('checkbox')).toBeChecked();

    expectLayerOnly(tick);
    expect(Number(layerOf(tick).opacity)).toBe(1);

    await frames();

    expect(fades).toEqual([]);
  });
});
