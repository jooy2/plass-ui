/**
 * Runs the suite in shards, because one browser tab cannot hold all of it.
 *
 * `fileParallelism` is off — a browser has one focus to hand out, and focus is
 * half of what these components do — so all 152 files run as frames of a single
 * page. That page's renderer starts at about 450 MB and climbs roughly 5 MB per
 * file to 1.2 GB: `isolate` gives every file a fresh iframe, and Chromium is in
 * no hurry to reclaim the module graph of the one it just detached. Somewhere
 * past a hundred files it stops being in a hurry to stay alive either, and the
 * run ends with
 *
 *     [vitest] Browser connection was closed while running tests.
 *
 * naming whichever file happened to be running. It is not that file. Locally it
 * took three runs in four; in CI it took two of the nine matrix jobs.
 *
 * Three shards is what it costs to fix: each one is a fresh browser over a
 * third of the files, peaks around 880 MB, and nine consecutive shard runs came
 * back green where the single run could not manage two. They run one after
 * another rather than at once — the machine has one set of cores and the point
 * is a smaller browser, not a faster wall clock.
 *
 * **A filtered run is not sharded.** `npm test -- test/components/button` is a
 * handful of files and fits in one page, and sharding it would start three
 * browsers to run two files in one of them. Set `VITEST_SHARDS=1` to force the
 * single unsharded run back for a whole suite, which is worth having when the
 * thing being debugged is the runner itself.
 */
import { spawnSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, resolve } from 'node:path';

/** Enough to keep a shard's renderer well under where the page starts dying. */
const DEFAULT_SHARDS = 3;

/**
 * Vitest's own executable, found through its manifest.
 *
 * The `bin` is not in the package's `exports` map, so it cannot be resolved
 * directly — `./package.json` is, which gives the package root and the path the
 * manifest itself names for the binary. `docs/scripts/build-site.mjs` reaches
 * VitePress the same way and for the same reason.
 */
const require = createRequire(import.meta.url);
const manifestPath = require.resolve('vitest/package.json');
const { bin } = JSON.parse(readFileSync(manifestPath, 'utf8'));
const vitest = resolve(dirname(manifestPath), typeof bin === 'string' ? bin : bin.vitest);

const args = process.argv.slice(2);
const asked = Number.parseInt(process.env.VITEST_SHARDS ?? '', 10);
const shards = Number.isInteger(asked) && asked > 0 ? asked : DEFAULT_SHARDS;

/** Anything the caller passed is a filter, and a filtered run is a small one. */
const count = args.length > 0 || shards === 1 ? 1 : shards;

for (let shard = 1; shard <= count; shard += 1) {
  const sharded = count > 1 ? [`--shard=${shard}/${count}`] : [];
  const { status, error } = spawnSync(process.execPath, [vitest, 'run', ...sharded, ...args], {
    stdio: 'inherit'
  });

  if (error) {
    throw error;
  }

  if (status !== 0) {
    // The remaining shards are not run: a red suite is red, and starting two
    // more browsers to say so again takes a minute nobody is waiting for.
    process.exitCode = status ?? 1;
    break;
  }
}
