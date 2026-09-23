/**
 * Where a `PlTabs` bar brings a tab to, which only the stylesheet can answer.
 *
 * A bar with more tabs than room fades whichever end still has tabs behind it,
 * over `--p-fade`. A tab brought into view — the chosen one as the bar is laid
 * out, or the next one along as the arrow keys move — has to stop clear of that
 * fade rather than flush with the edge, where it would be drawn half gone. The
 * reveal is Base UI's, and it honours the list's `scroll-padding`, so that is
 * where the length is given. Loaded the way `back-top.test.tsx` loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { PlTab, PlTabs } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

const names = ['Overview', 'Activity', 'Settings', 'Members', 'Billing', 'Integrations', 'Alerts'];

function Bar({ value, dir }: { value: string; dir?: 'rtl' }) {
  return (
    <div dir={dir} style={{ width: 280 }}>
      <PlTabs defaultValue={value}>
        {names.map((name) => (
          <PlTab key={name} value={name}>
            {name}
          </PlTab>
        ))}
      </PlTabs>
    </div>
  );
}

/** The fade's length, read off the list rather than assumed. */
function fadeOf(list: HTMLElement) {
  const probe = document.createElement('div');

  // `flex: none`, or an overflowing flex row would shrink it to nothing.
  probe.style.flex = 'none';
  probe.style.width = 'var(--p-fade)';
  list.append(probe);

  const width = probe.getBoundingClientRect().width;

  probe.remove();

  return width;
}

/** How far the tab stands in from each side of the list's box. */
function clearance(list: HTMLElement, tab: HTMLElement) {
  const box = list.getBoundingClientRect();
  const rect = tab.getBoundingClientRect();

  return { left: rect.left - box.left, right: box.right - rect.right };
}

describe('a PlTabs bar with more tabs than room', () => {
  it('lays the chosen tab out clear of the fade', async () => {
    const screen = await render(<Bar value="Integrations" />);
    const list = screen.getByRole('tablist').element() as HTMLElement;
    const tab = screen.getByRole('tab', { name: 'Integrations' }).element() as HTMLElement;
    const fade = fadeOf(list);

    expect(fade).toBeGreaterThan(0);
    await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'both');
    await expect.poll(() => clearance(list, tab).right).toBeGreaterThanOrEqual(fade - 1);
  });

  it('brings the next tab along clear of the fade', async () => {
    const screen = await render(<Bar value="Overview" />);
    const list = screen.getByRole('tablist').element() as HTMLElement;
    const fade = fadeOf(list);

    await userEvent.keyboard('{Tab}');
    await expect.element(screen.getByRole('tab', { name: 'Overview' })).toHaveFocus();

    for (let step = 0; step < 4; step += 1) {
      await userEvent.keyboard('{ArrowRight}');
    }

    const tab = screen.getByRole('tab', { name: 'Billing' }).element() as HTMLElement;

    await expect.element(screen.getByRole('tab', { name: 'Billing' })).toHaveFocus();
    await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'both');
    await expect.poll(() => clearance(list, tab).right).toBeGreaterThanOrEqual(fade - 1);
  });

  it('does the same from the other side under RTL', async () => {
    const screen = await render(<Bar value="Integrations" dir="rtl" />);
    const list = screen.getByRole('tablist').element() as HTMLElement;
    const tab = screen.getByRole('tab', { name: 'Integrations' }).element() as HTMLElement;
    const fade = fadeOf(list);

    await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'both');
    await expect.poll(() => clearance(list, tab).left).toBeGreaterThanOrEqual(fade - 1);
  });
});
