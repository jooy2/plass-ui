/**
 * That a fill which comes and goes with a state fades, which only the
 * stylesheet can answer.
 *
 * No browser eases a gradient to or from `none`, so a tick, a radio's ring, a
 * switch's track, a chosen day and a step's bullet paint theirs on a layer of
 * their own, `.plass-fill`'s `::before`, and a `solid` toggle and a current page
 * on `.plass-fill-layer`, an element, and fade its opacity. Written on the
 * element itself, the gradient arrived in one frame and left in one, and a
 * class-list assertion cannot tell the two apart, so this file loads
 * `src/standalone.css` the way `card.test.tsx` does and records the transitions
 * that actually run.
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
  PlHowToStep,
  PlHowToSteps,
  PlPagination,
  PlRadio,
  PlRadioGroup,
  PlSegment,
  PlSegmentedButton,
  PlStep,
  PlStepper,
  PlSwitch,
  PlTimeline,
  PlTimelineItem,
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
 *
 * `matches` records the fades of an element inside this one instead, for a layer
 * that is not there yet when the recording starts. The event bubbles to it.
 */
function recordFades(
  element: Element,
  pseudo: '::before' | '' = '::before',
  matches: (target: Element) => boolean = (target) => target === element
): Fade[] {
  const fades: Fade[] = [];

  element.addEventListener('transitionrun', (raw) => {
    const event = raw as TransitionEvent;
    const target = event.target as Element;

    if (!matches(target) || event.pseudoElement !== pseudo || event.propertyName !== 'opacity') {
      return;
    }

    const run = target.getAnimations({ subtree: true }).find((one) => {
      const effect = one.effect as KeyframeEffect;

      return (
        one instanceof CSSTransition &&
        one.transitionProperty === 'opacity' &&
        effect.target === target &&
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
      // The dash takes the ink a tick does on the gradient, and the neutral
      // edge goes clear over it as a tick's does.
      expect(getComputedStyle(half).color, state).toBe(getComputedStyle(ticked).color);
      expect(getComputedStyle(half).borderTopColor, state).toBe(
        getComputedStyle(ticked).borderTopColor
      );
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

  it('fades a step’s bullet in as the stepper reaches it and out as it leaves', async () => {
    const screen = await render(
      <PlStepper defaultActive={0} linear={false}>
        {[<PlStep key="account" label="Account" />, <PlStep key="verify" label="Verify" />]}
      </PlStepper>
    );
    // The bullet is the first thing in the step's button, and hidden from the name.
    const bullet = (name: string) =>
      screen
        .getByRole('button', { name })
        .element()
        .querySelector('span[aria-hidden="true"]') as HTMLElement;
    const account = bullet('Account');
    const verify = bullet('Verify');
    const reached = recordFades(verify);
    const passed = recordFades(account);

    expectLayerOnly(account);
    expect(Number(layerOf(account).opacity)).toBe(1);
    expect(Number(layerOf(verify).opacity)).toBe(0);

    await screen.getByRole('button', { name: 'Verify' }).click();
    await expect.poll(() => reached).toEqual([{ from: 0, to: 1 }]);
    await settle(verify);

    expectLayerOnly(verify);
    // A step left behind stays filled, so nothing about its fill moves.
    expect(passed).toEqual([]);

    await screen.getByRole('button', { name: 'Account' }).click();
    await expect
      .poll(() => reached)
      .toEqual([
        { from: 0, to: 1 },
        { from: 1, to: 0 }
      ]);
  });

  it('fills a timeline’s bullet under the ring it wears while upcoming', async () => {
    const screen = await render(
      <PlTimeline active={0}>
        {[
          <PlTimelineItem key="ordered" title="Ordered" />,
          <PlTimelineItem key="shipped" title="Shipped" />
        ]}
      </PlTimeline>
    );
    // The bullets, which are round, and not the lines between them.
    const [ordered, shipped] = Array.from(
      screen.container.querySelectorAll<HTMLElement>('li span[aria-hidden="true"].rounded-full')
    );

    expectLayerOnly(ordered);
    expect(Number(layerOf(ordered).opacity)).toBe(1);
    // Off, and laid out under the ring rather than inside it, so a bullet
    // fading out does not shrink as the ring arrives.
    expect(Number(layerOf(shipped).opacity)).toBe(0);
    expect(layerOf(shipped).borderTopWidth).toBe(getComputedStyle(shipped).borderTopWidth);
  });

  it('fills a how-to guide’s done and current bullets with the ink a stepper’s take', async () => {
    const screen = await render(
      <>
        <PlHowToSteps active={1} data-testid="guide">
          <PlHowToStep title="Install" />
          <PlHowToStep title="Sign in" />
          <PlHowToStep title="Deploy" />
        </PlHowToSteps>
        <PlStepper defaultActive={1} linear={false}>
          {[<PlStep key="account" label="Account" />, <PlStep key="verify" label="Verify" />]}
        </PlStepper>
      </>
    );
    // The bullet is the first thing in a step, and hidden from the name.
    const [done, current, upcoming] = Array.from(
      screen.getByTestId('guide').element().querySelectorAll(':scope > li'),
      (step) => step.querySelector('span[aria-hidden="true"]') as HTMLElement
    );
    const stepperBullet = screen
      .getByRole('button', { name: 'Account' })
      .element()
      .querySelector('span[aria-hidden="true"]') as HTMLElement;

    for (const bullet of [done, current]) {
      expectLayerOnly(bullet);
      expect(Number(layerOf(bullet).opacity)).toBe(1);
      expect(getComputedStyle(bullet).color).toBe(getComputedStyle(stepperBullet).color);
    }

    expect(Number(layerOf(upcoming).opacity)).toBe(0);
  });

  it('fades a how-to guide’s bullet in, and eases its ink, as `active` reaches it', async () => {
    const guide = (active: number) => (
      <PlHowToSteps active={active} data-testid="guide">
        <PlHowToStep title="Install" />
        <PlHowToStep title="Sign in" />
      </PlHowToSteps>
    );
    const screen = await render(guide(0));
    const bullet = screen
      .getByTestId('guide')
      .element()
      .querySelectorAll(':scope > li')[1]
      .querySelector('span[aria-hidden="true"]') as HTMLElement;
    const fades = recordFades(bullet);
    const inked: string[] = [];

    bullet.addEventListener('transitionrun', (raw) => {
      const event = raw as TransitionEvent;

      if (event.target === bullet && event.pseudoElement === '') {
        inked.push(event.propertyName);
      }
    });

    // Read before the change, which is also what gives the change a style to
    // ease from.
    expect(Number(layerOf(bullet).opacity)).toBe(0);

    await screen.rerender(guide(1));
    await expect.poll(() => fades).toEqual([{ from: 0, to: 1 }]);
    await expect.poll(() => inked).toContain('color');
  });

  it('fades the current page’s gradient from the page it leaves to the one it takes', async () => {
    const screen = await render(<PlPagination count={5} defaultPage={1} />);
    const first = screen.getByRole('button', { name: 'Page 1' }).element();
    const second = screen.getByRole('button', { name: 'Page 2' }).element();
    const layerIn = (element: Element) => element.querySelector('.plass-fill-layer') as HTMLElement;

    // The page paints no gradient of its own, which would arrive at once.
    expect(getComputedStyle(first).backgroundImage).toBe('none');

    const left = recordFades(layerIn(first), '');
    const taken = recordFades(layerIn(second), '');

    expect(getComputedStyle(layerIn(first)).backgroundImage).toContain('linear-gradient');
    expect(Number(getComputedStyle(layerIn(first)).opacity)).toBe(1);
    expect(Number(getComputedStyle(layerIn(second)).opacity)).toBe(0);

    await screen.getByRole('button', { name: 'Page 2' }).click();
    await expect
      .element(screen.getByRole('button', { name: 'Page 2' }))
      .toHaveAttribute('aria-current', 'page');
    await expect.poll(() => taken).toEqual([{ from: 0, to: 1 }]);
    await expect.poll(() => left).toEqual([{ from: 1, to: 0 }]);
    await settle(layerIn(second));

    // Nor does the page taking it, and its layer sits under the bloom, which is
    // the page's own `::before`.
    expect(getComputedStyle(second).backgroundImage).toBe('none');
    expect(Number(getComputedStyle(layerIn(second)).zIndex)).toBeLessThan(
      Number(getComputedStyle(second, '::before').zIndex)
    );
  });

  it('fades a solid segmented button’s tile in where the first choice lands', async () => {
    const screen = await render(
      <PlSegmentedButton aria-label="Period" variant="solid">
        <PlSegment value="day">Day</PlSegment>
        <PlSegment value="week">Week</PlSegment>
      </PlSegmentedButton>
    );
    const group = screen.getByRole('radiogroup').element();
    // Mounted by the first choice, so recorded from the set it lands in.
    const tileOf = () => group.querySelector<HTMLElement>(':scope > span[aria-hidden="true"]');
    const fades = recordFades(group, '::before', (target) => target === tileOf());

    expect(tileOf()).toBeNull();

    await screen.getByRole('radio', { name: 'Week' }).click();
    await expect.element(screen.getByRole('radio', { name: 'Week' })).toBeChecked();
    await expect.poll(() => fades).toEqual([{ from: 0, to: 1 }]);

    const tile = tileOf() as HTMLElement;

    await settle(tile);

    expectLayerOnly(tile);
    expect(Number(layerOf(tile).opacity)).toBe(1);

    // Sliding to the next segment moves the tile and leaves its fill alone.
    await screen.getByRole('radio', { name: 'Day' }).click();
    await expect.element(screen.getByRole('radio', { name: 'Day' })).toBeChecked();
    await frames();

    expect(fades).toEqual([{ from: 0, to: 1 }]);
    expect(Number(layerOf(tile).opacity)).toBe(1);
  });

  it('draws the tile a solid segmented button starts with already lit', async () => {
    // Recorded from the page, since the tile is mounted with the set.
    const fades = recordFades(document.body, '::before', (target) =>
      target.matches('[role="radiogroup"] > span[aria-hidden="true"]')
    );
    const screen = await render(
      <PlSegmentedButton aria-label="Period" variant="solid" defaultValue="week">
        <PlSegment value="day">Day</PlSegment>
        <PlSegment value="week">Week</PlSegment>
      </PlSegmentedButton>
    );
    const tile = screen
      .getByRole('radiogroup')
      .element()
      .querySelector(':scope > span[aria-hidden="true"]') as HTMLElement;

    expectLayerOnly(tile);
    expect(Number(layerOf(tile).opacity)).toBe(1);

    await frames();

    expect(fades).toEqual([]);
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
