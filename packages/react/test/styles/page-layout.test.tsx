/**
 * Which of a `PlPageLayout`'s parts is on top where two of them meet, which only
 * the stylesheet can answer.
 *
 * A `PlSidebar`'s resize handle straddles the sidebar's inner edge, so its
 * outer half lies over a header or a footer that spans only the content. A
 * pinned bar is `z-20`, and without the real CSS loaded neither that nor the
 * sidebar's own stacking context exists, so nothing is on top of anything.
 * Loaded the way `back-top.test.tsx` loads it, and read with
 * `document.elementFromPoint`, which is what a press goes to.
 */
import type { ReactElement } from 'react';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlFooter,
  PlHeader,
  PlPageLayout,
  PlSidebar,
  type PlPageLayoutScroll,
  type PlassPosition
} from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

afterEach(() => {
  window.scrollTo(0, 0);
});

const frame = () =>
  new Promise<void>((resolve) =>
    requestAnimationFrame(() => requestAnimationFrame(() => resolve()))
  );

const handle = () => document.querySelector<HTMLElement>('[role="separator"]')!;

/** Whether a point lies inside a box. */
const inside = (rect: DOMRect, x: number, y: number) =>
  x > rect.left && x < rect.right && y > rect.top && y < rect.bottom;

/** A page tall enough to scroll. */
const tallPage = <div style={{ height: 2000 }}>Content</div>;

describe('a PlSidebar resize handle beside a bar that spans the content', () => {
  const cases: {
    name: string;
    side: 'start' | 'end';
    bar: 'header' | 'footer';
    position: PlassPosition;
    dir: 'ltr' | 'rtl';
    scroll: PlPageLayoutScroll;
  }[] = [
    {
      name: 'a sticky header beside a start sidebar',
      side: 'start',
      bar: 'header',
      position: 'sticky',
      dir: 'ltr',
      scroll: 'page'
    },
    {
      name: 'a sticky header beside an end sidebar',
      side: 'end',
      bar: 'header',
      position: 'sticky',
      dir: 'ltr',
      scroll: 'page'
    },
    {
      name: 'a sticky footer beside a start sidebar',
      side: 'start',
      bar: 'footer',
      position: 'sticky',
      dir: 'ltr',
      scroll: 'page'
    },
    {
      // A glass bar is a stacking context of its own even when it is static,
      // and it comes after a start sidebar.
      name: 'a static header beside a start sidebar',
      side: 'start',
      bar: 'header',
      position: 'static',
      dir: 'ltr',
      scroll: 'page'
    },
    {
      name: 'a sticky header beside a start sidebar under RTL',
      side: 'start',
      bar: 'header',
      position: 'sticky',
      dir: 'rtl',
      scroll: 'page'
    },
    {
      name: 'a sticky header beside a start sidebar when only the content scrolls',
      side: 'start',
      bar: 'header',
      position: 'sticky',
      dir: 'ltr',
      scroll: 'content'
    }
  ];

  it.each(cases)('lies over $name', async ({ side, bar, position, dir, scroll }) => {
    const sidebar = <PlSidebar resizable>Navigation</PlSidebar>;

    await render(
      <div dir={dir}>
        <PlPageLayout
          collapseBelow="none"
          scroll={scroll}
          headerSpan="content"
          footerSpan="content"
          header={bar === 'header' ? <PlHeader position={position}>Bar</PlHeader> : undefined}
          footer={bar === 'footer' ? <PlFooter position={position}>Bar</PlFooter> : undefined}
          sidebar={side === 'start' ? sidebar : undefined}
          endSidebar={side === 'end' ? sidebar : undefined}
        >
          {tallPage}
        </PlPageLayout>
      </div>
    );
    await frame();

    const aside = document.querySelector('aside')!.getBoundingClientRect();
    const grip = handle().getBoundingClientRect();
    const box = document.querySelector(bar)!.getBoundingClientRect();

    // Halfway between the sidebar's edge and the handle's outer edge, on
    // whichever side of the sidebar that is.
    const x =
      grip.right > aside.right ? (aside.right + grip.right) / 2 : (grip.left + aside.left) / 2;
    const y = box.top + box.height / 2;

    // The point is on the handle and inside the bar, so the two do meet here.
    expect(inside(grip, x, y)).toBe(true);
    expect(inside(box, x, y)).toBe(true);
    expect(document.elementFromPoint(x, y)).toBe(handle());
  });

  it('leaves the header over the content that scrolls under it', async () => {
    await render(
      <PlPageLayout
        collapseBelow="none"
        headerSpan="content"
        header={<PlHeader>Bar</PlHeader>}
        sidebar={<PlSidebar resizable>Navigation</PlSidebar>}
      >
        <div className="relative z-10 h-40" data-testid="raised">
          Raised
        </div>
        {tallPage}
      </PlPageLayout>
    );
    await frame();

    window.scrollTo(0, 100);
    await frame();

    const box = document.querySelector('header')!.getBoundingClientRect();
    const raised = document.querySelector('[data-testid="raised"]')!.getBoundingClientRect();
    const x = box.left + box.width / 2;
    const y = box.top + box.height / 2;

    // The raised block has scrolled under the pinned bar.
    expect(inside(raised, x, y)).toBe(true);
    expect(document.elementFromPoint(x, y)?.closest('header')).not.toBeNull();
  });

  it('leaves a full-width header over a sidebar pushed up under it', async () => {
    await render(
      <>
        <PlPageLayout
          data-testid="layout"
          collapseBelow="none"
          footerSpan="content"
          header={<PlHeader>Bar</PlHeader>}
          footer={<PlFooter position="sticky">Bar</PlFooter>}
          sidebar={<PlSidebar resizable>Navigation</PlSidebar>}
        >
          {tallPage}
        </PlPageLayout>
        <div style={{ height: 2000 }}>After the layout</div>
      </>
    );
    await frame();

    // Scrolled until the layout ends halfway down the window. The sidebar holds
    // its height, so its bottom is taken up with the layout's and its top rises
    // under the header, which holds its place until the layout's bottom reaches
    // it.
    const layout = document.querySelector('[data-testid="layout"]')!;
    window.scrollTo(0, layout.getBoundingClientRect().bottom - innerHeight / 2);
    await frame();

    const box = document.querySelector('header')!.getBoundingClientRect();
    const aside = document.querySelector('aside')!.getBoundingClientRect();
    const x = aside.left + aside.width / 2;
    const y = box.top + box.height / 2;

    expect(inside(aside, x, y)).toBe(true);
    expect(inside(box, x, y)).toBe(true);
    expect(document.elementFromPoint(x, y)?.closest('header')).not.toBeNull();
  });

  it("leaves an outer layout's header over the sidebar of a layout inside it", async () => {
    const inner: ReactElement = (
      <PlPageLayout
        height={400}
        scroll="content"
        collapseBelow="none"
        headerSpan="content"
        header={<PlHeader label="Inner">Inner bar</PlHeader>}
        sidebar={<PlSidebar resizable>Navigation</PlSidebar>}
      >
        Inner content
      </PlPageLayout>
    );

    await render(
      <PlPageLayout collapseBelow="none" header={<PlHeader label="Outer">Outer bar</PlHeader>}>
        <div style={{ height: 200 }} />
        {inner}
        {tallPage}
      </PlPageLayout>
    );
    await frame();

    // Scrolled until the inner layout's top has passed under the outer header.
    window.scrollTo(0, 250);
    await frame();

    const outer = document.querySelector('header[aria-label="Outer"]')!;
    const box = outer.getBoundingClientRect();
    const aside = document.querySelector('aside')!.getBoundingClientRect();
    const x = aside.left + aside.width / 2;
    const y = box.top + box.height / 2;

    expect(inside(aside, x, y)).toBe(true);
    expect(inside(box, x, y)).toBe(true);
    expect(document.elementFromPoint(x, y)?.closest('header')).toBe(outer);
  });
});
