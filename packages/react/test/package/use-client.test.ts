/**
 * Which component modules carry `'use client'`, and which deliberately do not.
 *
 * Like `test/styles/standalone.test.tsx`, this is a test of the *package*
 * rather than of a component. Nearly every component here calls a hook or reads
 * a context, which makes it a client component in a React Server Component
 * graph — Next.js's App Router being the one almost everybody meets. The
 * directive is what says so, and it has to be on the module that holds the
 * component, not on a barrel that re-exports it: the boundary is per-module,
 * and a barrel with the directive would drag the whole library across it.
 *
 * **It is not free, which is why it is not uniform.** A client module cannot be
 * handed a function by a server component, so a component whose own API is
 * callbacks — every `PlTable` column is a `render` function — becomes unusable
 * from the server-rendered page it most belongs on. One that costs a consumer
 * something concrete is therefore kept out of the client graph on purpose, and
 * listed below.
 *
 * Only one direction of that is asserted, and the omission is deliberate.
 * *Reaching for a hook* is decidable from the source, so a module that does one
 * and says nothing fails here. *Not needing the directive* is not decidable: a
 * component that builds a handler of its own and hands it to a Base UI
 * primitive is across the boundary too, and no regex sees that. The absence of
 * a hook is necessary and not sufficient, so a component joins the list below
 * by review rather than by passing a test.
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

/**
 * The public hooks. Every one of them *is* a hook, so the directive is not a
 * judgement call here the way it is for a component — a module whose whole
 * export is `useSyncExternalStore` under another name has no server half.
 */
const hooks = import.meta.glob('../../src/hooks/use*.ts', {
  query: '?raw',
  import: 'default',
  eager: true
});

/** The barrels, which must *not* carry it — a client barrel is a client library. */
const barrels = {
  ...import.meta.glob('../../src/components/*/index.ts', {
    query: '?raw',
    import: 'default',
    eager: true
  }),
  ...import.meta.glob('../../src/hooks/index.ts', {
    query: '?raw',
    import: 'default',
    eager: true
  })
};

const name = (path: string) => path.replace(/^.*\/src\//, 'src/');

const hasDirective = (source: string) => source.split('\n')[0] === "'use client';";

/**
 * Comments out, because comments talk about hooks. `PlTable`'s own explanation
 * of why it stopped calling `React.useId` would otherwise read as a call to it.
 */
const code = (source: string) =>
  source.replace(/\/\*[\s\S]*?\*\//g, '').replace(/(^|[^:])\/\/.*$/gm, '$1');

/**
 * Whether a module reaches for something only a client component may have.
 *
 * React's own hooks and `createContext` are the obvious half. The other half is
 * this package's internal hooks — `useAnimateElement`, `usePickerLabels` and
 * the rest — which are hooks by every rule that matters, even though at this
 * level the name is the only thing saying so.
 *
 * `useRender` is the exception that has to be written down: it is Base UI's
 * render-prop helper, it calls no hook of its own, and a component whose only
 * `use*` is that one is a plain function spelled like a hook.
 */
const reachesForAHook = (source: string) =>
  /\bReact\.(use[A-Z]\w*|createContext)\b/.test(code(source)) ||
  /\buse(?!Render\b)[A-Z]\w*\(/.test(code(source));

/**
 * The modules kept out of the client graph, and what each one buys by it.
 *
 * Short on purpose. A component belongs here only when the directive costs a
 * consumer something they cannot work around, and being here is a promise that
 * the module keeps no state, reads no context and generates no id.
 */
const serverRenderable: Record<string, string> = {
  'src/components/table/PlTable.tsx':
    'every column is a `render` callback, and a server component cannot hand a function across a client boundary'
};

describe("'use client'", () => {
  it('finds every component module', () => {
    expect(Object.keys(sources).length).toBeGreaterThan(70);
  });

  it.each(Object.entries(sources))(
    '%s declares itself if it reaches for a hook',
    (path, source) => {
      const file = name(path);
      const mustDeclare = reachesForAHook(source);

      expect({ file, mustDeclare, declared: hasDirective(source) }).toEqual({
        file,
        mustDeclare,
        declared: mustDeclare || hasDirective(source)
      });
    }
  );

  it.each(Object.entries(serverRenderable))('%s stays out of the client graph', (file, why) => {
    const entry = Object.entries(sources).find(([path]) => name(path) === file);

    expect(
      entry,
      `${file} is listed as server-renderable and is not a component module`
    ).toBeDefined();

    const source = entry![1] as string;

    expect({ file, why, directive: hasDirective(source), hook: reachesForAHook(source) }).toEqual({
      file,
      why,
      directive: false,
      hook: false
    });
  });

  it.each(Object.entries(hooks))(
    '%s declares itself, because a hook has no server half',
    (path, source) => {
      expect({ file: name(path), declared: hasDirective(source as string) }).toEqual({
        file: name(path),
        declared: true
      });
    }
  );

  it.each(Object.entries(barrels))('%s does not carry it', (path, source) => {
    expect({ file: name(path), directive: /^\s*(['"])use client\1/.test(source) }).toEqual({
      file: name(path),
      directive: false
    });
  });
});
