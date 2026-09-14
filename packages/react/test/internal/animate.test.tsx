import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import * as React from 'react';
import {
  PlAnimateAppear,
  PlAnimateBlink,
  PlAnimateCounter,
  PlAnimateFade,
  PlAnimateFloat,
  PlAnimateGrow,
  PlAnimateHeadline,
  PlAnimateLighting,
  PlAnimateMarquee,
  PlAnimateReveal,
  PlAnimateRotate,
  PlAnimateScramble,
  PlAnimateShake,
  PlAnimateSlide,
  PlAnimateSplit,
  PlAnimateTyping,
  PlAnimateZoom
} from 'plass-ui';

interface HoverProps {
  className: string;
  tabIndex: number;
  onPointerEnter: () => void;
  onFocus: () => void;
}

/**
 * Every `PlAnimate*` that takes a hover trigger, each drawn with the least it
 * needs to render.
 *
 * All of them, rather than one of each ordering: which way round a component
 * put its spreads was decided file by file, so a table is the only way to know
 * none of them was missed.
 */
const subjects: [string, (props: HoverProps) => React.ReactElement][] = [
  [
    'PlAnimateAppear',
    (props) => (
      <PlAnimateAppear trigger="hover" {...props}>
        Hi
      </PlAnimateAppear>
    )
  ],
  [
    'PlAnimateBlink',
    (props) => (
      <PlAnimateBlink trigger="hover" {...props}>
        Hi
      </PlAnimateBlink>
    )
  ],
  ['PlAnimateCounter', (props) => <PlAnimateCounter trigger="hover" value={10} {...props} />],
  [
    'PlAnimateFade',
    (props) => (
      <PlAnimateFade trigger="hover" {...props}>
        Hi
      </PlAnimateFade>
    )
  ],
  [
    'PlAnimateFloat',
    (props) => (
      <PlAnimateFloat trigger="hover" {...props}>
        Hi
      </PlAnimateFloat>
    )
  ],
  [
    'PlAnimateGrow',
    (props) => (
      <PlAnimateGrow trigger="hover" {...props}>
        Hi
      </PlAnimateGrow>
    )
  ],
  [
    'PlAnimateHeadline',
    (props) => (
      <PlAnimateHeadline trigger="hover" {...props}>
        <span>One</span>
        <span>Two</span>
      </PlAnimateHeadline>
    )
  ],
  [
    'PlAnimateLighting',
    (props) => (
      <PlAnimateLighting trigger="hover" {...props}>
        Hi
      </PlAnimateLighting>
    )
  ],
  [
    'PlAnimateMarquee',
    (props) => (
      <PlAnimateMarquee trigger="hover" {...props}>
        Hi
      </PlAnimateMarquee>
    )
  ],
  [
    'PlAnimateReveal',
    (props) => (
      <PlAnimateReveal trigger="hover" {...props}>
        Hi
      </PlAnimateReveal>
    )
  ],
  [
    'PlAnimateRotate',
    (props) => (
      <PlAnimateRotate trigger="hover" {...props}>
        Hi
      </PlAnimateRotate>
    )
  ],
  [
    'PlAnimateScramble',
    (props) => (
      <PlAnimateScramble trigger="hover" {...props}>
        Hi
      </PlAnimateScramble>
    )
  ],
  [
    'PlAnimateShake',
    (props) => (
      <PlAnimateShake trigger="hover" {...props}>
        Hi
      </PlAnimateShake>
    )
  ],
  [
    'PlAnimateSlide',
    (props) => (
      <PlAnimateSlide trigger="hover" {...props}>
        Hi
      </PlAnimateSlide>
    )
  ],
  [
    'PlAnimateSplit',
    (props) => (
      <PlAnimateSplit trigger="hover" {...props}>
        Hi there
      </PlAnimateSplit>
    )
  ],
  ['PlAnimateTyping', (props) => <PlAnimateTyping trigger="hover" text="Hi" {...props} />],
  [
    'PlAnimateZoom',
    (props) => (
      <PlAnimateZoom trigger="hover" {...props}>
        Hi
      </PlAnimateZoom>
    )
  ]
];

function root(): HTMLElement {
  return document.querySelector<HTMLElement>('.animate-under-test')!;
}

function hoverProps(): HoverProps {
  return {
    className: 'animate-under-test',
    tabIndex: 0,
    onPointerEnter: vi.fn(),
    onFocus: vi.fn()
  };
}

describe('the hover trigger beside a caller’s own handlers', () => {
  describe.each(subjects)('%s', (_, draw) => {
    it('starts on the pointer and still calls the caller’s `onPointerEnter`', async () => {
      const props = hoverProps();

      await render(draw(props));

      expect(root()).toHaveAttribute('data-state', 'paused');

      // A DOM event rather than a real pointer: React reads `pointerover` as the
      // pointer entering, and nothing here depends on where the element is drawn.
      root().dispatchEvent(new PointerEvent('pointerover', { bubbles: true }));

      await expect.poll(() => root().getAttribute('data-state')).toBe('running');
      expect(props.onPointerEnter).toHaveBeenCalledTimes(1);
    });

    it('starts on focus and still calls the caller’s `onFocus`', async () => {
      const props = hoverProps();

      await render(draw(props));

      expect(root()).toHaveAttribute('data-state', 'paused');

      root().focus();

      await expect.poll(() => root().getAttribute('data-state')).toBe('running');
      expect(props.onFocus).toHaveBeenCalledTimes(1);
    });
  });
});
