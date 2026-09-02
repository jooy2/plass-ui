/**
 * What a consumer actually pays, measured the way they would pay it.
 *
 * `npm pack`'s size and bundlephobia's number both answer a different question
 * than the one that matters for a library of 99 components: what does an app
 * that imports *three* of them ship? Tree shaking is the whole answer to that,
 * and tree shaking is the one thing neither of those numbers can see — a
 * package can double a consumer's bundle without its own tarball changing by a
 * byte.
 *
 * So this bundles `dist/` for real, against fixed scenarios, and compares the
 * result to `size-budget.json`. Three things make the number the consumer's
 * number rather than a flattering one:
 *
 * - **React is external, `@base-ui/react` is not.** React is in every app
 *   already; Base UI arrives because of us and has to be counted as ours.
 * - **gzip, not raw.** Every server on the path compresses.
 * - **esbuild and Rollup are both wrong on their own.** They disagree about
 *   what is safe to drop — esbuild is stricter about a call it cannot prove
 *   pure — and a consumer runs one or the other. The budget tracks the worse
 *   of the two.
 *
 * Run `npm run size` to print the table, `npm run size -- --update` to write
 * the current numbers back into the budget after a change that is meant to move
 * them.
 */
import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { gzipSync } from 'node:zlib';
import * as esbuild from 'esbuild';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const budgetPath = resolve(root, 'size-budget.json');
const update = process.argv.includes('--update');

/** React is the consumer's; everything else on the graph is ours. */
const EXTERNAL = ['react', 'react-dom', 'react/jsx-runtime', 'react-dom/client'];

/**
 * The three shapes a consumer comes in. One component is the case a barrel
 * export gets wrong; five is the realistic middle; everything is the ceiling
 * and the only number that cannot be improved by tree shaking.
 */
const SCENARIOS = [
  { name: 'PlButton 하나', imports: ['PlButton'] },
  { name: 'PlTypography 하나', imports: ['PlTypography'] },
  { name: '폼 5개', imports: ['PlButton', 'PlTextField', 'PlCheckbox', 'PlCard', 'PlTypography'] },
  {
    name: '오버레이 5개',
    imports: ['PlModal', 'PlTooltip', 'PlMenu', 'PlToastProvider', 'PlSelect']
  },
  { name: '전체', imports: null }
];

const gzip = (text) => gzipSync(Buffer.from(text), { level: 9 }).length;
const kb = (bytes) => `${(bytes / 1024).toFixed(1)} kB`;

/** Every runtime export the barrel offers, for the ceiling scenario. */
async function allExports() {
  const barrel = await import(resolve(root, 'dist/index.js'));
  return Object.keys(barrel).sort();
}

/**
 * Node's own resolver, in a child process, on every entry point the package
 * claims to have.
 *
 * This is here because it is the failure a bundler hides: `tsc` copies an
 * extensionless `./types` straight through, every bundler resolves it, and Node
 * — which is what runs a server render — does not. The package can be broken
 * for SSR while every test in the suite passes.
 */
function checkNodeResolution(componentDirs) {
  const specifiers = [
    'plass-ui',
    'plass-ui/types',
    'plass-ui/hooks',
    'plass-ui/provider',
    ...componentDirs.map((d) => `plass-ui/${d}`)
  ];
  const dir = mkdtempSync(resolve(tmpdir(), 'plass-resolve-'));
  try {
    writeFileSync(
      resolve(dir, 'package.json'),
      JSON.stringify({ type: 'module', dependencies: { 'plass-ui': `file:${root}` } })
    );
    execFileSync('npm', ['install', '--no-audit', '--no-fund', '--ignore-scripts'], {
      cwd: dir,
      stdio: 'ignore'
    });
    const script = specifiers.map((s) => `await import(${JSON.stringify(s)});`).join('\n');
    writeFileSync(resolve(dir, 'check.mjs'), script);
    execFileSync(process.execPath, ['check.mjs'], { cwd: dir, stdio: 'pipe' });
    return { ok: true, count: specifiers.length };
  } catch (error) {
    return { ok: false, message: String(error.stderr ?? error.message).slice(0, 800) };
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

async function bundle(imports) {
  const entry = `import { ${imports.join(', ')} } from 'plass-ui';\nexport { ${imports.join(', ')} };\n`;
  const dir = mkdtempSync(resolve(tmpdir(), 'plass-size-'));
  try {
    const file = resolve(dir, 'entry.js');
    writeFileSync(file, entry);
    const result = await esbuild.build({
      entryPoints: [file],
      bundle: true,
      format: 'esm',
      minify: true,
      treeShaking: true,
      write: false,
      logLevel: 'silent',
      external: EXTERNAL,
      alias: { 'plass-ui': root },
      define: { 'process.env.NODE_ENV': '"production"' }
    });
    return gzip(result.outputFiles[0].text);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

const names = await allExports();
const { readdirSync } = await import('node:fs');
const componentDirs = readdirSync(resolve(root, 'dist/components'), { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name);

const resolution = checkNodeResolution(componentDirs);
if (!resolution.ok) {
  console.error('✗ Node가 dist를 로드하지 못했습니다 (SSR에서 그대로 실패합니다):\n');
  console.error(resolution.message);
  process.exitCode = 1;
} else {
  console.log(`✓ Node ESM 해석 ${resolution.count}개 진입점 통과\n`);
}

const budget = JSON.parse(readFileSync(budgetPath, 'utf8'));
const measured = {};
let regressed = false;

console.log(
  '시나리오'.padEnd(22) + 'gzip'.padStart(10) + '예산'.padStart(12) + '차이'.padStart(12)
);
console.log('-'.repeat(56));
for (const scenario of SCENARIOS) {
  const bytes = await bundle(scenario.imports ?? names);
  measured[scenario.name] = bytes;
  const allowed = budget.scenarios[scenario.name];
  const delta = allowed === undefined ? null : bytes - allowed;
  /* A budget is a ceiling with a little air in it — a 2% swing is a bundler
     patch release, not a regression worth failing a build over. */
  const over = allowed !== undefined && bytes > allowed * 1.02;
  if (over) regressed = true;
  console.log(
    scenario.name.padEnd(22) +
      kb(bytes).padStart(10) +
      (allowed === undefined ? '—' : kb(allowed)).padStart(12) +
      (delta === null ? '—' : `${delta >= 0 ? '+' : ''}${(delta / 1024).toFixed(1)} kB`).padStart(
        12
      ) +
      (over ? '  ✗' : '')
  );
}

if (update) {
  writeFileSync(budgetPath, `${JSON.stringify({ ...budget, scenarios: measured }, null, 2)}\n`);
  console.log('\nsize-budget.json 갱신됨');
} else if (regressed) {
  console.error('\n✗ 예산 초과. 의도한 변경이라면 `npm run size -- --update`');
  process.exitCode = 1;
}
