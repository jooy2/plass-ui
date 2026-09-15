/**
 * Puts the React package's `CHANGELOG.md` on the docs site.
 *
 * Each package keeps its changelog beside its manifest, where npm, pub.dev and
 * a reader browsing that package all expect to find it. Keeping a second copy
 * under `docs/` would be two files that say the same thing until the day one of
 * them does not, so the docs' copy is generated instead — written before
 * VitePress starts and ignored by git.
 *
 * The only thing added is the frontmatter: the sidebar reads `title` for the
 * label and `order` for where it sits, and the source file cannot carry either
 * without npm and GitHub rendering it as a stray table at the top.
 *
 * `description` is there for the same reason. A page that declares none falls
 * back to `summaryOf` in `.vitepress/config.ts`, which takes the first block of
 * prose — and every block a changelog is made of is a heading, a quote or a
 * list item, so the fallback used to reach an entry from the middle of the list
 * and put it in the page's `<meta name="description">` and its `og:description`.
 */
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const docsDir = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = resolve(docsDir, '..');

/** One entry per locale served by the docs. Keep in step with `supportLocales`. */
const pages = {
  en: {
    title: 'Changelog',
    description:
      'Every release of the plass-ui React package, newest first, with the breaking changes and the fixes each one carried. The Flutter package keeps its own history.'
  },
  ko: {
    title: '변경 기록',
    description:
      'plass-ui React 패키지의 릴리스를 최신 순으로 모았습니다. 버전마다 breaking change와 수정 내용을 적었고, Flutter 패키지는 자체 기록을 따로 둡니다.'
  }
};

const changelog = readFileSync(resolve(repoRoot, 'packages/react/CHANGELOG.md'), 'utf8');

for (const [locale, { title, description }] of Object.entries(pages)) {
  const target = resolve(docsDir, locale, 'changelog.md');
  mkdirSync(dirname(target), { recursive: true });
  writeFileSync(
    target,
    `---\ntitle: ${title}\ndescription: ${description}\norder: 1\neditLink: false\n---\n\n${changelog}`,
    'utf8'
  );
}
