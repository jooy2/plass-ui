/**
 * What `plass-ui/css/<component>.css` scans, and why it is more than one folder.
 *
 * Like `use-client.test.ts`, a test of the package rather than of a component.
 * `scripts/build-styles.mjs` writes one manifest per component, and Tailwind
 * scans files rather than the import graph — so a manifest that names only a
 * component's own folder drops every utility spelled in a component it renders,
 * and a `base.css` that scans the whole of `internal/` makes one component pay
 * for the modules of all of them. The build reads the graph off `dist/`; this
 * reads the same graph off `src/`, through the same function, so no build has
 * to have run.
 */
import { describe, expect, it } from 'vitest';
import { componentSources } from '../../scripts/component-sources.mjs';

const modules = Object.fromEntries(
  Object.entries(
    import.meta.glob('../../src/**/*.{ts,tsx}', {
      query: '?raw',
      import: 'default',
      eager: true
    }) as Record<string, string>
  ).map(([path, text]) => [path.replace('../../src/', ''), text])
);

const { shared, components: sources } = componentSources(modules);

/* The files a component's modules reach, walked here on its own terms: every
   relative specifier, resolved against the files that exist. */
function reachable(component: string): string[] {
  const byKey = new Map(Object.keys(modules).map((path) => [path.replace(/\.tsx?$/, ''), path]));
  const seen = new Set<string>();
  const pending = Object.keys(modules).filter((path) =>
    path.startsWith(`components/${component}/`)
  );

  while (pending.length > 0) {
    const path = pending.pop()!;

    if (seen.has(path)) {
      continue;
    }

    seen.add(path);

    for (const [, specifier] of modules[path].matchAll(/\b(?:from|import)\s*\(?\s*'(\.[^']+)'/g)) {
      const url = new URL(specifier, `file:///${path}`).pathname.slice(1);
      const target = byKey.get(url.replace(/\.js$/, ''));

      if (target) {
        pending.push(target);
      }
    }
  }

  return [...seen];
}

describe('the per-component scan manifests', () => {
  it('lists every component, its own folder first', () => {
    expect(Object.keys(sources).length).toBeGreaterThan(100);

    for (const [component, paths] of Object.entries(sources)) {
      expect(paths[0]).toBe(`components/${component}`);
    }
  });

  it('scans a component that another one renders directly', () => {
    expect(sources['icon-button']).toContain('components/button');
    expect(sources.transfer).toEqual(
      expect.arrayContaining(['components/checkbox', 'components/text-field'])
    );
  });

  it('scans a component reached through an internal module', () => {
    // `internal/calendar` renders `PlButton`; `internal/chart-frame` renders `PlBox`.
    expect(sources['date-picker']).toEqual(
      expect.arrayContaining(['components/button', 'internal/calendar.tsx'])
    );
    expect(sources['area-chart']).toEqual(
      expect.arrayContaining(['components/box', 'internal/chart-frame.tsx'])
    );
  });

  it('follows a chain of components to its end', () => {
    // `PlBackTop` renders `PlIconButton`, which renders `PlButton`.
    expect(sources['back-top']).toEqual(
      expect.arrayContaining(['components/icon-button', 'components/button'])
    );
  });

  it('leaves the shared table to `base.css`, and only the shared table', () => {
    expect(shared).toEqual(['internal/styles.ts']);

    for (const paths of Object.values(sources)) {
      expect(paths).not.toContain('internal/styles.ts');
      expect(paths).not.toContain('internal');
    }
  });

  it('scans the internal modules a component reaches, and no others', () => {
    expect(sources.button).toEqual(
      expect.arrayContaining(['internal/glow.ts', 'internal/icons.tsx', 'internal/loading.ts'])
    );
    expect(sources.button).not.toContain('internal/chart.ts');
    expect(sources.button).not.toContain('internal/calendar.tsx');
  });

  it('covers every file each component reaches', () => {
    for (const [component, paths] of Object.entries(sources)) {
      const scanned = [...shared, ...paths];

      for (const file of reachable(component)) {
        expect(
          scanned.some((path) => file === path || file.startsWith(`${path}/`)),
          `<${component}> reaches ${file}, which neither its manifest nor base.css scans`
        ).toBe(true);
      }
    }
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
      }).components.a
    ).toEqual(['components/a', 'components/b', 'components/c']);
  });

  it('names a module outside `components/` by its own file, through a hook too', () => {
    expect(
      componentSources({
        'components/a/PlA.js': 'import{u}from"../../hooks/useA.js";import"../../internal/b.js";',
        'hooks/useA.js': 'import{m}from"../internal/media.js";',
        'internal/b.js': '',
        'internal/media.js': '',
        'internal/unused.js': '',
        'internal/styles.js': ''
      })
    ).toEqual({
      shared: ['internal/styles.js'],
      components: { a: ['components/a', 'hooks/useA.js', 'internal/b.js', 'internal/media.js'] }
    });
  });

  it('ends on an import cycle', () => {
    expect(
      componentSources({
        'components/a/PlA.tsx': "import { PlB } from '../b/PlB.js';",
        'components/b/PlB.tsx': "import { PlA } from '../a/PlA.js';"
      }).components
    ).toEqual({ a: ['components/a', 'components/b'], b: ['components/b', 'components/a'] });
  });
});
