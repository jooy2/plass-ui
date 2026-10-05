/**
 * What an effect shows a reader who has asked for less movement, which the
 * stylesheet decides.
 *
 * Under reduced motion an effect is run in no time rather than switched off, so
 * what is on screen is its last frame, and that frame is a keyframe: with no
 * stylesheet in the room every element sits in its natural state whatever it
 * was asked to do. So `src/standalone.css` is loaded here the way
 * `marquee.test.tsx` loads it. What is asserted is whether the content is there
 * and the angle a caller asked for, never a shade or a size.
 */
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlAnimateFade,
  PlAnimateGrow,
  PlAnimateLighting,
  PlAnimateMarquee,
  PlAnimateReveal,
  PlAnimateRotate,
  PlAnimateSlide,
  PlAnimateSplit,
  PlAnimateZoom
} from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia, emulateReducedMotion } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

beforeEach(async () => {
  await emulateMedia({ reducedMotion: 'reduce' });
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

/** The element carrying the effect, found by the class a test gave it. */
function target(): HTMLElement {
  return document.querySelector('.effect-under-test') as HTMLElement;
}

const opacity = (element: HTMLElement) => getComputedStyle(element).opacity;

/**
 * Whether anything of the element is drawn: it is not faded away and not
 * clipped away. A reveal leaves by its `clip-path` and keeps its ink.
 */
function drawn(element: HTMLElement): boolean {
  const style = getComputedStyle(element);
  const clip = style.clipPath;

  return style.opacity !== '0' && (clip === 'none' || /^inset\(0(px)?\)$/.test(clip));
}

/** Long enough for a frame, which is all a run in no time takes. */
const frame = () => new Promise((resolve) => setTimeout(resolve, 50));

describe('an effect under reduced motion', () => {
  it('turns to the angle it was asked to end at', async () => {
    await render(
      <PlAnimateRotate className="effect-under-test" from={0} to={90} fade={false}>
        Turning
      </PlAnimateRotate>
    );

    await expect.poll(() => getComputedStyle(target()).rotate).toBe('90deg');
  });

  it('stands at that angle while it waits to be let go', async () => {
    await render(
      <PlAnimateRotate className="effect-under-test" from={0} to={90} trigger="manual">
        Turning
      </PlAnimateRotate>
    );

    await frame();

    expect(getComputedStyle(target()).rotate).toBe('90deg');
    expect(opacity(target())).toBe('1');
  });

  it('ends one pass of an endless turn', async () => {
    await render(
      <PlAnimateRotate
        className="effect-under-test"
        from={0}
        to={90}
        fade={false}
        repeat="infinite"
        easing="linear"
      >
        Turning
      </PlAnimateRotate>
    );

    await expect.poll(() => getComputedStyle(target()).rotate).toBe('90deg');
  });

  it('keeps an entrance', async () => {
    await render(<PlAnimateFade className="effect-under-test">Arriving</PlAnimateFade>);

    await frame();

    expect(opacity(target())).toBe('1');
  });

  it('shows an entrance that is waiting for its trigger', async () => {
    await render(
      <PlAnimateFade className="effect-under-test" trigger="manual">
        Arriving
      </PlAnimateFade>
    );

    await frame();

    expect(opacity(target())).toBe('1');
  });

  for (const [name, exit] of [
    ['PlAnimateFade', <PlAnimateFade key="fade" className="effect-under-test" mode="out" />],
    ['PlAnimateGrow', <PlAnimateGrow key="grow" className="effect-under-test" mode="out" />],
    ['PlAnimateZoom', <PlAnimateZoom key="zoom" className="effect-under-test" mode="out" />],
    ['PlAnimateSlide', <PlAnimateSlide key="slide" className="effect-under-test" mode="out" />],
    ['PlAnimateRotate', <PlAnimateRotate key="rotate" className="effect-under-test" mode="out" />],
    ['PlAnimateReveal', <PlAnimateReveal key="reveal" className="effect-under-test" mode="out" />]
  ] as const) {
    it(`hides a ${name} that leaves`, async () => {
      await render(exit);

      await expect.poll(() => drawn(target())).toBe(false);
    });
  }

  it('hides every part of a PlAnimateSplit that leaves', async () => {
    await render(
      <PlAnimateSplit className="effect-under-test" mode="out">
        Two words
      </PlAnimateSplit>
    );

    const parts = () => Array.from(target().querySelectorAll<HTMLElement>('.plass-anim'));

    expect(parts()).toHaveLength(2);
    await expect.poll(() => parts().some(drawn)).toBe(false);
  });

  it('tells a caller waiting on the end that it has ended', async () => {
    const ended = vi.fn();

    await render(
      <PlAnimateFade className="effect-under-test" mode="out" onAnimationEnd={ended}>
        Leaving
      </PlAnimateFade>
    );

    await expect.poll(() => ended.mock.calls.length).toBe(1);
  });

  it('leaves an exit in place until it is let go', async () => {
    const screen = await render(
      <PlAnimateFade className="effect-under-test" mode="out" trigger="manual" play={false}>
        Leaving
      </PlAnimateFade>
    );

    await frame();

    expect(opacity(target())).toBe('1');

    await screen.rerender(
      <PlAnimateFade className="effect-under-test" mode="out" trigger="manual" play>
        Leaving
      </PlAnimateFade>
    );

    await expect.poll(() => opacity(target())).toBe('0');
  });

  it('keeps an exit on screen for its delay', async () => {
    await render(
      <PlAnimateFade className="effect-under-test" mode="out" delay={400}>
        Leaving
      </PlAnimateFade>
    );

    await frame();

    expect(opacity(target())).toBe('1');
    await expect.poll(() => opacity(target())).toBe('0');
  });

  it('ends where an alternating run ends', async () => {
    // Out and back: the second pass runs backwards, so it finishes faded out.
    await render(
      <PlAnimateFade className="effect-under-test" alternate repeat={2}>
        Blinking once
      </PlAnimateFade>
    );

    await expect.poll(() => opacity(target())).toBe('0');
  });
});

/** The keyframe running on `element` itself. */
function keyframe(element: HTMLElement): Animation {
  return element.getAnimations()[0];
}

/**
 * Long enough that no run started in a test is anywhere near its end when the
 * setting is taken back, however slow the runner is.
 */
const long = 60_000;

describe('an effect when movement is given back', () => {
  it('leaves a finite run that landed where it landed', async () => {
    const ended = vi.fn();

    await render(
      <PlAnimateFade className="effect-under-test" duration={long} onAnimationEnd={ended}>
        Arriving
      </PlAnimateFade>
    );

    await expect.poll(() => ended.mock.calls.length).toBe(1);
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('finished');
    expect(opacity(target())).toBe('1');
  });

  it('leaves a finite run that landed when the setting arrived during it where it landed', async () => {
    const ended = vi.fn();

    await emulateMedia({ reducedMotion: 'no-preference' });
    await render(
      <PlAnimateFade className="effect-under-test" duration={long} onAnimationEnd={ended}>
        Arriving
      </PlAnimateFade>
    );

    await expect.poll(() => keyframe(target()).playState).toBe('running');
    await emulateMedia({ reducedMotion: 'reduce' });
    await expect.poll(() => ended.mock.calls.length).toBe(1);
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('finished');
    expect(opacity(target())).toBe('1');
  });

  it('leaves every part of a staggered run that landed where it landed, and waits on with the rest', async () => {
    const ended = vi.fn();

    await render(
      <PlAnimateFade
        className="effect-under-test"
        duration={long}
        stagger={long}
        onAnimationEnd={ended}
      >
        <span>Here</span>
        <span>Later</span>
      </PlAnimateFade>
    );

    const [first, second] = Array.from(target().children) as HTMLElement[];

    await expect.poll(() => ended.mock.calls.length).toBe(1);
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(first).playState).toBe('finished');
    expect(opacity(first)).toBe('1');
    // Still waiting out its delay, on its first frame.
    expect(keyframe(second).playState).toBe('running');
    expect(opacity(second)).toBe('0');
  });

  it('turns an endless run on again', async () => {
    const ended = vi.fn();

    await render(
      <PlAnimateRotate
        className="effect-under-test"
        duration={long}
        repeat="infinite"
        onAnimationEnd={ended}
      >
        Turning
      </PlAnimateRotate>
    );

    await expect.poll(() => ended.mock.calls.length).toBe(1);
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('running');
  });

  it('plays a run that is still waiting out its delay when the wait is over', async () => {
    await render(
      <PlAnimateFade className="effect-under-test" duration={long} delay={long}>
        Arriving
      </PlAnimateFade>
    );

    await frame();
    await emulateMedia({ reducedMotion: 'no-preference' });

    const timing = keyframe(target()).effect!.getComputedTiming();

    expect(keyframe(target()).playState).toBe('running');
    expect(timing.duration).toBe(long);
    expect(Number(timing.localTime)).toBeLessThan(long);
    expect(opacity(target())).toBe('0');
  });

  it('plays the next run with movement', async () => {
    const ended = vi.fn();
    const fade = (play: boolean) => (
      <PlAnimateFade
        className="effect-under-test"
        duration={long}
        trigger="manual"
        play={play}
        onAnimationEnd={ended}
      >
        Arriving
      </PlAnimateFade>
    );
    const screen = await render(fade(true));

    await expect.poll(() => ended.mock.calls.length).toBe(1);
    await emulateMedia({ reducedMotion: 'no-preference' });
    await screen.rerender(fade(false));
    await screen.rerender(fade(true));

    await expect.poll(() => keyframe(target()).playState).toBe('running');
    expect(keyframe(target()).effect!.getComputedTiming().duration).toBe(long);
    expect(Number(opacity(target()))).toBeLessThan(1);
  });

  it('leaves an endless run held by `paused` on the frame it showed until it is let go', async () => {
    const fade = (paused: boolean) => (
      <PlAnimateFade
        className="effect-under-test"
        duration={long}
        repeat="infinite"
        paused={paused}
      >
        Pulsing
      </PlAnimateFade>
    );
    const screen = await render(fade(true));

    await frame();
    expect(opacity(target())).toBe('1');

    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('paused');
    expect(opacity(target())).toBe('1');

    // Let go, it goes on from where its clock stands, which is its start.
    await screen.rerender(fade(false));

    await expect.poll(() => keyframe(target()).playState).toBe('running');
    expect(keyframe(target()).effect!.getComputedTiming().duration).toBe(long);
    expect(Number(opacity(target()))).toBeLessThan(1);
  });

  it('leaves an endless turn that landed and was then held by `paused` at its angle', async () => {
    const ended = vi.fn();
    const rotate = (paused: boolean) => (
      <PlAnimateRotate
        className="effect-under-test"
        from={0}
        to={90}
        fade={false}
        duration={long}
        repeat="infinite"
        paused={paused}
        onAnimationEnd={ended}
      >
        Turning
      </PlAnimateRotate>
    );
    const screen = await render(rotate(false));

    await expect.poll(() => ended.mock.calls.length).toBe(1);
    await screen.rerender(rotate(true));
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('paused');
    expect(getComputedStyle(target()).rotate).toBe('90deg');

    await screen.rerender(rotate(false));

    await expect.poll(() => keyframe(target()).playState).toBe('running');
    expect(keyframe(target()).effect!.getComputedTiming().duration).toBe(long);
  });

  it('leaves an endless turn held by `paused` before it moved at the angle it stood at', async () => {
    await render(
      <PlAnimateRotate
        className="effect-under-test"
        from={0}
        to={90}
        fade={false}
        duration={long}
        repeat="infinite"
        paused
      >
        Turning
      </PlAnimateRotate>
    );

    await frame();
    expect(getComputedStyle(target()).rotate).toBe('90deg');

    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(getComputedStyle(target()).rotate).toBe('90deg');
  });

  it('leaves an endless run paused with movement on the frame reduced motion showed', async () => {
    const fade = (paused: boolean) => (
      <PlAnimateFade
        className="effect-under-test"
        duration={long}
        repeat="infinite"
        easing="linear"
        paused={paused}
      >
        Pulsing
      </PlAnimateFade>
    );

    await emulateMedia({ reducedMotion: 'no-preference' });

    const screen = await render(fade(false));

    await expect.poll(() => keyframe(target()).playState).toBe('running');
    await screen.rerender(fade(true));
    await emulateMedia({ reducedMotion: 'reduce' });
    // A page hears that the setting changed on the frame after it did.
    await frame();

    expect(opacity(target())).toBe('1');

    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('paused');
    expect(opacity(target())).toBe('1');
  });

  it('leaves every part of a staggered endless run held by `paused` on the frame it showed', async () => {
    await render(
      <PlAnimateFade
        className="effect-under-test"
        duration={long}
        repeat="infinite"
        stagger={100}
        paused
      >
        <span>One</span>
        <span>Two</span>
      </PlAnimateFade>
    );

    const parts = Array.from(target().children) as HTMLElement[];

    await frame();
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(parts.map(opacity)).toEqual(['1', '1']);
  });

  for (const [name, effect, angle] of [
    [
      'PlAnimateFade',
      (props: { delay?: number; paused: boolean }) => (
        <PlAnimateFade className="effect-under-test" duration={long} {...props}>
          Arriving
        </PlAnimateFade>
      ),
      'none'
    ],
    [
      'PlAnimateRotate',
      (props: { delay?: number; paused: boolean }) => (
        <PlAnimateRotate className="effect-under-test" from={0} to={90} duration={long} {...props}>
          Turning
        </PlAnimateRotate>
      ),
      '90deg'
    ]
  ] as const) {
    /** What reduced motion shows before the run: the content, at the angle a turn ends at. */
    const still = () => [opacity(target()), getComputedStyle(target()).rotate];

    it(`leaves a finite ${name} held by \`paused\` from the mount on the frame it showed until it is let go`, async () => {
      const screen = await render(effect({ paused: true }));

      await frame();
      expect(still()).toEqual(['1', angle]);

      await emulateMedia({ reducedMotion: 'no-preference' });

      expect(keyframe(target()).playState).toBe('paused');
      expect(still()).toEqual(['1', angle]);

      // Let go, it goes on from where its clock stands, which is its start.
      await screen.rerender(effect({ paused: false }));

      await expect.poll(() => keyframe(target()).playState).toBe('running');
      expect(keyframe(target()).effect!.getComputedTiming().duration).toBe(long);
      expect(Number(opacity(target()))).toBeLessThan(1);
    });

    it(`leaves a finite ${name} held by \`paused\` during its delay on the frame it showed until it is let go`, async () => {
      const screen = await render(effect({ delay: long, paused: false }));

      await frame();
      await screen.rerender(effect({ delay: long, paused: true }));
      expect(still()).toEqual(['1', angle]);

      await emulateMedia({ reducedMotion: 'no-preference' });

      expect(keyframe(target()).playState).toBe('paused');
      expect(still()).toEqual(['1', angle]);

      // Let go, it waits out the rest of its delay on its first frame.
      await screen.rerender(effect({ delay: long, paused: false }));

      await expect.poll(() => keyframe(target()).playState).toBe('running');
      expect(keyframe(target()).effect!.getComputedTiming().duration).toBe(long);
      expect(opacity(target())).toBe('0');
    });
  }

  it('leaves a run that was never let go waiting for its trigger', async () => {
    const fade = (play: boolean) => (
      <PlAnimateFade className="effect-under-test" duration={long} trigger="manual" play={play}>
        Arriving
      </PlAnimateFade>
    );
    const screen = await render(fade(false));

    await frame();
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('paused');
    expect(opacity(target())).toBe('0');

    await screen.rerender(fade(true));

    await expect.poll(() => keyframe(target()).playState).toBe('running');
    expect(keyframe(target()).effect!.getComputedTiming().duration).toBe(long);
  });
});

/** Whatever is running on the element or inside it, its arc included. */
function running(element: HTMLElement): Animation[] {
  return element
    .getAnimations({ subtree: true })
    .filter((animation) => animation.playState === 'running');
}

describe('a light or a strip when movement is given back', () => {
  /** How far round the arc of the light under test has travelled. */
  const angle = () =>
    getComputedStyle(target(), '::before').getPropertyValue('--plass-glow-angle').trim();

  const tracks = () => Array.from(target().querySelectorAll<HTMLElement>('.plass-marquee-track'));

  it('leaves a finite PlAnimateLighting that landed where it landed', async () => {
    const ended = vi.fn();

    await render(
      <PlAnimateLighting
        className="effect-under-test"
        duration={long}
        repeat={1}
        onAnimationEnd={ended}
      >
        <div style={{ height: '80px' }}>Glowing</div>
      </PlAnimateLighting>
    );

    await expect.poll(() => ended.mock.calls.length).toBe(1);
    await emulateMedia({ reducedMotion: 'no-preference' });

    // Standing where a turn ends, which is where it begins.
    expect(running(target())).toEqual([]);
    expect(['0deg', '360deg']).toContain(angle());
  });

  for (const orientation of ['horizontal', 'vertical'] as const) {
    it(`leaves a finite ${orientation} PlAnimateMarquee that landed where it landed`, async () => {
      const ended = vi.fn();

      await render(
        <PlAnimateMarquee
          className="effect-under-test"
          orientation={orientation}
          duration={long}
          repeat={1}
          style={{ width: 200, height: 40 }}
          onAnimationEnd={ended}
        >
          <span style={{ display: 'block', width: 300, height: 80 }}>Headline</span>
        </PlAnimateMarquee>
      );

      await expect.poll(() => ended.mock.calls.length).toBe(1);

      // Under the setting, nothing it draws has moved.
      expect(getComputedStyle(tracks()[0]).translate).toBe('none');
      expect(getComputedStyle(tracks()[1]).display).toBe('none');

      await emulateMedia({ reducedMotion: 'no-preference' });

      // Both copies stand where the strip started, the one that was not drawn
      // under the setting as well.
      expect(running(target())).toEqual([]);
      expect(getComputedStyle(tracks()[1]).display).toBe('flex');
      expect(tracks().map((track) => getComputedStyle(track).translate)).toEqual(['none', 'none']);
    });
  }

  it('plays the next run of a finite PlAnimateLighting with movement', async () => {
    const ended = vi.fn();
    const lighting = (play: boolean) => (
      <PlAnimateLighting
        className="effect-under-test"
        duration={long}
        repeat={1}
        trigger="manual"
        play={play}
        onAnimationEnd={ended}
      >
        <div style={{ height: '80px' }}>Glowing</div>
      </PlAnimateLighting>
    );
    const screen = await render(lighting(true));

    await expect.poll(() => ended.mock.calls.length).toBe(1);
    await emulateMedia({ reducedMotion: 'no-preference' });
    await screen.rerender(lighting(false));
    await screen.rerender(lighting(true));

    await expect.poll(() => running(target()).length).toBe(1);
    expect(running(target())[0].effect!.getComputedTiming().duration).toBe(long);
  });

  it('turns an endless PlAnimateLighting on again from its start', async () => {
    const ended = vi.fn();

    await render(
      <PlAnimateLighting className="effect-under-test" duration={long} onAnimationEnd={ended}>
        <div style={{ height: '80px' }}>Glowing</div>
      </PlAnimateLighting>
    );

    await frame();

    // An even glow with nothing running and nothing to end.
    expect(target().getAnimations({ subtree: true })).toEqual([]);
    expect(ended).not.toHaveBeenCalled();

    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(running(target())).toHaveLength(1);
    expect(Number(running(target())[0].currentTime)).toBeLessThan(long);
  });

  /** Whether the light is the even glow reduced motion draws rather than an arc. */
  const even = () => getComputedStyle(target(), '::before').backgroundImage === 'none';

  for (const [name, repeat] of [
    ['an endless', 'infinite'],
    ['a finite', 1]
  ] as const) {
    it(`leaves ${name} PlAnimateLighting held by \`paused\` on the even glow until it is let go`, async () => {
      const lighting = (paused: boolean) => (
        <PlAnimateLighting
          className="effect-under-test"
          duration={long}
          repeat={repeat}
          paused={paused}
        >
          <div style={{ height: '80px' }}>Glowing</div>
        </PlAnimateLighting>
      );
      const screen = await render(lighting(true));

      await frame();
      expect(even()).toBe(true);

      await emulateMedia({ reducedMotion: 'no-preference' });

      expect(running(target())).toEqual([]);
      expect(even()).toBe(true);

      // Let go, it turns from its start.
      await screen.rerender(lighting(false));

      expect(even()).toBe(false);
      await expect.poll(() => running(target()).length).toBe(1);
      expect(Number(running(target())[0].currentTime)).toBeLessThan(long);
    });
  }

  it('leaves an endless PlAnimateLighting paused with movement on the even glow reduced motion showed', async () => {
    const lighting = (paused: boolean) => (
      <PlAnimateLighting className="effect-under-test" duration={long} paused={paused}>
        <div style={{ height: '80px' }}>Glowing</div>
      </PlAnimateLighting>
    );

    await emulateMedia({ reducedMotion: 'no-preference' });

    const screen = await render(lighting(false));

    await expect.poll(() => running(target()).length).toBe(1);
    await screen.rerender(lighting(true));
    await emulateMedia({ reducedMotion: 'reduce' });
    // A page hears that the setting changed on the frame after it did.
    await frame();

    expect(even()).toBe(true);

    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(even()).toBe(true);
  });

  for (const orientation of ['horizontal', 'vertical'] as const) {
    it(`sets an endless ${orientation} PlAnimateMarquee going again from its start, its copies in step`, async () => {
      const ended = vi.fn();

      await render(
        <PlAnimateMarquee
          className="effect-under-test"
          orientation={orientation}
          duration={long}
          style={{ width: 200, height: 40 }}
          onAnimationEnd={ended}
        >
          <span style={{ display: 'block', width: 300, height: 80 }}>Headline</span>
        </PlAnimateMarquee>
      );

      await frame();

      expect(target().getAnimations({ subtree: true })).toEqual([]);
      expect(ended).not.toHaveBeenCalled();

      await emulateMedia({ reducedMotion: 'no-preference' });

      const copies = tracks().map((track) => track.getAnimations());

      expect(copies.map((animations) => animations.length)).toEqual([1, 1]);

      const [first, second] = copies.map(([animation]) => animation);

      await Promise.all([first.ready, second.ready]);

      // Read together, so a copy that started later is behind by the gap.
      expect((first as CSSAnimation).animationName).toBe(
        orientation === 'vertical' ? 'plass-anim-marquee-y' : 'plass-anim-marquee-x'
      );
      expect(first.playState).toBe('running');
      expect(Number(first.currentTime)).toBe(Number(second.currentTime));
    });
  }

  /** Whether the strip stands where it starts, where the setting shows it. */
  const unmoved = (track: HTMLElement) => {
    const translate = getComputedStyle(track).translate;

    return translate === 'none' || translate.split(' ').every((part) => parseFloat(part) === 0);
  };

  /** Whether the box is the one scrolling copy the setting draws. */
  const scrolling = (orientation: 'horizontal' | 'vertical') => {
    const box = getComputedStyle(target());
    const along = orientation === 'vertical' ? box.overflowY : box.overflowX;
    const across = orientation === 'vertical' ? box.overflowX : box.overflowY;

    return (
      along === 'auto' && across === 'hidden' && getComputedStyle(tracks()[1]).display === 'none'
    );
  };

  /** Scrolls the box along the strip, and says how far it is scrolled. */
  const scrolled = (orientation: 'horizontal' | 'vertical', to?: number) => {
    const box = target();

    if (to !== undefined) {
      box[orientation === 'vertical' ? 'scrollTop' : 'scrollLeft'] = to;
    }

    return orientation === 'vertical' ? box.scrollTop : box.scrollLeft;
  };

  for (const orientation of ['horizontal', 'vertical'] as const) {
    for (const [name, repeat] of [
      ['an endless', 'infinite'],
      ['a finite', 1]
    ] as const) {
      it(`leaves ${name} ${orientation} PlAnimateMarquee held by \`paused\` on the one copy it scrolls until it is let go`, async () => {
        const marquee = (paused: boolean) => (
          <PlAnimateMarquee
            className="effect-under-test"
            orientation={orientation}
            duration={long}
            repeat={repeat}
            paused={paused}
            style={{ width: 200, height: 40 }}
          >
            <span style={{ display: 'block', width: 300, height: 80 }}>Headline</span>
          </PlAnimateMarquee>
        );
        const screen = await render(marquee(true));

        await frame();

        expect(scrolling(orientation)).toBe(true);
        expect(scrolled(orientation, 30)).toBe(30);

        await emulateReducedMotion('no-preference');

        // Where the reader left it, and still a tab stop to scroll it from.
        expect(scrolling(orientation)).toBe(true);
        expect(scrolled(orientation)).toBe(30);
        expect(unmoved(tracks()[0])).toBe(true);
        expect(target()).toHaveAttribute('tabindex', '0');

        // Let go, it is the moving strip.
        await screen.rerender(marquee(false));

        expect(scrolling(orientation)).toBe(false);
        expect(getComputedStyle(tracks()[1]).display).toBe('flex');
        expect(target()).not.toHaveAttribute('tabindex');
        await expect.poll(() => running(target()).length).toBe(2);
      });
    }

    it(`leaves a finite ${orientation} PlAnimateMarquee paused with movement during its run on the one copy reduced motion showed`, async () => {
      const marquee = (paused: boolean) => (
        <PlAnimateMarquee
          className="effect-under-test"
          orientation={orientation}
          duration={long}
          repeat={1}
          paused={paused}
          style={{ width: 200, height: 40 }}
        >
          <span style={{ display: 'block', width: 300, height: 80 }}>Headline</span>
        </PlAnimateMarquee>
      );

      await emulateReducedMotion('no-preference');

      const screen = await render(marquee(false));

      await expect.poll(() => unmoved(tracks()[0])).toBe(false);
      await screen.rerender(marquee(true));
      await emulateReducedMotion('reduce');
      await frame();

      expect(scrolling(orientation)).toBe(true);
      expect(unmoved(tracks()[0])).toBe(true);

      await emulateReducedMotion('no-preference');

      expect(scrolling(orientation)).toBe(true);
      expect(unmoved(tracks()[0])).toBe(true);
    });

    it(`leaves an endless ${orientation} PlAnimateMarquee paused with movement on the one copy reduced motion showed`, async () => {
      const marquee = (paused: boolean) => (
        <PlAnimateMarquee
          className="effect-under-test"
          orientation={orientation}
          duration={long}
          paused={paused}
          style={{ width: 200, height: 40 }}
        >
          <span style={{ display: 'block', width: 300, height: 80 }}>Headline</span>
        </PlAnimateMarquee>
      );

      await emulateReducedMotion('no-preference');

      const screen = await render(marquee(false));

      await expect.poll(() => running(target()).length).toBe(2);
      await screen.rerender(marquee(true));
      await emulateReducedMotion('reduce');

      expect(scrolling(orientation)).toBe(true);

      await emulateReducedMotion('no-preference');

      expect(scrolling(orientation)).toBe(true);
      expect(unmoved(tracks()[0])).toBe(true);
    });
  }
});
