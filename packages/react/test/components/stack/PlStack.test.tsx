import { page } from 'vitest/browser';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlStack } from 'plass-ui';

/** The stack's own offset wrappers, in document order. */
function wrappers() {
  return [
    ...(document.querySelector('.stack-under-test') as HTMLElement).children
  ] as HTMLElement[];
}

/** The box inside a wrapper that carries the depth. */
function depths() {
  return wrappers().map((wrapper) => wrapper.firstElementChild as HTMLElement);
}

/*
 * An array rather than a fragment, and the difference is the component's own
 * rule: `React.Children.toArray` counts a fragment as one child, so a stack is
 * a pile of whatever it was handed at the top level. That is also how to keep
 * two things together as one item — group them.
 */
const three = ['One', 'Two', 'Three'].map((label) => <span key={label}>{label}</span>);

let initialViewport: [number, number];

beforeAll(() => {
  initialViewport = [window.innerWidth, window.innerHeight];
});

afterAll(async () => {
  await page.viewport(...initialViewport);
});

describe('PlStack', () => {
  it('renders what it was given, whatever that is', async () => {
    const screen = await render(<PlStack>{three}</PlStack>);

    await expect.element(screen.getByText('One')).toBeInTheDocument();
    await expect.element(screen.getByText('Three')).toBeInTheDocument();
  });

  describe('the flow', () => {
    it('overlaps with a negative margin rather than an offset', async () => {
      await render(<PlStack className="stack-under-test">{three}</PlStack>);

      const root = document.querySelector('.stack-under-test') as HTMLElement;

      // The whole reason this is a layout and not a translate: a translated pile
      // is laid out one item wide, draws outside its own box, and every element
      // after it is placed against a width the reader never sees.
      expect(root.className).toContain('margin-inline-start:calc(var(--p-overlap)*-1)');
      expect(root.className).not.toContain('translate');
      expect(root.style.getPropertyValue('--p-overlap')).toBe('0.875rem');
    });

    it('takes an overlap of its own, in pixels or as a length', async () => {
      const screen = await render(
        <PlStack className="stack-under-test" overlap={12}>
          {three}
        </PlStack>
      );

      const root = document.querySelector('.stack-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-overlap')).toBe('12px');

      await screen.rerender(
        <PlStack className="stack-under-test" overlap="1.5rem">
          {three}
        </PlStack>
      );

      expect(root.style.getPropertyValue('--p-overlap')).toBe('1.5rem');
    });

    it('runs down the page when it is told to', async () => {
      await render(
        <PlStack className="stack-under-test" direction="vertical">
          {three}
        </PlStack>
      );

      const root = document.querySelector('.stack-under-test') as HTMLElement;

      expect(root).toHaveClass('flex-col');
      expect(root.className).toContain('margin-block-start:calc(var(--p-overlap)*-1)');
    });

    it('multiplies the drop by the index on the axis the flow does not run on', async () => {
      await render(
        <PlStack className="stack-under-test" direction="diagonal" drop={10}>
          {three}
        </PlStack>
      );

      const root = document.querySelector('.stack-under-test') as HTMLElement;

      // A flow only overlaps on the axis it flows along, so one fixed
      // `margin-block-start` in a row would put every item at the same height.
      //
      // Read computed rather than off the inline string: the engine
      // re-serialises `calc(10px * 2)` as `calc(20px)`, and how a browser spells
      // arithmetic is not what this is about.
      expect(root).toHaveClass('flex-row');
      expect(wrappers().map((wrapper) => getComputedStyle(wrapper).marginBlockStart)).toEqual([
        '0px',
        '10px',
        '20px'
      ]);
    });

    it('lets the drop fall back to the overlap, which is a fan of the same step', async () => {
      await render(
        <PlStack className="stack-under-test" direction="diagonal" overlap={10}>
          {three}
        </PlStack>
      );

      expect(getComputedStyle(wrappers()[2]).marginBlockStart).toBe('20px');
    });

    it('leaves the other two directions flat', async () => {
      await render(<PlStack className="stack-under-test">{three}</PlStack>);

      expect(wrappers().every((wrapper) => wrapper.style.marginBlockStart === '')).toBe(true);
    });
  });

  describe('a responsive direction', () => {
    it('turns at the rung it was named', async () => {
      await page.viewport(500, 600);

      await render(
        <PlStack className="stack-under-test" direction={{ xs: 'vertical', md: 'horizontal' }}>
          {three}
        </PlStack>
      );

      const root = document.querySelector('.stack-under-test') as HTMLElement;

      // Resolved in JavaScript rather than in CSS because the direction picks
      // *which margin axis* each item takes — different declarations rather
      // than one value a slot could carry.
      await expect.poll(() => root.classList.contains('flex-col')).toBe(true);
      expect(root.className).toContain('margin-block-start:calc(var(--p-overlap)*-1)');

      await page.viewport(900, 600);

      await expect.poll(() => root.classList.contains('flex-row')).toBe(true);
      expect(root.className).toContain('margin-inline-start:calc(var(--p-overlap)*-1)');
    });
  });

  describe('the order', () => {
    it('states the stacking order rather than inheriting the DOM’s', async () => {
      await render(<PlStack className="stack-under-test">{three}</PlStack>);

      // Stated so the other reading is available at all, and so neither one
      // depends on what the browser happens to do with paint order.
      expect(wrappers().map((wrapper) => wrapper.style.zIndex)).toEqual(['1', '2', '3']);
    });

    it('turns it round for a deck, whose top card is the one you read first', async () => {
      await render(
        <PlStack className="stack-under-test" front="first">
          {three}
        </PlStack>
      );

      expect(wrappers().map((wrapper) => wrapper.style.zIndex)).toEqual(['3', '2', '1']);
    });
  });

  describe('depth', () => {
    it('costs nothing while nobody asked for it', async () => {
      await render(<PlStack className="stack-under-test">{three}</PlStack>);

      expect(depths().every((box) => box.getAttribute('style') === null)).toBe(true);
    });

    it('compounds away from whichever end is in front', async () => {
      await render(
        <PlStack className="stack-under-test" scaleStep={0.5} opacityStep={0.5}>
          {three}
        </PlStack>
      );

      // The front item is always at full size: the step counts backwards from
      // it, so turning `front` round does not also have to turn this round.
      expect(depths().map((box) => box.style.scale)).toEqual(['0.25', '0.5', '1']);
      expect(depths().map((box) => box.style.opacity)).toEqual(['0.25', '0.5', '1']);
    });

    it('counts from the other end for a deck', async () => {
      await render(
        <PlStack className="stack-under-test" front="first" scaleStep={0.5}>
          {three}
        </PlStack>
      );

      expect(depths().map((box) => box.style.scale)).toEqual(['1', '0.5', '0.25']);
    });

    it('keeps the depth off the box an entrance would animate', async () => {
      await render(
        <PlStack className="stack-under-test" scaleStep={0.9}>
          {three}
        </PlStack>
      );

      // Two boxes per item, and the second is not spare: every keyframe in the
      // library that grows or zooms writes the standalone `scale` property, and
      // on one box it would overwrite the depth on its first frame.
      for (const wrapper of wrappers()) {
        expect(wrapper.style.scale).toBe('');
        expect((wrapper.firstElementChild as HTMLElement).style.scale).not.toBe('');
      }
    });
  });

  describe('max, total and overflow', () => {
    it('draws every item when nobody capped it', async () => {
      await render(<PlStack className="stack-under-test">{three}</PlStack>);

      expect(wrappers()).toHaveLength(3);
    });

    it('stops at max and hands the rest to overflow as a number', async () => {
      const screen = await render(
        <PlStack className="stack-under-test" max={2} overflow={(n) => <span>+{n}</span>}>
          {three}
        </PlStack>
      );

      expect(wrappers()).toHaveLength(3);
      await expect.element(screen.getByText('+1')).toBeInTheDocument();
      expect(screen.getByText('Three').query()).toBeNull();
    });

    it('counts against total when it was handed only the first few', async () => {
      const screen = await render(
        <PlStack className="stack-under-test" total={11} overflow={(n) => <span>+{n}</span>}>
          {three}
        </PlStack>
      );

      await expect.element(screen.getByText('+8')).toBeInTheDocument();
    });

    it('draws no overflow item when nothing overflowed', async () => {
      await render(
        <PlStack className="stack-under-test" max={3} overflow={(n) => <span>+{n}</span>}>
          {three}
        </PlStack>
      );

      expect(wrappers()).toHaveLength(3);
    });

    it('leaves the count out entirely when it was given no way to draw one', async () => {
      await render(
        <PlStack className="stack-under-test" max={2}>
          {three}
        </PlStack>
      );

      expect(wrappers()).toHaveLength(2);
    });
  });

  describe('ring', () => {
    it('is off until it is asked for', async () => {
      const screen = await render(<PlStack className="stack-under-test">{three}</PlStack>);

      expect(
        screen.getByText('One').element().closest('.stack-under-test')?.className
      ).not.toContain('ring-2');
    });

    it('lands on the element the caller passed, three boxes down', async () => {
      const screen = await render(
        <PlStack className="stack-under-test" ring>
          <span data-testid="mine">Ada</span>
        </PlStack>
      );

      const root = document.querySelector('.stack-under-test') as HTMLElement;

      // A fixed depth, and the honest answer: copying a class onto the children
      // instead would stop working the moment one of them is a tooltip, a
      // fragment, or somebody else's `.map()`.
      expect(root.className).toContain('[&>*>*>*]:ring-2');
      expect(root.className).toContain('[&>*>*>*]:ring-(--plass-surface)');

      // Three boxes down is the element the caller wrote: the offset wrapper,
      // the depth box, and then theirs. Which is why the ring takes *their*
      // shape — wrap an avatar in something square and the ring is square.
      expect(depths()[0].firstElementChild).toBe(screen.getByTestId('mine').element());
    });
  });
});
