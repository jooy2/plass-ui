import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

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
    '[role="tablist"] { display: flex; overflow-x: auto; width: 160px; }' +
    '[role="tab"] { flex: 0 0 auto; width: 120px; }';
  document.head.append(style);

  return () => style.remove();
}

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
  });
});
