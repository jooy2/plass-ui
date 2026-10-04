/**
 * Where a browser's own padding on a `<button>` still reaches a component,
 * which only the stylesheet can answer.
 *
 * Tailwind's Preflight takes the padding off every element, so a project that
 * runs Tailwind never sees it. The reset in `plass-ui/styles.css` leaves
 * padding alone, because it reaches a page's own buttons too, so there the
 * browser's padding stays wherever a component's button sets none on an axis:
 * a step of a trail stood taller than a link beside it, and a field's value
 * started further in than its padding put it. Where the button's height is
 * fixed its box is right, but WebKit pads a button a pixel deeper below than
 * above, so the words or the glyph in it sat half a pixel high.
 * `src/standalone.css` is loaded the way `combobox.test.tsx` loads it, and each
 * button is measured against what it should line up with: a sibling that is
 * not a button where there is one, and otherwise its own content. No length is
 * asserted, only that the two agree.
 */
import * as React from 'react';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAlert,
  PlBreadcrumb,
  PlBreadcrumbItem,
  PlButton,
  PlCalendar,
  PlCarousel,
  PlChip,
  PlColorPicker,
  PlCombobox,
  PlDatePicker,
  PlDateRangePicker,
  PlDateTimePicker,
  PlDrawer,
  PlFilePicker,
  PlFloatingBottomNavigation,
  PlFloatingBottomNavigationItem,
  PlMenubar,
  PlMenubarMenu,
  PlMenuItem,
  PlModal,
  PlNavigationMenu,
  PlNavigationMenuItem,
  PlNavigationMenuLink,
  PlNumberField,
  PlPill,
  PlPopover,
  PlSelect,
  PlTab,
  PlTabs,
  PlTimePicker,
  PlToastProvider,
  PlToggle,
  PlTour,
  PlTreeSelect,
  PlWindowPane,
  usePlToast
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

/** The box round the first words in `element`. */
function wordsOf(element: Element): DOMRect {
  const walker = document.createTreeWalker(element, NodeFilter.SHOW_TEXT);

  for (let node = walker.nextNode(); node; node = walker.nextNode()) {
    if (node.textContent?.trim()) {
      const range = document.createRange();

      range.selectNodeContents(node);

      return range.getBoundingClientRect();
    }
  }

  throw new Error('no words in the button');
}

/** The box round the glyph `element` draws. */
function glyphOf(element: Element): DOMRect {
  return element.querySelector('svg')!.getBoundingClientRect();
}

/**
 * How far what `button` holds moves inside it once a browser's padding is taken
 * off every button, by a rule of no specificity as Preflight takes it off.
 *
 * Each of the four distances from the content to the button's edges is
 * compared, so padding that moved it either way shows. The content is not
 * compared with the button's middle: Chromium rounds a font's ascent and
 * descent apart, which leaves some words half a pixel off the middle of any box.
 */
function shiftWithoutPadding(button: Element, content: (button: Element) => DOMRect): number {
  const gaps = () => {
    const box = button.getBoundingClientRect();
    const inner = content(button);

    return [
      inner.top - box.top,
      box.bottom - inner.bottom,
      inner.left - box.left,
      box.right - inner.right
    ];
  };
  const before = gaps();
  const reset = document.createElement('style');

  reset.textContent = ':where(button) { padding: 0 }';
  document.head.append(reset);

  const after = gaps();

  reset.remove();

  return Math.max(...before.map((gap, index) => Math.abs(gap - after[index])));
}

/** A toast with an action, raised once as soon as it is mounted. */
function RaiseToast() {
  const toast = usePlToast();
  const raised = React.useRef(false);

  React.useEffect(() => {
    if (!raised.current) {
      raised.current = true;
      toast.add({ title: 'Deleted', timeout: 0, actionLabel: 'Undo', onAction: () => {} });
    }
  }, [toast]);

  return null;
}

/** The `<button>` whose words are exactly `text`. */
function buttonWith(text: string): Element | undefined {
  return [...document.querySelectorAll('button')].find((button) => button.textContent === text);
}

describe('a button of fixed height', () => {
  it.each(SIZES)('holds the label of a PlButton where no padding puts it at %s', async (size) => {
    const screen = await render(<PlButton size={size}>Save</PlButton>);
    const button = screen.getByRole('button', { name: 'Save' }).element();

    expect(shiftWithoutPadding(button, wordsOf)).toBeLessThan(0.01);
  });

  it.each(SIZES)('holds the label of a PlTab where no padding puts it at %s', async (size) => {
    const screen = await render(
      <PlTabs size={size} defaultValue="account">
        <PlTab value="account">Account</PlTab>
        <PlTab value="billing">Billing</PlTab>
      </PlTabs>
    );

    for (const name of ['Account', 'Billing']) {
      const tab = screen.getByRole('tab', { name }).element();

      expect(tab.tagName).toBe('BUTTON');
      expect(shiftWithoutPadding(tab, wordsOf), name).toBeLessThan(0.01);
    }
  });

  it.each(SIZES)(
    'holds the number of a PlCalendar day where no padding puts it at %s',
    async (size) => {
      await render(<PlCalendar size={size} defaultValue={new Date(2026, 6, 15)} />);

      const days = [...document.querySelectorAll('button[role="gridcell"]')];

      expect(days.length).toBeGreaterThan(27);

      for (const day of days) {
        expect(shiftWithoutPadding(day, wordsOf), day.getAttribute('aria-label')!).toBeLessThan(
          0.01
        );
      }
    }
  );

  it('holds the words of every other such button where no padding puts them', async () => {
    await render(
      <>
        <PlToggle>Bold</PlToggle>
        <PlChip onClick={() => {}}>Pressable</PlChip>
        <PlSelect label="City" items={[{ value: 'seoul', label: 'Seoul' }]} defaultValue="seoul" />
        <PlMenubar>
          <PlMenubarMenu label="File">
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
        <PlNavigationMenu>
          <PlNavigationMenuItem label="Product">
            <PlNavigationMenuLink href="#" title="Analytics" />
          </PlNavigationMenuItem>
        </PlNavigationMenu>
        <PlTimePicker label="Time" defaultValue={new Date(2026, 6, 15, 9, 30)} defaultOpen />
        <PlToastProvider>
          <RaiseToast />
        </PlToastProvider>
      </>
    );

    await expect.poll(() => buttonWith('Undo')).toBeDefined();
    await expect.poll(() => document.querySelector('[role="option"]')).not.toBeNull();

    const buttons: Array<[string, Element | null | undefined]> = [
      ['PlToggle', document.querySelector('button[aria-pressed]')],
      ['PlChip', buttonWith('Pressable')],
      ['PlSelect', document.querySelector('[role="combobox"]')],
      ['PlMenubarMenu', buttonWith('File')],
      ['PlNavigationMenuItem', buttonWith('Product')],
      ['PlTimePicker', document.querySelector('[role="option"]')],
      ['PlToast', buttonWith('Undo')]
    ];

    for (const [name, button] of buttons) {
      expect(button?.tagName, name).toBe('BUTTON');
      expect(shiftWithoutPadding(button!, wordsOf), name).toBeLessThan(0.01);
    }
  });

  it('holds the glyph of every such button where no padding puts it', async () => {
    const file = new File(['x'], 'notes.txt', { type: 'text/plain' });
    const target = document.createElement('button');

    target.textContent = 'Filter';
    document.body.append(target);

    try {
      await render(
        <>
          <PlNumberField label="Count" defaultValue={2} />
          <PlChip onDelete={() => {}}>Design</PlChip>
          <PlAlert title="Saved" onClose={() => {}} />
          <PlFilePicker label="Files" multiple defaultValue={[file]} />
          <PlFloatingBottomNavigation label="Main" value="home">
            <PlFloatingBottomNavigationItem
              value="home"
              icon={
                <svg viewBox="0 0 16 16" aria-hidden="true">
                  <rect width="16" height="16" />
                </svg>
              }
            >
              Home
            </PlFloatingBottomNavigationItem>
          </PlFloatingBottomNavigation>
          <PlWindowPane title="Notes">Body</PlWindowPane>
          <PlModal defaultOpen title="Delete project">
            Are you sure?
          </PlModal>
          <PlDrawer defaultOpen title="Filters" showClose>
            Nothing yet
          </PlDrawer>
          <PlPopover defaultOpen showClose title="Rename" trigger={<PlButton>Rename</PlButton>}>
            Body
          </PlPopover>
          <PlTour
            defaultOpen
            scrollIntoView={false}
            steps={[{ target: () => target, title: 'Narrow the list' }]}
          />
          <PlToastProvider>
            <RaiseToast />
          </PlToastProvider>
        </>
      );

      await expect.poll(() => buttonWith('Undo')).toBeDefined();

      const named = (label: string) =>
        [...document.querySelectorAll('button[aria-label]')].filter((button) =>
          button.getAttribute('aria-label')!.startsWith(label)
        );
      const buttons: Array<[string, Element[], number]> = [
        ['the steppers of a PlNumberField', [...named('Increase'), ...named('Decrease')], 2],
        ['the × of a PlChip and a PlFilePicker', named('Remove'), 2],
        ['the × of a PlAlert', named('Dismiss'), 1],
        ['a PlFloatingBottomNavigationItem', [...document.querySelectorAll('[data-disc]')], 1],
        ['the controls of a PlWindowPane', [...named('Minimize'), ...named('Maximize')], 2],
        // A window pane, a modal, a drawer, a popover, a tour and a toast.
        ['each ×', named('Close'), 6]
      ];

      for (const [name, found, count] of buttons) {
        expect(found, name).toHaveLength(count);

        for (const button of found) {
          expect(button.tagName, name).toBe('BUTTON');
          expect(shiftWithoutPadding(button, glyphOf), name).toBeLessThan(0.01);
        }
      }
    } finally {
      target.remove();
    }
  });
});
