/**
 * Puts both packages' `CHANGELOG.md` on the docs site, as one page with the
 * framework switch on it.
 *
 * Each package keeps its changelog beside its manifest, where npm, pub.dev and
 * a reader browsing that package all expect to find it. Keeping a second copy
 * under `docs/` would be two files that say the same thing until the day one of
 * them does not, so the docs' copy is generated instead — written before
 * VitePress starts and ignored by git.
 *
 * The two histories go in `::: fw` blocks rather than on two pages, which is
 * what every other page in this site does with a difference between the
 * frameworks. It buys the same three things here: the switch is instant, both
 * halves are in the search index, and a reader who has chosen Flutter finds the
 * Flutter history under the same link somebody sent them. `theme/Layout.vue`
 * already drops an outline entry whose heading is inside a hidden block, so the
 * contents list on the right shows one package's versions rather than two
 * interleaved sets of them.
 *
 * **React's half is written first, and that is not a preference.** Anchors are
 * made unique by the order they are rendered in, so a second `### Fixed` takes
 * `#fixed-1`. Putting Flutter first would renumber every anchor in the React
 * history, and those are the links that have been handed out.
 *
 * The frontmatter is the only thing added: the sidebar reads `title` for the
 * label and `order` for where it sits, and a source file cannot carry either
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
    heading: 'Changelog',
    description:
      'Every release of both Plass packages, newest first, with the breaking changes and the fixes each one carried. The React and the Flutter package version independently.',
    lede: 'The two packages version independently, so a release on one side is not a release on the other and the numbers will not always agree. Pick a framework in the sidebar to read its history.'
  },
  ko: {
    title: '변경 기록',
    heading: '변경 기록',
    description:
      'Plass 두 패키지의 릴리스를 최신 순으로 모았습니다. 버전마다 breaking change와 수정 내용을 적었고, React와 Flutter 패키지는 서로 다른 번호를 씁니다.',
    lede: '두 패키지는 각자 버전을 올립니다. 한쪽의 릴리스가 다른 쪽의 릴리스는 아니어서 번호가 늘 맞지는 않습니다. 사이드바에서 프레임워크를 고르면 그쪽 기록이 보입니다.'
  }
};

/**
 * A package's history, ready to drop into a block.
 *
 * The `# Changelog` heading goes, because the page has one of its own and two
 * would be two pages in one. So does the line under it that points at the other
 * package, which is what a reader on GitHub needs and what the switch on this
 * page already answers.
 */
function historyOf(path) {
  const lines = readFileSync(resolve(repoRoot, path), 'utf8').split('\n');
  let at = 0;

  while (at < lines.length && !lines[at].startsWith('## ')) {
    at += 1;
  }

  return lines.slice(at).join('\n').trim();
}

const histories = [
  ['react', historyOf('packages/react/CHANGELOG.md')],
  ['flutter', historyOf('packages/flutter/CHANGELOG.md')]
];

for (const [locale, { title, heading, description, lede }] of Object.entries(pages)) {
  const target = resolve(docsDir, locale, 'changelog.md');
  const blocks = histories
    .map(([framework, history]) => `::: fw ${framework}\n\n${history}\n\n:::`)
    .join('\n\n');

  mkdirSync(dirname(target), { recursive: true });
  writeFileSync(
    target,
    `---\ntitle: ${title}\ndescription: ${description}\norder: 1\neditLink: false\n---\n\n` +
      `# ${heading}\n\n${lede}\n\n${blocks}\n`,
    'utf8'
  );
}
