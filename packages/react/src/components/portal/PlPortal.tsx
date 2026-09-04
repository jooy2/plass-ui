'use client';

import * as React from 'react';
import { createPortal } from 'react-dom';
import { useRender } from '@base-ui/react/use-render';
import { cx } from '../../internal/styles.js';

/**
 * Somewhere in the document to put the children.
 *
 * Four shapes, and the last three exist because of the same fact: the element a
 * portal targets is usually one React has not created yet when the prop is
 * being built. A ref is `null` on the render that creates it, and a query
 * finds nothing until the tree is in the document — so the target is resolved
 * after mount rather than read off the props.
 */
export type PlPortalContainer =
  | Element
  | DocumentFragment
  | React.RefObject<Element | null>
  | (() => Element | DocumentFragment | null)
  | null;

export interface PlPortalProps extends React.ComponentPropsWithoutRef<'div'> {
  /**
   * Where the children go. `document.body` when it is not said.
   *
   * Takes an element, a fragment, a **ref**, or a function returning one of
   * those. The ref and the function are resolved after mount, which is what
   * lets a portal target something React itself renders.
   */
  container?: PlPortalContainer;
  /**
   * Renders in place instead of moving anything.
   *
   * **Decide it once, at mount.** A portalled subtree and an inline one are
   * different children as far as React is concerned, so turning this on or off
   * remounts everything inside and throws away what was in it: a half-filled
   * form, a scroll position, a video that was playing. That is
   * reconciliation rather than a shortcoming here, and no portal escapes it.
   *
   * It is a prop rather than an absence so that a caller can decide from
   * something only they know — a subtree that is already inside a portal, an
   * embed with no `document.body` worth reaching, a test that wants the markup
   * where it was written.
   * @default false
   */
  disabled?: boolean;
  /**
   * Renders something other than a `<div>`: `render={<ul />}` for a portal
   * whose target is a list, `render={<tbody />}` for one whose target is a
   * table. Base UI's own escape hatch, and the answer to a wrapper that is the
   * wrong element for where it landed.
   */
  render?: useRender.RenderProp;
  /** What is moved. */
  children?: React.ReactNode;
}

/** The element a container prop is pointing at, whichever of the four it is. */
function resolveContainer(container: PlPortalContainer | undefined): Element | DocumentFragment {
  if (typeof container === 'function') {
    return container() ?? document.body;
  }

  if (container && 'current' in container) {
    return container.current ?? document.body;
  }

  return container ?? document.body;
}

/**
 * Children, rendered somewhere else in the document.
 *
 * `createPortal` with the three things this library has to add on top, and it
 * is worth being clear that the first is the only real reason to reach for it.
 *
 * **It carries `plass-portal`.** Every surface the library sends through a
 * portal — a modal, a drawer, a menu, a popover, a tooltip, a toast — lands with
 * that class on it, because a portalled subtree leaves whatever element a host
 * had scoped its CSS reset to and the class is how that host finds it again.
 * A caller's own portal that did not carry it is the one subtree on the page
 * the reset misses.
 *
 * **It renders nothing until it has mounted.** There is no `document` on a
 * server, so the HTML that ships never contains a portalled subtree and the
 * hydrating render does not either. That is not a limitation to work around —
 * it is what a portal is — so anything that has to be in the server's HTML does
 * not belong in one.
 *
 * **`container` is resolved after mount**, which is what lets it be a ref or a
 * query. The element a portal targets is usually one React has not created yet
 * at the moment the prop is written.
 *
 * What it does **not** do is carry the colour scheme. `styles.css` answers to a
 * `.dark` or a `[data-theme]` on any ancestor, and a portal to `document.body`
 * has left every ancestor it had — so a subtree pinned to one theme goes back
 * to the page's. That is true of the library's own popups too, and the fix is
 * the same for both: portal into an element that is inside the theme, with
 * `container`.
 */
export const PlPortal = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlPortalProps>(
  function PlPortal({ container, disabled = false, render, className, children, ...props }, ref) {
    // `document` is a browser fact, so the first render — the one a server
    // produces and the one hydration has to match — is deliberately nothing.
    const [target, setTarget] = React.useState<Element | DocumentFragment | null>(null);

    React.useEffect(() => {
      if (disabled) {
        return;
      }

      setTarget(resolveContainer(container));
    }, [container, disabled]);

    const content = useRender({
      render,
      ref,
      props: {
        className: cx('plass-portal', className),
        children,
        ...props
      }
    });

    if (disabled) {
      return content;
    }

    return target ? createPortal(content, target) : null;
  }
);
