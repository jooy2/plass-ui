/**
 * A stand-in for the `Link` a router brings, for the components that take one
 * through `render`.
 *
 * It does what Next.js's and React Router's do with a press: it runs the
 * handler it was handed, and unless that handler cancelled the event it takes
 * the navigation over itself, so the browser never leaves the page. Where the
 * press would have gone is reported to `onNavigate` instead. `data-router` is
 * what a test finds it by: the anchor in the document is this element and not
 * one the component drew in its place.
 */
import type * as React from 'react';

export interface RouterLinkProps extends React.ComponentPropsWithRef<'a'> {
  onNavigate?: (href: string) => void;
}

export function RouterLink({ onClick, onNavigate, ...props }: RouterLinkProps) {
  return (
    <a
      data-router=""
      {...props}
      onClick={(event) => {
        onClick?.(event);

        if (event.defaultPrevented) {
          return;
        }

        event.preventDefault();
        onNavigate?.(props.href ?? '');
      }}
    />
  );
}
