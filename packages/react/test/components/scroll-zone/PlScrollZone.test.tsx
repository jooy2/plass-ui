import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlScrollZone } from 'plass-ui';

/*
 * No component test loads CSS, and a scroller with no `overflow` cannot be
 * scrolled — so nothing here asserts a scroll offset. What is observable is
 * every decision that leads to one: the track's own layout, which is written
 * inline because `lines` is a number the caller picked; how far the component
 * asks to be scrolled, read off a spy on the element's own `scrollBy`; and
 * whether it thinks there is anywhere left to go, which it works out from
 * `scrollWidth` — a measurement the browser makes whether or not the box clips.
 *
 * The children are given widths so the strip genuinely overflows the page.
 */
const cards = Array.from({ length: 6 }, (_, index) => (
  <div key={index} style={{ width: 300 }}>
    Card {index + 1}
  </div>
));

/** The scrolling box: the focusable one, wherever the buttons have put it. */
function scroller(screen: Awaited<ReturnType<typeof render>>) {
  return screen
    .getByTestId('zone')
    .element()
    .querySelector<HTMLElement>(':scope > [tabindex="0"]') as HTMLElement;
}

/** And the grid inside it. */
function track(screen: Awaited<ReturnType<typeof render>>) {
  return scroller(screen).firstElementChild as HTMLElement;
}

/**
 * The two declarations a scroll offset depends on, since no component test
 * loads CSS and a box that does not clip cannot be scrolled at all. Returns the
 * undo, which every test that calls this owes a `finally`.
 */
function clip() {
  const style = document.createElement('style');

  style.textContent = '[data-testid="zone"] > [tabindex="0"] { overflow-x: auto; width: 400px; }';
  document.head.append(style);

  return () => style.remove();
}

describe('PlScrollZone', () => {
  describe('rendering', () => {
    it('renders every child', async () => {
      const screen = await render(<PlScrollZone data-testid="zone">{cards}</PlScrollZone>);

      await expect.element(screen.getByText('Card 1')).toBeInTheDocument();
      await expect.element(screen.getByText('Card 6')).toBeInTheDocument();
    });

    it('lays the children out in one line running across', async () => {
      const screen = await render(<PlScrollZone data-testid="zone">{cards}</PlScrollZone>);

      expect(track(screen).style.gridAutoFlow).toBe('column');
      expect(track(screen).style.gridTemplateRows).toBe('repeat(1, auto)');
    });

    it('takes a second line', async () => {
      const screen = await render(
        <PlScrollZone lines={2} data-testid="zone">
          {cards}
        </PlScrollZone>
      );

      expect(track(screen).style.gridTemplateRows).toBe('repeat(2, auto)');
    });

    it('turns the layout on its side when it runs down the page', async () => {
      const screen = await render(
        <PlScrollZone orientation="vertical" lines={3} data-testid="zone">
          {cards}
        </PlScrollZone>
      );

      expect(track(screen).style.gridAutoFlow).toBe('row');
      expect(track(screen).style.gridTemplateColumns).toBe('repeat(3, minmax(0px, 1fr))');
    });

    it('writes spacing as a length on the house spacing scale', async () => {
      const screen = await render(
        <PlScrollZone spacing={6} data-testid="zone">
          {cards}
        </PlScrollZone>
      );

      expect(track(screen).style.gap).toBe('1.5rem');
    });

    it('names the scrollable region', async () => {
      const screen = await render(
        <PlScrollZone label="Categories" data-testid="zone">
          {cards}
        </PlScrollZone>
      );

      await expect.element(screen.getByRole('group', { name: 'Categories' })).toBeInTheDocument();
    });

    it('leaves the strip reachable from the keyboard', async () => {
      const screen = await render(<PlScrollZone data-testid="zone">{cards}</PlScrollZone>);

      expect(scroller(screen)).toHaveAttribute('tabindex', '0');
    });

    it('draws no sheet of its own', async () => {
      const screen = await render(<PlScrollZone data-testid="zone">{cards}</PlScrollZone>);
      const element = screen.getByTestId('zone').element() as HTMLElement;

      // A shelf is a way of laying children out, and the children arrive with
      // their own surfaces. Only the ring slot reaches it.
      expect(element.style.getPropertyValue('--p-ring')).toBe('var(--plass-primary-ring)');
      expect(element.style.getPropertyValue('--p-elev')).toBe('');
    });

    it('keeps caller-supplied class names alongside its own, and forwards the rest', async () => {
      const screen = await render(
        <PlScrollZone className="my-own-class" id="shelf" data-testid="zone">
          {cards}
        </PlScrollZone>
      );

      expect(screen.getByTestId('zone').element()).toHaveClass('my-own-class');
      expect(screen.getByTestId('zone').element()).toHaveAttribute('id', 'shelf');
    });
  });

  describe('the buttons', () => {
    it('offers the one that has somewhere to go', async () => {
      // Overlaid, because that is the placement where a button with nowhere to
      // go is gone rather than holding an empty lane. The lane is the test at
      // the end of the block below.
      const screen = await render(
        <PlScrollZone buttonPlacement="overlay" data-testid="zone">
          {cards}
        </PlScrollZone>
      );

      await expect.element(screen.getByRole('button', { name: 'Next' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Previous' }).query()).toBeNull();
    });

    it('draws both from the first paint when it is told to', async () => {
      const screen = await render(
        <PlScrollZone buttons="always" data-testid="zone">
          {cards}
        </PlScrollZone>
      );

      await expect.element(screen.getByRole('button', { name: 'Previous' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Next' })).toBeEnabled();
    });

    it('draws none at all when it is told to', async () => {
      const screen = await render(
        <PlScrollZone buttons="none" data-testid="zone">
          {cards}
        </PlScrollZone>
      );

      await expect.element(screen.getByText('Card 1')).toBeInTheDocument();
      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('draws neither while everything fits', async () => {
      const screen = await render(
        <PlScrollZone data-testid="zone">
          <div>Alone</div>
        </PlScrollZone>
      );

      await expect.element(screen.getByText('Alone')).toBeInTheDocument();
      expect(screen.getByRole('button').query()).toBeNull();
    });

    it('takes names of its own', async () => {
      const screen = await render(
        <PlScrollZone buttons="always" previousLabel="Earlier" nextLabel="Later" data-testid="zone">
          {cards}
        </PlScrollZone>
      );

      await expect.element(screen.getByRole('button', { name: 'Later' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Earlier' })).toBeInTheDocument();
    });
  });

  describe('where the buttons sit', () => {
    // Overlaid, the strip keeps every pixel of its box and an item passes under
    // a button. Inline, the scroller stops where the button starts, so an item
    // is cut off at its edge rather than half-hidden behind it.
    it('puts them beside the strip by default', async () => {
      const screen = await render(
        <PlScrollZone buttons="always" data-testid="zone">
          {cards}
        </PlScrollZone>
      );
      const root = screen.getByTestId('zone').element();

      await expect.element(screen.getByRole('button', { name: 'Next' })).toBeInTheDocument();
      // A button, the scroller, and the other button — the strip stops where
      // the control starts.
      expect(root.children).toHaveLength(3);
      expect(root.children[1]).toBe(scroller(screen));
      expect(
        root.children[2].contains(screen.getByRole('button', { name: 'Next' }).element())
      ).toBe(true);
    });

    it('overlays them when it is asked to', async () => {
      const screen = await render(
        <PlScrollZone buttonPlacement="overlay" data-testid="zone">
          {cards}
        </PlScrollZone>
      );
      const root = screen.getByTestId('zone').element();

      await expect.element(screen.getByRole('button', { name: 'Next' })).toBeInTheDocument();
      // The scroller and the overlay the buttons are in, and nothing else.
      expect(root.children).toHaveLength(2);
      expect(root.children[1]).toHaveClass('absolute');
    });

    /*
     * The one thing the note at the top of this file rules out everywhere else:
     * a strip that has genuinely been scrolled. Every other test here reads the
     * buttons at rest, so nothing was checking the half of the component that
     * only happens once the box has moved — and a zone whose buttons never
     * change is a zone that scrolls once and then lies about where it is.
     *
     * It needs real `overflow`, which no component test loads CSS for, and the
     * overlay, which is the placement where a button that cannot move is gone
     * rather than invisible.
     */
    it('changes which button it offers as the strip moves', async () => {
      const restore = clip();

      try {
        const screen = await render(
          <PlScrollZone buttonPlacement="overlay" data-testid="zone">
            {cards}
          </PlScrollZone>
        );
        const box = scroller(screen);

        // Six 300px cards in 400px: there is a long way forward and no way back.
        await expect.element(screen.getByRole('button', { name: 'Next' })).toBeInTheDocument();
        expect(screen.getByRole('button', { name: 'Previous' }).query()).toBeNull();

        box.scrollTo({ left: 300, behavior: 'auto' });

        // Both, now — the only position where the zone offers a choice.
        await expect.element(screen.getByRole('button', { name: 'Previous' })).toBeInTheDocument();
        await expect.element(screen.getByRole('button', { name: 'Next' })).toBeInTheDocument();

        box.scrollTo({ left: box.scrollWidth - box.clientWidth, behavior: 'auto' });

        // And the mirror of the first assertion, which is the one that fails if
        // the scroll never reaches the measurement.
        await expect.element(screen.getByRole('button', { name: 'Previous' })).toBeInTheDocument();
        await expect.element(screen.getByRole('button', { name: 'Next' })).not.toBeInTheDocument();
      } finally {
        restore();
      }
    });

    // A lane that came and went would resize the strip under the pointer that
    // had just reached the end of it.
    it('keeps the lane of a button that has nowhere to go', async () => {
      const screen = await render(
        <PlScrollZone buttonPlacement="inline" data-testid="zone">
          {cards}
        </PlScrollZone>
      );
      const root = screen.getByTestId('zone').element();

      await expect.element(screen.getByRole('button', { name: 'Next' })).toBeInTheDocument();
      // The button is still in the markup, holding its lane open — and `inert`,
      // which is what keeps it out of the tab order and off the accessibility
      // tree while it is invisible.
      expect(root.children[0]).toHaveClass('invisible');
      expect(root.children[0]).toHaveAttribute('inert');
      expect(screen.getByRole('button', { name: 'Previous' }).element().closest('[inert]')).toBe(
        root.children[0]
      );
    });

    it('runs the strip down the page with the buttons above and below it', async () => {
      const screen = await render(
        <PlScrollZone
          orientation="vertical"
          buttonPlacement="inline"
          buttons="always"
          data-testid="zone"
        >
          {cards}
        </PlScrollZone>
      );

      expect(screen.getByTestId('zone').element()).toHaveClass('flex-col');
      expect(screen.getByTestId('zone').element().children).toHaveLength(3);
    });
  });

  describe('the wheel', () => {
    /**
     * A wheel event of the kind a mouse produces, dispatched at the strip. It
     * is untrusted, so the browser scrolls nothing of its own accord — what
     * moves the box is the component, which is the whole point of the block.
     */
    function wheel(element: HTMLElement, init: WheelEventInit) {
      const event = new WheelEvent('wheel', { bubbles: true, cancelable: true, ...init });

      element.dispatchEvent(event);

      return event;
    }

    it('scrolls the strip along on a vertical wheel', async () => {
      const restore = clip();

      try {
        const screen = await render(<PlScrollZone data-testid="zone">{cards}</PlScrollZone>);
        const box = scroller(screen);

        expect(wheel(box, { deltaY: 120 }).defaultPrevented).toBe(true);
        await expect.poll(() => box.scrollLeft).toBe(120);
      } finally {
        restore();
      }
    });

    it('counts a wheel that arrives in lines rather than in pixels', async () => {
      const restore = clip();

      try {
        const screen = await render(<PlScrollZone data-testid="zone">{cards}</PlScrollZone>);
        const box = scroller(screen);

        // Three lines, which is one notch of a wheel in the browsers that
        // report them.
        wheel(box, { deltaY: 3, deltaMode: 1 });

        await expect.poll(() => box.scrollLeft).toBe(48);
      } finally {
        restore();
      }
    });

    it('leaves a sideways gesture to the browser', async () => {
      const restore = clip();

      try {
        const screen = await render(<PlScrollZone data-testid="zone">{cards}</PlScrollZone>);
        const box = scroller(screen);

        // A trackpad, a tilt wheel, or Shift held down: the browser already
        // scrolls the strip with these, and a second handler would double them.
        expect(wheel(box, { deltaX: 120 }).defaultPrevented).toBe(false);
        expect(box.scrollLeft).toBe(0);
      } finally {
        restore();
      }
    });

    it('gives the wheel back once the strip has reached its end', async () => {
      const restore = clip();

      try {
        const screen = await render(<PlScrollZone data-testid="zone">{cards}</PlScrollZone>);
        const box = scroller(screen);

        // Backwards from the start, and forwards from the end: both of them
        // belong to the page, or a shelf would be a hole a reader scrolls into.
        expect(wheel(box, { deltaY: -120 }).defaultPrevented).toBe(false);

        box.scrollTo({ left: box.scrollWidth - box.clientWidth, behavior: 'auto' });

        await expect.poll(() => wheel(box, { deltaY: 120 }).defaultPrevented).toBe(false);
      } finally {
        restore();
      }
    });

    it('leaves the wheel alone when it is turned off', async () => {
      const restore = clip();

      try {
        const screen = await render(
          <PlScrollZone wheel={false} data-testid="zone">
            {cards}
          </PlScrollZone>
        );
        const box = scroller(screen);

        expect(wheel(box, { deltaY: 120 }).defaultPrevented).toBe(false);
        expect(box.scrollLeft).toBe(0);
      } finally {
        restore();
      }
    });

    it('leaves a strip that runs down the page alone', async () => {
      const screen = await render(
        <PlScrollZone orientation="vertical" data-testid="zone">
          {cards}
        </PlScrollZone>
      );

      // A vertical wheel over a vertical strip is the browser's own, and it
      // does the whole job — the overscroll, the momentum and the chaining.
      expect(wheel(scroller(screen), { deltaY: 120 }).defaultPrevented).toBe(false);
    });
  });

  describe('pressing one', () => {
    it('moves to the next child along', async () => {
      const screen = await render(<PlScrollZone data-testid="zone">{cards}</PlScrollZone>);
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');

      await screen.getByRole('button', { name: 'Next' }).click();

      // The second card starts 300px plus the default gutter along, and that is
      // the offset the component measured rather than one it assumed.
      expect(scrollBy).toHaveBeenCalledWith(expect.objectContaining({ left: 308 }));
    });

    it('moves by more than one when it is asked to', async () => {
      const screen = await render(
        <PlScrollZone step={2} data-testid="zone">
          {cards}
        </PlScrollZone>
      );
      const scrollBy = vi.spyOn(scroller(screen), 'scrollBy');

      await screen.getByRole('button', { name: 'Next' }).click();

      expect(scrollBy).toHaveBeenCalledWith(expect.objectContaining({ left: 616 }));
    });

    it('moves by everything on screen in page mode', async () => {
      const screen = await render(
        <PlScrollZone mode="page" data-testid="zone">
          {cards}
        </PlScrollZone>
      );
      const box = scroller(screen);
      const scrollBy = vi.spyOn(box, 'scrollBy');

      await screen.getByRole('button', { name: 'Next' }).click();

      expect(scrollBy).toHaveBeenCalledWith(expect.objectContaining({ left: box.clientWidth }));
    });

    it('still moves on a tap in hold mode, rather than doing nothing', async () => {
      const screen = await render(
        <PlScrollZone mode="hold" data-testid="zone">
          {cards}
        </PlScrollZone>
      );
      const scrollBy = vi.spyOn(scroller(screen), 'scrollBy');

      await screen.getByRole('button', { name: 'Next' }).click();

      await expect.poll(() => scrollBy.mock.calls.length).toBeGreaterThan(0);
    });
  });
});
