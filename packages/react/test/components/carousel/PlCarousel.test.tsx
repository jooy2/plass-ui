import * as React from 'react';
import { commands, userEvent } from 'vitest/browser';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCarousel } from 'plass-ui';
import { emulateMedia } from '../../support/media';

/** Three slides with something findable in each. */
const slides = [<p key="a">Alpha</p>, <p key="b">Bravo</p>, <p key="c">Charlie</p>];

describe('PlCarousel', () => {
  describe('rendering', () => {
    it('renders a named carousel region', async () => {
      const screen = await render(<PlCarousel label="Gallery">{slides}</PlCarousel>);

      await expect.element(screen.getByRole('region', { name: 'Gallery' })).toBeInTheDocument();
    });

    it('wraps every top-level child in a slide of its own', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      await expect.element(screen.getByRole('group', { name: 'Slide 1 of 3' })).toBeInTheDocument();
      await expect.element(screen.getByRole('group', { name: 'Slide 3 of 3' })).toBeInTheDocument();
    });

    it('keeps every slide in the document, so nothing is unreachable', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      await expect.element(screen.getByText('Alpha')).toBeInTheDocument();
      await expect.element(screen.getByText('Charlie')).toBeInTheDocument();
    });

    it('never hides an off-screen slide from a screen reader', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      // A slide can hold a link, and an `aria-hidden` subtree that is still in
      // the tab order is the exact shape of the bug where a keyboard reader
      // lands somewhere their screen reader refuses to describe.
      expect(screen.getByRole('group', { name: 'Slide 3 of 3' }).element()).not.toHaveAttribute(
        'aria-hidden'
      );
    });

    it('reflects a changed set of slides on re-render', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      await screen.rerender(
        <PlCarousel>
          <p>Delta</p>
        </PlCarousel>
      );

      await expect.element(screen.getByText('Delta')).toBeInTheDocument();
      expect(screen.getByText('Alpha').query()).toBeNull();
    });

    it('keeps the slides it had mounted when one is added at the front', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);
      const before = ['Alpha', 'Bravo', 'Charlie'].map((text) => screen.getByText(text).element());

      await screen.rerender(<PlCarousel>{[<p key="new">Delta</p>, ...slides]}</PlCarousel>);

      await expect.element(screen.getByRole('group', { name: 'Slide 4 of 4' })).toBeInTheDocument();

      // A slide that was remounted is a new `<p>`, and whatever state a video or
      // a form inside it held went with the old one.
      const after = ['Alpha', 'Bravo', 'Charlie'].map((text) => screen.getByText(text).element());

      expect(after.every((element, index) => element === before[index])).toBe(true);
    });

    it('names each slide through slideLabel', async () => {
      const screen = await render(
        <PlCarousel slideLabel={(index, count) => `${index}/${count}`}>{slides}</PlCarousel>
      );

      await expect.element(screen.getByRole('group', { name: '2/3' })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<PlCarousel className="my-own-class">{slides}</PlCarousel>);

      expect(screen.getByRole('region').element()).toHaveClass('my-own-class');
    });
  });

  describe('the chrome', () => {
    it('draws arrows and dots by default', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      await expect
        .element(screen.getByRole('button', { name: 'Previous slide' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Next slide' })).toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toBeInTheDocument();
    });

    it('gives each dot a 24px press target around the dot it draws', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      const dot = screen.getByRole('button', { name: 'Slide 2 of 3' }).element();

      // Nothing loads Tailwind here, so the target is read off its classes, and
      // the drawn dot is the element inside it.
      expect(dot).toHaveClass('h-6', 'min-w-6');
      expect(dot.firstElementChild).toHaveClass('h-1.5', 'w-1.5', 'rounded-full');
      expect(dot.firstElementChild).toHaveAttribute('aria-hidden', 'true');
    });

    it('drops them when it is asked to', async () => {
      const screen = await render(
        <PlCarousel arrows={false} indicators={false}>
          {slides}
        </PlCarousel>
      );

      expect(screen.getByRole('button', { name: 'Next slide' }).query()).toBeNull();
      expect(screen.getByRole('button', { name: 'Slide 2 of 3' }).query()).toBeNull();
    });

    it('has nothing to steer with a single slide', async () => {
      const screen = await render(
        <PlCarousel>
          <p>Only</p>
        </PlCarousel>
      );

      expect(screen.getByRole('button', { name: 'Next slide' }).query()).toBeNull();
    });
  });

  describe('autoPlay', () => {
    /** Long enough for three turns of a 200ms interval. */
    const aWhile = () => new Promise((resolve) => setTimeout(resolve, 700));

    const current = (screen: Awaited<ReturnType<typeof render>>) =>
      screen.container.querySelector('button[aria-current="true"]')?.getAttribute('aria-label');

    // Every test here is about the timer, and a pointer over the carousel stops
    // it. The runner leaves the pointer wherever the last file pressed
    // something, and a carousel rendered under it is handed a `pointerenter`
    // that nobody performed, so it starts out paused and never moves.
    beforeEach(async () => {
      await commands.parkPointer();
    });

    it('advances on its own', async () => {
      const screen = await render(
        <PlCarousel autoPlay interval={200}>
          {slides}
        </PlCarousel>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }), { timeout: 2000 })
        .toHaveAttribute('aria-current', 'true');
    });

    it('holds still while the focus is inside it', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCarousel autoPlay interval={200} onValueChange={onValueChange}>
          {slides}
        </PlCarousel>
      );

      (screen.getByRole('group', { name: 'Carousel' }).element() as HTMLElement).focus();

      // The turns are counted rather than the slide read at the end: three turns
      // of three slides also end where they began. A slow machine can take the
      // first turn before the focus arrives, so what is held is the slide the
      // focus found.
      const held = current(screen);

      onValueChange.mockClear();
      await aWhile();

      expect(onValueChange).not.toHaveBeenCalled();
      expect(current(screen)).toBe(held);
    });

    it('does not start for a reader who asked for reduced motion', async () => {
      await emulateMedia({ reducedMotion: 'reduce' });

      try {
        const onValueChange = vi.fn();
        const screen = await render(
          <PlCarousel autoPlay interval={200} onValueChange={onValueChange}>
            {slides}
          </PlCarousel>
        );

        await aWhile();

        // Not one turn from the render on, which a slide read at the end could
        // not tell from three.
        expect(onValueChange).not.toHaveBeenCalled();
        expect(current(screen)).toBe('Slide 1 of 3');

        // It starts stopped rather than being unable to start: the button says
        // so, and pressing it is the reader asking for the motion anyway.
        await screen.getByRole('button', { name: 'Start slide show' }).click();
        await commands.parkPointer();

        await expect
          .poll(() => onValueChange.mock.calls.length, { timeout: 2000 })
          .toBeGreaterThan(0);
      } finally {
        await emulateMedia({ reducedMotion: 'no-preference' });
      }
    });

    it('holds still while the tab is in the background', async () => {
      Object.defineProperty(document, 'hidden', { configurable: true, get: () => true });

      try {
        const onValueChange = vi.fn();
        const screen = await render(
          <PlCarousel autoPlay interval={200} onValueChange={onValueChange}>
            {slides}
          </PlCarousel>
        );

        await aWhile();

        expect(onValueChange).not.toHaveBeenCalled();
        expect(current(screen)).toBe('Slide 1 of 3');
      } finally {
        // The document's own getter, on its prototype, answers again.
        delete (document as { hidden?: boolean }).hidden;
      }
    });

    it('holds the slide for a whole interval once the tab is back', async () => {
      const interval = 600;
      const turns: number[] = [];
      const onValueChange = () => turns.push(performance.now());

      await render(
        <PlCarousel autoPlay interval={interval} onValueChange={onValueChange}>
          {slides}
        </PlCarousel>
      );

      const started = performance.now();

      Object.defineProperty(document, 'hidden', { configurable: true, get: () => true });

      try {
        document.dispatchEvent(new Event('visibilitychange'));
        // Back most of an interval after the one it went into the background
        // in started, so an interval that ran on behind the tab would turn it
        // almost at once.
        await new Promise((resolve) =>
          setTimeout(resolve, Math.max(0, started + interval - 100 - performance.now()))
        );
      } finally {
        delete (document as { hidden?: boolean }).hidden;
      }

      turns.length = 0;

      const shownAt = performance.now();

      document.dispatchEvent(new Event('visibilitychange'));
      await expect.poll(() => turns.length, { timeout: interval * 4 }).toBeGreaterThan(0);

      // The margin is for the clock the browser rounds.
      expect(turns[0] - shownAt).toBeGreaterThanOrEqual(interval - 10);
    });

    describe('hidden in a tab panel', () => {
      /** The box a tab panel that is not selected, or a closed disclosure, hides it in. */
      function Tab({
        shown,
        interval,
        onValueChange
      }: {
        shown: boolean;
        interval: number;
        onValueChange: (index: number) => void;
      }) {
        return (
          <div style={{ display: shown ? 'block' : 'none' }}>
            <PlCarousel autoPlay interval={interval} onValueChange={onValueChange}>
              {slides}
            </PlCarousel>
          </div>
        );
      }

      it('holds still while it is hidden, and goes on from the slide it was hidden on', async () => {
        const onValueChange = vi.fn();
        const screen = await render(<Tab shown interval={200} onValueChange={onValueChange} />);

        await screen.rerender(<Tab shown={false} interval={200} onValueChange={onValueChange} />);

        // A slow machine can take a turn before the box is hidden, so what is
        // held is the slide it was hidden on.
        const held = current(screen);
        // "Slide n of 3" is index n - 1, so the slide after it is index n,
        // wrapped round.
        const next = Number(held?.split(' ')[1]) % 3;

        onValueChange.mockClear();
        await aWhile();

        expect(onValueChange).not.toHaveBeenCalled();
        expect(current(screen)).toBe(held);

        await screen.rerender(<Tab shown interval={200} onValueChange={onValueChange} />);

        // Hiding it is not the reader stopping it: the button still offers the
        // stop, and it moves on by itself.
        await expect
          .element(screen.getByRole('button', { name: 'Stop slide show' }))
          .toBeInTheDocument();
        await expect
          .poll(() => onValueChange.mock.calls.length, { timeout: 2000 })
          .toBeGreaterThan(0);
        expect(onValueChange.mock.calls[0][0]).toBe(next);
      });

      it('holds the slide for a whole interval once it is shown again', async () => {
        const interval = 600;
        const turns: number[] = [];
        const onValueChange = () => turns.push(performance.now());
        const screen = await render(
          <Tab shown interval={interval} onValueChange={onValueChange} />
        );
        const started = performance.now();

        await screen.rerender(
          <Tab shown={false} interval={interval} onValueChange={onValueChange} />
        );
        // Shown again most of an interval after the one it was hidden in
        // started, so an interval that ran on while it was hidden would turn
        // it almost at once.
        await new Promise((resolve) =>
          setTimeout(resolve, Math.max(0, started + interval - 100 - performance.now()))
        );
        turns.length = 0;

        const shownAt = performance.now();

        await screen.rerender(<Tab shown interval={interval} onValueChange={onValueChange} />);
        await expect.poll(() => turns.length, { timeout: interval * 4 }).toBeGreaterThan(0);

        // A timer fires no earlier than it was asked to, and the whole interval
        // starts once the carousel has seen its width come back, which is after
        // `shownAt`. The margin is for the clock the browser rounds.
        expect(turns[0] - shownAt).toBeGreaterThanOrEqual(interval - 10);
      });
    });

    it('moves the strip without scrolling the page while it plays', async () => {
      const screen = await render(
        <PlCarousel autoPlay interval={200} label="Tall">
          <div style={{ height: 1500 }}>One</div>
          <div style={{ height: 1500 }}>Two</div>
        </PlCarousel>
      );

      window.scrollTo(0, 0);

      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 2' }), { timeout: 2000 })
        .toHaveAttribute('aria-current', 'true');
      await new Promise((resolve) => setTimeout(resolve, 100));

      // Nothing loads the stylesheet, so the second slide is below the fold: the
      // case where a scroll that walked the ancestors would move the window.
      expect(window.scrollY).toBe(0);
    });

    it('keeps advancing inside a parent that renders more often than the interval', async () => {
      function Ticking() {
        const [, setTick] = React.useState(0);
        const [shown, setShown] = React.useState(0);

        React.useEffect(() => {
          const timer = window.setInterval(() => setTick((tick) => tick + 1), 50);

          return () => window.clearInterval(timer);
        }, []);

        // An inline handler, a new function on every one of those renders.
        return (
          <PlCarousel autoPlay interval={200} onValueChange={(next) => setShown(next)}>
            <p>Alpha {shown}</p>
            <p>Bravo</p>
            <p>Charlie</p>
          </PlCarousel>
        );
      }

      const screen = await render(<Ticking />);

      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }), { timeout: 2000 })
        .toHaveAttribute('aria-current', 'true');
    });

    it('holds still while the pointer is over it', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCarousel autoPlay interval={200} onValueChange={onValueChange}>
          {slides}
        </PlCarousel>
      );

      await screen.getByRole('region').hover();

      try {
        // The timer starts with the render, and the hover arrives whenever the
        // runner delivers it, which on a slow machine is after the first turn.
        // What is held is the slide the pointer found, and no turn is asked for
        // after it: three turns of three slides would also end where they began.
        const held = current(screen);

        onValueChange.mockClear();
        await aWhile();

        expect(onValueChange).not.toHaveBeenCalled();
        expect(current(screen)).toBe(held);
      } finally {
        // The runner's pointer stays where it was left, and a carousel drawn
        // under it in a later test would start out paused.
        await screen.getByRole('region').unhover();
      }
    });

    describe('under a finger', () => {
      const finger = { pointerId: 7, pointerType: 'touch', isPrimary: true, bubbles: true };

      /** A touch event carrying one touch, the finger's. Built by hand, because
       * Firefox and WebKit on a desktop have no `TouchEvent` to construct. */
      const touch = (type: string) =>
        Object.defineProperty(new Event(type, { bubbles: true }), 'changedTouches', {
          value: [{ identifier: 7 }]
        });

      /**
       * What Chromium sends for a finger that lands on the strip and drags it:
       * the pointer arrives and goes down and the touch starts, and once the
       * browser takes the drag over as a pan it cancels the pointer and says
       * it has left, while the finger stays down. Dispatched rather than
       * performed, since only Chromium can be handed a real touch.
       */
      const pan = (track: HTMLElement) => {
        track.dispatchEvent(new PointerEvent('pointerover', finger));
        track.dispatchEvent(new PointerEvent('pointerdown', finger));
        track.dispatchEvent(touch('touchstart'));
        track.dispatchEvent(new PointerEvent('pointercancel', finger));
        track.dispatchEvent(
          new PointerEvent('pointerout', { ...finger, relatedTarget: document.body })
        );
      };

      it('holds still while the finger drags the strip, and for a whole interval once it lifts', async () => {
        const interval = 200;
        const turns: number[] = [];
        const screen = await render(
          <PlCarousel
            autoPlay
            interval={interval}
            onValueChange={() => turns.push(performance.now())}
          >
            {slides}
          </PlCarousel>
        );
        const track = screen.getByRole('group', { name: 'Carousel' }).element() as HTMLElement;

        pan(track);

        // A slow machine can take a turn before the finger lands, so what is
        // held is the slide it found.
        const held = current(screen);

        turns.length = 0;
        await aWhile();

        expect(turns).toEqual([]);
        expect(current(screen)).toBe(held);

        const lifted = performance.now();

        track.dispatchEvent(touch('touchend'));

        await expect.poll(() => turns.length, { timeout: interval * 4 }).toBeGreaterThan(0);
        // The margin is for the clock the browser rounds.
        expect(turns[0] - lifted).toBeGreaterThanOrEqual(interval - 10);
      });
    });

    it('holds still under the pointer and still calls the caller’s `onPointerEnter`', async () => {
      const onValueChange = vi.fn();
      const onPointerEnter = vi.fn();
      const screen = await render(
        <PlCarousel
          autoPlay
          interval={200}
          onValueChange={onValueChange}
          onPointerEnter={onPointerEnter}
        >
          {slides}
        </PlCarousel>
      );

      await screen.getByRole('region').hover();

      try {
        // A caller's handler used to replace the pause instead of running
        // beside it, so the strip turned under the pointer.
        const held = current(screen);

        onValueChange.mockClear();
        await aWhile();

        expect(onValueChange).not.toHaveBeenCalled();
        expect(current(screen)).toBe(held);
        expect(onPointerEnter).toHaveBeenCalled();
      } finally {
        await screen.getByRole('region').unhover();
      }
    });

    it('holds still with the focus inside and still calls the caller’s `onFocus` and `onBlur`', async () => {
      const onValueChange = vi.fn();
      const onFocus = vi.fn();
      const onBlur = vi.fn();
      const screen = await render(
        <PlCarousel
          autoPlay
          interval={200}
          onValueChange={onValueChange}
          onFocus={onFocus}
          onBlur={onBlur}
        >
          {slides}
        </PlCarousel>
      );
      const track = screen.getByRole('group', { name: 'Carousel' }).element() as HTMLElement;

      track.focus();

      const held = current(screen);

      onValueChange.mockClear();
      await aWhile();

      expect(onValueChange).not.toHaveBeenCalled();
      expect(current(screen)).toBe(held);
      expect(onFocus).toHaveBeenCalled();

      track.blur();

      expect(onBlur).toHaveBeenCalled();
    });

    it('draws a button that stops it and starts it again', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCarousel autoPlay interval={200} onValueChange={onValueChange}>
          {slides}
        </PlCarousel>
      );

      await screen.getByRole('button', { name: 'Stop slide show' }).click();
      // The press put the pointer over the frame, which pauses it on its own.
      await commands.parkPointer();

      await expect
        .element(screen.getByRole('button', { name: 'Start slide show' }))
        .toBeInTheDocument();

      onValueChange.mockClear();
      await aWhile();

      expect(onValueChange).not.toHaveBeenCalled();

      await screen.getByRole('button', { name: 'Start slide show' }).click();
      await commands.parkPointer();

      await expect
        .element(screen.getByRole('button', { name: 'Stop slide show' }))
        .toBeInTheDocument();
      await expect
        .poll(() => onValueChange.mock.calls.length, { timeout: 2000 })
        .toBeGreaterThan(0);
    });

    it('stays stopped once the focus has been inside, until the button starts it', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCarousel autoPlay interval={200} onValueChange={onValueChange}>
          {slides}
        </PlCarousel>
      );
      const track = screen.getByRole('group', { name: 'Carousel' }).element() as HTMLElement;

      track.focus();
      track.blur();

      // The focus leaving is not the reader asking for it to move again.
      await expect
        .element(screen.getByRole('button', { name: 'Start slide show' }))
        .toBeInTheDocument();

      onValueChange.mockClear();
      await aWhile();

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('does not start again when the pointer leaves while the focus is inside', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCarousel autoPlay interval={200} onValueChange={onValueChange}>
          {slides}
        </PlCarousel>
      );

      await screen.getByRole('region').hover();
      (screen.getByRole('group', { name: 'Carousel' }).element() as HTMLElement).focus();
      await commands.parkPointer();

      onValueChange.mockClear();
      await aWhile();

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('keeps playing while the focus is on its own button, and after play is pressed', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCarousel autoPlay interval={200} onValueChange={onValueChange}>
          {slides}
        </PlCarousel>
      );
      const button = screen.getByRole('button', { name: 'Stop slide show' });

      // The first thing a keyboard reader reaches, and landing on it stops
      // nothing: it is where they stop it from.
      (button.element() as HTMLElement).focus();

      await expect
        .poll(() => onValueChange.mock.calls.length, { timeout: 2000 })
        .toBeGreaterThan(0);

      await userEvent.keyboard('{Enter}');
      await expect
        .element(screen.getByRole('button', { name: 'Start slide show' }))
        .toBeInTheDocument();
      await userEvent.keyboard('{Enter}');

      // Started again from inside, so moving on to the strip does not stop it.
      (screen.getByRole('group', { name: 'Carousel' }).element() as HTMLElement).focus();
      onValueChange.mockClear();

      await expect
        .poll(() => onValueChange.mock.calls.length, { timeout: 2000 })
        .toBeGreaterThan(0);
      await expect
        .element(screen.getByRole('button', { name: 'Stop slide show' }))
        .toBeInTheDocument();
    });

    // A DOM click rather than the runner's, which focuses the button it presses
    // in every browser Playwright drives. Safari does not focus a button it
    // clicks, so there the click has to stop the strip by itself.
    it.each(['Next slide', 'Slide 3 of 3'])(
      'stops once the button “%s” is clicked, when the click brings no focus in',
      async (name) => {
        const screen = await render(
          <PlCarousel autoPlay interval={200}>
            {slides}
          </PlCarousel>
        );

        (screen.getByRole('button', { name }).element() as HTMLElement).click();

        expect(screen.getByRole('region').element().contains(document.activeElement)).toBe(false);
        await expect
          .element(screen.getByRole('button', { name: 'Start slide show' }))
          .toBeInTheDocument();
      }
    );

    it('keeps playing through a click on an arrow or a dot once its button has started it, when no click brings the focus in', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCarousel autoPlay interval={200} onValueChange={onValueChange}>
          {slides}
        </PlCarousel>
      );
      const click = (name: string) =>
        (screen.getByRole('button', { name }).element() as HTMLElement).click();

      click('Stop slide show');
      await expect
        .element(screen.getByRole('button', { name: 'Start slide show' }))
        .toBeInTheDocument();
      click('Start slide show');
      await expect
        .element(screen.getByRole('button', { name: 'Stop slide show' }))
        .toBeInTheDocument();

      // The reader has just answered the stop, with the focus outside the
      // carousel all along.
      click('Next slide');
      click('Slide 1 of 3');
      onValueChange.mockClear();

      expect(screen.getByRole('region').element().contains(document.activeElement)).toBe(false);
      await expect
        .element(screen.getByRole('button', { name: 'Stop slide show' }))
        .toBeInTheDocument();
      await expect
        .poll(() => onValueChange.mock.calls.length, { timeout: 2000 })
        .toBeGreaterThan(0);
    });

    it('stops once the focus comes in after a click that brought no focus in started it', async () => {
      const screen = await render(
        <PlCarousel autoPlay interval={200}>
          {slides}
        </PlCarousel>
      );
      const click = (name: string) =>
        (screen.getByRole('button', { name }).element() as HTMLElement).click();

      click('Stop slide show');
      await expect
        .element(screen.getByRole('button', { name: 'Start slide show' }))
        .toBeInTheDocument();
      click('Start slide show');
      await expect
        .element(screen.getByRole('button', { name: 'Stop slide show' }))
        .toBeInTheDocument();

      // What the start answered was a stop made from outside, so a reader who
      // then tabs into a slide is reading it.
      (screen.getByRole('group', { name: 'Carousel' }).element() as HTMLElement).focus();

      await expect
        .element(screen.getByRole('button', { name: 'Start slide show' }))
        .toBeInTheDocument();
    });

    it('announces the slide once it is stopped, and not while it plays', async () => {
      const screen = await render(
        <PlCarousel autoPlay interval={60000}>
          {slides}
        </PlCarousel>
      );
      const live = screen.container.querySelector('[aria-live]')!;

      expect(live).toHaveAttribute('aria-live', 'off');

      await screen.getByRole('button', { name: 'Stop slide show' }).click();
      await commands.parkPointer();

      await expect.poll(() => live.getAttribute('aria-live')).toBe('polite');
    });

    it('takes its two names from playLabel and stopLabel', async () => {
      const screen = await render(
        <PlCarousel autoPlay interval={60000} playLabel="Play" stopLabel="Pause">
          {slides}
        </PlCarousel>
      );

      await screen.getByRole('button', { name: 'Pause' }).click();
      await commands.parkPointer();

      await expect.element(screen.getByRole('button', { name: 'Play' })).toBeInTheDocument();
    });

    it('has no button when it does not play on its own', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      expect(screen.getByRole('button', { name: 'Stop slide show' }).query()).toBeNull();
      expect(screen.getByRole('button', { name: 'Start slide show' }).query()).toBeNull();
    });
  });

  describe('navigation', () => {
    it('moves to the next slide and marks its dot as current', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      await expect
        .element(screen.getByRole('button', { name: 'Slide 1 of 3' }))
        .toHaveAttribute('aria-current', 'true');

      await screen.getByRole('button', { name: 'Next slide' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toHaveAttribute('aria-current', 'true');
    });

    it('moves the strip without scrolling the page to it', async () => {
      const screen = await render(
        <PlCarousel label="Tall">
          <div style={{ height: 1500 }}>One</div>
          <div style={{ height: 1500 }}>Two</div>
        </PlCarousel>
      );

      window.scrollTo(0, 0);
      // A DOM click rather than the runner's, which would scroll the button
      // into view itself before pressing it.
      (screen.getByRole('button', { name: 'Next slide' }).element() as HTMLElement).click();
      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 2' }))
        .toHaveAttribute('aria-current', 'true');
      await new Promise((resolve) => setTimeout(resolve, 100));

      // Nothing loads the stylesheet here, so the slides stack down the page
      // and the second one starts below the fold: the case where a scroll that
      // walked the ancestors would have moved the window.
      expect(window.scrollY).toBe(0);
    });

    it('jumps straight to a slide from its dot', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<PlCarousel onValueChange={onValueChange}>{slides}</PlCarousel>);

      await screen.getByRole('button', { name: 'Slide 3 of 3' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(2);
    });

    it('wraps at the ends while looping', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<PlCarousel onValueChange={onValueChange}>{slides}</PlCarousel>);

      await screen.getByRole('button', { name: 'Previous slide' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(2);
    });

    it('goes inert at the ends when it does not loop', async () => {
      const screen = await render(<PlCarousel loop={false}>{slides}</PlCarousel>);

      await expect.element(screen.getByRole('button', { name: 'Previous slide' })).toBeDisabled();
      await expect.element(screen.getByRole('button', { name: 'Next slide' })).toBeEnabled();
    });

    it('honours a controlled value and does not move on its own', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <PlCarousel value={1} onValueChange={onValueChange}>
          {slides}
        </PlCarousel>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toHaveAttribute('aria-current', 'true');

      await screen.getByRole('button', { name: 'Next slide' }).click();

      expect(onValueChange).toHaveBeenLastCalledWith(2);
      // The parent said 1 and never said otherwise, so 1 is where it stays.
      await expect
        .element(screen.getByRole('button', { name: 'Slide 2 of 3' }))
        .toHaveAttribute('aria-current', 'true');
    });

    it('starts on defaultValue', async () => {
      const screen = await render(<PlCarousel defaultValue={2}>{slides}</PlCarousel>);

      await expect
        .element(screen.getByRole('button', { name: 'Slide 3 of 3' }))
        .toHaveAttribute('aria-current', 'true');
    });
  });

  describe('the surface', () => {
    it('maps color and elevation onto the container slots', async () => {
      const screen = await render(
        <PlCarousel color="success" elevation={2}>
          {slides}
        </PlCarousel>
      );
      const element = screen.getByRole('region').element() as HTMLElement;

      expect(element.style.getPropertyValue('--p-line')).toBe('var(--plass-success-line)');
      expect(element.style.getPropertyValue('--p-elev')).toBe('var(--plass-shadow-2)');
    });

    it('is a scroll container rather than a translated track', async () => {
      const screen = await render(<PlCarousel>{slides}</PlCarousel>);

      // Nothing is transformed: the house rule against moving a surface holds
      // here for free, where a translated track would have had to argue for an
      // exception.
      expect(screen.getByRole('region').element().innerHTML).not.toContain('translate-x');
      expect(screen.getByRole('group', { name: 'Carousel' }).element()).toHaveClass('snap-x');
    });
  });
});
