/**
 * Where a browser's own padding on a `<button>` still reaches a component,
 * which only the stylesheet can answer.
 *
 * Tailwind's Preflight takes the padding off every element, so a project that
 * runs Tailwind never sees it. The reset in `plass-ui/styles.css` leaves
 * padding alone, because it reaches a page's own buttons too, so there the
 * browser's padding stays wherever a component's button sets none on an axis:
 * a step of a trail stood taller than a link beside it, and a field's value
 * started further in than its padding put it. `src/standalone.css` is loaded the way `combobox.test.tsx`
 * loads it, and each button is measured against what it should line up with: a
 * sibling that is not a button where there is one, and otherwise its own
 * content. No length is asserted, only that the two agree.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlBreadcrumb,
  PlBreadcrumbItem,
  PlCarousel,
  PlColorPicker,
  PlCombobox,
  PlDatePicker,
  PlDateRangePicker,
  PlDateTimePicker,
  PlPill,
  PlTimePicker,
  PlTreeSelect
} from 'plass-ui';
import type { PlassSize } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

const SIZES: PlassSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/** The laid-out height of `element`. */
function height(element: Element): number {
  return element.getBoundingClientRect().height;
}

/** The laid-out width of `element`. */
function width(element: Element): number {
  return element.getBoundingClientRect().width;
}

/** The four edges of `element`'s box. */
function edges(element: Element) {
  const { top, right, bottom, left } = element.getBoundingClientRect();

  return { top, right, bottom, left };
}

/** The four edges of the smallest box round everything in `element`. */
function contentEdges(element: Element) {
  const boxes = [...element.children].map((child) => child.getBoundingClientRect());

  return {
    top: Math.min(...boxes.map((box) => box.top)),
    right: Math.max(...boxes.map((box) => box.right)),
    bottom: Math.max(...boxes.map((box) => box.bottom)),
    left: Math.min(...boxes.map((box) => box.left))
  };
}

describe('a PlBreadcrumb step', () => {
  it.each(SIZES)('stands a link, a button and a text step at one height at %s', async (size) => {
    const screen = await render(
      <PlBreadcrumb size={size}>
        <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
        <PlBreadcrumbItem onClick={() => {}}>Projects</PlBreadcrumbItem>
        <PlBreadcrumbItem>Plass</PlBreadcrumbItem>
      </PlBreadcrumb>
    );
    const link = screen.getByRole('link', { name: 'Home' }).element();
    const button = screen.getByRole('button', { name: 'Projects' }).element();
    const text = screen.getByText('Plass').element().parentElement!;

    expect(button.tagName).toBe('BUTTON');
    expect(text.tagName).toBe('SPAN');
    expect(height(button)).toBe(height(link));
    expect(height(text)).toBe(height(link));
  });

  it.each(SIZES)('stands a disabled button step as tall as a disabled link at %s', async (size) => {
    const screen = await render(
      <PlBreadcrumb size={size}>
        <PlBreadcrumbItem href="/" disabled>
          Home
        </PlBreadcrumbItem>
        <PlBreadcrumbItem onClick={() => {}} disabled>
          Projects
        </PlBreadcrumbItem>
        <PlBreadcrumbItem>Plass</PlBreadcrumbItem>
      </PlBreadcrumb>
    );
    const link = screen.getByRole('link', { name: 'Home' }).element();
    const button = screen.getByRole('button', { name: 'Projects' }).element();

    expect(height(button)).toBe(height(link));
  });

  it.each(SIZES)('stands a fold that opens as tall as one that does not at %s', async (size) => {
    const trail = (expandable: boolean) => (
      <PlBreadcrumb size={size} maxItems={3} expandable={expandable}>
        <PlBreadcrumbItem href="/">Home</PlBreadcrumbItem>
        <PlBreadcrumbItem href="/a">A</PlBreadcrumbItem>
        <PlBreadcrumbItem href="/b">B</PlBreadcrumbItem>
        <PlBreadcrumbItem href="/c">C</PlBreadcrumbItem>
        <PlBreadcrumbItem>Plass</PlBreadcrumbItem>
      </PlBreadcrumb>
    );
    const screen = await render(
      <>
        <div data-testid="open">{trail(true)}</div>
        <div data-testid="shut">{trail(false)}</div>
      </>
    );
    const fold = screen.getByTestId('open').getByRole('button').element();
    // The separators are hidden on their `<li>`, so the only hidden `<span>`
    // sitting straight in one is the fold that cannot be opened.
    const mark = screen
      .getByTestId('shut')
      .element()
      .querySelector('li > span[aria-hidden="true"]')!;

    expect(fold.tagName).toBe('BUTTON');
    expect(height(fold)).toBe(height(mark));
  });
});

describe('a PlPill', () => {
  it.each(SIZES)('stands as tall with an `onClick` as without one at %s', async (size) => {
    const screen = await render(
      <>
        <PlPill size={size} title="Recording" description="00:41" data-testid="still" />
        <PlPill
          size={size}
          title="Recording"
          description="00:41"
          onClick={() => {}}
          data-testid="pressable"
        />
        <PlPill size={size} title="Recording" data-testid="still-line" />
        <PlPill size={size} title="Recording" onClick={() => {}} data-testid="pressable-line" />
      </>
    );

    expect(screen.getByRole('button', { name: /Recording.*00:41/ }).element().tagName).toBe(
      'BUTTON'
    );
    expect(height(screen.getByTestId('pressable').element())).toBe(
      height(screen.getByTestId('still').element())
    );
    expect(height(screen.getByTestId('pressable-line').element())).toBe(
      height(screen.getByTestId('still-line').element())
    );
  });
});

describe('the trigger of a picker', () => {
  it.each([
    ['PlDatePicker', <PlDatePicker key="date" label="Field" />],
    ['PlDateRangePicker', <PlDateRangePicker key="range" label="Field" />],
    ['PlDateTimePicker', <PlDateTimePicker key="moment" label="Field" />],
    ['PlTimePicker', <PlTimePicker key="time" label="Field" />],
    ['PlColorPicker', <PlColorPicker key="colour" label="Field" />],
    [
      'PlTreeSelect',
      <PlTreeSelect key="tree" label="Field" items={[{ id: 'france', label: 'France' }]} />
    ]
  ])('of a %s holds its value with no padding round it', async (_, field) => {
    const screen = await render(field);
    const trigger = screen.getByRole('button', { name: /^Field/ }).element();

    // What it holds starts where the field's own padding puts it, and the
    // trigger is no taller than the line it holds.
    expect(contentEdges(trigger)).toEqual(edges(trigger));
  });
});

describe('a PlColorPicker swatch', () => {
  it.each(SIZES)('stands as tall as it is wide, chosen or not, at %s', async (size) => {
    const swatches = ['#0f172a', '#1a58d1', '#0ea5e9', '#10b981', '#f59e0b', '#ef4444'];
    const screen = await render(
      <PlColorPicker inline label="Brand" size={size} swatches={swatches} defaultValue="#1a58d1" />
    );

    await expect
      .element(screen.getByRole('button', { name: '#1a58d1' }))
      .toHaveAttribute('aria-pressed', 'true');

    for (const swatch of swatches) {
      const button = screen.getByRole('button', { name: swatch }).element();

      expect(height(button), swatch).toBe(width(button));
    }
  });
});

describe('a PlCombobox', () => {
  it('draws its chevron and its × as wide as their glyphs', async () => {
    const screen = await render(
      <PlCombobox items={[{ value: 'seoul', label: 'Seoul' }]} defaultValue="seoul" clearable />
    );

    for (const name of ['Open', 'Clear']) {
      const button = screen.getByRole('button', { name }).element();

      expect(width(button), name).toBe(width(button.firstElementChild!));
    }
  });
});

describe('a PlCarousel', () => {
  it.each(SIZES)(
    'makes each dot’s target the larger of its floor and its dot at %s',
    async (size) => {
      const screen = await render(
        <div style={{ width: 320 }}>
          <PlCarousel size={size}>
            <div style={{ height: 120 }}>Alpha</div>
            <div style={{ height: 120 }}>Bravo</div>
            <div style={{ height: 120 }}>Charlie</div>
          </PlCarousel>
        </div>
      );

      for (const index of [1, 2, 3]) {
        const target = screen.getByRole('button', { name: `Slide ${index} of 3` }).element();
        const floor = parseFloat(getComputedStyle(target).minWidth);

        // The current dot is the wide one, and its target grows only as far as the dot.
        expect(width(target), `slide ${index}`).toBe(
          Math.max(floor, width(target.firstElementChild!))
        );
      }
    }
  );
});
