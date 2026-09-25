/**
 * What the house transition does under reduced motion, which the stylesheet
 * decides.
 *
 * The transition is a set of utilities rather than a class, so the assertion is
 * on the durations a control's own element resolves, read with
 * `src/standalone.css` loaded the way `card.test.tsx` loads it. Nothing here
 * changes a state, so no pointer and no timing is involved.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlCheckbox, PlSwitch, PlToggle } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
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

/**
 * The duration each property of the element's transition gets, in seconds,
 * keyed by property. The two lists pair up by position, and a shorter duration
 * list repeats, as CSS reads them.
 */
function durations(element: Element): Record<string, number> {
  const style = getComputedStyle(element);
  const properties = style.transitionProperty.split(',').map((one) => one.trim());
  const lengths = style.transitionDuration.split(',').map((one) => parseFloat(one));

  return Object.fromEntries(
    properties.map((property, index) => [property, lengths[index % lengths.length]])
  );
}

/** The four controls whose surface the house transition, or its list, eases. */
async function renderControls(): Promise<Element[]> {
  const screen = await render(
    <div>
      <PlButton>Save</PlButton>
      <PlToggle variant="solid" aria-label="Bold" />
      <PlCheckbox label="Remember me" />
      <PlSwitch label="Wi-Fi" />
    </div>
  );

  return [
    screen.getByRole('button', { name: 'Save' }).element(),
    screen.getByRole('button', { name: 'Bold' }).element(),
    screen.getByRole('checkbox').element(),
    screen.getByRole('switch').element()
  ];
}

describe('the house transition', () => {
  it('eases a control’s colours', async () => {
    for (const control of await renderControls()) {
      const eased = durations(control);

      expect(eased['background-color']).toBeGreaterThan(0);
      expect(eased['box-shadow']).toBeGreaterThan(0);
    }
  });

  it('changes a control’s colours at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    for (const control of await renderControls()) {
      const eased = durations(control);

      expect(eased['background-color']).toBe(0);
      expect(eased['box-shadow']).toBe(0);
      expect(Object.values(eased).every((length) => length === 0)).toBe(true);
    }
  });
});
