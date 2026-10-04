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
 *
 * The last two groups ask the stylesheet a second question: where the content
 * of a page with a fixed header is in the HTML a server sends, and how tall the
 * sidebar under a sticky one is, before the layout has measured anything, and
 * whether hydrating moves either.
 */
import { act, type ReactElement } from 'react';
import { hydrateRoot, type Root } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { afterAll, afterEach, beforeAll, describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlFooter,
  PlHeader,
  PlPageLayout,
  PlSidebar,
  type PlPageLayoutScroll,
  type PlPageLayoutSpan,
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

  it.each(['sticky', 'fixed'] as const)(
    'leaves a %s header over the content that scrolls under it',
    async (position) => {
      await render(
        <PlPageLayout
          collapseBelow="none"
          headerSpan="content"
          header={<PlHeader position={position}>Bar</PlHeader>}
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
      const x = raised.left + raised.width / 2;
      const y = box.top + box.height / 2;

      // The raised block has scrolled under the pinned bar.
      expect(inside(box, x, y)).toBe(true);
      expect(inside(raised, x, y)).toBe(true);
      expect(document.elementFromPoint(x, y)?.closest('header')).not.toBeNull();
    }
  );

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

describe('a fixed bar in a layout whose bars span the content', () => {
  const cases: {
    name: string;
    side: 'start' | 'end';
    bar: 'header' | 'footer';
    dir: 'ltr' | 'rtl';
    scroll: PlPageLayoutScroll;
    scrolled?: boolean;
  }[] = [
    {
      name: 'a header over a start sidebar',
      side: 'start',
      bar: 'header',
      dir: 'ltr',
      scroll: 'page'
    },
    {
      name: 'a header over an end sidebar',
      side: 'end',
      bar: 'header',
      dir: 'ltr',
      scroll: 'page'
    },
    {
      name: 'a header over a start sidebar under RTL',
      side: 'start',
      bar: 'header',
      dir: 'rtl',
      scroll: 'page'
    },
    {
      name: 'a header over a start sidebar once the page has scrolled',
      side: 'start',
      bar: 'header',
      dir: 'ltr',
      scroll: 'page',
      scrolled: true
    },
    {
      name: 'a header over a start sidebar when only the content scrolls',
      side: 'start',
      bar: 'header',
      dir: 'ltr',
      scroll: 'content'
    },
    {
      name: 'a footer under a start sidebar',
      side: 'start',
      bar: 'footer',
      dir: 'ltr',
      scroll: 'page'
    },
    {
      name: 'a footer under an end sidebar under RTL',
      side: 'end',
      bar: 'footer',
      dir: 'rtl',
      scroll: 'page'
    },
    {
      name: 'a footer under a start sidebar when only the content scrolls',
      side: 'start',
      bar: 'footer',
      dir: 'ltr',
      scroll: 'content'
    }
  ];

  it.each(cases)(
    'keeps the sidebar clear of $name',
    async ({ side, bar, dir, scroll, scrolled }) => {
      const sidebar = <PlSidebar resizable>Navigation</PlSidebar>;

      await render(
        <div dir={dir}>
          <PlPageLayout
            collapseBelow="none"
            scroll={scroll}
            headerSpan="content"
            footerSpan="content"
            header={bar === 'header' ? <PlHeader position="fixed">Bar</PlHeader> : undefined}
            footer={bar === 'footer' ? <PlFooter position="fixed">Bar</PlFooter> : undefined}
            sidebar={side === 'start' ? sidebar : undefined}
            endSidebar={side === 'end' ? sidebar : undefined}
          >
            {tallPage}
          </PlPageLayout>
        </div>
      );
      await frame();

      if (scrolled) {
        window.scrollTo(0, 500);
        await frame();
      }

      const aside = document.querySelector('aside')!.getBoundingClientRect();
      const grip = handle().getBoundingClientRect();
      const box = document.querySelector(bar)!.getBoundingClientRect();

      // The bar spans the window, so it is across the sidebar's column.
      expect(box.left).toBeLessThanOrEqual(aside.left);
      expect(box.right).toBeGreaterThanOrEqual(aside.right);

      // The sidebar starts below a header and ends above a footer, and so does
      // the handle along its edge: its end nearest the bar is the handle's.
      const x = (grip.left + grip.right) / 2;

      if (bar === 'header') {
        expect(aside.top).toBeGreaterThanOrEqual(box.bottom - 0.5);
        expect(document.elementFromPoint(x, grip.top + 2)).toBe(handle());
      } else {
        expect(aside.bottom).toBeLessThanOrEqual(box.top + 0.5);
        expect(document.elementFromPoint(x, grip.bottom - 2)).toBe(handle());
      }
    }
  );

  it('leaves a sticky header beside the sidebar', async () => {
    await render(
      <PlPageLayout
        collapseBelow="none"
        headerSpan="content"
        header={<PlHeader>Bar</PlHeader>}
        sidebar={<PlSidebar resizable>Navigation</PlSidebar>}
      >
        {tallPage}
      </PlPageLayout>
    );
    await frame();

    const aside = document.querySelector('aside')!.getBoundingClientRect();
    const box = document.querySelector('header')!.getBoundingClientRect();

    // Both start at the top of the window, the bar in the column beside the
    // sidebar rather than across it.
    expect(aside.top).toBe(box.top);
    expect(box.left).toBeGreaterThanOrEqual(aside.right - 0.5);
  });
});

/** A server's markup in the document, as a browser has it before any script runs. */
function serve(tree: ReactElement) {
  const host = document.createElement('div');

  host.innerHTML = renderToString(tree);
  document.body.append(host);

  const layout = host.querySelector<HTMLElement>('[data-testid="layout"]')!;
  const header = host.querySelector<HTMLElement>('header')!;
  const first = host.querySelector<HTMLElement>('[data-testid="first"]')!;
  const aside = host.querySelector<HTMLElement>('aside')!;

  return {
    host,
    layout,
    header,
    aside,
    // How far below the top of the layout the content and the sidebar start.
    content: () => first.getBoundingClientRect().top - layout.getBoundingClientRect().top,
    sidebar: () => aside.getBoundingClientRect().top - layout.getBoundingClientRect().top
  };
}

/** Every size, variant and divider a header can be drawn with. */
const headerCases = (['xs', 'sm', 'md', 'lg', 'xl'] as const).flatMap((size) =>
  (['glass', 'solid', 'ghost'] as const).flatMap((variant) =>
    [true, false].map((divider) => ({ size, variant, divider }))
  )
);

describe('a fixed header in the HTML a server sends', () => {
  const page = (header: ReactElement, children?: ReactElement) => (
    <PlPageLayout
      data-testid="layout"
      height="auto"
      collapseBelow="none"
      header={header}
      sidebar={<PlSidebar>Navigation</PlSidebar>}
    >
      <p data-testid="first" style={{ margin: 0 }}>
        The first line of the page
      </p>
      {children}
    </PlPageLayout>
  );

  it.each(headerCases)(
    'has the content below a $size $variant header (divider: $divider) before hydration, and leaves it there',
    async ({ size, variant, divider }) => {
      const tree = page(
        <PlHeader position="fixed" size={size} variant={variant} divider={divider}>
          Bar
        </PlHeader>
      );
      const { host, layout, header, content, sidebar } = serve(tree);
      const onRecoverableError = vi.fn();
      let root: Root | undefined;

      try {
        const height = header.getBoundingClientRect().height;

        // Before any script ran: the room is already there, for the content and
        // for the sidebar beside it.
        expect(height).toBeGreaterThan(0);
        expect(content()).toBe(height);
        expect(sidebar()).toBe(height);

        root = await act(async () => hydrateRoot(host, tree, { onRecoverableError }));
        await frame();

        // After it, nothing has moved, and the room is the measured height.
        expect(onRecoverableError).not.toHaveBeenCalled();
        expect(content()).toBe(height);
        expect(sidebar()).toBe(height);
        expect(layout.style.getPropertyValue('--p-layout-header-inset')).toBe(`${height}px`);
      } finally {
        await act(async () => root?.unmount());
        host.remove();
      }
    }
  );

  it('measures a header that grows past its floor, and follows it back', async () => {
    const tree = page(<PlHeader position="fixed">Bar</PlHeader>);
    const { host, layout, header, content } = serve(tree);
    const height = () => header.getBoundingClientRect().height;
    let root: Root | undefined;

    try {
      root = await act(async () => hydrateRoot(host, tree));
      await frame();

      const floor = height();
      const row = header.firstElementChild as HTMLElement;

      row.style.minHeight = '120px';
      await expect.poll(content).toBe(height());
      expect(height()).toBeGreaterThan(floor);
      expect(layout.style.getPropertyValue('--p-layout-header-inset')).toBe(`${height()}px`);

      row.style.minHeight = '';
      await expect.poll(content).toBe(floor);
    } finally {
      await act(async () => root?.unmount());
      host.remove();
    }
  });

  it("leaves a layout inside the page out of the outer header's room", async () => {
    const { host } = serve(
      page(
        <PlHeader position="fixed">Bar</PlHeader>,
        <PlPageLayout data-testid="inner" height="auto" header={<PlHeader>Inner bar</PlHeader>}>
          Inner
        </PlPageLayout>
      )
    );

    try {
      const inner = host.querySelector<HTMLElement>('[data-testid="inner"]')!;

      expect(getComputedStyle(inner).paddingTop).toBe('0px');
    } finally {
      host.remove();
    }
  });
});

describe('a sticky header in the HTML a server sends', () => {
  // `sticky` is a header's default, so none of these bars says so.
  const page = (
    header: ReactElement,
    { span = 'full', long = false }: { span?: PlPageLayoutSpan; long?: boolean } = {}
  ) => (
    <PlPageLayout
      data-testid="layout"
      collapseBelow="none"
      headerSpan={span}
      header={header}
      footer={<PlFooter>Footer</PlFooter>}
      sidebar={<PlSidebar>Navigation</PlSidebar>}
    >
      <p data-testid="first" style={{ margin: 0, height: long ? 2000 : undefined }}>
        The first line of the page
      </p>
    </PlPageLayout>
  );

  /**
   * Where the sidebar starts and how tall it is, where it sticks once the page
   * scrolls, and where the footer starts, against the top of the layout.
   */
  function place({ layout, aside, sidebar }: ReturnType<typeof serve>) {
    const footer = layout.querySelector('footer')!;

    return {
      sidebar: sidebar(),
      height: aside.getBoundingClientRect().height,
      stuck: getComputedStyle(aside).top,
      footer: footer.getBoundingClientRect().top - layout.getBoundingClientRect().top
    };
  }

  it.each(headerCases)(
    'has the sidebar below a $size $variant header (divider: $divider) before hydration, and leaves it there',
    async ({ size, variant, divider }) => {
      const tree = page(
        <PlHeader size={size} variant={variant} divider={divider}>
          Bar
        </PlHeader>
      );
      const served = serve(tree);
      const { host, layout, header, content } = served;
      const onRecoverableError = vi.fn();
      let root: Root | undefined;

      try {
        const height = header.getBoundingClientRect().height;
        const before = place(served);

        // Before any script ran: the sidebar is the window less the header and
        // holds its place below it, so the footer of a short page is already
        // where it stays rather than a header further down. The header is in
        // the flow, so the content has no room made for it beyond that.
        expect(height).toBeGreaterThan(0);
        expect(before).toEqual({
          sidebar: height,
          height: innerHeight - height,
          stuck: `${height}px`,
          footer: innerHeight
        });
        expect(content()).toBe(height);
        expect(getComputedStyle(layout).paddingTop).toBe('0px');

        root = await act(async () => hydrateRoot(host, tree, { onRecoverableError }));
        await frame();

        // After it, nothing has moved, and the room is the measured height.
        expect(onRecoverableError).not.toHaveBeenCalled();
        expect(place(served)).toEqual(before);
        expect(content()).toBe(height);
        expect(layout.style.getPropertyValue('--p-layout-header')).toBe(`${height}px`);
        expect(layout.style.getPropertyValue('--p-layout-header-inset')).toBe('0px');
      } finally {
        await act(async () => root?.unmount());
        host.remove();
      }
    }
  );

  it('holds the sidebar below the header of a page scrolled before hydration', async () => {
    const tree = page(<PlHeader>Bar</PlHeader>, { long: true });
    const { host, layout, header, aside } = serve(tree);
    let root: Root | undefined;

    try {
      window.scrollTo(0, layout.getBoundingClientRect().top + 500);
      await frame();

      const height = header.getBoundingClientRect().height;

      // Both have stuck: the header to the top of the window, and the sidebar
      // below it rather than under it.
      expect(header.getBoundingClientRect().top).toBe(0);
      expect(aside.getBoundingClientRect().top).toBe(height);
      expect(aside.getBoundingClientRect().bottom).toBe(innerHeight);

      root = await act(async () => hydrateRoot(host, tree));
      await frame();

      expect(aside.getBoundingClientRect().top).toBe(height);
      expect(aside.getBoundingClientRect().bottom).toBe(innerHeight);
    } finally {
      await act(async () => root?.unmount());
      host.remove();
    }
  });

  it('leaves the sidebar the whole window beside a header that spans the content', async () => {
    const tree = page(<PlHeader>Bar</PlHeader>, { span: 'content' });
    const served = serve(tree);
    const { host, layout } = served;
    let root: Root | undefined;

    try {
      const before = place(served);

      expect(before).toEqual({
        sidebar: 0,
        height: innerHeight,
        stuck: '0px',
        footer: innerHeight
      });

      root = await act(async () => hydrateRoot(host, tree));
      await frame();

      expect(place(served)).toEqual(before);
      expect(layout.style.getPropertyValue('--p-layout-header')).toBe('0px');
    } finally {
      await act(async () => root?.unmount());
      host.remove();
    }
  });

  it('measures a header that grows past its floor, and follows it back', async () => {
    const tree = page(<PlHeader>Bar</PlHeader>);
    const served = serve(tree);
    const { host, layout, header } = served;
    const height = () => header.getBoundingClientRect().height;
    let root: Root | undefined;

    try {
      root = await act(async () => hydrateRoot(host, tree));
      await frame();

      const floor = height();
      const row = header.firstElementChild as HTMLElement;

      row.style.minHeight = '120px';
      await expect.poll(() => place(served).height).toBe(innerHeight - height());
      expect(height()).toBeGreaterThan(floor);
      expect(place(served).stuck).toBe(`${height()}px`);
      expect(layout.style.getPropertyValue('--p-layout-header')).toBe(`${height()}px`);

      row.style.minHeight = '';
      await expect.poll(() => place(served).height).toBe(innerHeight - floor);
    } finally {
      await act(async () => root?.unmount());
      host.remove();
    }
  });

  it("leaves a header the page draws out of the layout's room", async () => {
    const { host, aside } = serve(
      <PlPageLayout
        data-testid="layout"
        collapseBelow="none"
        sidebar={<PlSidebar>Navigation</PlSidebar>}
      >
        <PlHeader label="Article">An article&apos;s own header</PlHeader>
      </PlPageLayout>
    );

    try {
      expect(getComputedStyle(aside).top).toBe('0px');
      expect(aside.getBoundingClientRect().height).toBe(innerHeight);
    } finally {
      host.remove();
    }
  });
});
