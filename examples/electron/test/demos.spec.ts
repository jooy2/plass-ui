import { mkdirSync, readdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { expect, test } from '@playwright/test';
import { openApp } from './support';

const root = fileURLToPath(new URL('../../../docs/.vitepress/demos', import.meta.url));
const skipped = new Set(['component-index', 'examples', 'home', 'showcase']);

const names = readdirSync(root, { withFileTypes: true })
  .filter((entry) => entry.isDirectory() && !skipped.has(entry.name))
  .flatMap((entry) =>
    readdirSync(`${root}/${entry.name}`)
      .filter((file) => file.endsWith('.tsx') && file !== 'glyphs.tsx')
      .map((file) => `${entry.name}/${file.replace(/\.tsx$/, '')}`)
  );

test('every demo renders in Electron without a complaint', async () => {
  const { app, page, problems } = await openApp();
  const failures: Record<string, string[]> = {};

  for (const name of names) {
    await page.evaluate((hash) => {
      location.hash = hash;
    }, '#/settings');
    await page.evaluate((hash) => {
      location.hash = hash;
    }, `#/components/${name}`);
    await page.waitForFunction(
      () => (document.querySelector('[data-testid="demo"]')?.childElementCount ?? 0) > 0
    );
    await page.waitForTimeout(120);

    if (process.env.PLASS_SHOTS) {
      await page.screenshot({ path: `shots/demos/${name.replace('/', '__')}.png` });
    }

    const found = problems.splice(0);

    // A demo of a picture that fails to load fails to load one on purpose.
    const real = found.filter((text) => !/missing\.png|128x128|Failed to load resource/.test(text));

    if (real.length > 0) {
      failures[name] = real;
    }
  }

  await app.close();
  mkdirSync('shots', { recursive: true });
  writeFileSync('shots/demos.json', JSON.stringify(failures, null, 2));
  expect(failures).toEqual({});
});
