/**
 * What an effect inside another effect reads, which is its own slots.
 *
 * Every effect writes its `--p-anim-*` slots inline and the stylesheet reads
 * them, and a custom property is inherited, so a slot an inner effect leaves
 * out is whatever an outer one wrote. Which slot a keyframe reads is decided
 * in `src/standalone.css`, loaded here the way `animate-reduced.test.tsx`
 * loads it. Each case compares the inner effect with the same effect on its
 * own, so nothing here pins a curve or a shade.
 */
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import * as React from 'react';
import {
  PlAnimateBlink,
  PlAnimateFade,
  PlAnimateFloat,
  PlAnimateGrow,
  PlAnimateHeadline,
  PlAnimateLighting,
  PlAnimateMarquee,
  PlAnimateReveal,
  PlAnimateRotate,
  PlAnimateShake,
  PlAnimateSlide,
  PlAnimateZoom
} from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

afterEach(async () => {
  await emulateMedia({ reducedMotion: 'no-preference' });
});

/** The inner effect, and the same effect rendered on its own beside it. */
function inner(): HTMLElement {
  return document.querySelector('.inner-under-test') as HTMLElement;
}

function alone(): HTMLElement {
  return document.querySelector('.alone-under-test') as HTMLElement;
}

/**
 * An outer effect for every conditional slot there is: a curve, a reduced-
 * motion count, a scroll timeline, and a start state in every slot a keyframe
 * reads, each of them different from the defaults.
 */
function Outer({ children }: { children: React.ReactNode }) {
  return (
    <PlAnimateSlide from="left" distance={50} easing="steps(4)" repeat="infinite">
      <PlAnimateGrow from={0.3} fade={false}>
        <PlAnimateReveal from="top" fade>
          <PlAnimateRotate from={33} to={77} easing="linear" repeat="infinite">
            <PlAnimateFade timeline="view" from={0.4}>
              {children}
            </PlAnimateFade>
          </PlAnimateRotate>
        </PlAnimateReveal>
      </PlAnimateGrow>
    </PlAnimateSlide>
  );
}

/** What a keyframe effect draws and how it runs, the properties its slots feed. */
function reading(element: HTMLElement) {
  const style = getComputedStyle(element);

  return {
    timing: style.animationTimingFunction,
    count: style.animationIterationCount,
    opacity: style.opacity,
    scale: style.scale,
    translate: style.translate,
    rotate: style.rotate,
    clip: style.clipPath,
    // A scroll-linked keyframe is on a view timeline rather than the page's.
    clock: element.getAnimations()[0]?.timeline === document.timeline
  };
}

describe('an effect inside another effect', () => {
  it('eases on its own curve inside an endless linear turn', async () => {
    await render(
      <>
        <PlAnimateRotate repeat="infinite" easing="linear">
          <PlAnimateFade className="inner-under-test">Arriving</PlAnimateFade>
        </PlAnimateRotate>
        <PlAnimateFade className="alone-under-test">Arriving</PlAnimateFade>
      </>
    );

    expect(getComputedStyle(inner()).animationTimingFunction).toBe(
      getComputedStyle(alone()).animationTimingFunction
    );
  });

  it('ends where its own run ends inside an endless turn, under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    await render(
      <PlAnimateRotate repeat="infinite">
        <PlAnimateFade className="inner-under-test" alternate repeat={2}>
          Blinking once
        </PlAnimateFade>
      </PlAnimateRotate>
    );

    // Out and back: the second pass runs backwards, so it finishes faded out.
    await expect.poll(() => getComputedStyle(inner()).opacity).toBe('0');
  });

  it('runs on the clock inside an effect that follows the scroll', async () => {
    await render(
      <PlAnimateFade timeline="view">
        <PlAnimateFade className="inner-under-test" duration={60_000}>
          Arriving
        </PlAnimateFade>
      </PlAnimateFade>
    );

    expect(inner().getAnimations()[0].timeline).toBe(document.timeline);
  });

  for (const [name, effect] of [
    ['PlAnimateFade', PlAnimateFade],
    ['PlAnimateGrow', PlAnimateGrow],
    ['PlAnimateZoom', PlAnimateZoom],
    ['PlAnimateSlide', PlAnimateSlide],
    ['PlAnimateRotate', PlAnimateRotate],
    ['PlAnimateReveal', PlAnimateReveal],
    ['PlAnimateBlink', PlAnimateBlink],
    ['PlAnimateShake', PlAnimateShake],
    ['PlAnimateFloat', PlAnimateFloat]
  ] as const) {
    it(`draws a waiting ${name} from its own first frame, and runs it as its own`, async () => {
      const Effect = effect as React.ComponentType<Record<string, unknown>>;

      await render(
        <>
          <Outer>
            <Effect className="inner-under-test" trigger="manual">
              Waiting
            </Effect>
          </Outer>
          <Effect className="alone-under-test" trigger="manual">
            Waiting
          </Effect>
        </>
      );

      expect(reading(inner())).toEqual(reading(alone()));
    });
  }

  it('turns the arc of a PlAnimateLighting on its own curve', async () => {
    await render(
      <>
        <PlAnimateFade easing="ease-in">
          <PlAnimateLighting className="inner-under-test">
            <span>Glowing</span>
          </PlAnimateLighting>
        </PlAnimateFade>
        <PlAnimateLighting className="alone-under-test">
          <span>Glowing</span>
        </PlAnimateLighting>
      </>
    );

    expect(getComputedStyle(inner(), '::before').animationTimingFunction).toBe(
      getComputedStyle(alone(), '::before').animationTimingFunction
    );
  });

  it('runs the strip of a PlAnimateMarquee on its own curve', async () => {
    await render(
      <>
        <PlAnimateFade easing="ease-in">
          <PlAnimateMarquee className="inner-under-test">
            <span>Headline</span>
          </PlAnimateMarquee>
        </PlAnimateFade>
        <PlAnimateMarquee className="alone-under-test">
          <span>Headline</span>
        </PlAnimateMarquee>
      </>
    );

    const track = (root: HTMLElement) => root.querySelector('.plass-marquee-track') as HTMLElement;

    expect(getComputedStyle(track(inner())).animationTimingFunction).toBe(
      getComputedStyle(track(alone())).animationTimingFunction
    );
  });

  it('turns the lines of a PlAnimateHeadline on its own curve', async () => {
    await render(
      <>
        <PlAnimateFade easing="ease-in">
          <PlAnimateHeadline className="inner-under-test">
            <span>First</span>
            <span>Second</span>
          </PlAnimateHeadline>
        </PlAnimateFade>
        <PlAnimateHeadline className="alone-under-test">
          <span>First</span>
          <span>Second</span>
        </PlAnimateHeadline>
      </>
    );

    const line = (root: HTMLElement) => root.querySelector('.plass-headline-item') as HTMLElement;

    expect(getComputedStyle(line(inner())).animationTimingFunction).toBe(
      getComputedStyle(line(alone())).animationTimingFunction
    );
  });
});
