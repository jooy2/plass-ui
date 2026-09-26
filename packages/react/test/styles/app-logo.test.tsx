/**
 * How a `PlAppLogo` plate changes colour, which only the stylesheet can answer:
 * without the real CSS loaded a transition is a class name and nothing else.
 * Loaded the way `toast.test.tsx` loads it, with the house duration drawn out
 * so a change is still under way when it is read.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAppLogo, type PlassColor } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
  document.documentElement.style.setProperty('--plass-duration', '10s');
});

afterAll(() => {
  sheet.remove();
  document.documentElement.style.removeProperty('--plass-duration');
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

function Logo({ color }: { color: PlassColor }) {
  return (
    <>
      <PlAppLogo shape="plate" color={color} className="logo-under-test">
        <svg viewBox="0 0 16 16" />
      </PlAppLogo>
      <span data-testid="probe" style={{ color: 'var(--plass-warning-on-solid)' }} />
    </>
  );
}

/**
 * Draws a `solid` plate in `info`, turns it `warning`, and hands back the ink
 * on the plate straight afterwards, with the ink `warning` settles on.
 */
async function change() {
  const screen = await render(<Logo color="info" />);

  await screen.rerender(<Logo color="warning" />);

  const plate = document.querySelector('.logo-under-test')!.firstElementChild!;

  return {
    ink: getComputedStyle(plate).color,
    settled: getComputedStyle(screen.getByTestId('probe').element()).color
  };
}

describe('a PlAppLogo plate whose colour changes', () => {
  it('eases its ink to the new colour', async () => {
    const { ink, settled } = await change();

    expect(ink).not.toBe(settled);
  });

  it('changes its ink at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    const { ink, settled } = await change();

    expect(ink).toBe(settled);
  });
});
