/* A static `from '…'`, a bare `import '…'` and a dynamic `import('…')`, in
   source as written or as terser leaves it. */
const IMPORT = /(?:\bfrom\s*|\bimport\s*\(?\s*)["']([^"']+)["']/g;

/**
 * The text of every file under `plass-ui/css/`: `base.css`, and one manifest
 * per component that scans what `componentSources` says it reaches.
 *
 * `base.css` is the tokens and nothing else. No module is reached by every
 * component, so anything it scanned would be paid for by a project that never
 * reaches it — which is what the whole set of files exists to avoid.
 *
 * @param {Record<string, string>} files As for `componentSources`.
 * @param {string[]} [folders] Component folders that need a manifest even if no
 *   module in `files` lives in them; such a manifest scans the folder alone.
 * @returns {Record<string, string>} CSS text by file name: `base.css`,
 *   `button.css`.
 */
export function scanManifests(files, folders = []) {
  const sources = componentSources(files);
  /** @type {Record<string, string>} */
  const manifests = {
    'base.css': [
      '/* The tokens. Import this once, then one `plass-ui/css/<component>.css` per',
      ' * component, which scans everything that component reaches. */',
      "@import '../tokens.css';",
      ''
    ].join('\n')
  };

  for (const component of [...new Set([...Object.keys(sources), ...folders])].sort()) {
    manifests[`${component}.css`] = [
      `/* Scan manifest for <${component}>. Needs \`plass-ui/css/base.css\` first. */`,
      ...(sources[component] ?? [`components/${component}`]).map((path) => `@source '../${path}';`),
      ''
    ].join('\n');
  }

  return manifests;
}

/**
 * Which files a component's utilities can be spelled in.
 *
 * Tailwind scans files, so a `plass-ui/css/<component>.css` manifest has to name
 * every file whose classes end up on the component's elements — not only its
 * own folder. `PlIconButton` renders a `PlButton`, so the button's box shadow is
 * spelled in `components/button/`; the date pickers reach `PlButton` through
 * `internal/calendar`, and every chart reaches `PlBox` through
 * `internal/chart-frame`. A manifest that named the component's own folder
 * alone built a stylesheet with those utilities missing.
 *
 * A component folder is named whole. A module outside `components/` is named by
 * its own file, so a project that registers `PlButton` scans the seven modules
 * the button reaches rather than every module in `internal/`. That includes
 * `internal/styles`, which 129 of the 130 components read: it is named in each
 * of those manifests rather than once in `base.css`, so a project that
 * registers only `PlTypography`, which reaches no module at all, does not pay
 * for it.
 *
 * Kept free of Node so the build, which reads `dist/`, and the test, which reads
 * `src/` in a browser, walk the same graph.
 *
 * @param {Record<string, string>} files Module text by path, relative to the
 *   package's source or build root: `components/icon-button/PlIconButton.js`,
 *   `internal/calendar.tsx`.
 * @returns {Record<string, string[]>} For each component folder, the paths
 *   its manifest scans: its folder first, then the other component folders it
 *   reaches, then every other module it reaches. A path is a folder
 *   (`components/button`) or a file spelled as it is in `files`
 *   (`internal/glow.js`).
 */
export function componentSources(files) {
  /** @type {Map<string, string[]>} */
  const modules = new Map();
  /** @type {Map<string, string>} */
  const paths = new Map();

  for (const [path, text] of Object.entries(files)) {
    const imports = [];

    for (const match of text.matchAll(IMPORT)) {
      if (match[1].startsWith('.')) {
        imports.push(withoutExtension(join(dirname(path), match[1])));
      }
    }

    modules.set(withoutExtension(path), imports);
    paths.set(withoutExtension(path), path);
  }

  const components = [...new Set([...modules.keys()].map(folderOf).filter(Boolean))].sort();
  /** @type {Record<string, string[]>} */
  const sources = {};

  for (const component of components) {
    const folders = new Set();
    const others = new Set();
    const seen = new Set();
    const pending = [...modules.keys()].filter((key) => folderOf(key) === component);

    while (pending.length > 0) {
      const key = pending.pop();

      if (seen.has(key)) {
        continue;
      }

      seen.add(key);

      const folder = folderOf(key);

      if (folder) {
        if (folder !== component) {
          folders.add(folder);
        }
      } else if (paths.has(key)) {
        others.add(paths.get(key));
      }

      pending.push(...(modules.get(key) ?? []));
    }

    sources[component] = [
      `components/${component}`,
      ...[...folders].sort().map((folder) => `components/${folder}`),
      ...[...others].sort()
    ];
  }

  return sources;
}

function folderOf(key) {
  const parts = key.split('/');

  return parts[0] === 'components' && parts.length > 2 ? parts[1] : null;
}

function dirname(path) {
  const slash = path.lastIndexOf('/');

  return slash === -1 ? '' : path.slice(0, slash);
}

/* A `.js` specifier names the `.ts` or `.tsx` file it was compiled from, so the
   extension is not part of a module's identity here. */
function withoutExtension(path) {
  return path.replace(/\.(?:[cm]?js|tsx?)$/, '');
}

function join(base, specifier) {
  const parts = [];

  for (const part of `${base}/${specifier}`.split('/')) {
    if (part === '..') {
      parts.pop();
    } else if (part !== '.' && part !== '') {
      parts.push(part);
    }
  }

  return parts.join('/');
}
