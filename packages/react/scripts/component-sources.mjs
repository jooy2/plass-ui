/* A static `from '…'`, a bare `import '…'` and a dynamic `import('…')`, in
   source as written or as terser leaves it. */
const IMPORT = /(?:\bfrom\s*|\bimport\s*\(?\s*)["']([^"']+)["']/g;

/* What `plass-ui/css/base.css` scans, so that no manifest has to: the shared
   table of heights, radii and surfaces, which 129 of the 130 components read.
   Named rather than worked out, because no module is reached by every
   component (`PlTypography` reaches none), so the floor they all share is
   empty. A module named here that no longer exists is simply not scanned by
   `base.css`, and every manifest that reaches its successor names that. */
const SHARED = ['internal/styles'];

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
 * the button reaches rather than every module in `internal/`.
 *
 * Kept free of Node so the build, which reads `dist/`, and the test, which reads
 * `src/` in a browser, walk the same graph.
 *
 * @param {Record<string, string>} files Module text by path, relative to the
 *   package's source or build root: `components/icon-button/PlIconButton.js`,
 *   `internal/calendar.tsx`.
 * @returns {{ shared: string[], components: Record<string, string[]> }} The
 *   paths `base.css` scans, and for each component folder the paths its own
 *   manifest scans: its folder first, then the other component folders it
 *   reaches, then every other module it reaches that `shared` does not cover.
 *   A path is a folder (`components/button`) or a file spelled as it is in
 *   `files` (`internal/glow.js`).
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
      } else if (paths.has(key) && !SHARED.includes(key)) {
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

  return {
    shared: SHARED.filter((key) => paths.has(key)).map((key) => paths.get(key)),
    components: sources
  };
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
