import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlMeter } from 'plass-ui';

/** The element carrying the role, which Base UI puts on the whole component. */
function meter(): HTMLElement {
  return document.querySelector<HTMLElement>('[role="meter"]')!;
}

/** The groove: the last `<div>` under the root, after the optional head row. */
function track(root = '.meter-under-test'): HTMLElement {
  return document.querySelector<HTMLElement>(`${root} > div:last-of-type`)!;
}

/** How much of the groove is filled, as a percentage string. */
function fill(): string {
  return (track().firstElementChild as HTMLElement).style.width;
}

/** The `--p-fill` slot the wrapper wrote, which is the family it landed on. */
function family(): string {
  return document
    .querySelector<HTMLElement>('.meter-under-test')!
    .style.getPropertyValue('--p-fill');
}

describe('PlMeter', () => {
  describe('the quantity', () => {
    it('fills the groove by the fraction of the range', async () => {
      await render(<PlMeter className="meter-under-test" value={40} />);

      expect(fill()).toBe('40%');
    });

    it('reads the fraction against the range it was given', async () => {
      await render(<PlMeter className="meter-under-test" value={3} min={0} max={4} />);

      expect(fill()).toBe('75%');
    });

    it('clamps a value outside the range rather than overflowing', async () => {
      // `value` usually arrives from a division somewhere, and a bar drawn 140%
      // wide is a worse bug than one sitting full.
      await render(<PlMeter className="meter-under-test" value={140} />);

      expect(fill()).toBe('100%');

      await render(<PlMeter className="meter-under-test second" value={-20} />);

      expect((track('.second').firstElementChild as HTMLElement).style.width).toBe('0%');
    });

    it('sits at nothing when the range is empty, and says so', async () => {
      await render(<PlMeter className="meter-under-test" value={5} min={10} max={10} showValue />);

      // A caller's mistake rather than a state. What is announced is the
      // clamped value, so the number read out and the bar drawn agree.
      expect(fill()).toBe('0%');
      expect(meter().getAttribute('aria-valuenow')).toBe('10');
    });
  });

  describe('the value it writes out', () => {
    it('is a percentage of the range when nothing said otherwise', async () => {
      const screen = await render(
        <PlMeter className="meter-under-test" value={3} max={4} showValue />
      );

      await expect.element(screen.getByText('75%')).toBeInTheDocument();
    });

    it('takes `format` when the number means something', async () => {
      const screen = await render(
        <PlMeter
          className="meter-under-test"
          value={2}
          max={8}
          showValue
          format={{ style: 'unit', unit: 'gigabyte' }}
        />
      );

      // The formatted value, not `25%`: a caller who passed `format` has said
      // what the number is.
      await expect.element(screen.getByText(/2/)).toBeInTheDocument();
      expect(document.body.textContent).not.toContain('25%');
    });

    it('draws nothing at all unless it was asked to', async () => {
      await render(<PlMeter className="meter-under-test" value={30} showValue={false} />);

      expect(
        document.querySelector('.meter-under-test')!.querySelector('span.tabular-nums')
      ).toBeNull();
    });
  });

  describe('thresholds', () => {
    it('takes the component colour while the value is under all of them', async () => {
      await render(
        <PlMeter
          className="meter-under-test"
          value={20}
          thresholds={[
            { from: 75, color: 'warning' },
            { from: 90, color: 'danger' }
          ]}
        />
      );

      expect(family()).toBe('var(--plass-primary-fill)');
    });

    it('takes the highest band at or below the value', async () => {
      await render(
        <PlMeter
          className="meter-under-test"
          value={80}
          thresholds={[
            { from: 75, color: 'warning' },
            { from: 90, color: 'danger' }
          ]}
        />
      );

      expect(family()).toBe('var(--plass-warning-fill)');

      await render(
        <PlMeter
          className="meter-under-test second"
          value={95}
          thresholds={[
            { from: 75, color: 'warning' },
            { from: 90, color: 'danger' }
          ]}
        />
      );

      expect(
        document.querySelector<HTMLElement>('.second')!.style.getPropertyValue('--p-fill')
      ).toBe('var(--plass-danger-fill)');
    });

    it('does not care what order the bands were written in', async () => {
      await render(
        <PlMeter
          className="meter-under-test"
          value={95}
          thresholds={[
            { from: 90, color: 'danger' },
            { from: 75, color: 'warning' }
          ]}
        />
      );

      expect(family()).toBe('var(--plass-danger-fill)');
    });

    it('enters a band exactly at its own value', async () => {
      await render(
        <PlMeter
          className="meter-under-test"
          value={75}
          thresholds={[{ from: 75, color: 'warning' }]}
        />
      );

      expect(family()).toBe('var(--plass-warning-fill)');
    });
  });

  describe('accessibility', () => {
    it('is a meter and not a progress bar', async () => {
      await render(<PlMeter className="meter-under-test" value={40} />);

      // A meter reports a quantity that is already known; a progress bar
      // reports something advancing, and the two are announced differently.
      expect(meter().getAttribute('role')).toBe('meter');
    });

    it('carries the range as well as the value', async () => {
      await render(<PlMeter className="meter-under-test" value={3} min={1} max={5} />);

      expect(meter().getAttribute('aria-valuenow')).toBe('3');
      expect(meter().getAttribute('aria-valuemin')).toBe('1');
      expect(meter().getAttribute('aria-valuemax')).toBe('5');
    });

    it('says what the value reads as rather than leaving it a bare number', async () => {
      await render(<PlMeter className="meter-under-test" value={3} max={4} />);

      // "3" out of a range that is not 0–100 is a percentage a browser would
      // guess wrong, so the text is written out.
      expect(meter().getAttribute('aria-valuetext')).toBe('75%');
    });

    it('is named by its label', async () => {
      await render(<PlMeter className="meter-under-test" value={40} label="Disk used" />);

      const named = document.getElementById(meter().getAttribute('aria-labelledby')!);

      expect(named?.textContent).toBe('Disk used');
    });

    it('claims no name it does not have', async () => {
      await render(<PlMeter className="meter-under-test" value={40} />);

      expect(meter().getAttribute('aria-labelledby')).toBeNull();
    });

    it('clamps the value it announces to the range it drew', async () => {
      await render(<PlMeter className="meter-under-test" value={140} />);

      // The bar sits full and the announced value is 100, rather than a
      // screen reader hearing a number the bar could not draw.
      expect(fill()).toBe('100%');
      expect(meter().getAttribute('aria-valuenow')).toBe('100');
    });
  });
});
