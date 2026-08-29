/**
 * The `'use client'` directive on every component module.
 *
 * Like `test/styles/standalone.test.tsx`, this is a test of the *package*
 * rather than of a component. Every component here calls a hook, reads a
 * context or attaches a DOM handler, which makes all 74 of them client
 * components in a React Server Component graph — Next.js's App Router being the
 * one almost everybody meets. The directive is what says so, and it has to be
 * on the module that holds the component, not on a barrel that re-exports it:
 * the boundary is per-module, and a barrel with the directive would drag the
 * whole library across it.
 *
 * It is asserted here because nothing else notices. The docs render through
 * Vite, the suite runs in a browser and `tsc` copies the directive through
 * without an opinion — so a component added without one builds, tests and
 * documents perfectly, and then throws `You're importing a component that needs
 * useState` in somebody else's app. `scripts/minify.mjs` guards the other half
 * of the same promise, that terser does not strip it back out of `dist`.
 */
import { describe, expect, it } from 'vitest';

/** Every component implementation module, as source text. */
const sources = import.meta.glob('../../src/components/*/Pl*.tsx', {
  query: '?raw',
  import: 'default',
  eager: true
});

/** The barrels, which must *not* carry it — a client barrel is a client library. */
const barrels = import.meta.glob('../../src/components/*/index.ts', {
  query: '?raw',
  import: 'default',
  eager: true
});

const name = (path: string) => path.replace(/^.*\/src\//, 'src/');

describe("'use client'", () => {
  it('finds every component module', () => {
    expect(Object.keys(sources).length).toBeGreaterThan(70);
  });

  it.each(Object.entries(sources))('%s starts with the directive', (path, source) => {
    expect({ file: name(path), first: source.split('\n')[0] }).toEqual({
      file: name(path),
      first: "'use client';"
    });
  });

  it.each(Object.entries(barrels))('%s does not carry it', (path, source) => {
    expect({ file: name(path), directive: /^\s*(['"])use client\1/.test(source) }).toEqual({
      file: name(path),
      directive: false
    });
  });
});
