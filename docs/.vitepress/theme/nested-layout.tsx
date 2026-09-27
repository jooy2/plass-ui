/**
 * The wrapper a `<Demo nested>` preview is rendered in.
 *
 * A React preview is drawn inline in the docs page, and the page is the
 * document: it has a `<main>` of its own. A layout demo left to itself would
 * add a `<main id="main">` and a "Skip to content" link for every layout it
 * draws, so the page would list the same landmark several times and every
 * skip link on it would jump to the first demo. A `PlPageLayout` inside
 * another puts its content in a `<div>` and draws no skip link and no `id`,
 * which is what a demo on a page wants, so this hands the layout the context
 * that says there is one above it.
 *
 * `plass-ui` does not export that context, so it is read from the source the
 * `plass-ui` alias already points at. It is the same module the library
 * imports, which is what makes the layout read this provider rather than a
 * copy of it. Nothing else changes: the layout hands its own context to
 * everything inside it, and a bar that registers here goes nowhere, as it does
 * with no layout above it.
 */
import * as React from 'react';
import { PlPageLayoutContext } from '../../../packages/react/src/internal/page-layout';

export function NestedLayout({ children }: { children: React.ReactNode }) {
  const outer = React.useContext(PlPageLayoutContext);
  const value = React.useMemo(() => ({ ...outer, present: true }), [outer]);

  return <PlPageLayoutContext.Provider value={value}>{children}</PlPageLayoutContext.Provider>;
}
