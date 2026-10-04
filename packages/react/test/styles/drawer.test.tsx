/**
 * Whether a closed `PlDrawer` that `keepMounted` keeps is out of sight, which
 * only the stylesheet can answer.
 *
 * Base UI marks the closed parts `hidden`, and with no CSS loaded the browser's
 * own `display: none` for that attribute is all there is. With the stylesheet
 * loaded, the `flex` the viewport and the panel are laid out with outranks it,
 * so the question is whether the panel stays hidden once the real classes are
 * in the room. Loaded the way `back-top.test.tsx` loads it.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlDrawer, PlSidebar } from 'plass-ui';
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

const link = () => document.querySelector<HTMLAnchorElement>('a[href="/docs"]');

describe('a closed drawer that is kept mounted', () => {
  it('draws nothing of the panel, the scrim or the viewport', async () => {
    await render(
      <PlDrawer keepMounted title="Menu" classNames={{ backdrop: 'kept-backdrop' }}>
        <a href="/docs">Docs</a>
      </PlDrawer>
    );

    await expect.poll(link).not.toBeNull();

    const panel = link()!.closest<HTMLElement>('[role="dialog"], [hidden]')!;
    const viewport = panel.parentElement!;

    expect(panel).toHaveAttribute('hidden');
    expect(viewport).toHaveAttribute('hidden');

    expect(getComputedStyle(panel).display).toBe('none');
    expect(getComputedStyle(viewport).display).toBe('none');
    expect(getComputedStyle(document.querySelector('.kept-backdrop')!).display).toBe('none');
    expect(link()!.checkVisibility()).toBe(false);
  });

  it('draws the panel once it is opened', async () => {
    const screen = await render(
      <PlDrawer keepMounted modal="trap-focus" trigger={<PlButton>Menu</PlButton>} title="Menu">
        <a href="/docs">Docs</a>
      </PlDrawer>
    );

    await expect.poll(link).not.toBeNull();
    await screen.getByRole('button', { name: 'Menu' }).click();

    await expect.poll(() => link()!.checkVisibility()).toBe(true);
  });

  it("keeps a collapsed sidebar's links out of sight", async () => {
    // The browser the suite runs in is narrower than `md`, so the sidebar is a
    // drawer here.
    await render(
      <PlSidebar collapseBelow="md" keepMounted>
        <a href="/docs">Docs</a>
      </PlSidebar>
    );

    await expect.poll(link).not.toBeNull();

    expect(link()!.checkVisibility()).toBe(false);
  });
});
