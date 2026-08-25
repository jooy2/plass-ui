import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlBadge } from 'plass-ui';

describe('PlBadge', () => {
  describe('the count', () => {
    it('draws what it is given', async () => {
      const screen = await render(<PlBadge content={3} />);

      await expect.element(screen.getByText('3')).toBeInTheDocument();
    });

    it('caps a number past `max` and adds a plus', async () => {
      const screen = await render(<PlBadge content={128} />);

      await expect.element(screen.getByText('99+')).toBeInTheDocument();
    });

    it('takes a cap of its own', async () => {
      const screen = await render(<PlBadge content={12} max={9} />);

      await expect.element(screen.getByText('9+')).toBeInTheDocument();
    });

    it('leaves a word alone, because it cannot know how to truncate one', async () => {
      const screen = await render(<PlBadge content="New" max={2} />);

      await expect.element(screen.getByText('New')).toBeInTheDocument();
    });

    it('reflects a changed count on re-render', async () => {
      const screen = await render(<PlBadge content={3} />);

      await screen.rerender(<PlBadge content={4} />);

      await expect.element(screen.getByText('4')).toBeInTheDocument();
      expect(screen.getByText('3').query()).toBeNull();
    });
  });

  describe('zero and emptiness', () => {
    it('says nothing at all for a count of zero', async () => {
      const screen = await render(<PlBadge content={0} />);

      expect(screen.getByText('0').query()).toBeNull();
    });

    it('shows it when asked', async () => {
      const screen = await render(<PlBadge content={0} showZero />);

      await expect.element(screen.getByText('0')).toBeInTheDocument();
    });

    it('hides itself from the accessibility tree when it has nothing to report', async () => {
      await render(<PlBadge className="badge-under-test" />);

      expect(document.querySelector('.badge-under-test')).toHaveAttribute('aria-hidden', 'true');
    });
  });

  describe('the dot', () => {
    it('draws no digits but still reads the count', async () => {
      const screen = await render(<PlBadge dot content={7} className="badge-under-test" />);

      await expect.element(screen.getByText('7')).toBeInTheDocument();
      expect(document.querySelector('.badge-under-test')).not.toHaveAttribute('aria-hidden');
    });

    it('is what an empty badge with `dot` becomes', async () => {
      await render(<PlBadge dot className="badge-under-test" />);

      expect(document.querySelector('.badge-under-test')).not.toHaveAttribute('aria-hidden');
    });
  });

  describe('the anchor', () => {
    it('wraps whatever it is pinned to', async () => {
      const screen = await render(
        <PlBadge content={2}>
          <button type="button">Inbox</button>
        </PlBadge>
      );

      await expect.element(screen.getByRole('button', { name: 'Inbox' })).toBeInTheDocument();
      await expect.element(screen.getByText('2')).toBeInTheDocument();
    });

    it('lays out inline with no children', async () => {
      await render(<PlBadge content="Beta" className="badge-under-test" />);

      expect(document.querySelector('.badge-under-test')).toHaveClass('relative');
    });
  });

  describe('the accessible name', () => {
    it('reads the sentence rather than the number when one is given', async () => {
      const screen = await render(<PlBadge content={3} label="3 unread notifications" />);

      await expect.element(screen.getByText('3 unread notifications')).toBeInTheDocument();
    });

    it('says nothing when it is invisible', async () => {
      const screen = await render(<PlBadge invisible content={3} className="badge-under-test" />);

      expect(screen.getByText('3').query()).toBeNull();
      expect(document.querySelector('.badge-under-test')).toHaveAttribute('aria-hidden', 'true');
    });
  });

  describe('rendering', () => {
    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlBadge content={1} className="my-own-class" />);

      expect(screen.getByText('1').element().closest('.my-own-class')).not.toBeNull();
    });

    it('forwards unknown props to the marker', async () => {
      const screen = await render(<PlBadge content={1} data-testid="marker" />);

      expect(screen.getByTestId('marker').element()).toBeInTheDocument();
    });
  });
});
