/**
 * That a fill which comes and goes with a state fades, which only the
 * stylesheet can answer.
 *
 * No browser eases a gradient to or from `none`, so a tick, a radio's ring, a
 * switch's track and a chosen day paint theirs on a layer of their own,
 * `.plass-fill`'s `::before`, and a `solid` toggle on `.plass-fill-layer`, an
 * element, and fade its opacity. Written on the element
 * itself, the gradient arrived in one frame and left in one, and a class-list
 * assertion cannot tell the two apart, so this file loads `src/standalone.css`
 * the way `card.test.tsx` does and records the transitions that actually run.
 *
 * No duration is asserted, only that the layer eases between off and on, and
 * that under reduced motion it does not.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlCalendar,
  PlCheckbox,
  PlDatePicker,
  PlRadio,
  PlRadioGroup,
  PlSwitch,
  PlToggle
} from 'plass-ui';
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
 * Every fade the fill layer starts, as the opacities its transition runs
 * between: the element's `::before`, or the element itself when `pseudo` is
 * empty. Read on `transitionrun`, from the transition's own keyframes, so
 * nothing has to sample a frame.
 */
function recordFades(element: Element, pseudo: '::before' | '' = '::before'): Fade[] {
  const fades: Fade[] = [];

  element.addEventListener('transitionrun', (raw) => {
    const event = raw as TransitionEvent;

    if (
      event.target !== element ||
      event.pseudoElement !== pseudo ||
      event.propertyName !== 'opacity'
    ) {
      return;
    }

    const run = element.getAnimations({ subtree: true }).find((one) => {
      const effect = one.effect as KeyframeEffect;

      return (
        one instanceof CSSTransition &&
        one.transitionProperty === 'opacity' &&
        effect.target === element &&
        (effect.pseudoElement ?? '') === pseudo
      );
    });
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

  it('fills a half-set checkbox as a ticked one, live, read-only or disabled', async () => {
    const screen = await render(
      <>
        {(['live', 'read-only', 'disabled'] as const).map((state) => (
          <div key={state}>
            <PlCheckbox
              label={`Half ${state}`}
              indeterminate
              readOnly={state === 'read-only'}
              disabled={state === 'disabled'}
            />
            <PlCheckbox
              label={`Ticked ${state}`}
              defaultChecked
              readOnly={state === 'read-only'}
              disabled={state === 'disabled'}
            />
          </div>
        ))}
      </>
    );

    for (const state of ['live', 'read-only', 'disabled']) {
      const half = screen.getByRole('checkbox', { name: `Half ${state}` }).element();
      const ticked = screen.getByRole('checkbox', { name: `Ticked ${state}` }).element();

      expectLayerOnly(half);
      expect(Number(layerOf(half).opacity), state).toBe(1);
      // The dash takes the ink a tick does on the gradient.
      expect(getComputedStyle(half).color, state).toBe(getComputedStyle(ticked).color);
    }
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

  it('fills the chosen day of a calendar on the page, and fades it as the choice moves', async () => {
    const july15 = new Date(2026, 6, 15);
    const july18 = new Date(2026, 6, 18);
    const screen = await render(
      <PlCalendar locale="en-GB" defaultValue={july15} data-testid="calendar" />
    );
    const before = screen.getByRole('gridcell', { name: fullDate(july15) }).element();
    const after = screen.getByRole('gridcell', { name: fullDate(july18) }).element();
    const sheet = screen.getByTestId('calendar').element();
    const left = recordFades(before);
    const taken = recordFades(after);

    expectLayerOnly(before);
    expect(Number(layerOf(before).opacity)).toBe(1);
    // The fill is the chosen day's alone: the sheet round it stays undyed.
    expect(getComputedStyle(sheet).backgroundImage).toBe('none');

    await screen.getByRole('gridcell', { name: fullDate(july18) }).click();
    await expect
      .element(screen.getByRole('gridcell', { name: fullDate(july18) }))
      .toHaveAttribute('aria-selected', 'true');
    await expect.poll(() => taken).toEqual([{ from: 0, to: 1 }]);
    await expect.poll(() => left).toEqual([{ from: 1, to: 0 }]);
  });

  it('fades a solid toggle’s gradient in under its light and out again', async () => {
    const screen = await render(<PlToggle variant="solid">Bold</PlToggle>);
    const toggle = screen.getByRole('button').element();
    const layer = toggle.querySelector('.plass-fill-layer') as HTMLElement;
    const fades = recordFades(layer, '');

    expect(getComputedStyle(layer).backgroundImage).toContain('linear-gradient');
    expect(Number(getComputedStyle(layer).opacity)).toBe(0);

    await screen.getByRole('button').click();
    await expect.element(screen.getByRole('button')).toHaveAttribute('aria-pressed', 'true');
    await expect.poll(() => fades).toEqual([{ from: 0, to: 1 }]);
    await settle(layer);

    expect(getComputedStyle(toggle).backgroundImage).toBe('none');
    // Under the bloom, which is the toggle's own `::before` and comes first.
    expect(Number(getComputedStyle(layer).zIndex)).toBeLessThan(
      Number(getComputedStyle(toggle, '::before').zIndex)
    );

    await screen.getByRole('button').click();
    await expect.element(screen.getByRole('button')).toHaveAttribute('aria-pressed', 'false');
    await expect
      .poll(() => fades)
      .toEqual([
        { from: 0, to: 1 },
        { from: 1, to: 0 }
      ]);
  });

  it('puts the gradient on at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    const screen = await render(
      <>
        <PlCheckbox label="Remember me" />
        <PlToggle variant="solid">Bold</PlToggle>
      </>
    );
    const tick = screen.getByRole('checkbox').element();
    const layer = screen
      .getByRole('button', { name: 'Bold' })
      .element()
      .querySelector('.plass-fill-layer') as HTMLElement;
    const fades = recordFades(tick);
    const toggled = recordFades(layer, '');

    await screen.getByText('Remember me').click();
    await screen.getByRole('button', { name: 'Bold' }).click();
    await expect.element(screen.getByRole('checkbox')).toBeChecked();
    await expect
      .element(screen.getByRole('button', { name: 'Bold' }))
      .toHaveAttribute('aria-pressed', 'true');

    expectLayerOnly(tick);
    expect(Number(layerOf(tick).opacity)).toBe(1);
    expect(Number(getComputedStyle(layer).opacity)).toBe(1);

    await frames();

    expect(fades).toEqual([]);
    expect(toggled).toEqual([]);
  });
});
