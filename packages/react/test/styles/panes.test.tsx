/**
 * Whether a server-rendered `PlPanes` is drawn at its `defaultSize`s before it
 * hydrates, and stays there when it does, which only the stylesheet can answer.
 *
 * The split measures itself in an effect, which runs only once the page has
 * hydrated, and the panes used to take an even share until it had: a split
 * whose first pane asked for a quarter was drawn half and half by the server and
 * then moved. These render on the server, put the HTML in a page with
 * `src/standalone.css` loaded the way `navigation-menu.test.tsx` loads it, and
 * read the panes before and after hydration.
 */
import * as React from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { PlPane, PlPanes } from 'plass-ui';
import type { PlPaneSize } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { committed } from '../support/timing';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/**
 * A split of `sizes` in a box `width` wide, which is what is left for the panes
 * once the 8px of each `md` handle has come off.
 */
function split(sizes: (PlPaneSize | undefined)[], width: number) {
  return (
    <div style={{ width: `${width + 8 * (sizes.length - 1)}px`, height: '300px' }}>
      <PlPanes className="split-under-test">
        {sizes.map((size, index) => (
          <PlPane key={index} defaultSize={size}>
            Pane {index + 1}
          </PlPane>
        ))}
      </PlPanes>
    </div>
  );
}

/** Every pane's width, in order. */
function widths(host: Element): number[] {
  return Array.from(
    host.querySelectorAll<HTMLElement>('.split-under-test > div:not([role="separator"])')
  ).map((pane) => pane.getBoundingClientRect().width);
}

/**
 * The panes' widths in the server's HTML, and again once that HTML has hydrated
 * and the split has measured itself.
 */
async function serverThenHydrated(
  element: React.ReactElement
): Promise<{ server: number[]; hydrated: number[]; errors: unknown[] }> {
  const host = document.createElement('div');
  const onRecoverableError = vi.fn();

  host.innerHTML = renderToString(element);
  document.body.append(host);

  const server = widths(host);
  let root: ReturnType<typeof hydrateRoot> | undefined;

  try {
    await committed(() => {
      root = hydrateRoot(host, element, { onRecoverableError });
    });

    // The split has measured itself once every handle says where it is.
    await expect
      .poll(() =>
        Array.from(host.querySelectorAll('[role="separator"]')).every((handle) =>
          handle.hasAttribute('aria-valuenow')
        )
      )
      .toBe(true);

    return {
      server,
      hydrated: widths(host),
      errors: onRecoverableError.mock.calls
    };
  } finally {
    await committed(() => root?.unmount());
    host.remove();
  }
}

/** That `actual` is `expected`, each to within half a pixel. */
function expectWidths(actual: number[], expected: number[]): void {
  expect(actual).toHaveLength(expected.length);

  actual.forEach((width, index) => {
    expect(Math.abs(width - expected[index]), `pane ${index + 1}`).toBeLessThanOrEqual(0.5);
  });
}

describe('a server-rendered PlPanes', () => {
  it('draws a percentage at its share before hydration, and keeps it', async () => {
    const { server, hydrated, errors } = await serverThenHydrated(split([25, undefined], 600));

    expectWidths(server, [150, 450]);
    expectWidths(hydrated, server);
    expect(errors).toEqual([]);
  });

  it('normalises percentages that do not add up to the whole, as the measurement does', async () => {
    const { server, hydrated } = await serverThenHydrated(split([20, 60], 600));

    expectWidths(server, [150, 450]);
    expectWidths(hydrated, server);
  });

  it('draws a pixel length beside a pane that takes the rest at that length', async () => {
    const { server, hydrated, errors } = await serverThenHydrated(
      split(['200px', 25, undefined], 600)
    );

    expectWidths(server, [200, 150, 250]);
    expectWidths(hydrated, server);
    expect(errors).toEqual([]);
  });

  it('shares the width out by pixel lengths that name every pane', async () => {
    const { server, hydrated } = await serverThenHydrated(split(['100px', '200px'], 600));

    expectWidths(server, [200, 400]);
    expectWidths(hydrated, server);
  });
});
