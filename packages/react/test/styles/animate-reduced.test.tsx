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
import { commands } from 'vitest/browser';
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
  // A marquee pauses under the pointer, and the pointer stays wherever the last
  // file left it, so a strip drawn under it would never run or land.
  await commands.parkPointer();
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

/**
 * How long a run in no time may take to report that it landed. Ubuntu WebKit on
 * CI has taken longer than the poll's default second to send `animationend`.
 */
const landing = 5000;

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

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
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

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
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
    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('finished');
    expect(opacity(target())).toBe('1');
  });

  it('leaves a finite run that landed on its last frame when it is given more passes', async () => {
    const ended = vi.fn();
    const fade = (repeat: number) => (
      <PlAnimateFade
        className="effect-under-test"
        duration={long}
        repeat={repeat}
        onAnimationEnd={ended}
      >
        Arriving
      </PlAnimateFade>
    );
    const screen = await render(fade(1));

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);

    // Given them while the setting is still on, and again once it has gone.
    await screen.rerender(fade(2));

    expect(keyframe(target()).playState).toBe('finished');
    expect(opacity(target())).toBe('1');

    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('finished');
    expect(opacity(target())).toBe('1');

    await screen.rerender(fade(3));

    expect(keyframe(target()).playState).toBe('finished');
    expect(opacity(target())).toBe('1');
  });

  for (const [repeat, alternate, landed] of [
    [1, false, '1'],
    [2, true, '0']
  ] as const) {
    it(`leaves a finite run that landed at the end of one pass when it is given an endless count${alternate ? ', with alternate' : ''}`, async () => {
      const ended = vi.fn();
      const fade = (count: number | 'infinite', play = true) => (
        <PlAnimateFade
          className="effect-under-test"
          duration={long}
          repeat={count}
          alternate={alternate}
          trigger="manual"
          play={play}
          onAnimationEnd={ended}
        >
          Arriving
        </PlAnimateFade>
      );
      const screen = await render(fade(repeat));

      await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
      expect(opacity(target())).toBe(landed);

      // Given it while the setting is still on, and kept once it has gone: one
      // pass is what the setting shows of an endless run.
      await screen.rerender(fade('infinite'));

      expect(keyframe(target()).playState).toBe('finished');
      expect(opacity(target())).toBe('1');

      await emulateMedia({ reducedMotion: 'no-preference' });

      expect(keyframe(target()).playState).toBe('finished');
      expect(opacity(target())).toBe('1');

      // Until it runs again, which is endless.
      await screen.rerender(fade('infinite', false));
      await screen.rerender(fade('infinite'));

      await expect.poll(() => keyframe(target()).playState).toBe('running');
      expect(keyframe(target()).effect!.getComputedTiming().iterations).toBe(Infinity);
    });
  }

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

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
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

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('running');
  });

  /** An endless fade that is given a finite count while it stands landed. */
  const pulse = (repeat: number | 'infinite', props: { duration: number; paused?: boolean }) => (
    <PlAnimateFade className="effect-under-test" repeat={repeat} {...props}>
      Pulsing
    </PlAnimateFade>
  );

  it('plays an endless run given a finite count while the setting was on from where its clock is', async () => {
    const screen = await render(pulse('infinite', { duration: long }));

    await expect.poll(() => keyframe(target()).playState, { timeout: landing }).toBe('finished');
    await screen.rerender(pulse(5, { duration: long }));

    // On the last frame of the new count, as the setting shows it, and never
    // marked as landed, since it was endless when it landed.
    expect(keyframe(target()).playState).toBe('finished');
    expect(opacity(target())).toBe('1');
    expect(target()).not.toHaveAttribute('data-plass-landed');

    // Time for its clock to count, which goes on from when the run began.
    await new Promise((resolve) => setTimeout(resolve, 250));
    await emulateMedia({ reducedMotion: 'no-preference' });

    const animation = keyframe(target());
    const timing = animation.effect!.getComputedTiming();

    expect(animation.playState).toBe('running');
    expect(timing.iterations).toBe(5);
    expect(timing.duration).toBe(long);
    expect(Number(animation.currentTime)).toBeGreaterThanOrEqual(250);
    expect(Number(opacity(target()))).toBeLessThan(1);
  });

  it('leaves an endless run given a finite count while the setting was on at its end once its clock is past it', async () => {
    const screen = await render(pulse('infinite', { duration: 40 }));

    await expect.poll(() => keyframe(target()).playState, { timeout: landing }).toBe('finished');
    await screen.rerender(pulse(5, { duration: 40 }));

    // Past five passes of 40ms by the time the setting goes.
    await new Promise((resolve) => setTimeout(resolve, 400));
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('finished');
    expect(opacity(target())).toBe('1');
  });

  it('leaves an endless run given a finite count while `paused` held it on its frame until it is let go', async () => {
    const screen = await render(pulse('infinite', { duration: long }));

    await expect.poll(() => keyframe(target()).playState, { timeout: landing }).toBe('finished');
    await screen.rerender(pulse('infinite', { duration: long, paused: true }));
    await screen.rerender(pulse(5, { duration: long, paused: true }));
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(keyframe(target()).playState).toBe('paused');
    expect(opacity(target())).toBe('1');

    // Let go, it goes on from where its clock stopped, which is where it
    // landed, the start of a pass.
    await screen.rerender(pulse(5, { duration: long }));

    await expect.poll(() => keyframe(target()).playState).toBe('running');
    expect(keyframe(target()).effect!.getComputedTiming().iterations).toBe(5);
    expect(Number(opacity(target()))).toBeLessThan(1);
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

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
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

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
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
    // The page hears that the setting changed a frame or more after it did,
    // so it is the pause's mark that is waited for rather than a fixed time.
    await expect.poll(() => target().hasAttribute('data-plass-held')).toBe(true);

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

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
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

      await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);

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

  it('leaves a finite PlAnimateLighting that landed where it landed when it is given more passes', async () => {
    const ended = vi.fn();
    const lighting = (repeat: number) => (
      <PlAnimateLighting
        className="effect-under-test"
        duration={long}
        repeat={repeat}
        onAnimationEnd={ended}
      >
        <div style={{ height: '80px' }}>Glowing</div>
      </PlAnimateLighting>
    );
    const screen = await render(lighting(1));

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
    await screen.rerender(lighting(2));
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(running(target())).toEqual([]);
    expect(['0deg', '360deg']).toContain(angle());

    await screen.rerender(lighting(3));

    expect(running(target())).toEqual([]);
    expect(['0deg', '360deg']).toContain(angle());
  });

  it('leaves a finite PlAnimateMarquee that landed where it landed when it is given more passes', async () => {
    const ended = vi.fn();
    const marquee = (repeat: number) => (
      <PlAnimateMarquee
        className="effect-under-test"
        duration={long}
        repeat={repeat}
        style={{ width: 200, height: 40 }}
        onAnimationEnd={ended}
      >
        <span style={{ display: 'block', width: 300, height: 80 }}>Headline</span>
      </PlAnimateMarquee>
    );
    const screen = await render(marquee(1));

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
    await screen.rerender(marquee(2));
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(running(target())).toEqual([]);
    expect(tracks().map((track) => getComputedStyle(track).translate)).toEqual(['none', 'none']);

    await screen.rerender(marquee(3));

    expect(running(target())).toEqual([]);
    expect(tracks().map((track) => getComputedStyle(track).translate)).toEqual(['none', 'none']);
  });

  it('leaves a finite PlAnimateLighting that landed where it landed when it is given an endless count', async () => {
    const ended = vi.fn();
    const lighting = (repeat: number | 'infinite') => (
      <PlAnimateLighting
        className="effect-under-test"
        duration={long}
        repeat={repeat}
        onAnimationEnd={ended}
      >
        <div style={{ height: '80px' }}>Glowing</div>
      </PlAnimateLighting>
    );
    const screen = await render(lighting(1));

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
    await screen.rerender(lighting('infinite'));

    expect(running(target())).toEqual([]);

    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(running(target())).toEqual([]);
    expect(['0deg', '360deg']).toContain(angle());
  });

  it('leaves a finite PlAnimateMarquee that landed where it landed when it is given an endless count', async () => {
    const ended = vi.fn();
    const marquee = (repeat: number | 'infinite') => (
      <PlAnimateMarquee
        className="effect-under-test"
        duration={long}
        repeat={repeat}
        style={{ width: 200, height: 40 }}
        onAnimationEnd={ended}
      >
        <span style={{ display: 'block', width: 300, height: 80 }}>Headline</span>
      </PlAnimateMarquee>
    );
    const screen = await render(marquee(1));

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
    await screen.rerender(marquee('infinite'));

    expect(running(target())).toEqual([]);

    await emulateReducedMotion('no-preference');

    expect(running(target())).toEqual([]);
    expect(getComputedStyle(tracks()[1]).display).toBe('flex');
    expect(tracks().map((track) => getComputedStyle(track).translate)).toEqual(['none', 'none']);
  });

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

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
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

  it('leaves an endless PlAnimateLighting given a finite count while the setting was on where it lands', async () => {
    const ended = vi.fn();
    const lighting = (repeat: number | 'infinite') => (
      <PlAnimateLighting
        className="effect-under-test"
        duration={long}
        repeat={repeat}
        onAnimationEnd={ended}
      >
        <div style={{ height: '80px' }}>Glowing</div>
      </PlAnimateLighting>
    );
    const screen = await render(lighting('infinite'));

    await frame();
    await screen.rerender(lighting(5));

    // Switched off under the setting, it has a keyframe again that ends, which
    // lands in no time.
    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(running(target())).toEqual([]);
    expect(['0deg', '360deg']).toContain(angle());
  });

  it('leaves an endless PlAnimateMarquee given a finite count while the setting was on where it lands', async () => {
    const ended = vi.fn();
    const marquee = (repeat: number | 'infinite') => (
      <PlAnimateMarquee
        className="effect-under-test"
        duration={long}
        repeat={repeat}
        style={{ width: 200, height: 40 }}
        onAnimationEnd={ended}
      >
        <span style={{ display: 'block', width: 300, height: 80 }}>Headline</span>
      </PlAnimateMarquee>
    );
    const screen = await render(marquee('infinite'));

    await frame();
    await screen.rerender(marquee(5));

    await expect.poll(() => ended.mock.calls.length, { timeout: landing }).toBe(1);
    await emulateReducedMotion('no-preference');

    expect(running(target())).toEqual([]);
    expect(tracks().map((track) => getComputedStyle(track).translate)).toEqual(['none', 'none']);
  });

  it('plays the count an endless PlAnimateLighting was given while the setting was on when the setting goes before its delay is over', async () => {
    const ended = vi.fn();
    const lighting = (repeat: number | 'infinite') => (
      <PlAnimateLighting
        className="effect-under-test"
        duration={long}
        delay={long}
        repeat={repeat}
        onAnimationEnd={ended}
      >
        <div style={{ height: '80px' }}>Glowing</div>
      </PlAnimateLighting>
    );
    const screen = await render(lighting('infinite'));

    await screen.rerender(lighting(5));

    // The keyframe the count gives it back waits out its delay before it can
    // land, and the setting goes long before that.
    expect(target().getAnimations({ subtree: true })).toHaveLength(1);
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(ended).not.toHaveBeenCalled();
    expect(target()).not.toHaveAttribute('data-plass-landed');

    const [arc] = running(target());

    // Still waiting out its delay, and then the whole count.
    expect(arc.effect!.getComputedTiming()).toMatchObject({
      delay: long,
      duration: long,
      iterations: 5
    });
    expect(Number(arc.currentTime)).toBeLessThan(long);
  });

  it('plays the count an endless PlAnimateMarquee was given while the setting was on when the setting goes before its delay is over', async () => {
    const ended = vi.fn();
    const marquee = (repeat: number | 'infinite') => (
      <PlAnimateMarquee
        className="effect-under-test"
        duration={long}
        delay={long}
        repeat={repeat}
        style={{ width: 200, height: 40 }}
        onAnimationEnd={ended}
      >
        <span style={{ display: 'block', width: 300, height: 80 }}>Headline</span>
      </PlAnimateMarquee>
    );
    const screen = await render(marquee('infinite'));

    await screen.rerender(marquee(5));

    expect(target().getAnimations({ subtree: true })).toHaveLength(1);
    await emulateReducedMotion('no-preference');

    expect(ended).not.toHaveBeenCalled();
    expect(target()).not.toHaveAttribute('data-plass-landed');
    expect(running(target())).toHaveLength(2);

    for (const strip of running(target())) {
      expect(strip.effect!.getComputedTiming()).toMatchObject({ delay: long, iterations: 5 });
      expect(Number(strip.currentTime)).toBeLessThan(long);
    }
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

    // The page hears that the setting changed a frame or more after it did,
    // and the light is even under the setting before the pause marks it held,
    // so it is the mark that is waited for rather than a fixed time.
    await expect.poll(() => target().hasAttribute('data-plass-held')).toBe(true);
    expect(even()).toBe(true);

    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(even()).toBe(true);
  });

  for (const [delay, again] of [
    [0, false],
    [300, false],
    [300, true]
  ] as const) {
    const setting = again ? 'comes and goes again' : 'goes';

    it(`plays an endless PlAnimateLighting given a finite count while \`paused\` held it under the setting from its start once it is let go after the setting ${setting}, with a delay of ${delay}ms`, async () => {
      const lighting = (repeat: number | 'infinite', paused: boolean) => (
        <PlAnimateLighting
          className="effect-under-test"
          duration={long}
          delay={delay}
          repeat={repeat}
          paused={paused}
        >
          <div style={{ height: '80px' }}>Glowing</div>
        </PlAnimateLighting>
      );
      const screen = await render(lighting('infinite', false));

      await screen.rerender(lighting('infinite', true));
      await expect.poll(() => target().hasAttribute('data-plass-held')).toBe(true);
      await screen.rerender(lighting(5, true));

      // The keyframe the count gives it back is held before its run, so it
      // does not land.
      expect(
        target()
          .getAnimations({ subtree: true })
          .map(({ playState }) => playState)
      ).toEqual(['paused']);

      await emulateMedia({ reducedMotion: 'no-preference' });

      if (again) {
        await emulateMedia({ reducedMotion: 'reduce' });
        await emulateMedia({ reducedMotion: 'no-preference' });
      }

      expect(running(target())).toEqual([]);
      expect(target()).not.toHaveAttribute('data-plass-landed');
      expect(even()).toBe(true);

      await screen.rerender(lighting(5, false));

      // Let go, it plays the whole count from its start.
      expect(even()).toBe(false);
      await expect.poll(() => running(target()).length).toBe(1);

      const [arc] = running(target());

      expect(arc.effect!.getComputedTiming()).toMatchObject({ duration: long, iterations: 5 });
      expect(Number(arc.currentTime)).toBeLessThan(long);
    });
  }

  it('leaves an endless PlAnimateLighting given a finite count while `paused` held it under the setting where it lands when the setting comes back to the start of its run', async () => {
    const lighting = (repeat: number | 'infinite', paused: boolean) => (
      <PlAnimateLighting
        className="effect-under-test"
        duration={long}
        repeat={repeat}
        paused={paused}
      >
        <div style={{ height: '80px' }}>Glowing</div>
      </PlAnimateLighting>
    );
    const screen = await render(lighting('infinite', false));

    await screen.rerender(lighting('infinite', true));
    await expect.poll(() => target().hasAttribute('data-plass-held')).toBe(true);
    await screen.rerender(lighting(5, true));
    await emulateMedia({ reducedMotion: 'no-preference' });

    // With no delay, the paused keyframe stands at the start of its run, which
    // keeps the delay it started with.
    await expect.poll(() => target().style.getPropertyValue('--p-anim-run-delay')).not.toBe('');
    await emulateMedia({ reducedMotion: 'reduce' });

    // The setting runs it in no time, which lands it.
    await expect
      .poll(() => target().hasAttribute('data-plass-landed'), { timeout: landing })
      .toBe(true);
    await emulateMedia({ reducedMotion: 'no-preference' });

    expect(even()).toBe(true);

    await screen.rerender(lighting(5, false));

    // Let go, it stands where a turn ends, which is where it begins.
    expect(running(target())).toEqual([]);
    expect(even()).toBe(false);
    expect(['0deg', '360deg']).toContain(angle());
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

    for (const [delay, again] of [
      [0, false],
      [300, false],
      [300, true]
    ] as const) {
      const setting = again ? 'comes and goes again' : 'goes';

      it(`plays an endless ${orientation} PlAnimateMarquee given a finite count while \`paused\` held it under the setting from its start once it is let go after the setting ${setting}, with a delay of ${delay}ms`, async () => {
        const marquee = (repeat: number | 'infinite', paused: boolean) => (
          <PlAnimateMarquee
            className="effect-under-test"
            orientation={orientation}
            duration={long}
            delay={delay}
            repeat={repeat}
            paused={paused}
            style={{ width: 200, height: 40 }}
          >
            <span style={{ display: 'block', width: 300, height: 80 }}>Headline</span>
          </PlAnimateMarquee>
        );
        const screen = await render(marquee('infinite', false));

        await screen.rerender(marquee('infinite', true));
        await expect.poll(() => target().hasAttribute('data-plass-held')).toBe(true);
        await screen.rerender(marquee(5, true));

        // The keyframe the count gives it back is held before its run, so it
        // does not land.
        expect(
          target()
            .getAnimations({ subtree: true })
            .map(({ playState }) => playState)
        ).toEqual(['paused']);

        await emulateReducedMotion('no-preference');

        if (again) {
          await emulateReducedMotion('reduce');
          await emulateReducedMotion('no-preference');
        }

        expect(running(target())).toEqual([]);
        expect(target()).not.toHaveAttribute('data-plass-landed');
        expect(scrolling(orientation)).toBe(true);
        expect(unmoved(tracks()[0])).toBe(true);

        await screen.rerender(marquee(5, false));

        // Let go, both copies play the whole count from their start.
        expect(scrolling(orientation)).toBe(false);
        await expect.poll(() => running(target()).length).toBe(2);

        for (const strip of running(target())) {
          expect(strip.effect!.getComputedTiming().iterations).toBe(5);
          expect(Number(strip.currentTime)).toBeLessThan(
            Number(strip.effect!.getComputedTiming().duration)
          );
        }
      });
    }

    it(`leaves an endless ${orientation} PlAnimateMarquee given a finite count while \`paused\` held it under the setting where it lands when the setting comes back to the start of its run`, async () => {
      const marquee = (repeat: number | 'infinite', paused: boolean) => (
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
      const screen = await render(marquee('infinite', false));

      await screen.rerender(marquee('infinite', true));
      await expect.poll(() => target().hasAttribute('data-plass-held')).toBe(true);
      await screen.rerender(marquee(5, true));
      await emulateReducedMotion('no-preference');

      // With no delay, the paused keyframe stands at the start of its run,
      // which keeps the delay it started with.
      await expect
        .poll(() => tracks()[0].style.getPropertyValue('--p-anim-run-delay'))
        .not.toBe('');
      await emulateReducedMotion('reduce');

      // The setting runs it in no time, which lands it.
      await expect
        .poll(() => target().hasAttribute('data-plass-landed'), { timeout: landing })
        .toBe(true);
      await emulateReducedMotion('no-preference');

      expect(scrolling(orientation)).toBe(true);

      await screen.rerender(marquee(5, false));

      // Let go, both copies stand where the strip started.
      expect(running(target())).toEqual([]);
      expect(scrolling(orientation)).toBe(false);
      expect(tracks().map(unmoved)).toEqual([true, true]);
    });
  }
});
