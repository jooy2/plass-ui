/**
 * Every subpath a consumer can `import` from the package, read off `exports`.
 *
 * Derived rather than listed, because a list has to be remembered: `exports`
 * gained `./locales` and the hand-written one in `scripts/size.mjs` did not, so
 * the resolution check never once loaded the label packs. Reading the field the
 * consumer's resolver reads means the next subpath is checked the day it is
 * added.
 *
 * Only the JavaScript ones come back. The stylesheets are real entry points but
 * Node's ESM loader cannot import a `.css` file at all, and `./package.json`
 * needs an import attribute, so neither would say anything about the package.
 *
 * Kept free of Node so the script, which has `dist/` in front of it, and the
 * test, which runs in a browser, ask the same question.
 *
 * @param {Record<string, unknown>} exports The package's `exports` field.
 * @param {string[]} componentDirs The folder names under `dist/components`,
 *   which is what the `./*` wildcard stands for.
 * @returns {string[]} Import specifiers, in the order `exports` declares them.
 */
export function entryPoints(exports, componentDirs) {
  const specifiers = [];

  for (const [subpath, target] of Object.entries(exports)) {
    const file = typeof target === 'string' ? target : target?.default;

    if (typeof file !== 'string' || !file.endsWith('.js')) {
      continue;
    }

    const specifier = subpath === '.' ? 'plass-ui' : `plass-ui/${subpath.slice(2)}`;

    if (specifier.includes('*')) {
      for (const dir of componentDirs) {
        specifiers.push(specifier.replace('*', dir));
      }
    } else {
      specifiers.push(specifier);
    }
  }

  return specifiers;
}
