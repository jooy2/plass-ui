/**
 * The grammar engine behind [PlCodeBlock], and the only thing in the library that
 * is loaded rather than imported.
 *
 * highlight.js is the second runtime dependency Plass has, and it is here for a
 * reason no amount of hand-written regex answers: colouring a language means
 * knowing that language, and there are thirty-five of them. It is reached
 * through `highlight.js/lib/core` plus one module per language — never through
 * the package root, which is all hundred and ninety at once.
 *
 * **Every one of those specifiers is behind an `import()`, and that is the
 * whole design.** A bundler resolves it at build time and emits it as its own
 * chunk, so a page that imports `PlCodeBlock` and never highlights anything — a
 * one-line `npm install` with `highlight={false}` — downloads none of it, and a
 * page that highlights TypeScript downloads the core and TypeScript and not the
 * other thirty-four. A component that does the same with a static import
 * spends forty kilobytes before it has drawn a character.
 *
 * The dependency is a real `dependencies` entry rather than an optional peer
 * because a specifier a bundler cannot resolve fails the *whole* build, not
 * just the part that would have used it: Rollup walks and resolves
 * `PlCodeBlock.js` while it is still deciding whether to keep it. An optional peer
 * would mean `import { PlButton } from 'plass-ui'` breaking for anyone who had
 * not installed a syntax highlighter.
 *
 * What comes back out of here is not HTML. highlight.js emits a string of
 * nested `<span>`s, and PlCodeBlock needs lines — a line is what carries a
 * number, a prompt and a place in a scroll — so `tokenize` turns that string
 * into runs of text with a class on them, split at every newline. That also
 * means nothing in the library ever writes `dangerouslySetInnerHTML`.
 */

/** One run of text with a single colour: the innermost span highlight.js drew. */
export interface PlCodeToken {
  text: string;
  /** The class highlight.js put on it — `hljs-keyword`, `hljs-title function_`. */
  token?: string;
}

/** One line of code, as the runs it is made of. An empty array is a blank line. */
export type PlCodeLine = PlCodeToken[];

/** The core, and what it hands `registerLanguage`. Opaque here; only hljs reads them. */
type Hljs = typeof import('highlight.js/lib/core').default;
type LanguageDefinition = Parameters<Hljs['registerLanguage']>[1];

/**
 * The languages that come with the component, one dynamic import each.
 *
 * Written out rather than built from a template literal on purpose. A
 * `import(\`highlight.js/lib/languages/${name}\`)` cannot be resolved to one
 * module, so every bundler answers it by emitting a chunk for **all** hundred
 * and ninety languages. An explicit map is thirty-five chunks, of which a page
 * fetches the ones it actually shows.
 *
 * The set is highlight.js's own "common" list plus the four a documentation
 * page reaches for and it leaves out: Dockerfile, PowerShell, GraphQL and
 * **Dart** — which this library needs more than most, because half of its own
 * pages are written in it. Anything else is `registerLanguage`, below.
 */
const loaders: Record<string, () => Promise<{ default: LanguageDefinition }>> = {
  bash: () => import('highlight.js/lib/languages/bash'),
  c: () => import('highlight.js/lib/languages/c'),
  cpp: () => import('highlight.js/lib/languages/cpp'),
  csharp: () => import('highlight.js/lib/languages/csharp'),
  css: () => import('highlight.js/lib/languages/css'),
  dart: () => import('highlight.js/lib/languages/dart'),
  diff: () => import('highlight.js/lib/languages/diff'),
  dockerfile: () => import('highlight.js/lib/languages/dockerfile'),
  go: () => import('highlight.js/lib/languages/go'),
  graphql: () => import('highlight.js/lib/languages/graphql'),
  ini: () => import('highlight.js/lib/languages/ini'),
  java: () => import('highlight.js/lib/languages/java'),
  javascript: () => import('highlight.js/lib/languages/javascript'),
  json: () => import('highlight.js/lib/languages/json'),
  kotlin: () => import('highlight.js/lib/languages/kotlin'),
  less: () => import('highlight.js/lib/languages/less'),
  lua: () => import('highlight.js/lib/languages/lua'),
  makefile: () => import('highlight.js/lib/languages/makefile'),
  markdown: () => import('highlight.js/lib/languages/markdown'),
  objectivec: () => import('highlight.js/lib/languages/objectivec'),
  perl: () => import('highlight.js/lib/languages/perl'),
  php: () => import('highlight.js/lib/languages/php'),
  plaintext: () => import('highlight.js/lib/languages/plaintext'),
  powershell: () => import('highlight.js/lib/languages/powershell'),
  python: () => import('highlight.js/lib/languages/python'),
  r: () => import('highlight.js/lib/languages/r'),
  ruby: () => import('highlight.js/lib/languages/ruby'),
  rust: () => import('highlight.js/lib/languages/rust'),
  scss: () => import('highlight.js/lib/languages/scss'),
  shell: () => import('highlight.js/lib/languages/shell'),
  sql: () => import('highlight.js/lib/languages/sql'),
  swift: () => import('highlight.js/lib/languages/swift'),
  typescript: () => import('highlight.js/lib/languages/typescript'),
  xml: () => import('highlight.js/lib/languages/xml'),
  yaml: () => import('highlight.js/lib/languages/yaml')
};

/**
 * What a caller writes, against what highlight.js was registered as.
 *
 * A `language` prop is copied out of a fenced code block or a file extension —
 * `tsx`, `yml`, `sh` — and a component that only answered to highlight.js's own
 * canonical names would leave most of those unhighlighted with no way to tell
 * why. The mapping is one-way and the canonical names map to themselves.
 */
const aliases: Record<string, string> = {
  'c++': 'cpp',
  cc: 'cpp',
  cjs: 'javascript',
  console: 'bash',
  cs: 'csharp',
  cts: 'typescript',
  docker: 'dockerfile',
  gql: 'graphql',
  golang: 'go',
  h: 'cpp',
  hpp: 'cpp',
  htm: 'xml',
  html: 'xml',
  js: 'javascript',
  jsx: 'javascript',
  kt: 'kotlin',
  kts: 'kotlin',
  md: 'markdown',
  mdx: 'markdown',
  mjs: 'javascript',
  mm: 'objectivec',
  mts: 'typescript',
  mysql: 'sql',
  node: 'javascript',
  none: 'plaintext',
  objc: 'objectivec',
  plain: 'plaintext',
  posh: 'powershell',
  ps1: 'powershell',
  psql: 'sql',
  py: 'python',
  rb: 'ruby',
  rs: 'rust',
  sh: 'bash',
  svelte: 'xml',
  svg: 'xml',
  text: 'plaintext',
  toml: 'ini',
  ts: 'typescript',
  tsx: 'typescript',
  txt: 'plaintext',
  vue: 'xml',
  yml: 'yaml',
  zsh: 'bash'
};

/** Languages the consumer brought, waiting for the core to arrive. */
const extra = new Map<string, LanguageDefinition>();

/**
 * Teaches CodeBlock a language the built-in set does not have.
 *
 * The same arrangement `src/locales/` makes for the languages the library's own
 * words are not translated into, and for the same reason: highlight.js knows a
 * hundred and ninety grammars, a documentation site uses six, and the
 * thirty-five here are a guess at which six. Registering is how a Nix flake or
 * an Elixir project gets coloured without the other hundred and fifty being in
 * anyone's build.
 *
 * ```ts
 * import { registerLanguage } from 'plass-ui';
 * import elixir from 'highlight.js/lib/languages/elixir';
 *
 * registerLanguage('elixir', elixir);
 * ```
 *
 * Call it at module scope. A language registered after a block has drawn does
 * not repaint that block — nothing re-renders on its own — but every block
 * mounted after it sees it.
 *
 * @param name What `language` will be written as. Registering a name the
 *   library already has replaces it.
 * @param definition The default export of a `highlight.js/lib/languages/*`
 *   module.
 */
export function registerLanguage(name: string, definition: LanguageDefinition): void {
  const key = name.toLowerCase();

  extra.set(key, definition);
  resolved.delete(key);
}

/** The one `highlight.js/lib/core`, once something has asked for it. */
let core: Promise<Hljs> | null = null;

/**
 * Every language already handed to that core, by the name it went in under.
 *
 * A promise rather than a flag, so two blocks in the same language mounting in
 * the same frame share one fetch instead of racing to register twice.
 */
const resolved = new Map<string, Promise<string | null>>();

/** The canonical name a caller's spelling means, whether or not it can be loaded. */
export function canonicalLanguage(language: string | undefined): string | null {
  if (!language) return null;

  const key = language.trim().toLowerCase();
  if (!key) return null;

  return aliases[key] ?? key;
}

/**
 * Fetches the core and the one grammar, and answers with the name to highlight
 * under — or `null` for a language nothing here knows, which is a block drawn
 * plain rather than a block that throws.
 */
async function prepare(name: string): Promise<string | null> {
  const registered = extra.get(name);
  const load = registered ? undefined : loaders[name];

  if (!registered && !load) return null;

  core ??= import('highlight.js/lib/core').then((module) => module.default);

  const hljs = await core;

  if (registered) hljs.registerLanguage(name, registered);
  else if (!hljs.getLanguage(name)) hljs.registerLanguage(name, (await load!()).default);

  return name;
}

/**
 * Colours `code`, or returns `null` when the language is unknown or the chunk
 * has not arrived yet.
 *
 * Highlighting the block as a whole and splitting afterwards, never line by
 * line: a block comment, a template literal and a heredoc all span lines, and a
 * highlighter handed one line at a time sees the second line of a comment as
 * code.
 */
export async function highlight(code: string, language: string): Promise<PlCodeLine[] | null> {
  let pending = resolved.get(language);

  if (!pending) {
    // Dropped again if it fails. A chunk that did not arrive is a network
    // event, not a fact about the language — cached, it would leave every
    // block in that language plain for the rest of the page's life, including
    // the ones that mount after the connection came back.
    pending = prepare(language).catch((error: unknown) => {
      resolved.delete(language);

      throw error;
    });
    resolved.set(language, pending);
  }

  const name = await pending;
  if (!name || !core) return null;

  const hljs = await core;

  return tokenize(hljs.highlight(code, { language: name, ignoreIllegals: true }).value);
}

/** The five entities highlight.js writes, and nothing else — it escapes no others. */
const entities: Record<string, string> = {
  '&amp;': '&',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&#x27;': "'"
};

/**
 * highlight.js's own markup, as lines of coloured runs.
 *
 * The output is a strictly nested tree of `<span class="…">` with escaped text
 * between, and a span may cross a newline — which is exactly why this exists
 * rather than a `split('\n')` over the string. Walking it keeps the open class
 * across the break and reopens it on the next line.
 *
 * Only the innermost class survives a nesting. In the browser it is the one on
 * the element the text actually sits in, so it is the one whose colour applies;
 * keeping the ancestors would put two equally specific rules on one run and let
 * stylesheet order decide the colour.
 */
export function tokenize(html: string): PlCodeLine[] {
  const lines: PlCodeLine[] = [[]];
  const open: string[] = [];
  const pattern = /<span class="([^"]*)">|<\/span>/g;
  let index = 0;

  const push = (raw: string) => {
    if (!raw) return;

    const token = open[open.length - 1];
    const text = raw.replace(/&(?:amp|lt|gt|quot|#x27);/g, (entity) => entities[entity]);

    text.split('\n').forEach((part, position) => {
      if (position > 0) lines.push([]);
      if (part) lines[lines.length - 1].push(token ? { text: part, token } : { text: part });
    });
  };

  for (const match of html.matchAll(pattern)) {
    push(html.slice(index, match.index));
    index = match.index + match[0].length;

    if (match[1] === undefined) open.pop();
    else open.push(match[1]);
  }

  push(html.slice(index));

  return lines;
}

/** The same shape with no colour in it: what a block draws before its chunk lands. */
export function plainLines(code: string): PlCodeLine[] {
  return code.split('\n').map((line) => (line ? [{ text: line }] : []));
}
