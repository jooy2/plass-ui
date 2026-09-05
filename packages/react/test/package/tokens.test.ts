/**
 * That `PlassToken`, `styles.css` and the components all agree about which
 * tokens exist.
 *
 * Like `use-client.test.ts`, this is a test of the *package* rather than of a
 * component, and it exists because nothing else notices. The type is the
 * caller's map of the theming channel — the one that reaches the edge, the
 * shadow and the fill that no `className` can — and a token added to the
 * stylesheet without a line here is a token nobody can find, while a line here
 * with no token behind it is a name that compiles and paints nothing. Neither
 * breaks a build, a test or the docs.
 *
 * It reads the files as text on purpose. A union type has no runtime value to
 * assert against, so the alternative would be a second list in JavaScript — and
 * a third copy of a list is exactly what this is here to prevent.
 *
 * The third check is the one that has actually caught something. A component
 * that reads a token nobody declared is not an error anywhere: an unresolvable
 * `var()` in a `stroke` computes to `none` and in a `fill` to black, so the
 * mark is simply missing or wrong and every build stays green. Two shipped that
 * way — the chart frame's three greys, and the sheet a marker's ring is cut
 * out of — before this was written down.
 */
import { describe, expect, it } from 'vitest';
import styles from '../../src/styles.css?raw';
import types from '../../src/types.ts?raw';

/**
 * Every source file the package ships, as text.
 *
 * Through Vite's glob rather than `node:fs`, because these run in a real
 * browser and there is no file system in one.
 */
const sources: Record<string, string> = {
  ...import.meta.glob('../../src/**/*.ts', { query: '?raw', import: 'default', eager: true }),
  ...import.meta.glob('../../src/**/*.tsx', { query: '?raw', import: 'default', eager: true })
};

/**
 * Every `--plass-*` token a component actually reads.
 *
 * The lookahead drops the names that are only a prefix — a ladder read as
 * `var(--plass-shadow-${elevation})` is a whole rung of real tokens and none of
 * them is called `--plass-shadow-`. What is left is every name written out in
 * full, which is where a typo or a token from another library ends up.
 */
function readTokens(files: Record<string, string>): Set<string> {
  const found = new Set<string>();

  for (const file of Object.values(files)) {
    for (const [, token] of file.matchAll(/var\((--plass-[a-z0-9-]+)(?![a-z0-9-]|\$)/g))
      found.add(token);
    // Tailwind's own shorthand for the same thing: `bg-(--plass-glass)`.
    for (const [, token] of file.matchAll(/-\((--plass-[a-z0-9-]+)\)/g)) found.add(token);
  }

  return found;
}

/** Every `--plass-*` custom property the stylesheet declares a value for. */
function declaredTokens(css: string): Set<string> {
  return new Set(Array.from(css.matchAll(/^\s*(--plass-[a-z0-9-]+)\s*:/gm), (m) => m[1]));
}

/** The members of a string-union type alias, as written. */
function unionMembers(source: string, name: string): string[] {
  const match = source.match(new RegExp(`export type ${name} =([\\s\\S]*?);`));

  if (!match) throw new Error(`no type ${name} in src/types.ts`);

  return Array.from(match[1].matchAll(/'([^']+)'/g), (m) => m[1]);
}

/**
 * The token union, with its template literals expanded.
 *
 * Three of its members are patterns rather than names — a family crossed with
 * its slots, the radius ladder, the shadow ladder — and the lists they cross
 * are the other unions in the same file, which is what keeps this from being a
 * fourth copy of the palette.
 */
function tokenUnion(source: string): Set<string> {
  const lists: Record<string, string[]> = {
    PlassColor: unionMembers(source, 'PlassColor'),
    PlassColorSlot: unionMembers(source, 'PlassColorSlot'),
    PlassSize: unionMembers(source, 'PlassSize')
  };

  const body = source.match(/export type PlassToken =([\s\S]*?);/)?.[1];

  if (!body) throw new Error('no type PlassToken in src/types.ts');

  const tokens = new Set(Array.from(body.matchAll(/'(--plass-[^']+)'/g), (m) => m[1]));

  for (const [, pattern] of body.matchAll(/`([^`]+)`/g)) {
    let expanded = [''];

    for (const piece of pattern.split(/(\$\{[^}]+\})/)) {
      const placeholder = piece.match(/^\$\{(.+)\}$/);
      const values = placeholder
        ? (lists[placeholder[1]] ?? placeholder[1].split('|').map((v) => v.trim()))
        : [piece];

      expanded = expanded.flatMap((prefix) => values.map((value) => prefix + value));
    }

    for (const token of expanded) tokens.add(token);
  }

  return tokens;
}

describe('the token channel', () => {
  const declared = declaredTokens(styles);
  const named = tokenUnion(types);

  it('reads a stylesheet that actually declares tokens', () => {
    // A regex that matched nothing would make both assertions below vacuous.
    expect(declared.size).toBeGreaterThan(100);
  });

  it('names every token the stylesheet declares', () => {
    expect([...declared].filter((token) => !named.has(token)).sort()).toEqual([]);
  });

  it('names no token the stylesheet does not declare', () => {
    expect([...named].filter((token) => !declared.has(token)).sort()).toEqual([]);
  });

  it('declares every token a component reads', () => {
    const read = readTokens(sources);

    expect(read.size).toBeGreaterThan(20);
    expect([...read].filter((token) => !declared.has(token)).sort()).toEqual([]);
  });
});
