/**
 * Runs `vitepress build` with a heap big enough to finish it.
 *
 * VitePress builds the client bundle, the SSR bundle and every page in one
 * process, and this site is a component library's worth of them: 234 pages
 * across two locales, ~490 React demos behind an `import.meta.glob`, and two
 * framework halves of nearly every page. It peaks at 5.7 GB, against Node's
 * default old-space ceiling of about 4 GB — a ceiling Node picks from a table
 * rather than from the machine, so a laptop with 64 GB in it hits the same wall
 * a 4 GB one does. The build dies with `Reached heap limit` partway through the
 * bundles, which reads as a code error in the site and is not one.
 *
 * The ceiling has to be set on the process **before** it starts, which is why
 * this is a launcher rather than a line inside the build. Spawning Node
 * directly, rather than exporting `NODE_OPTIONS` in an npm script, is what
 * keeps `npm run build` working on a shell that does not take `VAR=value
 * command` — every other script here runs on all three platforms and this one
 * has no reason not to.
 *
 * A ceiling already in `NODE_OPTIONS` is honoured instead of ours. It has to be
 * checked rather than left to the runtime: a command-line flag **wins** over
 * `NODE_OPTIONS`, so passing ours unconditionally would quietly overrule
 * somebody who had asked for something else.
 */
import { spawnSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, resolve } from 'node:path';

/** Measured peak is 5.7 GB. The rest is room for the site to keep growing. */
const HEAP_MB = 8192;

/**
 * VitePress's own executable, found through its manifest.
 *
 * The `bin` is not in the package's `exports` map, so it cannot be resolved
 * directly — `./package.json` is, which gives the package root and the path
 * the manifest itself names for the binary.
 */
const require = createRequire(import.meta.url);
const manifestPath = require.resolve('vitepress/package.json');
const { bin } = JSON.parse(readFileSync(manifestPath, 'utf8'));
const vitepress = resolve(dirname(manifestPath), typeof bin === 'string' ? bin : bin.vitepress);

const asked = /--max[-_]old[-_]space[-_]size/.test(process.env.NODE_OPTIONS ?? '');
const args = asked ? [] : [`--max-old-space-size=${HEAP_MB}`];

const { status, error } = spawnSync(process.execPath, [...args, vitepress, 'build'], {
  stdio: 'inherit'
});

if (error) {
  throw error;
}

// `exitCode` rather than `exit()`: the launcher has nothing left to do, and
// the repository's other spawning scripts report a child's failure this way.
process.exitCode = status ?? 1;
