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

/**
 * Counts the rewinds an element goes through.
 *
 * A rewind clears `animation-name` inline and puts it back, and that shows as a
 * change to the `style` attribute whose old value mentions `animation-name`.
 * Watching for it is how a test without the stylesheet can tell a rewound
 * element from one that was left alone.
 */
function watchRewinds(element: HTMLElement): () => number {
  let rewinds = 0;

  const count = (records: MutationRecord[]) => {
    for (const record of records) {
      if (record.oldValue?.includes('animation-name')) {
        rewinds += 1;
      }
    }
  };

  const observer = new MutationObserver(count);

  observer.observe(element, {
    attributes: true,
    attributeFilter: ['style'],
    attributeOldValue: true
  });

  return () => {
    count(observer.takeRecords());

    return rewinds;
  };
}

describe('restarting an animation', () => {
  it('leaves another `PlAnimate*` nested inside it alone', async () => {
    function Subject() {
      const [attempts, setAttempts] = React.useState(0);

      return (
        <div>
          <button type="button" onClick={() => setAttempts((count) => count + 1)}>
            Submit
          </button>
          <PlAnimateShake className="shake-under-test" replay={attempts}>
            <PlAnimateFade className="fade-under-test">Wrong password</PlAnimateFade>
          </PlAnimateShake>
        </div>
      );
    }

    await render(<Subject />);

    const shake = document.querySelector<HTMLElement>('.shake-under-test')!;
    const fade = document.querySelector<HTMLElement>('.fade-under-test')!;
    const shakeRewinds = watchRewinds(shake);
    const fadeRewinds = watchRewinds(fade);

    document.querySelector('button')!.click();

    await expect.poll(() => shake.getAttribute('data-state')).toBe('running');

    // The shake is what was asked to play again. The message inside it has
    // already arrived, and fading it in on every refusal would be a second
    // entrance nobody asked for.
    expect(shakeRewinds()).toBeGreaterThan(0);
    expect(fadeRewinds()).toBe(0);
  });

  it('still rewinds the children it wrote a stagger onto', async () => {
    function Subject() {
      const [playing, setPlaying] = React.useState(false);

      return (
        <div>
          <button type="button" onClick={() => setPlaying(true)}>
            Play
          </button>
          <PlAnimateFade className="fade-under-test" trigger="manual" play={playing} stagger={50}>
            <span className="first-child">One</span>
            <span>Two</span>
          </PlAnimateFade>
        </div>
      );
    }

    await render(<Subject />);

    const fade = document.querySelector<HTMLElement>('.fade-under-test')!;
    const childRewinds = watchRewinds(document.querySelector<HTMLElement>('.first-child')!);

    document.querySelector('button')!.click();

    await expect.poll(() => fade.getAttribute('data-state')).toBe('running');

    expect(childRewinds()).toBeGreaterThan(0);
  });
});
