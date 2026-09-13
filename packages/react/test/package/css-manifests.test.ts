/**
 * What `plass-ui/css/<component>.css` scans, and why it is more than one folder.
 *
 * Like `use-client.test.ts`, a test of the package rather than of a component.
 * `scripts/build-styles.mjs` writes one manifest per component, and Tailwind
 * scans files rather than the import graph — so a manifest that names only a
 * component's own folder drops every utility spelled in a component it renders.
 * The build reads the graph off `dist/`; this reads the same graph off `src/`,
 * through the same function, so no build has to have run.
 */
import { describe, expect, it } from 'vitest';
import { componentSources } from '../../scripts/component-sources.mjs';

const modules = import.meta.glob('../../src/{components,internal}/**/*.{ts,tsx}', {
  query: '?raw',
  import: 'default',
  eager: true
}) as Record<string, string>;

const sources = componentSources(
  Object.fromEntries(
    Object.entries(modules).map(([path, text]) => [path.replace('../../src/', ''), text])
  )
);

describe('the per-component scan manifests', () => {
  it('lists every component, its own folder first', () => {
    expect(Object.keys(sources).length).toBeGreaterThan(100);

    for (const [component, folders] of Object.entries(sources)) {
      expect(folders[0]).toBe(component);
    }
  });

  it('scans a component that another one renders directly', () => {
    expect(sources['icon-button']).toContain('button');
    expect(sources.transfer).toEqual(expect.arrayContaining(['checkbox', 'text-field']));
  });

  it('scans a component reached through an internal module', () => {
    // `internal/calendar` renders `PlButton`; `internal/chart-frame` renders `PlBox`.
    expect(sources['date-picker']).toContain('button');
    expect(sources['area-chart']).toContain('box');
  });

  it('follows a chain of components to its end', () => {
    // `PlBackTop` renders `PlIconButton`, which renders `PlButton`.
    expect(sources['back-top']).toEqual(expect.arrayContaining(['icon-button', 'button']));
  });
});

describe('componentSources', () => {
  it('reads the built form of an import as well as the written one', () => {
    expect(
      componentSources({
        'components/a/PlA.js': 'import{PlB as r}from"../b/PlB.js";const l=import("./Lazy.js");',
        'components/a/Lazy.js': 'import"../c/PlC.js";',
        'components/b/PlB.js': '',
        'components/c/PlC.js': ''
      }).a
    ).toEqual(['a', 'b', 'c']);
  });

  it('ends on an import cycle', () => {
    expect(
      componentSources({
        'components/a/PlA.tsx': "import { PlB } from '../b/PlB.js';",
        'components/b/PlB.tsx': "import { PlA } from '../a/PlA.js';"
      })
    ).toEqual({ a: ['a', 'b'], b: ['b', 'a'] });
  });
});
