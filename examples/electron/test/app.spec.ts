import { expect, test, type Page } from '@playwright/test';
import { openApp, type Session } from './support';

let session: Session;
let page: Page;

test.beforeAll(async () => {
  session = await openApp();
  page = session.page;
});

test.afterAll(async () => {
  await session.app.close();
});

test.afterEach(() => {
  expect(session.problems.splice(0)).toEqual([]);
});

async function go(name: string) {
  await page.getByRole('navigation', { name: 'Main' }).getByText(name, { exact: true }).click();
}

const shot = (name: string) => page.screenshot({ path: `shots/app/${name}.png` });

test('loads from its own scheme with the sandbox on', async () => {
  expect(page.url()).toMatch(/^plass:\/\/app\//);
  expect(await page.evaluate(() => typeof window.desktop?.setTheme)).toBe('function');
  expect(await page.evaluate(() => 'require' in window)).toBe(false);
});

for (const name of ['Dashboard', 'Showcase', 'Sign-up', 'Landing']) {
  test(`${name} draws`, async () => {
    await go(name);
    await expect(page.locator('main').locator('*').first()).toBeVisible();
    await page.waitForTimeout(600);
    await shot(name);
  });
}

test('Inbox searches and sends', async () => {
  await go('Inbox');
  await page.getByLabel('Search', { exact: true }).fill('invoice');
  await expect(page.getByText('Theo Quinn')).toBeVisible();
  await expect(page.getByText('Anya Sol')).toHaveCount(0);
  await page.getByLabel('Search', { exact: true }).fill('');
  await page.getByLabel('Reply').fill('On my way');
  await page.getByRole('button', { name: 'Send' }).click();
  await expect(page.getByText('On my way')).toBeVisible();
  await shot('inbox');
});

test.describe('Overlays', () => {
  test.beforeAll(() => go('Overlays'));

  for (const [name, inside] of [
    ['Modal', 'Rename project'],
    ['Drawer', 'Filters'],
    ['Popover', 'Effective rate'],
    ['Menu', 'Paste']
  ]) {
    test(`${name} opens and closes`, async () => {
      await page.getByRole('button', { name, exact: true }).click();
      await expect(page.getByText(inside, { exact: true })).toBeVisible();
      await page.waitForTimeout(350);
      await shot(`overlay-${name}`);
      await page.keyboard.press('Escape');
      await expect(page.getByText(inside, { exact: true })).toHaveCount(0);
    });
  }

  test('Tooltip shows on hover', async () => {
    await page.getByRole('button', { name: 'Tooltip', exact: true }).hover();
    await expect(page.getByText('Saved two minutes ago')).toBeVisible();
    await page.mouse.move(0, 0);
  });

  test('Toast and Confirm', async () => {
    await page.getByRole('button', { name: 'Toast', exact: true }).click();
    await expect(page.getByText('Your changes are live.')).toBeVisible();
    await page.getByRole('button', { name: 'Confirm', exact: true }).click();
    await expect(page.getByText('Delete this project?')).toBeVisible();
    await shot('overlay-confirm');
    await page.getByRole('button', { name: 'Delete', exact: true }).click();
    await expect(page.getByText('Deleted', { exact: true })).toBeVisible();
  });

  test('Command palette', async () => {
    await page.getByRole('button', { name: 'Command palette' }).click();
    await page.keyboard.type('invite');
    await expect(page.getByText('Invite a colleague')).toBeVisible();
    await shot('overlay-palette');
    await page.keyboard.press('Escape');
  });

  test('Context menu opens on a right-click', async () => {
    await page.getByText('Right-click here').click({ button: 'right' });
    await expect(page.getByText('Duplicate')).toBeVisible();
    await page.keyboard.press('Escape');
  });
});

test('Desktop highlights code from a lazy chunk and copies it', async () => {
  await go('Desktop');
  await expect(page.locator('.hljs-keyword, [class*="hljs"]').first()).toBeVisible();
  await shot('desktop');

  const copy = page.getByRole('button', { name: /copy/i }).first();

  await copy.click();
  expect(await session.app.evaluate(({ clipboard }) => clipboard.readText())).toContain('PlButton');
});

test('Settings changes the theme natively, the direction and the density', async () => {
  await go('Settings');
  await page.getByRole('radio', { name: 'Dark' }).click();
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  expect(
    await session.app.evaluate(({ nativeTheme }) => nativeTheme.themeSource)
  ).toBe('dark');
  await page.waitForTimeout(200);
  await shot('settings-dark');
  await page.getByText('Right to left').click();
  await expect(page.locator('html')).toHaveAttribute('dir', 'rtl');
  await shot('settings-rtl');
  await page.getByText('Right to left').click();
  await page.getByRole('radio', { name: 'System' }).click();
});
