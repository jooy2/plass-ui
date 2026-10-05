/**
 * What an `interactive` card's lift does under reduced motion, and where a
 * `headerAction` sits against the title, both of which the stylesheet decides.
 *
 * The lift is a `hover:` translate eased by the card's own transition, so the
 * assertion is on the transition that applies to `transform`, read with
 * `src/standalone.css` loaded the way `marquee.test.tsx` loads it. Nothing here
 * hovers, so no pointer and no timing is involved.
 *
 * The header action is read from the boxes: its middle against the middle of
 * the title's first line, and its edges against the header row's. No height
 * from the type scale or the size ladder is asserted, only that the two agree.
 */
import type { ReactNode } from 'react';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlButton, PlCard, PlIconButton, type PlassSize } from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';
import { emulateMedia } from '../support/media';

const SIZES: PlassSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

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

/**
 * The duration the card's transition gives `property`, in seconds. The two
 * lists pair up by position, and a shorter duration list repeats, as CSS
 * reads them.
 */
function durationOf(element: HTMLElement, property: string): number {
  const style = getComputedStyle(element);
  const properties = style.transitionProperty.split(',').map((one) => one.trim());
  const durations = style.transitionDuration.split(',').map((one) => parseFloat(one));
  const index = properties.indexOf(property);

  expect(index).not.toBe(-1);

  return durations[index % durations.length];
}

describe('the card stylesheet', () => {
  it('eases an interactive card’s lift', async () => {
    await render(
      <PlCard className="card-under-test" interactive>
        Body
      </PlCard>
    );

    const card = document.querySelector('.card-under-test') as HTMLElement;

    expect(durationOf(card, 'transform')).toBeGreaterThan(0);
  });

  it('lifts an interactive card at once under reduced motion', async () => {
    await emulateMedia({ reducedMotion: 'reduce' });

    await render(
      <PlCard className="card-under-test" interactive>
        Body
      </PlCard>
    );

    const card = document.querySelector('.card-under-test') as HTMLElement;

    expect(durationOf(card, 'transform')).toBe(0);
  });
});

/** The vertical middle of `element`'s box. */
function middleOf(element: Element): number {
  const box = element.getBoundingClientRect();

  return box.top + box.height / 2;
}

/**
 * The vertical middle of the first line of text in `element`: its top, which is
 * the top of that line, and half the line it sets.
 */
function firstLineMiddleOf(element: Element): number {
  return element.getBoundingClientRect().top + parseFloat(getComputedStyle(element).lineHeight) / 2;
}

/**
 * Renders a card with `action` in its header and returns the header row, the
 * element holding the title's text and the element holding the action.
 */
async function renderHeader({
  size = 'md',
  width = 320,
  title,
  subtitle,
  action
}: {
  size?: PlassSize;
  width?: number;
  title?: ReactNode;
  subtitle?: ReactNode;
  action: ReactNode;
}) {
  await render(
    <PlCard
      className="card-under-test"
      size={size}
      style={{ width }}
      title={title}
      subtitle={subtitle}
      headerAction={action}
    >
      Body
    </PlCard>
  );

  const card = document.querySelector('.card-under-test') as HTMLElement;
  const header = card.firstElementChild as HTMLElement;
  const body = card.lastElementChild as HTMLElement;

  return { header, body, action: header.querySelector('[data-action]') as HTMLElement };
}

/** A pixel either way, for the rounding each engine does to a line box. */
function expectNear(actual: number, expected: number) {
  expect(Math.abs(actual - expected)).toBeLessThanOrEqual(1);
}

/** The action sits wholly inside the header row, and the body starts below it. */
function expectInside(action: HTMLElement, header: HTMLElement, body: HTMLElement) {
  const box = action.getBoundingClientRect();
  const row = header.getBoundingClientRect();

  expect(box.top).toBeGreaterThanOrEqual(row.top - 1);
  expect(box.bottom).toBeLessThanOrEqual(row.bottom + 1);
  expect(body.getBoundingClientRect().top).toBeGreaterThanOrEqual(box.bottom);
}

describe('a header action', () => {
  it.each(SIZES)('centres on a one-line title, and the header holds it, at %s', async (size) => {
    const { header, body, action } = await renderHeader({
      size,
      title: <span data-title>Billing</span>,
      action: <PlIconButton data-action size={size} label="More" icon={<span>•</span>} />
    });
    const title = header.querySelector('[data-title]')!.parentElement!;

    expectNear(middleOf(action), firstLineMiddleOf(title));
    expectInside(action, header, body);
  });

  it.each(SIZES)('moves itself rather than the title when it is shorter, at %s', async (size) => {
    const { header, body, action } = await renderHeader({
      size,
      title: <span data-title>Billing</span>,
      action: <span data-action style={{ display: 'block', width: 8, height: 8 }} />
    });
    const title = header.querySelector('[data-title]')!.parentElement!;

    expectNear(middleOf(action), firstLineMiddleOf(title));
    expectNear(title.getBoundingClientRect().top, header.getBoundingClientRect().top);
    expectInside(action, header, body);
  });

  it('stays on the first line of a title that wraps', async () => {
    const { header, action } = await renderHeader({
      width: 200,
      title: <span data-title>Quarterly billing summary for the whole team</span>,
      action: <PlIconButton data-action label="More" icon={<span>•</span>} />
    });
    const title = header.querySelector('[data-title]')!.parentElement!;

    // Wrapped, or the test is not about a wrapping title.
    expect(title.getBoundingClientRect().height).toBeGreaterThan(
      parseFloat(getComputedStyle(title).lineHeight) * 1.5
    );
    expectNear(middleOf(action), firstLineMiddleOf(title));
  });

  it('centres a labelled button on the title rather than lining up its label', async () => {
    const { header, body, action } = await renderHeader({
      title: <span data-title>Billing</span>,
      action: (
        <PlButton data-action size="sm">
          Edit
        </PlButton>
      )
    });
    const title = header.querySelector('[data-title]')!.parentElement!;

    expectNear(middleOf(action), firstLineMiddleOf(title));
    expectInside(action, header, body);
  });

  it('centres on the title when a subtitle is under it', async () => {
    const { header, body, action } = await renderHeader({
      title: <span data-title>Billing</span>,
      subtitle: 'Visa ending 4242',
      action: <PlIconButton data-action label="More" icon={<span>•</span>} />
    });
    const title = header.querySelector('[data-title]')!.parentElement!;

    expectNear(middleOf(action), firstLineMiddleOf(title));
    expectInside(action, header, body);
  });

  it.each(SIZES)('centres on the subtitle when there is no title, at %s', async (size) => {
    const { header, body, action } = await renderHeader({
      size,
      subtitle: <span data-subtitle>Visa ending 4242</span>,
      action: <PlIconButton data-action size={size} label="More" icon={<span>•</span>} />
    });
    const subtitle = header.querySelector('[data-subtitle]')!.parentElement!;

    expectNear(middleOf(action), firstLineMiddleOf(subtitle));
    expectInside(action, header, body);
  });

  it.each(SIZES)('centres on a heading passed as the title, at %s', async (size) => {
    const { header, body, action } = await renderHeader({
      size,
      title: <h2>Billing</h2>,
      action: <PlIconButton data-action size={size} label="More" icon={<span>•</span>} />
    });
    const heading = header.querySelector('h2')!;

    expectNear(middleOf(action), firstLineMiddleOf(heading));
    expectInside(action, header, body);
  });

  it('is centred with a line the stylesheet draws rather than the markup holds', async () => {
    const { header } = await renderHeader({
      title: 'Billing',
      action: <PlIconButton data-action label="More" icon={<span>•</span>} />
    });
    const strut = header.querySelector('.plass-strut')!;

    expect(strut.textContent).toBe('');
    expect(getComputedStyle(strut, '::before').content).toBe('"\u200b"');
  });

  it('sits at the top of a header that holds nothing else', async () => {
    const { header, body, action } = await renderHeader({
      action: <PlIconButton data-action label="More" icon={<span>•</span>} />
    });

    expectNear(action.getBoundingClientRect().top, header.getBoundingClientRect().top);
    expectInside(action, header, body);
  });
});
