/**
 * That `PlassToken` still names every token `styles.css` declares.
 *
 * Like `use-client.test.ts`, this is a test of the *package* rather than of a
 * component, and it exists because nothing else notices. The type is the
 * caller's map of the theming channel — the one that reaches the edge, the
 * shadow and the fill that no `className` can — and a token added to the
 * stylesheet without a line here is a token nobody can find, while a line here
 * with no token behind it is a name that compiles and paints nothing. Neither
 * breaks a build, a test or the docs.
 *
 * It reads both files as text on purpose. A union type has no runtime value to
 * assert against, so the alternative would be a second list in JavaScript — and
 * a third copy of a list is exactly what this is here to prevent.
 */
import { describe, expect, it } from 'vitest';
import styles from '../../src/styles.css?raw';
import types from '../../src/types.ts?raw';

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
});
