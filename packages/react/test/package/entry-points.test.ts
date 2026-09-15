/**
 * Which subpaths `npm run size` asks Node to resolve.
 *
 * Like `css-manifests.test.ts`, a test of the package rather than of a
 * component. `scripts/size.mjs` loads every entry point through Node's own ESM
 * resolver, which is the failure a bundler hides: a bundler resolves an
 * extensionless specifier and Node, which is what runs a server render, does
 * not. That check is only as good as the list it walks, and the list used to be
 * written by hand — `plass-ui/locales` was never on it. It is read off
 * `exports` now, and this holds it there.
 */
import { describe, expect, it } from 'vitest';
import { entryPoints } from '../../scripts/entry-points.mjs';
import pkg from '../../package.json';

const components = ['button', 'text-field'];
const specifiers = entryPoints(pkg.exports, components);

describe('the entry points the resolution check walks', () => {
  it('names every JavaScript subpath the package exports', () => {
    expect(specifiers).toContain('plass-ui');
    expect(specifiers).toContain('plass-ui/types');
    expect(specifiers).toContain('plass-ui/hooks');
    expect(specifiers).toContain('plass-ui/locales');
    expect(specifiers).toContain('plass-ui/provider');
  });

  it('expands the component wildcard into one specifier per folder', () => {
    expect(specifiers).toContain('plass-ui/button');
    expect(specifiers).toContain('plass-ui/text-field');
    expect(specifiers).not.toContain('plass-ui/*');
  });

  it('leaves out what Node cannot import', () => {
    expect(specifiers).not.toContain('plass-ui/styles.css');
    expect(specifiers).not.toContain('plass-ui/tailwind.css');
    expect(specifiers).not.toContain('plass-ui/tokens.css');
    expect(specifiers).not.toContain('plass-ui/package.json');
  });

  it('misses nothing `exports` declares as JavaScript', () => {
    const declared = Object.entries(pkg.exports as Record<string, unknown>)
      .filter(([, target]) => {
        const file =
          typeof target === 'string' ? target : (target as { default?: string })?.default;
        return typeof file === 'string' && file.endsWith('.js');
      })
      .map(([subpath]) => subpath);

    for (const subpath of declared) {
      const specifier = subpath === '.' ? 'plass-ui' : `plass-ui/${subpath.slice(2)}`;
      const covered = specifier.includes('*')
        ? specifiers.some((candidate) => candidate.startsWith(specifier.replace('*', '')))
        : specifiers.includes(specifier);

      expect(covered, `${subpath} is exported but never resolved`).toBe(true);
    }
  });
});
