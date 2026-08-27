/**
 * The stylesheet half of the build.
 *
 * `tsc` only emits JavaScript, so nothing under `src/` that ends in `.css`
 * reaches `dist/` on its own. This runs last in `npm run build` and writes the
 * files the package exports:
 *
 *   src/standalone.css  --(Tailwind)-->  dist/styles.css      `plass-ui/styles.css`
 *   src/styles.css      --(copy)------>  dist/tailwind.css    `plass-ui/tailwind.css`
 *   src/styles.css      --(no @source)-> dist/tokens.css      `plass-ui/tokens.css`
 *                       --(generated)--> dist/css/*.css       `plass-ui/css/*.css`
 *
 * The first two names cross over, and deliberately so. `plass-ui/styles.css` is
 * the one line a project with no build-side Tailwind imports, so it has to be
 * the obvious name; `src/styles.css` is the token sheet, which is only *part*
 * of it.
 *
 * Compiling here rather than in the consumer's build is what removes Tailwind
 * from their install entirely: `tailwindcss` is a devDependency of this package
 * and stays one. The scan is driven by the `@source '.'` inside `src/styles.css`
 * — the same line that, in the copied file, means `node_modules/plass-ui/dist/`
 * for a consumer who does run Tailwind. One declaration serves both outputs.
 *
 * **The last two names are the small half of the package.** `@source '.'` is
 * generous on purpose: it is one line and it cannot be got wrong. What it costs
 * is that a project running Tailwind generates the utilities for all 47
 * components whether it imports one of them or all of them, because Tailwind
 * scans *files* and not the import graph — there is nothing in a build that
 * connects `import { PlButton }` to the classes `PlSelect.js` spells out.
 *
 * So the scan is also published in pieces. `dist/tokens.css` is the token sheet
 * with no `@source` at all, and `dist/css/<component>.css` is a file whose
 * whole content is the `@source` line for one component. A project that wants
 * to pay for what it uses writes the pieces instead of the whole:
 *
 *   @import 'tailwindcss';
 *   @import 'plass-ui/css/base.css';
 *   @import 'plass-ui/css/button.css';
 *   @import 'plass-ui/css/text-field.css';
 *
 * That is still **one** Tailwind pass over a narrower set of files, so the
 * utilities come out in Tailwind's own order — which is the reason this is
 * shipped as a scan and not as 45 pre-compiled stylesheets. Concatenating
 * pre-compiled files would put every shared utility ahead of every
 * component-specific one, and Tailwind's sort is what decides which of two
 * conflicting utilities wins. A stylesheet that is 5 kB smaller and sometimes
 * wrong is not a smaller stylesheet.
 */
import { copyFileSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import postcss from 'postcss';
import tailwindcss from '@tailwindcss/postcss';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const dist = resolve(root, 'dist');

mkdirSync(dist, { recursive: true });

const tokenSheet = readFileSync(resolve(root, 'src/styles.css'), 'utf8');

/* The token sheet, for a project that runs Tailwind itself. */
copyFileSync(resolve(root, 'src/styles.css'), resolve(dist, 'tailwind.css'));

/* The same sheet with the blanket scan taken out, for a project that would
   rather register the components it actually imports. Everything else about the
   two files is identical, so a project can move between them by changing which
   one it imports. */
const SOURCE_LINE = /^@source '\.';$/m;
if (!SOURCE_LINE.test(tokenSheet)) {
  throw new Error(
    "src/styles.css no longer contains `@source '.';` — dist/tokens.css would be wrong"
  );
}
writeFileSync(
  resolve(dist, 'tokens.css'),
  tokenSheet.replace(
    SOURCE_LINE,
    [
      '/* No `@source` here: this file is the tokens on their own.',
      ' * Register the components you import — `plass-ui/css/base.css` plus one',
      ' * `plass-ui/css/<component>.css` per component — or import',
      ' * `plass-ui/tailwind.css` instead, which scans all of them. */'
    ].join('\n')
  )
);

/* One scan manifest per component, plus the shared floor every component needs.
   These are written rather than hand-maintained so that a new component folder
   cannot be added without its manifest. */
const cssDir = resolve(dist, 'css');
rmSync(cssDir, { recursive: true, force: true });
mkdirSync(cssDir, { recursive: true });

const components = readdirSync(resolve(dist, 'components'), { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .sort();

writeFileSync(
  resolve(cssDir, 'base.css'),
  [
    '/* The tokens, plus the classes every component shares.',
    ' * Import this once, then one `plass-ui/css/<component>.css` per component. */',
    "@import '../tokens.css';",
    "@source '../internal';",
    ''
  ].join('\n')
);

for (const component of components) {
  writeFileSync(
    resolve(cssDir, `${component}.css`),
    [
      `/* Scan manifest for <${component}>. Needs \`plass-ui/css/base.css\` first. */`,
      `@source '../components/${component}';`,
      ''
    ].join('\n')
  );
}

/* The finished stylesheet, for everyone else.
   `from` has to be the real source path: Tailwind resolves `@import` and
   `@source` against the file they are written in, so a wrong `from` would look
   for the tokens and the components somewhere they are not. */
const from = resolve(root, 'src/standalone.css');
const to = resolve(dist, 'styles.css');

const compiled = await postcss([tailwindcss({ optimize: true })]).process(
  readFileSync(from, 'utf8'),
  { from, to }
);

writeFileSync(to, compiled.css);

const kb = (bytes) => `${(bytes / 1024).toFixed(1)} kB`;

console.log(
  `styles: dist/styles.css ${kb(compiled.css.length)}, dist/tailwind.css ${kb(
    readFileSync(resolve(dist, 'tailwind.css')).length
  )}, dist/tokens.css + dist/css/ (${components.length} manifests)`
);
