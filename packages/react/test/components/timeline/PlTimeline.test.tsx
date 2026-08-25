import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlTimeline, PlTimelineItem } from 'plass-ui';

/** The status each step resolved to, in order. */
function statuses(): (string | null)[] {
  return [...document.querySelectorAll('.timeline-under-test li')].map((item) =>
    item.getAttribute('data-status')
  );
}

const steps = [
  <PlTimelineItem key="a" title="Ordered" />,
  <PlTimelineItem key="b" title="Packed" />,
  <PlTimelineItem key="c" title="Shipped" />,
  <PlTimelineItem key="d" title="Delivered" />
];

describe('PlTimeline', () => {
  describe('the sequence', () => {
    it('renders an ordered list of steps', async () => {
      const screen = await render(<PlTimeline>{steps}</PlTimeline>);

      expect(screen.getByRole('list').element().tagName).toBe('OL');
      expect(screen.getByRole('listitem').all()).toHaveLength(4);
    });

    it('says `role="list"` out loud, because a reset takes it away', async () => {
      const screen = await render(<PlTimeline>{steps}</PlTimeline>);

      expect(screen.getByRole('list').element()).toHaveAttribute('role', 'list');
    });

    it('renders every title', async () => {
      const screen = await render(<PlTimeline>{steps}</PlTimeline>);

      await expect.element(screen.getByText('Shipped')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlTimeline className="my-own-class">{steps}</PlTimeline>);

      expect(screen.getByRole('list').element()).toHaveClass('my-own-class');
    });
  });

  describe('active', () => {
    it('leaves every step upcoming when it is not given', async () => {
      await render(<PlTimeline className="timeline-under-test">{steps}</PlTimeline>);

      expect(statuses()).toEqual(['upcoming', 'upcoming', 'upcoming', 'upcoming']);
    });

    it('splits the sequence at the index it is given', async () => {
      await render(
        <PlTimeline className="timeline-under-test" active={2}>
          {steps}
        </PlTimeline>
      );

      expect(statuses()).toEqual(['complete', 'complete', 'current', 'upcoming']);
    });

    it('marks the whole sequence done at the item count', async () => {
      await render(
        <PlTimeline className="timeline-under-test" active={4}>
          {steps}
        </PlTimeline>
      );

      expect(statuses()).toEqual(['complete', 'complete', 'complete', 'complete']);
    });

    it('moves on re-render', async () => {
      const screen = await render(
        <PlTimeline className="timeline-under-test" active={1}>
          {steps}
        </PlTimeline>
      );

      await screen.rerender(
        <PlTimeline className="timeline-under-test" active={3}>
          {steps}
        </PlTimeline>
      );

      expect(statuses()).toEqual(['complete', 'complete', 'complete', 'current']);
    });

    it('marks the current step for a screen reader', async () => {
      await render(
        <PlTimeline className="timeline-under-test" active={1}>
          {steps}
        </PlTimeline>
      );

      const current = document.querySelector('.timeline-under-test li[aria-current]');

      expect(current).toHaveAttribute('aria-current', 'step');
      expect(current?.textContent).toContain('Packed');
    });
  });

  describe('an item', () => {
    it('overrides the computed status with one of its own', async () => {
      await render(
        <PlTimeline className="timeline-under-test" active={3}>
          <PlTimelineItem title="Ordered" />
          <PlTimelineItem title="Packed" status="upcoming" />
          <PlTimelineItem title="Shipped" />
          <PlTimelineItem title="Delivered" />
        </PlTimeline>
      );

      expect(statuses()).toEqual(['complete', 'upcoming', 'complete', 'current']);
    });

    it('draws whatever is put in its bullet', async () => {
      const screen = await render(
        <PlTimeline>
          <PlTimelineItem title="Ordered" bullet="1" />
        </PlTimeline>
      );

      await expect.element(screen.getByText('1')).toBeInTheDocument();
    });

    it('renders its meta and its body', async () => {
      const screen = await render(
        <PlTimeline>
          <PlTimelineItem title="Shipped" meta="Tuesday">
            Left the warehouse at 09:12.
          </PlTimelineItem>
        </PlTimeline>
      );

      await expect.element(screen.getByText('Tuesday')).toBeInTheDocument();
      await expect.element(screen.getByText('Left the warehouse at 09:12.')).toBeInTheDocument();
    });

    it('renders on its own, outside a timeline', async () => {
      const screen = await render(<PlTimelineItem title="Alone" />);

      await expect.element(screen.getByText('Alone')).toBeInTheDocument();
    });

    it('counts only the steps that are actually on the page', async () => {
      await render(
        <PlTimeline className="timeline-under-test" active={1}>
          <PlTimelineItem title="Ordered" />
          {false}
          <PlTimelineItem title="Shipped" />
        </PlTimeline>
      );

      expect(statuses()).toEqual(['complete', 'current']);
    });
  });
});
