/**
 * The first step of the build, and the only one that deletes anything.
 *
 * `tsc` writes; it never removes. A file compiled into `dist/` stays there for
 * the life of the working tree, so a component deleted from `src/` is still a
 * component this package ships: `package.json` publishes the whole directory,
 * and the `./*` export resolves `plass-ui/thing` straight out of it. The
 * removed name goes on importing, goes on being typed, and goes on being real
 * to everyone but the person who removed it.
 *
 * It is not only the export. `scripts/build-styles.mjs` reads the component
 * list off `dist/components` to write the `plass-ui/css/*.css` scan manifests,
 * so a stale folder there is also a stale stylesheet manifest — and
 * `scripts/minify.mjs` counts `@__PURE__` annotations across whatever it finds,
 * which is a count that quietly disagrees with the source it is supposed to be
 * a count of.
 *
 * None of that fails a build. It fails in somebody else's install, which is why
 * this runs before `tsc` rather than being left to whoever remembers.
 */
import { rmSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const dist = resolve(root, 'dist');

rmSync(dist, { recursive: true, force: true });

console.log('clean: dist/ removed');
