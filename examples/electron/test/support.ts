import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { _electron as electron, type ElectronApplication, type Page } from '@playwright/test';

export interface Session {
  app: ElectronApplication;
  page: Page;
  /** Everything the page has complained about so far. */
  problems: string[];
}

/** Opens the built app with a profile of its own. */
export async function openApp(): Promise<Session> {
  const app = await electron.launch({
    args: ['.'],
    env: {
      ...process.env,
      PLASS_USER_DATA: mkdtempSync(join(tmpdir(), 'plass-showcase-'))
    } as Record<string, string>
  });
  const page = await app.firstWindow();
  const problems: string[] = [];

  page.on('pageerror', (error) => problems.push(`pageerror: ${error.message}`));
  page.on('console', (message) => {
    if (message.type() === 'error' || message.type() === 'warning') {
      problems.push(`${message.type()}: ${message.text()}`);
    }
  });

  return { app, page, problems };
}
