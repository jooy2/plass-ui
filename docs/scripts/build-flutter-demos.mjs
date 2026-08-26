/**
 * Builds the Flutter gallery into `public/flutter`.
 *
 * The Flutter previews on this site are not screenshots and not a React stand-in
 * — they are the real package, compiled for the web and embedded one demo per
 * `<iframe>` by `theme/components/Demo.vue`. That has a cost, and it is this
 * step: a documentation build now needs the Flutter SDK.
 *
 * It is skipped when the output is already there, because a full web build takes
 * a minute or two and almost no documentation edit invalidates it. Pass
 * `--force` after a change to the package or to a demo.
 *
 * If Flutter is not installed the build is skipped with a warning rather than
 * failing: somebody editing Korean prose should not need a Flutter toolchain,
 * and `Demo.vue` already has a message for a preview whose build is missing.
 * CI installs the SDK, so the deployed site always has them.
 */
import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const docsDir = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = resolve(docsDir, '..');
const exampleDir = resolve(repoRoot, 'packages/flutter/example');
const outDir = resolve(docsDir, 'public/flutter');

const force = process.argv.includes('--force');

/** `flutter build web` writes this, and `Demo.vue` probes for it. */
const marker = resolve(outDir, 'version.json');

const flutter = process.platform === 'win32' ? 'flutter.bat' : 'flutter';

if (!force && existsSync(marker)) {
  console.log('[plass-ui docs] Flutter previews already built — pass --force to rebuild.');
} else {
  /*
   * `--base-href` has to match where the output is served from, which is
   * `public/flutter` → `/flutter/`. Without it every asset the engine asks for
   * resolves against the documentation page's own path and 404s.
   *
   * `--pwa-strategy=none` drops the service worker, and it is not an
   * optimisation — it is a correctness fix. Flutter's generated worker caches
   * the whole app under the documentation site's own origin, so **a rebuilt
   * gallery does not appear**: every reader who had already opened a component
   * page keeps being served the previous build until the worker happens to
   * update itself, which is exactly the bug that looks like "my change did
   * nothing". A preview embedded in a page has no use for offline support, and
   * the HTTP cache already does the part that was worth having.
   */
  const result = spawnSync(
    flutter,
    [
      'build',
      'web',
      '--release',
      '--base-href',
      '/flutter/',
      '--pwa-strategy=none',
      /*
       * The gallery ships no icon font, so there is nothing here to tree-shake
       * — and the shaker refuses outright on the one font that *is* shipped:
       * Inter, whose two faces in a single family it reads as an icon font it
       * cannot process. Leaving the flag off costs a build; turning it off
       * costs nothing, because the subset it would compute is empty.
       */
      '--no-tree-shake-icons',
      '--output',
      outDir
    ],
    { cwd: exampleDir, stdio: 'inherit', shell: process.platform === 'win32' }
  );

  if (result.error?.code === 'ENOENT') {
    console.warn(
      '[plass-ui docs] Flutter is not on PATH — the Flutter previews will be missing. ' +
        'Install the SDK from https://docs.flutter.dev/install and run `npm run flutter:demos`.'
    );
  } else if (result.status !== 0) {
    // A non-zero exit code rather than a throw: the Flutter toolchain has
    // already printed the real error, and a stack trace on top of it says
    // nothing.
    process.exitCode = result.status ?? 1;
  } else {
    console.log(`[plass-ui docs] Flutter previews built into ${outDir}`);
  }
}
