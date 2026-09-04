import { defineConfig } from 'vitest/config';
import ReactPlugin from '@vitejs/plugin-react';
import { playwright } from '@vitest/browser-playwright';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

const rootDir = dirname(fileURLToPath(import.meta.url));

const SUPPORTED_BROWSERS = ['chromium', 'firefox', 'webkit'] as const;

type SupportedBrowser = (typeof SUPPORTED_BROWSERS)[number];

// Locally we only run Chromium so a plain `npm test` needs a single browser
// installed. CI fans out across all three via the `VITEST_BROWSER` env var,
// which also accepts a comma-separated list.
function resolveBrowsers(): SupportedBrowser[] {
  const requested = process.env.VITEST_BROWSER;

  if (!requested) {
    return ['chromium'];
  }

  const names = requested
    .split(',')
    .map((name) => name.trim())
    .filter(Boolean);
  const unsupported = names.filter(
    (name) => !SUPPORTED_BROWSERS.includes(name as SupportedBrowser)
  );

  if (unsupported.length > 0) {
    throw new Error(
      `Unsupported VITEST_BROWSER value(s): ${unsupported.join(', ')}. ` +
        `Supported browsers are: ${SUPPORTED_BROWSERS.join(', ')}.`
    );
  }

  return names as SupportedBrowser[];
}

export default defineConfig({
  plugins: [ReactPlugin()],
  resolve: {
    alias: {
      // Tests import from 'plass-ui' exactly as a consumer would.
      'plass-ui': resolve(rootDir, 'src/index.ts')
    }
  },
  test: {
    include: ['test/**/*.test.{ts,tsx}'],
    setupFiles: ['test/support/setup.ts'],
    // One file at a time. Test files run as frames of one browser, and a
    // browser has a single focus to hand out: a click in one file takes it from
    // whichever file was holding it. Focus is half of what these components do,
    // and the failures that produces only ever appear in a full run.
    fileParallelism: false,
    // Components are built on Base UI, which relies on real browser APIs
    // (ResizeObserver, popover, dialog). Run them in a real browser rather
    // than polyfilling a DOM emulator.
    browser: {
      enabled: true,
      provider: playwright(),
      headless: true,
      screenshotFailures: false,
      instances: resolveBrowsers().map((browser) => ({ browser })),
      // Playwright's media emulation, handed to the suite. The library answers
      // `prefers-reduced-motion` and `prefers-color-scheme` in JavaScript as
      // well as in CSS, and neither can be asserted from inside the page: they
      // are the browser's answer, not the document's. Declared for TypeScript
      // in `test/env.d.ts`.
      commands: {
        async emulateMedia({ page }, options) {
          await page.emulateMedia(options);
        }
      }
    }
  }
});
