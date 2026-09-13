/* A static `from '…'`, a bare `import '…'` and a dynamic `import('…')`, in
   source as written or as terser leaves it. */
const IMPORT = /(?:\bfrom\s*|\bimport\s*\(?\s*)["']([^"']+)["']/g;

/**
 * Which component folders a component's utilities can be spelled in.
 *
 * Tailwind scans files, so a `plass-ui/css/<component>.css` manifest has to name
 * every folder whose classes end up on the component's elements — not only its
 * own. `PlIconButton` renders a `PlButton`, so the button's box shadow is
 * spelled in `components/button/`; the date pickers reach `PlButton` through
 * `internal/calendar`, and every chart reaches `PlBox` through
 * `internal/chart-frame`. A manifest that named the component's own folder
 * alone built a stylesheet with those utilities missing.
 *
 * Kept free of Node so the build, which reads `dist/`, and the test, which reads
 * `src/` in a browser, walk the same graph.
 *
 * @param {Record<string, string>} files Module text by path, relative to the
 *   package's source or build root: `components/icon-button/PlIconButton.js`,
 *   `internal/calendar.tsx`.
 * @returns {Record<string, string[]>} For each component folder, the folders
 *   to scan: its own first, then the rest in order.
 */
export function componentSources(files) {
  /** @type {Map<string, string[]>} */
  const modules = new Map();

  for (const [path, text] of Object.entries(files)) {
    const imports = [];

    for (const match of text.matchAll(IMPORT)) {
      if (match[1].startsWith('.')) {
        imports.push(withoutExtension(join(dirname(path), match[1])));
      }
    }

    modules.set(withoutExtension(path), imports);
  }

  const components = [...new Set([...modules.keys()].map(folderOf).filter(Boolean))].sort();
  /** @type {Record<string, string[]>} */
  const sources = {};

  for (const component of components) {
    const folders = new Set();
    const seen = new Set();
    const pending = [...modules.keys()].filter((key) => folderOf(key) === component);

    while (pending.length > 0) {
      const key = pending.pop();

      if (seen.has(key)) {
        continue;
      }

      seen.add(key);

      const folder = folderOf(key);

      if (folder && folder !== component) {
        folders.add(folder);
      }

      pending.push(...(modules.get(key) ?? []));
    }

    sources[component] = [component, ...[...folders].sort()];
  }

  return sources;
}

function folderOf(key) {
  const parts = key.split('/');

  return parts[0] === 'components' && parts.length > 2 ? parts[1] : null;
}

function dirname(path) {
  return path.slice(0, path.lastIndexOf('/'));
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
