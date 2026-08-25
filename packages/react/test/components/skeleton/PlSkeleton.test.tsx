import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlSkeleton } from 'plass-ui';

describe('PlSkeleton', () => {
  describe('shape', () => {
    it('draws one bar for a single line', async () => {
      await render(<PlSkeleton className="skeleton-under-test" />);

      const root = document.querySelector('.skeleton-under-test');

      expect(root?.children).toHaveLength(0);
      expect(root).toHaveClass('h-[0.8125rem]');
    });

    it('stacks bars for several lines and draws the last one short', async () => {
      await render(<PlSkeleton className="skeleton-under-test" lines={3} />);

      const bars = document.querySelectorAll('.skeleton-under-test > div');

      expect(bars).toHaveLength(3);
      expect(bars[0]).toHaveClass('w-full');
      expect(bars[2]).toHaveClass('w-3/5');
    });

    it('goes round for a circle, at the control diameter', async () => {
      await render(<PlSkeleton className="skeleton-under-test" shape="circle" size="lg" />);

      const root = document.querySelector('.skeleton-under-test');

      expect(root).toHaveClass('rounded-full');
      expect(root).toHaveClass('h-12');
      expect(root).toHaveClass('w-12');
    });

    it('takes a block height it was not given a height for', async () => {
      await render(<PlSkeleton className="skeleton-under-test" shape="rect" />);

      expect(document.querySelector('.skeleton-under-test')).toHaveClass('h-20');
    });

    it('drops that height once one is given', async () => {
      await render(<PlSkeleton className="skeleton-under-test" shape="rect" height={240} />);

      const root = document.querySelector('.skeleton-under-test') as HTMLElement;

      expect(root).not.toHaveClass('h-20');
      expect(root.style.height).toBe('240px');
    });
  });

  describe('width and height', () => {
    it('takes a number as pixels and a string as any CSS length', async () => {
      await render(<PlSkeleton className="skeleton-under-test" width={120} height="2rem" />);

      const root = document.querySelector('.skeleton-under-test') as HTMLElement;

      expect(root.style.width).toBe('120px');
      expect(root.style.height).toBe('2rem');
    });
  });

  describe('the sweep', () => {
    it('is on by default', async () => {
      await render(<PlSkeleton className="skeleton-under-test" />);

      expect(document.querySelector('.skeleton-under-test')).toHaveClass('plass-skeleton');
    });

    it('comes off when asked', async () => {
      await render(<PlSkeleton className="skeleton-under-test" animated={false} />);

      expect(document.querySelector('.skeleton-under-test')).not.toHaveClass('plass-skeleton');
    });
  });

  describe('what a screen reader hears', () => {
    it('says nothing without a label', async () => {
      const screen = await render(<PlSkeleton className="skeleton-under-test" />);

      expect(document.querySelector('.skeleton-under-test')).toHaveAttribute('aria-hidden', 'true');
      expect(screen.getByRole('status').query()).toBeNull();
    });

    it('becomes a live status with one', async () => {
      const screen = await render(<PlSkeleton label="Loading invoices" />);

      const status = screen.getByRole('status', { name: 'Loading invoices' });

      await expect.element(status).toBeInTheDocument();
      expect(status.element()).toHaveAttribute('aria-busy', 'true');
    });
  });

  describe('rendering', () => {
    it('takes a different element', async () => {
      const screen = await render(
        <PlSkeleton label="Loading" render={<span />} className="skeleton-under-test" />
      );

      expect(screen.getByRole('status').element().tagName).toBe('SPAN');
    });

    it('forwards unknown props to the element', async () => {
      const screen = await render(<PlSkeleton label="Loading" data-testid="placeholder" />);

      expect(screen.getByTestId('placeholder').element()).toBeInTheDocument();
    });
  });
});
