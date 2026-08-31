import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlStat } from 'plass-ui';

const box = (className: string) => document.querySelector(`.${className}`)!;

/** The change, which is the only part of a stat with an opinion in it. */
const change = () =>
  document.querySelector('.stat-under-test .flex.items-baseline > span:nth-child(2)');

describe('PlStat', () => {
  describe('the figure', () => {
    it('draws the label, the value and the description', async () => {
      const screen = await render(
        <PlStat label="Revenue" value="$48,120" description="vs last month" />
      );

      await expect.element(screen.getByText('Revenue')).toBeInTheDocument();
      await expect.element(screen.getByText('$48,120')).toBeInTheDocument();
      await expect.element(screen.getByText('vs last month')).toBeInTheDocument();
    });

    it('takes a node for the value, already formatted', async () => {
      const screen = await render(
        <PlStat
          label="Revenue"
          value={new Intl.NumberFormat('en-GB', { style: 'currency', currency: 'GBP' }).format(
            48120
          )}
        />
      );

      // How a figure is written is the page's decision, and `Intl` already
      // makes it.
      await expect.element(screen.getByText('£48,120.00')).toBeInTheDocument();
    });

    it('leaves out what it was not given', async () => {
      await render(<PlStat value="12" className="stat-under-test" />);

      expect(box('stat-under-test').children).toHaveLength(1);
    });
  });

  describe('the change', () => {
    it('writes a rise with a sign', async () => {
      await render(<PlStat value="$48,120" change={12.4} className="stat-under-test" />);

      expect(change()!.textContent).toBe('+12.4%');
    });

    it('writes a fall with its own', async () => {
      await render(<PlStat value="$48,120" change={-3.1} className="stat-under-test" />);

      expect(change()!.textContent).toBe('-3.1%');
    });

    it('is good news when it went the way it should', async () => {
      await render(<PlStat value="$48,120" change={12.4} className="stat-under-test" />);

      expect(change()!.className).toContain('success');
    });

    it('is bad news when it did not', async () => {
      await render(<PlStat value="$48,120" change={-3.1} className="stat-under-test" />);

      expect(change()!.className).toContain('danger');
    });

    it('reads the meaning rather than the sign', async () => {
      await render(
        <PlStat value="4.2%" change={12.4} improvesWhen="down" className="stat-under-test" />
      );

      // Churn going up is not good news, and a green arrow on it is a dashboard
      // lying to somebody.
      expect(change()!.className).toContain('danger');
    });

    it('is neither when nothing moved', async () => {
      await render(<PlStat value="$48,120" change={0} className="stat-under-test" />);

      expect(change()!.className).toContain('muted');
      expect(change()!.querySelector('svg')).toBeNull();
    });

    it('draws an arrow for a movement', async () => {
      await render(<PlStat value="$48,120" change={12.4} className="stat-under-test" />);

      expect(change()!.querySelector('svg')).toBeTruthy();
    });

    it('takes its own words instead of a percentage', async () => {
      await render(
        <PlStat
          value="1,204"
          change={8}
          changeLabel="+1,204 this week"
          className="stat-under-test"
        />
      );

      expect(change()!.textContent).toBe('+1,204 this week');
    });

    it('draws none when there is none', async () => {
      await render(<PlStat value="$48,120" className="stat-under-test" />);

      expect(change()).toBeNull();
    });
  });

  describe('loading', () => {
    it('draws a skeleton where the figure will be', async () => {
      await render(<PlStat label="Revenue" value="$48,120" loading className="stat-under-test" />);

      expect(box('stat-under-test').textContent).not.toContain('$48,120');
    });

    it('holds the change back with it', async () => {
      await render(<PlStat value="$48,120" change={12.4} loading className="stat-under-test" />);

      // A movement beside a figure nobody has yet is a movement of nothing.
      expect(change()).toBeNull();
    });
  });

  describe('the surface', () => {
    it('draws none', async () => {
      await render(<PlStat value="$48,120" className="stat-under-test" />);

      // A figure sits in a card or in a row of them, and a sheet inside a sheet
      // is two sheets.
      expect(box('stat-under-test').className).not.toContain('border');
    });
  });

  describe('caller styling', () => {
    it('keeps a caller-supplied class alongside its own', async () => {
      await render(<PlStat value="12" className="my-own-class" />);

      expect(box('my-own-class')).toHaveClass('flex');
    });

    it('passes native attributes through', async () => {
      await render(<PlStat value="12" id="revenue" aria-label="Revenue" />);

      expect(document.getElementById('revenue')).toHaveAttribute('aria-label', 'Revenue');
    });
  });
});
