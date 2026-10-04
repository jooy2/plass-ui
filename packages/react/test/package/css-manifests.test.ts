/**
 * What `plass-ui/css/<component>.css` scans, and why it is more than one folder.
 *
 * Like `use-client.test.ts`, a test of the package rather than of a component.
 * `scripts/build-styles.mjs` writes one manifest per component, and Tailwind
 * scans files rather than the import graph — so a manifest that names only a
 * component's own folder drops every utility spelled in a component it renders,
 * and a `base.css` that scans a module makes every project pay for it, whether
 * its components reach it or not. The build reads the graph off `dist/`; this
 * reads the same graph off `src/`, through the same functions, so no build has
 * to have run.
 */
import { describe, expect, it } from 'vitest';
import { componentSources, scanManifests } from '../../scripts/component-sources.mjs';

const modules = Object.fromEntries(
  Object.entries(
    import.meta.glob('../../src/**/*.{ts,tsx}', {
      query: '?raw',
      import: 'default',
      eager: true
    }) as Record<string, string>
  ).map(([path, text]) => [path.replace('../../src/', ''), text])
);

const sources = componentSources(modules);
const manifests = scanManifests(modules);

/* What a project scans when it imports `base.css` and one component's manifest,
   read off the text the build writes. */
function scanned(component: string): string[] {
  return [manifests['base.css'], manifests[`${component}.css`]].flatMap((text) =>
    [...text.matchAll(/^@source '\.\.\/(.+)';$/gm)].map((match) => match[1])
  );
}

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

  it('writes a `base.css` that scans nothing', () => {
    expect(manifests['base.css']).toContain("@import '../tokens.css';");
    expect(manifests['base.css']).not.toContain('@source');
  });

  it('scans the internal modules a component reaches, and no others', () => {
    expect(scanned('button')).toEqual(
      expect.arrayContaining([
        'internal/styles.ts',
        'internal/glow.ts',
        'internal/icons.tsx',
        'internal/loading.ts'
      ])
    );
    expect(scanned('button')).not.toContain('internal');
    expect(scanned('button')).not.toContain('internal/chart.ts');
    expect(scanned('button')).not.toContain('internal/calendar.tsx');
  });

  it('scans no internal module for a component that reaches none', () => {
    // `PlTypography` reads nothing from `internal/`, not even the shared table.
    expect(reachable('typography').filter((file) => file.startsWith('internal/'))).toEqual([]);
    expect(scanned('typography').filter((path) => path.startsWith('internal'))).toEqual([]);
  });

  it('covers every file each component reaches', () => {
    for (const component of Object.keys(sources)) {
      const paths = scanned(component);

      for (const file of reachable(component)) {
        expect(
          paths.some((path) => file === path || file.startsWith(`${path}/`)),
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
      }).a
    ).toEqual(['components/a', 'components/b', 'components/c']);
  });

  it('names a module outside `components/` by its own file, through a hook too', () => {
    expect(
      componentSources({
        'components/a/PlA.js': 'import{u}from"../../hooks/useA.js";import"../../internal/b.js";',
        'hooks/useA.js': 'import{m}from"../internal/media.js";',
        'internal/b.js': '',
        'internal/media.js': '',
        'internal/unused.js': ''
      })
    ).toEqual({ a: ['components/a', 'hooks/useA.js', 'internal/b.js', 'internal/media.js'] });
  });

  it('ends on an import cycle', () => {
    expect(
      componentSources({
        'components/a/PlA.tsx': "import { PlB } from '../b/PlB.js';",
        'components/b/PlB.tsx': "import { PlA } from '../a/PlA.js';"
      })
    ).toEqual({ a: ['components/a', 'components/b'], b: ['components/b', 'components/a'] });
  });

  it('writes a manifest for a folder with no module, scanning the folder alone', () => {
    expect(scanManifests({}, ['a'])['a.css']).toContain("@source '../components/a';");
  });
});
