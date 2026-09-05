import { commands } from 'vitest/browser';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAnimateFade } from 'plass-ui';

describe('PlAnimateFade', () => {
  it('renders a div holding its children', async () => {
    const screen = await render(<PlAnimateFade>Arriving</PlAnimateFade>);

    await expect.element(screen.getByText('Arriving')).toBeInTheDocument();
  });

  it('names the effect it is running', async () => {
    await render(<PlAnimateFade className="fade-under-test">Arriving</PlAnimateFade>);

    expect(document.querySelector('.fade-under-test')).toHaveAttribute(
      'data-plass-animation',
      'fade'
    );
  });

  it('fills the timing slots from its props', async () => {
    await render(
      <PlAnimateFade className="fade-under-test" duration={500} delay={120} easing="linear">
        Arriving
      </PlAnimateFade>
    );

    const root = document.querySelector('.fade-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-duration')).toBe('500ms');
    expect(root.style.getPropertyValue('--p-anim-delay')).toBe('120ms');
    expect(root.style.getPropertyValue('--p-anim-ease')).toBe('linear');
  });

  it('leaves the easing slot alone when nobody set one', async () => {
    await render(<PlAnimateFade className="fade-under-test">Arriving</PlAnimateFade>);

    const root = document.querySelector('.fade-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-ease')).toBe('');
  });

  it('starts from the opacity it was given', async () => {
    await render(
      <PlAnimateFade className="fade-under-test" from={0.3}>
        Arriving
      </PlAnimateFade>
    );

    const root = document.querySelector('.fade-under-test') as HTMLElement;

    expect(root.style.getPropertyValue('--p-anim-opacity')).toBe('0.3');
  });

  describe('timeline', () => {
    it('leaves the slots empty on the clock, which is what CSS already resolves to', async () => {
      await render(<PlAnimateFade className="fade-under-test">Arriving</PlAnimateFade>);

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      // `auto` is the property's own initial value, so writing it here would be
      // the same answer copied into every inline style on the page.
      expect(root.style.getPropertyValue('--p-anim-timeline')).toBe('');
      expect(root.style.getPropertyValue('--p-anim-range')).toBe('');
    });

    it('hands the effect to the scroll position when it is asked to', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" timeline="view">
          Arriving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-timeline')).toBe('view()');
      expect(root.style.getPropertyValue('--p-anim-range')).toBe('entry 0% cover 45%');
    });

    it('takes a range of its own', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" timeline="view" range="cover 20% cover 80%">
          Arriving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-range')).toBe('cover 20% cover 80%');
    });

    it('runs whatever the trigger said, because the scroll position is the trigger', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" timeline="view" trigger="visible">
          Arriving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      // A scroll-linked animation held `paused` shows its first frame and
      // nothing else, so an effect waiting to be scrolled into view would never
      // be seen no matter how far it was scrolled.
      expect(root.style.getPropertyValue('--p-anim-state')).toBe('running');
      expect(root).toHaveAttribute('data-state', 'running');
    });

    it('still stops where a caller says stop', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" timeline="view" paused>
          Arriving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      // `paused` is a caller saying "hold it" rather than "wait for something",
      // which is a different sentence from `trigger` and survives.
      expect(root.style.getPropertyValue('--p-anim-state')).toBe('paused');
    });

    it('reaches the children of a staggered set, which each get their own', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" timeline="view" stagger={70}>
          <span>One</span>
          <span>Two</span>
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      for (const child of [...root.children] as HTMLElement[]) {
        expect(child.style.getPropertyValue('--p-anim-timeline')).toBe('view()');
      }
    });
  });

  describe('stagger', () => {
    /** The three children, in document order, whatever order they play in. */
    function children() {
      return [
        ...(document.querySelector('.fade-under-test') as HTMLElement).children
      ] as HTMLElement[];
    }

    it('plays the box itself when nobody asked for one', async () => {
      await render(
        <PlAnimateFade className="fade-under-test">
          <span>One</span>
          <span>Two</span>
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root).toHaveClass('plass-anim-fade');
      expect(children().every((child) => !child.classList.contains('plass-anim'))).toBe(true);
    });

    it('moves the effect onto the children, and off the box', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" delay={100} stagger={70}>
          <span>One</span>
          <span>Two</span>
          <span>Three</span>
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      // Three children fading in under a box that is also fading in is the same
      // content faded twice, and the second one is not free.
      expect(root).not.toHaveClass('plass-anim-fade');
      expect(root.style.getPropertyValue('--p-anim-duration')).toBe('');

      expect(children().map((child) => child.style.getPropertyValue('--p-anim-delay'))).toEqual([
        '100ms',
        '170ms',
        '240ms'
      ]);
    });

    it('keeps the play state on the box, where every child reads it', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" stagger={70} trigger="manual">
          <span>One</span>
          <span>Two</span>
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      // One declaration that every child inherits, rather than the same answer
      // written once per child.
      expect(root.style.getPropertyValue('--p-anim-state')).toBe('paused');
      expect(root).toHaveAttribute('data-state', 'paused');
    });

    it('steps the duration, and never below zero', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" duration={300} stagger={10} durationStep={-200}>
          <span>One</span>
          <span>Two</span>
          <span>Three</span>
        </PlAnimateFade>
      );

      // A negative `animation-duration` is invalid, and an invalid declaration
      // is dropped — which would leave that one child running at the CSS
      // default while its neighbours honoured the prop.
      expect(children().map((child) => child.style.getPropertyValue('--p-anim-duration'))).toEqual([
        '300ms',
        '100ms',
        '0ms'
      ]);
    });

    it('turns the order round without turning the children round', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" stagger={70} reverse>
          <span>One</span>
          <span>Two</span>
          <span>Three</span>
        </PlAnimateFade>
      );

      const held = children();

      expect(held.map((child) => child.textContent)).toEqual(['One', 'Two', 'Three']);
      expect(held.map((child) => child.style.getPropertyValue('--p-anim-delay'))).toEqual([
        '140ms',
        '70ms',
        '0ms'
      ]);
      // Each child still plays forwards. An effect that runs backwards is
      // `mode="out"`.
      expect(held.map((child) => child.style.getPropertyValue('--p-anim-direction'))).toEqual([
        'normal',
        'normal',
        'normal'
      ]);
    });

    it("joins a child's own className and loses to its own style", async () => {
      await render(
        <PlAnimateFade className="fade-under-test" stagger={70}>
          <span className="mine" style={{ opacity: 0.5 }}>
            One
          </span>
        </PlAnimateFade>
      );

      const child = children()[0];

      expect(child).toHaveClass('mine');
      expect(child).toHaveClass('plass-anim-fade');
      expect(child.style.opacity).toBe('0.5');
    });

    it('wraps a bare string, which has no element to write onto', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" stagger={70}>
          One
        </PlAnimateFade>
      );

      expect(children()[0].tagName).toBe('SPAN');
      expect(children()[0]).toHaveClass('plass-anim-fade');
    });
  });

  describe('mode', () => {
    it('runs forwards coming in', async () => {
      await render(<PlAnimateFade className="fade-under-test">Arriving</PlAnimateFade>);

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-direction')).toBe('normal');
    });

    it('runs the same keyframe backwards going out', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" mode="out">
          Leaving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-direction')).toBe('reverse');
    });

    it('alternates in both directions', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" mode="out" alternate>
          Leaving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-direction')).toBe('alternate-reverse');
    });
  });

  describe('repeat', () => {
    it('writes a count as a number', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" repeat={3}>
          Arriving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-repeat')).toBe('3');
    });

    it('writes an endless one as the word CSS uses', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" repeat="infinite">
          Arriving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root.style.getPropertyValue('--p-anim-repeat')).toBe('infinite');
    });
  });

  describe('trigger', () => {
    it('runs on mount by default', async () => {
      await render(<PlAnimateFade className="fade-under-test">Arriving</PlAnimateFade>);

      expect(document.querySelector('.fade-under-test')).toHaveAttribute('data-state', 'running');
    });

    it('waits paused on its first frame until a manual play', async () => {
      const screen = await render(
        <PlAnimateFade className="fade-under-test" trigger="manual">
          Arriving
        </PlAnimateFade>
      );

      expect(document.querySelector('.fade-under-test')).toHaveAttribute('data-state', 'paused');

      await screen.rerender(
        <PlAnimateFade className="fade-under-test" trigger="manual" play>
          Arriving
        </PlAnimateFade>
      );

      await expect.element(screen.getByText('Arriving')).toHaveAttribute('data-state', 'running');
    });

    it('holds where it is when paused', async () => {
      await render(
        <PlAnimateFade className="fade-under-test" paused>
          Arriving
        </PlAnimateFade>
      );

      const root = document.querySelector('.fade-under-test') as HTMLElement;

      expect(root).toHaveAttribute('data-state', 'paused');
      expect(root.style.getPropertyValue('--p-anim-state')).toBe('paused');
    });

    it('starts on hover, and on focus for a reader without a mouse', async () => {
      // The pointer is the browser's and it is still wherever the previous file
      // left it. Rendered under a resting pointer, this starts hovered.
      await commands.parkPointer();

      const screen = await render(
        <PlAnimateFade className="fade-under-test" trigger="hover">
          Arriving
        </PlAnimateFade>
      );

      expect(document.querySelector('.fade-under-test')).toHaveAttribute('data-state', 'paused');

      await screen.getByText('Arriving').hover();

      await expect.element(screen.getByText('Arriving')).toHaveAttribute('data-state', 'running');
    });
  });

  it('renders something else entirely when asked', async () => {
    const screen = await render(<PlAnimateFade render={<section />}>Arriving</PlAnimateFade>);

    expect(screen.getByText('Arriving').element().tagName).toBe('SECTION');
  });

  it('keeps a caller class and a caller style beside its own', async () => {
    await render(
      <PlAnimateFade className="fade-under-test" style={{ color: 'red' }}>
        Arriving
      </PlAnimateFade>
    );

    const root = document.querySelector('.fade-under-test') as HTMLElement;

    expect(root).toHaveClass('plass-anim');
    expect(root).toHaveClass('plass-anim-fade');
    expect(root.style.color).toBe('red');
  });
});
