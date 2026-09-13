import * as React from 'react';

/**
 * The value `inert` has to be written with for a given React to put it in the
 * DOM.
 *
 * React 19 knows `inert` as a boolean attribute, writes `true` and drops an
 * empty string. React 18 does not know it at all: it drops `true` with a warning
 * and writes a string as it is. A dropped attribute leaves the subtree
 * focusable and on the accessibility tree, which is exactly what the attribute
 * was there to stop, and nothing on the page looks any different.
 */
export function inertValueFor(version: string): true | '' {
  return Number.parseInt(version, 10) >= 19 ? true : '';
}

const INERT = inertValueFor(React.version);

/**
 * `inert` as props to spread onto an element, written the way the running React
 * keeps it. Nothing at all when the element is not inert, so the attribute is
 * absent rather than present and false.
 */
export function inertProps(inert: boolean): { inert?: boolean } {
  if (!inert) {
    return {};
  }

  // React 19's types say boolean; React 18 needs the empty string at run time.
  return { inert: INERT as boolean };
}
