import { page } from 'vitest/browser';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Fragment, useEffect, useState } from 'react';
import { renderToString } from 'react-dom/server';
import { PlassProvider, PlTab, PlTabPanel, PlTabs } from 'plass-ui';
import { committed } from '../../support/timing';

function Settings(props: React.ComponentProps<typeof PlTabs>) {
  return (
    <PlTabs defaultValue="account" {...props}>
      <PlTab value="account">Account</PlTab>
      <PlTab value="billing">Billing</PlTab>
      <PlTab value="team">Team</PlTab>

      <PlTabPanel value="account">Your name and your avatar.</PlTabPanel>
      <PlTabPanel value="billing">Cards and invoices.</PlTabPanel>
      <PlTabPanel value="team">Who else is here.</PlTabPanel>
    </PlTabs>
  );
}

/**
 * The two declarations an overflowing bar depends on, since no component test
 * loads CSS and a box that does not clip has nothing to scroll. Returns the
 * undo, which every test that calls this owes a `finally`.
 */
function clip() {
  const style = document.createElement('style');

  style.textContent =
    // `position: relative` is on the real list too, and Base UI's reveal
    // measures a tab against its nearest positioned ancestor: without it the
    // arithmetic is run against the page under a right-to-left direction.
    '[role="tablist"] { position: relative; display: flex; overflow-x: auto; width: 160px; }' +
    '[role="tab"] { flex: 0 0 auto; width: 120px; }';
  document.head.append(style);

  return () => style.remove();
}

let initialViewport: [number, number];

beforeAll(() => {
  initialViewport = [window.innerWidth, window.innerHeight];
});

afterAll(async () => {
  await page.viewport(...initialViewport);
});

describe('PlTabs', () => {
  describe('rendering', () => {
    it('renders a tablist holding one tab per child', async () => {
      const screen = await render(<Settings />);

      await expect.element(screen.getByRole('tablist')).toBeInTheDocument();
      expect(screen.getByRole('tab').elements()).toHaveLength(3);
    });

    it('shows only the chosen panel', async () => {
      const screen = await render(<Settings />);

      await expect.element(screen.getByText('Your name and your avatar.')).toBeInTheDocument();
      expect(screen.getByText('Cards and invoices.').query()).toBeNull();
    });

    it('marks the chosen tab selected', async () => {
      const screen = await render(<Settings defaultValue="billing" />);

      expect(screen.getByRole('tab', { name: 'Billing' }).element()).toHaveAttribute(
        'aria-selected',
        'true'
      );
      expect(screen.getByRole('tab', { name: 'Account' }).element()).toHaveAttribute(
        'aria-selected',
        'false'
      );
    });

    it('sorts panels out of the tab list', async () => {
      await render(<Settings className="tabs-under-test" />);
      const list = document.querySelector('.tabs-under-test [role="tablist"]') as HTMLElement;

      // Three tabs and the indicator; the panels went in the other box.
      expect(list.querySelectorAll('[role="tab"]')).toHaveLength(3);
      expect(list.textContent).not.toContain('Your name');
    });

    it('opens Fragments on the way, so a tab and its panel can be mapped together', async () => {
      const items = [
        { value: 'account', label: 'Account', body: 'Your name and your avatar.' },
        { value: 'billing', label: 'Billing', body: 'Cards and invoices.' }
      ];

      await render(
        <PlTabs defaultValue="account" className="tabs-under-test">
          {items.map((item) => (
            <Fragment key={item.value}>
              <PlTab value={item.value}>{item.label}</PlTab>
              <PlTabPanel value={item.value}>{item.body}</PlTabPanel>
            </Fragment>
          ))}
        </PlTabs>
      );

      const list = document.querySelector('.tabs-under-test [role="tablist"]') as HTMLElement;

      expect(list.querySelectorAll('[role="tab"]')).toHaveLength(2);
      expect(list.textContent).not.toContain('Your name');
      expect(document.querySelector('.tabs-under-test [role="tabpanel"]')).toHaveTextContent(
        'Your name and your avatar.'
      );
    });

    it('renders the start and end slots', async () => {
      const screen = await render(
        <PlTabs defaultValue="a">
          <PlTab value="a" startIcon={<span>◆</span>} endIcon={<span>7</span>}>
            First
          </PlTab>
          <PlTabPanel value="a">Body</PlTabPanel>
        </PlTabs>
      );

      await expect.element(screen.getByText('◆')).toBeInTheDocument();
      await expect.element(screen.getByText('7')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<Settings className="my-own-class" />);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });
  });

  describe('switching', () => {
    it('shows the panel of the tab that was pressed', async () => {
      const screen = await render(<Settings />);

      await screen.getByRole('tab', { name: 'Billing' }).click();

      await expect.element(screen.getByText('Cards and invoices.')).toBeInTheDocument();
      await expect.element(screen.getByText('Your name and your avatar.')).not.toBeInTheDocument();
    });

    it('reports the new value to `onValueChange`', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Settings onValueChange={onValueChange} />);

      await screen.getByRole('tab', { name: 'Team' }).click();

      await vi.waitFor(() => expect(onValueChange).toHaveBeenCalledWith('team'));
    });

    it('obeys `value` rather than the press when controlled', async () => {
      const screen = await render(<Settings value="account" onValueChange={() => {}} />);

      await screen.getByRole('tab', { name: 'Team' }).click();

      await expect.element(screen.getByText('Your name and your avatar.')).toBeInTheDocument();
    });

    it('does not switch on a disabled tab', async () => {
      const screen = await render(
        <PlTabs defaultValue="a">
          <PlTab value="a">First</PlTab>
          <PlTab value="b" disabled>
            Second
          </PlTab>
          <PlTabPanel value="a">One</PlTabPanel>
          <PlTabPanel value="b">Two</PlTabPanel>
        </PlTabs>
      );

      expect(screen.getByRole('tab', { name: 'Second' }).element()).toBeDisabled();
      await expect.element(screen.getByText('One')).toBeInTheDocument();
    });
  });

  describe('panels', () => {
    it('drops a hidden panel from the DOM by default', async () => {
      await render(<Settings className="tabs-under-test" />);

      expect(document.body.textContent).not.toContain('Cards and invoices.');
    });

    it('keeps it when `keepMounted` says so', async () => {
      await render(
        <PlTabs defaultValue="a" className="tabs-under-test">
          <PlTab value="a">First</PlTab>
          <PlTab value="b">Second</PlTab>
          <PlTabPanel value="a">One</PlTabPanel>
          <PlTabPanel value="b" keepMounted>
            Two
          </PlTabPanel>
        </PlTabs>
      );

      const hidden = document.querySelector('.tabs-under-test [role="tabpanel"][hidden]');

      expect(hidden?.textContent).toBe('Two');
    });

    it('puts only the chosen panel and a `keepMounted` one into the server HTML', () => {
      // What a search engine reads, and what the docs tell a page that wants a
      // tab's content indexed to set.
      const html = renderToString(
        <PlTabs defaultValue="a">
          <PlTab value="a">First</PlTab>
          <PlTab value="b">Second</PlTab>
          <PlTab value="c">Third</PlTab>
          <PlTabPanel value="a">Chosen panel</PlTabPanel>
          <PlTabPanel value="b">Dropped panel</PlTabPanel>
          <PlTabPanel value="c" keepMounted>
            Kept panel
          </PlTabPanel>
        </PlTabs>
      );

      expect(html).toContain('Chosen panel');
      expect(html).not.toContain('Dropped panel');
      expect(html).toContain('Kept panel');
    });

    it('points each tab at the panel it controls', async () => {
      const screen = await render(<Settings />);
      const panelId = screen
        .getByRole('tab', { name: 'Account' })
        .element()
        .getAttribute('aria-controls');

      expect(panelId).toBeTruthy();
      expect(document.getElementById(panelId as string)).not.toBeNull();
    });
  });

  describe('the set decides the look', () => {
    it('gives every tab the size the set was given', async () => {
      const screen = await render(<Settings size="lg" />);

      for (const tab of screen.getByRole('tab').elements()) {
        expect(tab).toHaveClass('h-12');
      }
    });

    it('turns the tablist onto the other axis when vertical', async () => {
      const screen = await render(<Settings orientation="vertical" />);

      expect(screen.getByRole('tablist').element()).toHaveAttribute('aria-orientation', 'vertical');
    });

    it('shares the bar evenly when `fullWidth` is set', async () => {
      const screen = await render(<Settings fullWidth />);

      for (const tab of screen.getByRole('tab').elements()) {
        expect(tab).toHaveClass('flex-1');
      }
    });

    it('centres each label in its tab', async () => {
      const screen = await render(<Settings />);

      for (const tab of screen.getByRole('tab').elements()) {
        expect(tab).toHaveClass('justify-center');
      }
    });

    it('puts the label where `align` says instead, and moves nothing else', async () => {
      const screen = await render(<Settings align="start" />);

      for (const tab of screen.getByRole('tab').elements()) {
        expect(tab).toHaveClass('justify-start');
        expect(tab).not.toHaveClass('justify-center');
        // The label moves inside the tab; the tab itself is untouched, which is
        // what makes this safe to set on a bar that is already laid out.
        expect(tab).toHaveClass('h-10');
      }
    });
  });

  describe('a responsive orientation', () => {
    it('turns at the rung it was named, ARIA and all', async () => {
      await page.viewport(500, 600);

      const screen = await render(<Settings orientation={{ xs: 'vertical', md: 'horizontal' }} />);
      const list = () => screen.getByRole('tablist').element();

      // Not a class swap: an orientation decides the DOM, the `aria-orientation`
      // and which way the arrow keys walk, which is why it is resolved in
      // JavaScript rather than in the stylesheet.
      await expect.poll(() => list().getAttribute('aria-orientation')).toBe('vertical');
      expect(list()).toHaveClass('flex-col');

      await page.viewport(900, 600);

      // `horizontal` is ARIA's own default for a tab list, so Base UI leaves the
      // attribute off rather than writing it out.
      await expect.poll(() => list().getAttribute('aria-orientation')).toBeNull();
      expect(list()).not.toHaveClass('flex-col');
    });

    it('subscribes to nothing at all for a bare orientation', async () => {
      const listen = vi.spyOn(MediaQueryList.prototype, 'addEventListener');

      await render(<Settings orientation="vertical" />);

      // The whole reason a responsive prop is safe to add to a component that
      // is on every page: `useMediaQuery(null)` adds no listener, so a bar whose
      // orientation is one word costs exactly what it cost before.
      expect(listen).not.toHaveBeenCalled();

      await render(<Settings orientation={{ xs: 'vertical', md: 'horizontal' }} />);

      expect(listen).toHaveBeenCalled();

      listen.mockRestore();
    });
  });

  describe('a bar with more tabs than room', () => {
    it('says nothing while every tab fits', async () => {
      const screen = await render(<Settings />);

      // The bar scrolls rather than wrapping, so it has to say when it is
      // scrolling — and, just as importantly, when it is not. A bar with a
      // faded end that goes nowhere is a bar that lies.
      expect(screen.getByRole('tablist').element()).toHaveAttribute('data-overflow', 'none');
    });

    it('says which way the tabs it cannot show went', async () => {
      const restore = clip();

      try {
        const screen = await render(<Settings />);
        const list = screen.getByRole('tablist').element();

        expect(list.scrollWidth).toBeGreaterThan(list.clientWidth);

        // Measured rather than declared: whether a bar overflows depends on the
        // room it was given, which no prop can answer.
        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'end');

        list.scrollTo({ left: 60, behavior: 'auto' });

        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'both');

        list.scrollTo({ left: list.scrollWidth, behavior: 'auto' });

        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'start');
      } finally {
        restore();
      }
    });

    it('fades only the end that still has something behind it', async () => {
      const restore = clip();

      try {
        const screen = await render(<Settings />);
        const list = screen.getByRole('tablist').element() as HTMLElement;

        // The lengths are physical because a CSS gradient is, and the state
        // above is logical because a reader is. This is the one place the two
        // meet, and left-to-right is where they agree.
        expect(list.style.getPropertyValue('--p-fade-left')).toBe('');
        expect(list.style.getPropertyValue('--p-fade-right')).toBe('var(--p-fade)');

        list.scrollTo({ left: list.scrollWidth, behavior: 'auto' });

        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'start');

        expect(list.style.getPropertyValue('--p-fade-left')).toBe('var(--p-fade)');
        expect(list.style.getPropertyValue('--p-fade-right')).toBe('');
      } finally {
        restore();
      }
    });

    it('leaves a vertical bar alone, which runs down the side and does not', async () => {
      const screen = await render(<Settings orientation="vertical" />);

      expect(screen.getByRole('tablist').element()).not.toHaveAttribute('data-overflow');
    });

    it('fades the ends of a right-to-left bar from the other side', async () => {
      const restore = clip();

      try {
        const screen = await render(
          <div dir="rtl">
            <Settings />
          </div>
        );
        const list = screen.getByRole('tablist').element() as HTMLElement;

        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'end');
        expect(list.style.getPropertyValue('--p-fade-left')).toBe('var(--p-fade)');
        expect(list.style.getPropertyValue('--p-fade-right')).toBe('');

        // Negative, because a right-to-left strip counts its scroll backwards.
        list.scrollTo({ left: -list.scrollWidth, behavior: 'auto' });

        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'start');
        expect(list.style.getPropertyValue('--p-fade-left')).toBe('');
        expect(list.style.getPropertyValue('--p-fade-right')).toBe('var(--p-fade)');
      } finally {
        restore();
      }
    });
  });

  describe('measuring the bar', () => {
    const frame = () => new Promise((resolve) => requestAnimationFrame(resolve));

    /** Counts the reads of the list's `scrollWidth` from here on. */
    function countScrollWidth(list: Element) {
      const read = Object.getOwnPropertyDescriptor(Element.prototype, 'scrollWidth')?.get;
      let reads = 0;
      const spy = vi.spyOn(Element.prototype, 'scrollWidth', 'get').mockImplementation(function (
        this: Element
      ) {
        if (this === list) {
          reads += 1;
        }

        return read?.call(this) ?? 0;
      });

      return {
        reads: () => reads,
        restore: () => spy.mockRestore()
      };
    }

    it('reads no layout when a parent renders and nothing in the bar changed', async () => {
      // Nothing chosen, so Base UI's indicator, which measures the list in its
      // own render, has nothing to measure, and every read left is the bar's.
      function Page({ note }: { note: string }) {
        return (
          <div>
            <p>{note}</p>
            <PlTabs value={null}>
              <PlTab value="account">Account</PlTab>
              <PlTab value="billing">Billing</PlTab>
            </PlTabs>
          </div>
        );
      }

      const screen = await render(<Page note="Draft" />);
      const list = screen.getByRole('tablist').element();

      // The first layout, and the observers' first report of it.
      await frame();
      await frame();

      const count = countScrollWidth(list);

      try {
        await screen.rerender(<Page note="Saved" />);
        await frame();
        await frame();

        await expect.element(screen.getByText('Saved')).toBeInTheDocument();
        expect(count.reads()).toBe(0);
      } finally {
        count.restore();
      }
    });

    it('measures again, before the frame is drawn, when a tab is added', async () => {
      const restore = clip();

      function Bar({ count }: { count: number }) {
        return (
          <PlTabs defaultValue="t0">
            {Array.from({ length: count }, (_, index) => (
              <PlTab key={index} value={`t${index}`}>
                Tab {index}
              </PlTab>
            ))}
          </PlTabs>
        );
      }

      try {
        const screen = await render(<Bar count={1} />);
        const list = screen.getByRole('tablist').element();

        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'none');

        await screen.rerender(<Bar count={3} />);

        // Not polled: the commit that added the tabs is the one that says so.
        expect(list).toHaveAttribute('data-overflow', 'end');
      } finally {
        restore();
      }
    });

    it('measures again when a tab is renamed', async () => {
      const style = document.createElement('style');

      // Tabs as wide as their labels, so a longer label is a wider strip.
      style.textContent =
        '[role="tablist"] { position: relative; display: flex; overflow-x: auto; width: 160px; }' +
        '[role="tab"] { flex: 0 0 auto; white-space: nowrap; }';
      document.head.append(style);

      function Bar({ label }: { label: string }) {
        return (
          <PlTabs defaultValue="a">
            <PlTab value="a">{label}</PlTab>
          </PlTabs>
        );
      }

      try {
        const screen = await render(<Bar label="Short" />);
        const list = screen.getByRole('tablist').element();

        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'none');

        await screen.rerender(<Bar label="A label far too long for a bar this narrow" />);

        expect(list).toHaveAttribute('data-overflow', 'end');
      } finally {
        style.remove();
      }
    });

    it('reads no style while the bar scrolls', async () => {
      const restore = clip();

      try {
        const screen = await render(<Settings />);
        const list = screen.getByRole('tablist').element() as HTMLElement;
        const scrolled = () =>
          new Promise((resolve) => list.addEventListener('scroll', resolve, { once: true }));

        let done = scrolled();

        list.scrollTo({ left: 60, behavior: 'auto' });
        await done;
        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'both');

        const style = vi.spyOn(window, 'getComputedStyle');

        try {
          done = scrolled();
          list.scrollTo({ left: 70, behavior: 'auto' });
          await done;
          await frame();

          // The direction is read when the bar is laid out. A scroll moves the
          // strip and never turns it round.
          expect(style.mock.calls.filter(([element]) => element === list)).toHaveLength(0);
          expect(list).toHaveAttribute('data-overflow', 'both');
        } finally {
          style.mockRestore();
        }
      } finally {
        restore();
      }
    });

    it('turns the fade round when the document does', async () => {
      const restore = clip();
      const root = document.documentElement;
      const was = root.getAttribute('dir');

      try {
        const screen = await render(<Settings />);
        const list = screen.getByRole('tablist').element() as HTMLElement;

        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'end');
        expect(list.style.getPropertyValue('--p-fade-right')).toBe('var(--p-fade)');

        root.setAttribute('dir', 'rtl');

        await expect.poll(() => list.style.getPropertyValue('--p-fade-left')).toBe('var(--p-fade)');
        expect(list.style.getPropertyValue('--p-fade-right')).toBe('');
      } finally {
        if (was === null) {
          root.removeAttribute('dir');
        } else {
          root.setAttribute('dir', was);
        }

        restore();
      }
    });
  });

  describe('the indicator', () => {
    const frame = () => new Promise((resolve) => requestAnimationFrame(resolve));

    /**
     * A bar whose tabs are as wide as their labels and laid out from the
     * start, across or down, and a list the tabs are measured from. No
     * component test loads CSS, and without these the tabs would sit wherever
     * an inline button does.
     */
    function lay() {
      const style = document.createElement('style');

      style.textContent =
        '[role="tablist"] { position: relative; display: flex; width: 400px; }' +
        '[role="tablist"][aria-orientation="vertical"] { flex-direction: column; align-items: flex-start; }' +
        '[role="tab"] { flex: 0 0 auto; white-space: nowrap; }';
      document.head.append(style);

      return () => style.remove();
    }

    /**
     * Whether the indicator is under `tab`: the offset and the width Base UI
     * wrote for it against the ones the tab has now, to the pixel. What the
     * stylesheet does with them is a `left` and a `width`.
     */
    function under(list: Element, tab: HTMLElement) {
      const indicator = list.querySelector<HTMLElement>('[role="presentation"]');
      const left = parseFloat(indicator?.style.getPropertyValue('--active-tab-left') ?? '');
      const width = parseFloat(indicator?.style.getPropertyValue('--active-tab-width') ?? '');

      return (
        Math.abs(left - tab.offsetLeft) <= 1 &&
        Math.abs(width - tab.getBoundingClientRect().width) <= 1
      );
    }

    /**
     * Waits for the indicator to be under `tab`, and then for the observers'
     * first reports to have been delivered. A report still on its way when a
     * test changes something would move the indicator by itself, and hide
     * whether the change did.
     */
    async function settle(list: Element, tab: HTMLElement) {
      await expect.poll(() => under(list, tab)).toBe(true);
      await frame();
      await frame();
    }

    interface Knobs {
      value: string;
      label: string;
      width: number;
      dir: 'ltr' | 'rtl';
      note: string;
    }

    /** Changes what the page around the bar renders, as a parent would. */
    let change: (next: Partial<Knobs>) => void = () => {};

    /**
     * A page holding a bar, three tabs and a line of its own, all of it driven
     * from one piece of state the way a parent drives a bar. The direction is
     * said twice, as the docs ask of a subtree that runs the other way: on the
     * box, and to the `PlassProvider` around it.
     */
    function Page() {
      const [knobs, setKnobs] = useState<Knobs>({
        value: 'c',
        label: 'A',
        width: 40,
        dir: 'ltr',
        note: 'Draft'
      });

      useEffect(() => {
        change = (next) => setKnobs((previous) => ({ ...previous, ...next }));
      }, []);

      return (
        <PlassProvider direction={knobs.dir}>
          <div dir={knobs.dir}>
            <p>{knobs.note}</p>
            <PlTabs value={knobs.value}>
              <PlTab value="a" style={{ minWidth: knobs.width }}>
                {knobs.label}
              </PlTab>
              <PlTab value="b">Beta</PlTab>
              <PlTab value="c">Gamma</PlTab>
            </PlTabs>
          </div>
        </PlassProvider>
      );
    }

    async function renderPage() {
      const screen = await render(<Page />);
      const list = screen.getByRole('tablist').element();
      const tab = (name: string) => screen.getByRole('tab', { name }).element() as HTMLElement;

      await settle(list, tab('Gamma'));

      return { screen, list, tab };
    }

    it('reads no layout when its parent renders and nothing in the bar moved', async () => {
      const restore = lay();
      const { list } = await renderPage();
      const rect = vi.spyOn(Element.prototype, 'getBoundingClientRect');

      try {
        await committed(() => change({ note: 'Saved' }));
        await frame();

        // Base UI's indicator measures the list while it renders, so a new
        // indicator on every render of the bar was a layout read on every
        // render of whatever the bar is in.
        expect(rect.mock.contexts.filter((context) => context === list)).toHaveLength(0);
      } finally {
        rect.mockRestore();
        restore();
      }
    });

    it('moves at once when the value changes', async () => {
      const restore = lay();

      try {
        const { list, tab } = await renderPage();

        await committed(() => change({ value: 'a' }));

        expect(under(list, tab('A'))).toBe(true);
      } finally {
        restore();
      }
    });

    it('follows the chosen tab when a tab before it is renamed', async () => {
      const restore = lay();

      try {
        const { list, tab } = await renderPage();
        const before = tab('Gamma').offsetLeft;

        await committed(() => change({ label: 'A label a good deal longer' }));
        // Base UI's observer of the tabs, which reports on the frame after the
        // tab grew: a measurement taken while the bar renders reads the label
        // that was there before.
        await frame();
        await frame();

        expect(tab('Gamma').offsetLeft).toBeGreaterThan(before);
        expect(under(list, tab('Gamma'))).toBe(true);
      } finally {
        restore();
      }
    });

    it('follows the chosen tab when a tab before it changes size', async () => {
      const restore = lay();

      try {
        const { list, tab } = await renderPage();
        const before = tab('Gamma').offsetLeft;

        await committed(() => change({ width: 160 }));
        await frame();
        await frame();

        expect(tab('Gamma').offsetLeft).toBeGreaterThan(before);
        expect(under(list, tab('Gamma'))).toBe(true);
      } finally {
        restore();
      }
    });

    it('follows the chosen tab when the bar is resized', async () => {
      const restore = lay();

      try {
        const { list, tab } = await renderPage();

        await committed(() => change({ dir: 'rtl' }));

        const before = tab('Gamma').offsetLeft;

        // Right to left, the tabs are laid out from the right-hand edge, so a
        // narrower bar moves every one of them without resizing any.
        (list as HTMLElement).style.width = '300px';
        await frame();
        await frame();

        expect(tab('Gamma').offsetLeft).toBeLessThan(before);
        expect(under(list, tab('Gamma'))).toBe(true);
      } finally {
        restore();
      }
    });

    it('stays under the chosen tab while the bar scrolls', async () => {
      const restore = clip();

      try {
        const screen = await render(<Settings defaultValue="billing" />);
        const list = screen.getByRole('tablist').element() as HTMLElement;
        const tab = screen.getByRole('tab', { name: 'Billing' }).element() as HTMLElement;

        await settle(list, tab);

        const scrolled = new Promise((resolve) =>
          list.addEventListener('scroll', resolve, { once: true })
        );

        list.scrollTo({ left: list.scrollWidth, behavior: 'auto' });
        await scrolled;
        await frame();

        // Measured in the list's own coordinates, which a scroll does not move.
        expect(list.scrollLeft).toBeGreaterThan(0);
        expect(under(list, tab)).toBe(true);
      } finally {
        restore();
      }
    });

    it('moves at once when the bar turns round', async () => {
      const restore = lay();

      try {
        const { list, tab } = await renderPage();
        const before = tab('Gamma').offsetLeft;

        await committed(() => change({ dir: 'rtl' }));

        expect(tab('Gamma').offsetLeft).not.toBe(before);
        expect(under(list, tab('Gamma'))).toBe(true);

        await committed(() => change({ dir: 'ltr' }));

        expect(tab('Gamma').offsetLeft).toBe(before);
        expect(under(list, tab('Gamma'))).toBe(true);
      } finally {
        restore();
      }
    });

    it.each(['horizontal', 'vertical'] as const)(
      'moves a %s bar when the document turns round',
      async (orientation) => {
        const restore = lay();
        const root = document.documentElement;
        const was = root.getAttribute('dir');

        try {
          // Down the side, the tabs are as wide as their labels here, so a turn
          // moves them across without resizing one, as it does a bar that runs
          // across.
          const screen = await render(
            <PlTabs orientation={orientation} value="c">
              <PlTab value="a">Alpha</PlTab>
              <PlTab value="b">Beta</PlTab>
              <PlTab value="c">Gamma</PlTab>
            </PlTabs>
          );
          const list = screen.getByRole('tablist').element();
          const tab = screen.getByRole('tab', { name: 'Gamma' }).element() as HTMLElement;

          await settle(list, tab);

          const before = tab.offsetLeft;

          root.setAttribute('dir', 'rtl');
          await frame();
          await frame();

          expect(tab.offsetLeft).not.toBe(before);
          expect(under(list, tab)).toBe(true);
        } finally {
          if (was === null) {
            root.removeAttribute('dir');
          } else {
            root.setAttribute('dir', was);
          }

          restore();
        }
      }
    );
  });

  describe('the wheel', () => {
    /**
     * A wheel event of the kind a mouse produces, dispatched at the bar. It is
     * untrusted, so the browser scrolls nothing of its own accord — what moves
     * the bar is the component.
     */
    function wheel(element: HTMLElement, init: WheelEventInit) {
      const event = new WheelEvent('wheel', { bubbles: true, cancelable: true, ...init });

      element.dispatchEvent(event);

      return event;
    }

    /**
     * Counts the `wheel` listeners put on an element that may cancel the wheel,
     * the kind the browser has to wait for before it scrolls the page, and the
     * `wheel` listeners taken off it again.
     */
    function watchWheelListeners() {
      const add = vi.spyOn(EventTarget.prototype, 'addEventListener');
      const remove = vi.spyOn(EventTarget.prototype, 'removeEventListener');

      return {
        added: (element: Element) =>
          add.mock.calls.filter(
            ([type, , options], index) =>
              add.mock.contexts[index] === element &&
              type === 'wheel' &&
              !(typeof options === 'object' && options.passive === true)
          ).length,
        removed: (element: Element) =>
          remove.mock.calls.filter(
            ([type], index) => remove.mock.contexts[index] === element && type === 'wheel'
          ).length,
        restore() {
          add.mockRestore();
          remove.mockRestore();
        }
      };
    }

    it('puts no listener that could hold the page on a bar whose tabs all fit', async () => {
      const listeners = watchWheelListeners();

      try {
        const screen = await render(<Settings />);
        const list = screen.getByRole('tablist').element();

        // A listener that may cancel the wheel is one the browser waits for
        // before it scrolls the page, and a bar that fits has nothing to take
        // the wheel for.
        expect(list).toHaveAttribute('data-overflow', 'none');
        expect(listeners.added(list)).toBe(0);
      } finally {
        listeners.restore();
      }
    });

    it('takes the wheel once the tabs outgrow the bar, and lets it go once they fit again', async () => {
      const listeners = watchWheelListeners();
      let restore: (() => void) | undefined;

      try {
        const screen = await render(<Settings />);
        const list = screen.getByRole('tablist').element() as HTMLElement;

        expect(listeners.added(list)).toBe(0);

        restore = clip();

        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'end');
        await expect.poll(() => listeners.added(list)).toBe(1);
        expect(wheel(list, { deltaY: 120 }).defaultPrevented).toBe(true);

        restore();
        restore = undefined;
        list.scrollLeft = 0;

        await expect.element(screen.getByRole('tablist')).toHaveAttribute('data-overflow', 'none');
        await expect.poll(() => listeners.removed(list)).toBe(1);
        expect(wheel(list, { deltaY: 120 }).defaultPrevented).toBe(false);
      } finally {
        restore?.();
        listeners.restore();
      }
    });

    it('moves the bar along on a vertical wheel', async () => {
      const restore = clip();

      try {
        const screen = await render(<Settings />);
        const list = screen.getByRole('tablist').element() as HTMLElement;

        // A mouse has one wheel and it points down the page, which is the one
        // direction a tab bar does not run in.
        expect(wheel(list, { deltaY: 120 }).defaultPrevented).toBe(true);
        await expect.poll(() => list.scrollLeft).toBe(120);
      } finally {
        restore();
      }
    });

    it('moves a right-to-left bar along, reading the direction once a gesture', async () => {
      const restore = clip();
      const read = vi.spyOn(window, 'getComputedStyle');

      try {
        const screen = await render(
          <PlassProvider direction="rtl">
            <div dir="rtl">
              <Settings />
            </div>
          </PlassProvider>
        );
        const list = screen.getByRole('tablist').element() as HTMLElement;

        read.mockClear();

        for (let notch = 0; notch < 3; notch += 1) {
          wheel(list, { deltaY: 40 });
        }

        expect(read.mock.calls.filter(([element]) => element === list)).toHaveLength(1);
        await expect.poll(() => list.scrollLeft).toBe(-120);
      } finally {
        read.mockRestore();
        restore();
      }
    });

    it('keeps the wheel once the bar has reached its end', async () => {
      const restore = clip();

      try {
        const screen = await render(<Settings />);
        const list = screen.getByRole('tablist').element() as HTMLElement;

        list.scrollLeft = list.scrollWidth - list.clientWidth;

        expect(wheel(list, { deltaY: 120 }).defaultPrevented).toBe(true);
        expect(list).toHaveClass('overscroll-x-contain');
      } finally {
        restore();
      }
    });

    it('gives it back at the end when the page is left to chain', async () => {
      const restore = clip();

      try {
        const screen = await render(<Settings overscroll="auto" />);
        const list = screen.getByRole('tablist').element() as HTMLElement;

        list.scrollLeft = list.scrollWidth - list.clientWidth;

        expect(wheel(list, { deltaY: 120 }).defaultPrevented).toBe(false);
        expect(list).not.toHaveClass('overscroll-x-contain');
      } finally {
        restore();
      }
    });

    it('leaves a bar whose tabs all fit alone', async () => {
      const screen = await render(<Settings />);
      const list = screen.getByRole('tablist').element() as HTMLElement;

      // Not a scroller, so not a place on the page the reader cannot scroll
      // past. This is the whole of what keeps the containment honest.
      expect(wheel(list, { deltaY: 120 }).defaultPrevented).toBe(false);
    });

    it('leaves the wheel alone when it is turned off', async () => {
      const restore = clip();

      try {
        const screen = await render(<Settings wheel={false} />);
        const list = screen.getByRole('tablist').element() as HTMLElement;

        expect(wheel(list, { deltaY: 120 }).defaultPrevented).toBe(false);
        expect(list.scrollLeft).toBe(0);
      } finally {
        restore();
      }
    });

    it('leaves a bar that runs down the side alone', async () => {
      const screen = await render(<Settings orientation="vertical" />);
      const list = screen.getByRole('tablist').element() as HTMLElement;

      // There the wheel already runs the way the bar does, and the browser's
      // own scrolling does the whole job.
      expect(wheel(list, { deltaY: 120 }).defaultPrevented).toBe(false);
      expect(list).not.toHaveClass('overscroll-x-contain');
    });
  });
});
