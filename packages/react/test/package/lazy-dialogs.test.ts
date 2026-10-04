/**
 * Which heavy modules an app shell loads up front, and which it fetches later.
 *
 * Like `use-client.test.ts`, a test of the package rather than of a component.
 * `PlConfirmProvider` and `PlSidebar` sit in nearly every app's root, and each
 * renders a dialog only some of the time: the confirm dialog once a question is
 * asked, the sidebar's drawer once the window is narrower than its breakpoint.
 * The dialog stack behind both — Base UI's Dialog, the focus trap, the scroll
 * lock — is about half of what such a shell weighs, so both reach theirs
 * through `import()` rather than a static `import`.
 *
 * Nothing else notices a static import put back. The components render the
 * same, the tests pass, and a bundler is happy to put the dialog in the first
 * paint's chunk. So this reads the sources the way a bundler does and walks
 * what each of the two reaches through a static `import` or `export … from`,
 * leaving out a type-only one, which `tsc` erases.
 */
import { describe, expect, it } from 'vitest';

const modules = import.meta.glob('../../src/**/*.{ts,tsx}', {
  query: '?raw',
  import: 'default',
  eager: true
}) as Record<string, string>;

/** A module's identity: its path under `src/`, with no extension. */
const key = (path: string) => path.replace('../../src/', '').replace(/\.(?:tsx?|js)$/, '');

const sources = new Map(Object.entries(modules).map(([path, text]) => [key(path), text]));

/** `import … from '…'` and `export … from '…'`, over as many lines as the list takes. */
const STATIC = /^(?:import|export)(\s+type)?\s[^;]*?\bfrom\s*['"]([^'"]+)['"]/gm;

function resolve(from: string, specifier: string): string {
  const parts = from.split('/').slice(0, -1);

  for (const part of specifier.split('/')) {
    if (part === '..') parts.pop();
    else if (part !== '.') parts.push(part);
  }

  return parts.join('/').replace(/\.js$/, '');
}

/** Every module `start` loads before it can run, itself included. */
function eager(start: string): Set<string> {
  const seen = new Set<string>();
  const pending = [start];

  while (pending.length > 0) {
    const at = pending.pop()!;

    if (seen.has(at) || !sources.has(at)) continue;

    seen.add(at);

    for (const [, typeOnly, specifier] of sources.get(at)!.matchAll(STATIC)) {
      if (!typeOnly && specifier.startsWith('.')) pending.push(resolve(at, specifier));
    }
  }

  return seen;
}

describe('what an app shell loads up front', () => {
  it('reads the graph it is asked about', () => {
    // A walk that found nothing would pass every assertion below.
    expect(eager('components/confirm/PlConfirmProvider')).toContain('components/button/PlButton');
    expect(eager('components/sidebar/PlSidebar')).toContain('internal/page-layout');
    expect(eager('index')).toContain('components/drawer/PlDrawer');
  });

  it('leaves the confirm dialog to the first question', () => {
    expect(eager('components/confirm/PlConfirmProvider')).not.toContain('components/modal/PlModal');
    expect(sources.get('components/confirm/PlConfirmProvider')).toContain(
      "import('../modal/PlModal.js')"
    );
  });

  it('leaves the sidebar drawer to a window narrow enough for one', () => {
    expect(eager('components/sidebar/PlSidebar')).not.toContain('components/drawer/PlDrawer');
    expect(sources.get('components/sidebar/PlSidebar')).toContain(
      "import('../drawer/PlDrawer.js')"
    );
  });
});
