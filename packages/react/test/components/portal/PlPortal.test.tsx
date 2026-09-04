/**
 * A portal has one observable behaviour — where the markup ends up — so nearly
 * every test here is a question about the document rather than about the
 * component's own element.
 *
 * `vitest-browser-react` renders into a container of its own, which is what
 * makes "in place" and "somewhere else" distinguishable at all: content that
 * portalled is a direct child of `document.body` and content that did not is
 * inside that container.
 */
import { useRef } from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlPortal, PlassProvider, PlButton } from 'plass-ui';

/** The portal's own element, wherever in the document it landed. */
function portal(): HTMLElement | null {
  return document.querySelector<HTMLElement>('.portal-under-test');
}

/** Whether an element is a child of `document.body` rather than of the render root. */
function sitsOnBody(element: Element | null): boolean {
  return element?.parentElement === document.body;
}

describe('PlPortal', () => {
  it('puts its children on `document.body` when it was given nowhere else', async () => {
    await render(
      <div className="origin-under-test">
        <PlPortal className="portal-under-test">
          <span>moved</span>
        </PlPortal>
      </div>
    );

    await expect.poll(() => sitsOnBody(portal())).toBe(true);
    expect(document.querySelector('.origin-under-test')?.children.length).toBe(0);
  });

  it('carries `plass-portal`, which is the reason to reach for it', async () => {
    await render(
      <PlPortal className="portal-under-test">
        <span>moved</span>
      </PlPortal>
    );

    await expect.poll(() => portal()).not.toBeNull();
    // A portalled subtree leaves whatever element a host scoped its reset to,
    // and the class is how that host finds it again.
    expect(portal()!.classList.contains('plass-portal')).toBe(true);
  });

  it('takes an element as its container', async () => {
    const host = document.createElement('div');
    host.id = 'host-under-test';
    document.body.append(host);

    await render(
      <PlPortal className="portal-under-test" container={host}>
        <span>moved</span>
      </PlPortal>
    );

    await expect.poll(() => portal()?.parentElement?.id).toBe('host-under-test');

    host.remove();
  });

  it('takes a ref, resolved after mount', async () => {
    function Subject() {
      // `null` on the render that creates it, which is exactly the case a
      // container prop read off the props could not handle.
      const host = useRef<HTMLDivElement>(null);

      return (
        <div>
          <div ref={host} id="ref-host-under-test" />
          <PlPortal className="portal-under-test" container={host}>
            <span>moved</span>
          </PlPortal>
        </div>
      );
    }

    await render(<Subject />);

    await expect.poll(() => portal()?.parentElement?.id).toBe('ref-host-under-test');
  });

  it('takes a function, called after mount', async () => {
    const host = document.createElement('div');
    host.id = 'function-host-under-test';
    document.body.append(host);

    await render(
      <PlPortal
        className="portal-under-test"
        container={() => document.getElementById('function-host-under-test')}
      >
        <span>moved</span>
      </PlPortal>
    );

    await expect.poll(() => portal()?.parentElement?.id).toBe('function-host-under-test');

    host.remove();
  });

  it('falls back to the body when the container resolves to nothing', async () => {
    await render(
      <PlPortal className="portal-under-test" container={() => null}>
        <span>moved</span>
      </PlPortal>
    );

    await expect.poll(() => sitsOnBody(portal())).toBe(true);
  });

  it('leaves the markup where it was written when it is disabled', async () => {
    await render(
      <div className="origin-under-test">
        <PlPortal className="portal-under-test" disabled>
          <span>in place</span>
        </PlPortal>
      </div>
    );

    expect(document.querySelector('.origin-under-test')?.firstElementChild).toBe(portal());
    // Still the class, so a host's reset finds it either way.
    expect(portal()!.classList.contains('plass-portal')).toBe(true);
  });

  it('renders something other than a `<div>` when it is handed one', async () => {
    await render(
      <PlPortal className="portal-under-test" render={<ul />}>
        <li>moved</li>
      </PlPortal>
    );

    await expect.poll(() => portal()?.tagName).toBe('UL');
  });

  it('passes a native attribute straight through', async () => {
    await render(
      <PlPortal className="portal-under-test" id="named-portal" data-testid="portal">
        <span>moved</span>
      </PlPortal>
    );

    await expect.poll(() => portal()?.id).toBe('named-portal');
    expect(portal()!.dataset.testid).toBe('portal');
  });

  it('carries the defaults in scope across the move', async () => {
    await render(
      <PlassProvider size="xs">
        <PlPortal className="portal-under-test">
          <PlButton className="button-under-test">Save</PlButton>
        </PlPortal>
      </PlassProvider>
    );

    await expect.poll(() => document.querySelector('.button-under-test')).not.toBeNull();

    // React context crosses a portal — the tree it is read from is the React
    // one, not the DOM one — so `size`, `color`, `density` and `locale` all
    // arrive. The colour scheme is the one thing that does not, because that
    // one is a DOM ancestor.
    expect(document.querySelector('.button-under-test')!.classList.contains('h-6')).toBe(true);
  });
});
