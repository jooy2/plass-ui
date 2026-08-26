import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlGrid, PlGridItem } from 'plass-ui';

/** The inline slots a grid or an item wrote, as a plain object. */
function slots(selector: string): Record<string, string> {
  const element = document.querySelector<HTMLElement>(selector);
  const written: Record<string, string> = {};

  for (const name of Array.from(element?.style ?? [])) {
    if (name.startsWith('--p-')) written[name] = element!.style.getPropertyValue(name).trim();
  }

  return written;
}

describe('PlGrid', () => {
  describe('columns', () => {
    it('is twelve unless it is told otherwise', async () => {
      await render(<PlGrid className="grid-under-test" />);

      expect(slots('.grid-under-test')['--p-cols-xs']).toBe('12');
    });

    it('takes the count it was given', async () => {
      await render(<PlGrid className="grid-under-test" columns={24} />);

      expect(slots('.grid-under-test')['--p-cols-xs']).toBe('24');
    });

    it('rounds a fraction and never divides by zero', async () => {
      await render(<PlGrid className="grid-under-test" columns={0} />);

      expect(slots('.grid-under-test')['--p-cols-xs']).toBe('1');
    });

    it('writes only the breakpoints it was named, plus the baseline', async () => {
      await render(<PlGrid className="grid-under-test" columns={{ md: 6 }} />);

      const written = slots('.grid-under-test');

      expect(written['--p-cols-md']).toBe('6');
      // The `xs` entry is the documented default rather than the CSS fallback:
      // narrowing one breakpoint must not silently drop every other one.
      expect(written['--p-cols-xs']).toBe('12');
      expect(written['--p-cols-lg']).toBeUndefined();
    });
  });

  describe('spacing', () => {
    it('is two steps of the spacing scale by default', async () => {
      await render(<PlGrid className="grid-under-test" />);

      const written = slots('.grid-under-test');

      expect(written['--p-gap-x-xs']).toBe('0.5rem');
      expect(written['--p-gap-y-xs']).toBe('0.5rem');
    });

    it('takes fractions of a step', async () => {
      await render(<PlGrid className="grid-under-test" spacing={1.5} />);

      expect(slots('.grid-under-test')['--p-gap-x-xs']).toBe('0.375rem');
    });

    it('lets one axis be set on its own', async () => {
      await render(<PlGrid className="grid-under-test" spacing={4} rowSpacing={8} />);

      const written = slots('.grid-under-test');

      expect(written['--p-gap-x-xs']).toBe('1rem');
      expect(written['--p-gap-y-xs']).toBe('2rem');
    });
  });

  describe('the row', () => {
    it('wraps by default', async () => {
      await render(<PlGrid className="grid-under-test" />);

      expect(document.querySelector('.grid-under-test')).toHaveClass('flex-wrap');
    });

    it('runs on past the end when it is told not to', async () => {
      await render(<PlGrid className="grid-under-test" wrap={false} />);

      expect(document.querySelector('.grid-under-test')).toHaveClass('flex-nowrap');
    });

    it('takes the alignment it was given', async () => {
      await render(
        <PlGrid
          className="grid-under-test"
          justify="space-between"
          alignItems="center"
          alignContent="end"
        />
      );

      const element = document.querySelector('.grid-under-test');

      expect(element).toHaveClass('justify-between');
      expect(element).toHaveClass('items-center');
      expect(element).toHaveClass('content-end');
    });

    it('renders as whatever it was told to', async () => {
      await render(<PlGrid className="grid-under-test" render={<ul />} />);

      expect(document.querySelector('.grid-under-test')?.tagName).toBe('UL');
    });
  });
});

describe('PlGridItem', () => {
  it('writes only the breakpoints it was named', async () => {
    await render(<PlGridItem className="item-under-test" span={{ xs: 12, md: 6 }} />);

    const written = slots('.item-under-test');

    expect(written['--p-span-xs']).toBe('12');
    expect(written['--p-span-md']).toBe('6');
    expect(written['--p-span-lg']).toBeUndefined();
  });

  it('never spans less than one column', async () => {
    await render(<PlGridItem className="item-under-test" span={0} />);

    expect(slots('.item-under-test')['--p-span-xs']).toBe('1');
  });

  it('allows an offset of nothing', async () => {
    await render(<PlGridItem className="item-under-test" offset={0} />);

    expect(slots('.item-under-test')['--p-offset-xs']).toBe('0');
  });

  it('takes an alignment of its own', async () => {
    await render(<PlGridItem className="item-under-test" alignSelf="end" />);

    expect(document.querySelector('.item-under-test')).toHaveClass('self-end');
  });

  it('renders as whatever it was told to', async () => {
    await render(<PlGridItem className="item-under-test" render={<article />} />);

    expect(document.querySelector('.item-under-test')?.tagName).toBe('ARTICLE');
  });

  it('renders what it was given', async () => {
    const screen = await render(
      <PlGridItem>
        <span>A cell</span>
      </PlGridItem>
    );

    await expect.element(screen.getByText('A cell')).toBeInTheDocument();
  });
});
