/**
 * The JavaScript half of the build.
 *
 * `tsc` emits readable code with every comment still in it, which is the right
 * thing for a compiler to do and the wrong thing to publish: an install of this
 * package is 74 components whether the consumer wanted one of them or all of
 * them, and none of that text is read by anything but a bundler.
 *
 * Minifying a library was tried once and reverted, for a real reason — terser
 * strips the `@__PURE__` annotations, and those 189 comments are what let a
 * bundler drop the `React.createContext` and the `[...].join(' ')` of a
 * component the consumer never imported. Losing them costs a consumer far more
 * than the tarball saves.
 *
 * `format.preserve_annotations` is the option that was missed. With it, terser
 * re-emits every annotation it read, so the two things stop being a trade:
 *
 * - **`preserve_annotations: true`** — the annotations reach `dist` intact, and
 *   `npm run size` is what proves it, because it measures a consumer's bundle
 *   rather than ours.
 * - **`keep_fnames: true`, on both `compress` and `mangle`** — a component is
 *   `React.forwardRef(function PlButton(…))`, and that inner name is what React
 *   DevTools shows. Without it every component in the consumer's tree reads
 *   `Anonymous`. It costs 3 kB across the package.
 * - **The annotation count is asserted, not assumed.** A terser upgrade that
 *   quietly changed the option's behaviour would otherwise show up as nothing
 *   worse than a slightly larger bundle in somebody else's app.
 *
 * Nothing here touches the `.d.ts` files: their comments are the documentation
 * an editor shows on hover, which is read by a person and therefore stays.
 */
import { readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { minify } from 'terser';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const dist = resolve(root, 'dist');

const walk = (dir) =>
  readdirSync(dir, { withFileTypes: true }).flatMap((entry) =>
    entry.isDirectory() ? walk(join(dir, entry.name)) : [join(dir, entry.name)]
  );

const files = walk(dist).filter((file) => file.endsWith('.js'));
const annotations = (code) => (code.match(/@__PURE__/g) ?? []).length;

let before = 0;
let after = 0;
let kept = 0;

for (const file of files) {
  const source = readFileSync(file, 'utf8');
  const expected = annotations(source);
  const result = await minify(source, {
    module: true,
    ecma: 2022,
    compress: { passes: 2, keep_fnames: true },
    mangle: { keep_fnames: true },
    format: { preserve_annotations: true, comments: false }
  });

  const found = annotations(result.code);
  if (found !== expected) {
    throw new Error(
      `${file}: ${expected - found} of ${expected} \`@__PURE__\` annotations lost. ` +
        'Shipping this would cost consumers the tree shaking they buy — fix the terser options rather than the count.'
    );
  }

  before += Buffer.byteLength(source);
  after += Buffer.byteLength(result.code);
  kept += found;
  writeFileSync(file, result.code);
}

const kb = (bytes) => `${(bytes / 1024).toFixed(1)} kB`;

console.log(
  `minify: ${files.length} files, ${kb(before)} -> ${kb(after)}, ${kept} \`@__PURE__\` kept`
);
