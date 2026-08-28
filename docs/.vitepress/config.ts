import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { withSidebar } from 'vitepress-sidebar';
import container from 'markdown-it-container';
import packageJson from '../../packages/react/package.json' with { type: 'json' };
import {
  defineConfig,
  HeadConfig,
  MarkdownRenderer,
  SiteData,
  TransformContext,
  UserConfig
} from 'vitepress';
import { withI18n } from 'vitepress-i18n';
import ReactPlugin from '@vitejs/plugin-react';
import type { VitePressI18nOptions } from 'vitepress-i18n/types';
import type { VitePressSidebarOptions } from 'vitepress-sidebar/types';
import { FRAMEWORK_HEAD_SCRIPT, FRAMEWORK_IDS } from './data/frameworks';

const vitePressDir = dirname(fileURLToPath(import.meta.url));
const srcDir = resolve(vitePressDir, '..');
const rootDir = resolve(srcDir, '..');
/** The React package, which is what this site's live previews are built from. */
const reactDir = resolve(rootDir, 'packages/react');

const defaultLocale: string = 'en';
const supportLocales: string[] = [defaultLocale, 'ko'];
const editLinkPattern = `${packageJson.repository.url}/edit/main/docs/:path`;

const siteUrl = packageJson.homepage.replace(/\/+$/, '');
const repoUrl = packageJson.repository.url.replace(/\.git$/, '');
const npmUrl = `https://www.npmjs.com/package/${packageJson.name}`;

/**
 * The pub.dev page, read off the Flutter package's own manifest rather than
 * written out — the two package names differ (`plass-ui` against `plass_ui`),
 * and one of them being wrong in the footer is exactly the kind of thing nobody
 * notices. No YAML parser for one line.
 */
const pubUrl = `https://pub.dev/packages/${
  readFileSync(resolve(rootDir, 'packages/flutter/pubspec.yaml'), 'utf8').match(
    /^name:\s*(\S+)/m
  )?.[1] ?? 'plass_ui'
}`;

/**
 * Dart's own logo, for the pub.dev link in the navbar.
 *
 * A social link's icon is either a name VitePress ships or an SVG string, and
 * there is no name for pub.dev. `currentColor` on the path is what lets the
 * navbar hover it like the two icons beside it.
 */
const dartIcon =
  '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
  '<title>pub.dev</title>' +
  '<path fill="currentColor" d="M4.105 4.105S9.158 1.58 11.684.316a3.1 3.1 0 0 1 1.481-.315c.766.047 ' +
  '1.677.788 1.677.788L24 9.948v9.789h-4.263V24H9.789l-9-9C.303 14.5 0 13.795 0 13.105c0-.319.18-.818' +
  '.316-1.105zm.679.679v11.787c.002.543.021 1.024.498 1.508L10.204 23h8.533v-4.263zm12.055-.678c-.899' +
  '-.896-1.809-1.78-2.74-2.643c-.302-.267-.567-.468-1.07-.462c-.37.014-.87.195-.87.195L6.341 4.105z"/>' +
  '</svg>';

/** A glob Vite can read on either platform — `resolve` gives Windows backslashes. */
const glob = (pattern: string) => resolve(rootDir, pattern).replaceAll('\\', '/');

/**
 * Every `@base-ui/react` subpath the library imports, read out of `src/`.
 *
 * These are reached only from a demo, which is reached only from a dynamic
 * import — so the dev server discovers them one at a time as previews mount,
 * and each discovery re-runs the dependency optimizer and reloads the page
 * underneath whoever is reading it. Listing them up front makes that one
 * pre-bundle at startup instead. Derived rather than written out, so a
 * component that starts using a new primitive is not a second edit here.
 */
function baseUiEntries(): string[] {
  const componentsDir = resolve(reactDir, 'src');
  const entries = new Set<string>();

  for (const file of readdirSync(componentsDir, { recursive: true, encoding: 'utf8' })) {
    if (!/\.tsx?$/.test(file)) {
      continue;
    }

    for (const [, entry] of readFileSync(resolve(componentsDir, file), 'utf8').matchAll(
      /from '(@base-ui\/react\/[a-z-]+)'/g
    )) {
      entries.add(entry);
    }
  }

  return [...entries].sort();
}

/**
 * What the components import at runtime, read off the React package's manifest.
 *
 * They are a sibling package, and Node resolution walks *up* from the importing
 * file — so `react` imported from `packages/react/src` never finds
 * `docs/node_modules`, and on a clean checkout it finds nothing at all. It only
 * works on a developer's machine because they have run `npm install` in
 * `packages/react` too, which is why this was invisible until CI ran it.
 *
 * `resolve.dedupe` is the fix and it is also the right one: it pins these to the
 * copy at this site's root, which is a single copy. Two Reacts in one bundle is
 * not a slower build, it is broken hooks.
 *
 * Derived rather than written out, so a component that takes a new dependency
 * is not a second edit here.
 */
function componentDependencies(): string[] {
  return [
    ...Object.keys(packageJson.dependencies ?? {}),
    ...Object.keys(packageJson.peerDependencies ?? {})
  ].filter((name) => !name.startsWith('@types/'));
}

/** `/` for whichever locale is the default, `/{lang}/` for every other one. */
const localeBase = (lang: string) => (lang === defaultLocale ? '/' : `/${lang}/`);

const commonSidebarConfig: VitePressSidebarOptions = {
  collapsed: false,
  capitalizeFirst: true,
  useTitleFromFileHeading: true,
  useTitleFromFrontmatter: true,
  useFolderTitleFromIndexFile: true,
  // Without this the components group stops linking to the index page that
  // lists them all.
  useFolderLinkFromIndexFile: true,
  frontmatterOrderDefaultValue: 9,
  sortMenusByFrontmatterOrder: true
};

/**
 * The sidebar groups the folder tree cannot name.
 *
 * `design/` has no `index.md` and the changelog is a loose page, so neither can
 * take its heading from a page the way every other group does. Left to the
 * generator, `design/` would be capitalised to "Design" over Korean pages and
 * the changelog would sit at the root with no heading over it at all.
 */
const groupLabels: Record<string, { overview: string; design: string; more: string }> = {
  en: { overview: 'All components', design: 'Design', more: 'Discover more' },
  ko: { overview: '모든 컴포넌트', design: '디자인', more: '더 알아보기' }
};

const vitePressSidebarConfig = [
  ...supportLocales.map((lang) => {
    return {
      ...commonSidebarConfig,
      // Relative to the working directory, which is this `docs/` folder —
      // `vitepress-sidebar` joins it onto `process.cwd()`.
      documentRootPath: `/${lang}`,
      resolvePath: localeBase(lang),
      ...(defaultLocale === lang ? {} : { basePath: localeBase(lang) })
    };
  })
];

/** The same two destinations in every locale, prefixed with its base. */
const navFor = (lang: string, labels: [string, string]) => [
  { text: labels[0], link: `${localeBase(lang)}guide/getting-started` },
  { text: labels[1], link: `${localeBase(lang)}components/` }
];

const vitePressI18nConfig: VitePressI18nOptions = {
  locales: supportLocales,
  rootLocale: defaultLocale,
  searchProvider: 'local',
  description: {
    ko: '유리와 그러데이션으로 만든 UI 컴포넌트 라이브러리입니다. 매끄러운 색 유리 표면, 자기 색으로 드리우는 그림자, 그리고 포인터를 따라오는 빛. React와 Flutter로 제공되며, 접근성과 테마를 갖췄고 다크 모드가 기본으로 지원됩니다.',
    en: 'A UI component library made of glass and gradients — smooth tinted surfaces, shadows in their own colour, and light that follows the pointer. Ships for React and for Flutter, accessible and themeable, dark mode built in.'
  },
  themeConfig: {
    ko: { nav: navFor('ko', ['가이드', '컴포넌트']) },
    en: { nav: navFor('en', ['Guide', 'Components']) }
  }
};

/* ---------------------------------------------------------------------------
 * Search engines
 *
 * Two things a documentation site gets wrong by default, and both of them are
 * per page rather than per site:
 *
 * - **Every page ships the same description.** VitePress falls back to the
 *   site's own whenever a page declares none, so every page carries one
 *   sentence between them and not one of them says what it is about. There is
 *   already a better sentence on nearly every page — the lede under the title,
 *   which is written to be exactly this — so it is read out of the source.
 * - **Nothing says the two locales are the same page.** Without `hreflang` a
 *   crawler has no reason to connect `/components/inputs/button` to its Korean
 *   counterpart, and treats them as two documents competing for one query.
 * ------------------------------------------------------------------------- */

/**
 * The BCP-47 tag the site itself declares for a locale — `en` → `en-US`.
 *
 * Read back off the resolved config rather than written out again, because
 * VitePress's own sitemap already emits `hreflang` from exactly these values.
 */
function langTagOf(siteData: SiteData, lang: string): string {
  return siteData.locales[lang === defaultLocale ? 'root' : lang]?.lang ?? lang;
}

/** `en/components/inputs/button.md` → `/components/inputs/button`. */
function pathOf(filePath: string): string {
  const [lang, ...rest] = filePath.split('/');
  const page = rest
    .join('/')
    .replace(/(^|\/)index\.md$/, '$1')
    .replace(/\.md$/, '');

  return `${localeBase(lang)}${page}`;
}

/** Everything below the locale folder — the part two locales have in common. */
function pageOf(filePath: string): string {
  return filePath.split('/').slice(1).join('/');
}

/** Inline Markdown and HTML dropped: a `<meta>` carries text and nothing else. */
function plainText(source: string): string {
  return source
    .replace(/<[^>]+>/g, ' ')
    .replace(/!\[[^\]]*]\([^)]*\)/g, ' ')
    .replace(/\[([^\]]*)]\([^)]*\)/g, '$1')
    .replace(/[`*_]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

/** Cut at a word boundary, to about what a result page will show whole. */
function clamp(text: string, limit = 160): string {
  if (text.length <= limit) {
    return text;
  }

  const cut = text.slice(0, limit);

  return `${cut.slice(0, cut.lastIndexOf(' ')).trimEnd()}…`;
}

/**
 * A page's own one-line summary.
 *
 * The lede is what a component page opens with, and it already says what the
 * component is and what it is for in one or two sentences. The pages that have
 * none — the guide, the design notes — open with the same thing written as
 * prose, so their first paragraph stands in.
 */
function summaryOf(filePath: string): string | undefined {
  const file = resolve(srcDir, filePath);

  if (!existsSync(file)) {
    return undefined;
  }

  const source = readFileSync(file, 'utf8');
  const lede = source.match(/<p class="plass-lede">([\s\S]*?)<\/p>/);

  if (lede) {
    return clamp(plainText(lede[1]));
  }

  // Frontmatter off, then the first block that is prose: not the title, not a
  // fenced example, not one of the Vue components a page is built out of.
  for (const block of source.replace(/^---\r?\n[\s\S]*?\r?\n---/, '').split(/\n\s*\n/)) {
    const trimmed = block.trim();

    if (!trimmed || /^[#<`:|>-]/.test(trimmed)) {
      continue;
    }

    const text = plainText(trimmed);

    if (text) {
      return clamp(text);
    }
  }

  return undefined;
}

/** The locales that actually have this page — a mirror is not a guarantee. */
function localesWith(filePath: string): string[] {
  const page = pageOf(filePath);

  return supportLocales.filter((lang) => existsSync(resolve(srcDir, lang, page)));
}

/** What the package is, for the one page in each locale that is about it. */
function structuredData(description: string, url: string) {
  return {
    '@context': 'https://schema.org',
    '@type': 'SoftwareSourceCode',
    name: 'Plass',
    description,
    url,
    codeRepository: repoUrl,
    programmingLanguage: ['TypeScript', 'Dart'],
    runtimePlatform: ['React', 'Flutter'],
    license: 'https://opensource.org/licenses/MIT',
    author: { '@type': 'Organization', name: 'CDGet', url: 'https://cdget.com' },
    sameAs: [repoUrl, npmUrl, pubUrl]
  };
}

/**
 * The half of the metadata that is different on every page.
 *
 * Only runs at build time — `transformPageData` is what the dev server sees —
 * so the tags below are checked by reading a built page, not the preview.
 */
function transformHead({ pageData, siteData, title, description }: TransformContext): HeadConfig[] {
  const { filePath } = pageData;

  // A dynamic route, or the built-in 404: no source file, so no canonical URL
  // and nothing to point an alternate at.
  if (!filePath) {
    return [];
  }

  const lang = filePath.split('/')[0];
  const url = `${siteUrl}${pathOf(filePath)}`;
  const translations = localesWith(filePath);

  // Open Graph writes a BCP-47 tag with an underscore in it, and nothing else.
  const ogLocale = (of: string) => langTagOf(siteData, of).replace('-', '_');

  const head: HeadConfig[] = [
    ['link', { rel: 'canonical', href: url }],
    ['meta', { property: 'og:url', content: url }],
    ['meta', { property: 'og:title', content: title }],
    ['meta', { property: 'og:description', content: description }],
    ['meta', { property: 'og:locale', content: ogLocale(lang) }],
    ['meta', { name: 'twitter:title', content: title }],
    ['meta', { name: 'twitter:description', content: description }]
  ];

  for (const other of translations) {
    head.push([
      'link',
      {
        rel: 'alternate',
        hreflang: langTagOf(siteData, other),
        href: `${siteUrl}${pathOf(`${other}/${pageOf(filePath)}`)}`
      }
    ]);

    if (other !== lang) {
      head.push(['meta', { property: 'og:locale:alternate', content: ogLocale(other) }]);
    }
  }

  // Which one a crawler should serve to a reader it cannot place. The default
  // locale is the one that is served from `/`.
  if (translations.includes(defaultLocale)) {
    head.push([
      'link',
      {
        rel: 'alternate',
        hreflang: 'x-default',
        href: `${siteUrl}${pathOf(`${defaultLocale}/${pageOf(filePath)}`)}`
      }
    ]);
  }

  if (pageData.frontmatter.layout === 'home') {
    head.push([
      'script',
      { type: 'application/ld+json' },
      JSON.stringify(structuredData(description, url))
    ]);
  }

  return head;
}

// Ref: https://vitepress.dev/reference/site-config
const vitePressConfig: UserConfig = {
  title: 'Plass UI',
  lastUpdated: true,
  outDir: '../docs-dist',
  cleanUrls: true,
  metaChunk: true,
  /**
   * The default locale is served from `/`, not from `/{lang}/`.
   *
   * This has to agree with two other things or every sidebar link 404s:
   * `vitepress-i18n` puts the root locale in `locales.root` (no path prefix),
   * and `vitepress-sidebar` is told to resolve its links against `/`. The
   * rewrite is what actually moves `docs/{defaultLocale}/**` there. Every other
   * locale keeps its folder as its prefix. Switching `defaultLocale` swings all
   * three together.
   */
  rewrites: {
    [`${defaultLocale}/:rest*`]: ':rest*'
  },
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/logo.svg' }],
    // `--plass-primary-solid`, as a literal: a `<meta>` cannot read a custom
    // property, and this is the one place in the site that has to repeat one.
    ['meta', { name: 'theme-color', content: '#3558ef' }],
    // The half of the metadata that is the same on every page. The other half —
    // the canonical URL, the title, the description, the locale alternates — is
    // per page and lives in `transformHead`.
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'Plass UI' }],
    ['meta', { name: 'twitter:card', content: 'summary' }],
    // Which framework's half of every page is displayed, applied to `<html>`
    // before the first paint. See `data/frameworks.ts`.
    ['script', {}, FRAMEWORK_HEAD_SCRIPT]
  ],
  sitemap: {
    hostname: packageJson.homepage
  },
  /**
   * `robots.txt`, written rather than committed.
   *
   * It exists to name the sitemap, and the sitemap's own URL is already derived
   * from `package.json`. A copy of that host sitting in `public/` would be one
   * more place to forget when the site moves.
   */
  async buildEnd({ outDir }) {
    await writeFile(
      resolve(outDir, 'robots.txt'),
      `User-agent: *\nAllow: /\n\nSitemap: ${siteUrl}/sitemap.xml\n`
    );
  },
  /**
   * A description that is about this page rather than about the library.
   *
   * Runs in the dev server as well as in the build, which is what makes it the
   * right place for the description — `transformHead` would have to repeat the
   * fallback chain VitePress already applies to `pageData.description`.
   */
  transformPageData(pageData) {
    if (!pageData.description && pageData.filePath) {
      pageData.description = summaryOf(pageData.filePath) ?? '';
    }
  },
  transformHead,
  /**
   * `::: fw react` … `:::` — the block that only one framework sees.
   *
   * Both frameworks' blocks are in the document and CSS displays one of them,
   * which is what makes the switch instant and what keeps the two halves from
   * being two pages that drift apart. It also means the search index carries
   * both, so a reader looking up `onPressed` finds the button page whichever
   * framework they had selected.
   */
  markdown: {
    config(md: MarkdownRenderer) {
      md.use(container, 'fw', {
        validate: (params: string) => /^fw(\s+\S+)+$/.test(params.trim()),
        render(tokens: { nesting: number; info: string }[], index: number) {
          const token = tokens[index];

          if (token.nesting !== 1) {
            return '</div>\n';
          }

          // `::: fw flutter`, and `::: fw react flutter` for a block both of
          // them want but nobody else does.
          const wanted = token.info
            .trim()
            .split(/\s+/)
            .slice(1)
            .filter((id) => FRAMEWORK_IDS.includes(id));

          return `<div class="plass-fw" data-fw="${wanted.join(' ')}">\n`;
        }
      });
    }
  },
  /**
   * The docs render the real components, and the components are React. Every
   * live preview is a React island mounted by `theme/components/Demo.vue`, so
   * the site's Vite pipeline needs three things Vue alone does not give it: the
   * React plugin for the `.tsx` demos, an alias so those demos can `import
   * { PlButton } from 'plass-ui'` exactly as a consumer would, and the repository's
   * PostCSS config so Tailwind compiles the classes the library ships.
   */
  vite: {
    // Cast because VitePress 1.x ships its own copy of Vite: its `Plugin` type
    // is a different instance of the same shape from the one the React plugin
    // is built against, so the two are structurally identical and nominally
    // incompatible. Drops when VitePress and the repo share one Vite.
    plugins: [ReactPlugin() as never],
    resolve: {
      dedupe: componentDependencies(),
      alias: [
        // Anchored, so `plass-ui/styles.css` is not rewritten into the barrel too.
        // Pointing at the source rather than `dist/` is what lets a component
        // edit show up in the docs without a rebuild.
        { find: /^plass-ui$/, replacement: resolve(reactDir, 'src/index.ts') }
      ]
    },
    optimizeDeps: {
      // Every one of these is only ever reached through a dynamic import inside
      // a demo, so Vite would otherwise discover them mid-session and force a
      // reload. `react/jsx-dev-runtime` is what the demos' JSX compiles to.
      include: [
        'react',
        'react-dom/client',
        'react/jsx-runtime',
        'react/jsx-dev-runtime',
        ...baseUiEntries()
      ]
    },
    server: {
      fs: {
        /*
         * The components live in a sibling package.
         *
         * Vite's file-system allow-list defaults to the nearest workspace root,
         * which since `docs/` gained a `package.json` and a lockfile of its own
         * is this folder — so every import of `packages/react/src/**` is
         * refused before it is read. Opening the repository root is the same
         * access the previous single-package layout had.
         */
        allow: [rootDir]
      },
      warmup: {
        // The library is behind a dynamic import too, so the dev server would
        // not transform a single file of it until the first preview asks.
        clientFiles: [glob('packages/react/src/**/*.{ts,tsx}')]
      }
    }
  },
  themeConfig: {
    logo: { src: '/logo.svg', width: 24, height: 24 },
    /**
     * `h2` and `h3`, nested.
     *
     * A component page is one `h2` — Examples — with a dozen `h3`s under it,
     * one per prop. At the default depth the outline lists four words for a
     * page that is twenty screens long, and the thing a reader came for, the
     * prop they are looking up, is never in it.
     */
    outline: { level: [2, 3] },
    editLink: {
      pattern: editLinkPattern
    },
    /*
     * One per place the library is published, plus the source.
     *
     * VitePress knows npm and GitHub by name and has never heard of pub.dev, so
     * that one arrives as a drawing. The drawing is Dart's, not Flutter's, and
     * the difference is the point: the link goes to a package on a *Dart*
     * registry, and the Flutter mark is already spoken for by the sidebar's
     * switch, where it means "the Flutter half of this page" rather than "the
     * package".
     */
    socialLinks: [
      { icon: 'npm', link: npmUrl },
      { icon: { svg: dartIcon }, link: pubUrl, ariaLabel: 'pub.dev' },
      { icon: 'github', link: repoUrl }
    ],
    footer: {
      message: 'Released under the MIT License',
      copyright: '© <a href="https://cdget.com">CDGet</a>'
    }
  }
};

/* ---------------------------------------------------------------------------
 * Sidebar post-processing
 *
 * `vitepress-sidebar` derives the menu from the folder tree, which gets three
 * things wrong for this site — and none of the three can be fixed by moving
 * files around without also changing a URL. So the generated tree is reshaped
 * here instead, once, for every locale.
 * ------------------------------------------------------------------------- */

interface GeneratedSidebarItem {
  text?: string;
  link?: string;
  items?: GeneratedSidebarItem[];
  collapsed?: boolean;
}

/**
 * `useFolderLinkFromIndexFile` points a folder at `components/index.md`, which
 * VitePress resolves to `/components/index` — a URL that only works because the
 * SPA router is forgiving about it. The canonical one, and the only one a
 * static host serves directly, is `/components/`.
 *
 * `collapsed` goes at the same time: VitePress draws the expand/collapse caret
 * for any item where `collapsed != null`, so the only way to have permanently
 * open groups with no toggle is for the key to be absent entirely.
 */
function cleanUpItems<T extends GeneratedSidebarItem>(items: T[]): T[] {
  return items.map((item) => {
    const cleaned = {
      ...item,
      ...(item.link ? { link: item.link.replace(/(^|\/)index\.md$/, '$1') } : {}),
      ...(item.items ? { items: cleanUpItems(item.items) } : {})
    };

    delete cleaned.collapsed;

    return cleaned;
  });
}

/** The first link anywhere in a subtree — how a group is identified below. */
function firstLink(item: GeneratedSidebarItem): string | undefined {
  return item.link ?? item.items?.map(firstLink).find(Boolean);
}

const startsWith = (prefix: string) => (item: GeneratedSidebarItem) =>
  firstLink(item)?.startsWith(prefix) ?? false;

/** Every page in a subtree, with the folder headings above them dropped. */
function flattenItems<T extends GeneratedSidebarItem>(items: T[]): T[] {
  return items.flatMap((item) => (item.items?.length ? flattenItems(item.items as T[]) : [item]));
}

/** By label, so a flat list of components can be scanned for a name. */
function byText(a: GeneratedSidebarItem, b: GeneratedSidebarItem): number {
  return (a.text ?? '').localeCompare(b.text ?? '');
}

/**
 * Guide, Components, Design, Discover more — with the component groups kept as
 * headings inside Components.
 *
 * Most of that cannot be stated by the folder tree, which is what this function
 * is for:
 *
 * - **The index page is an entry rather than the heading's link.** Left to the
 *   generator, `/components/` is only reachable by clicking the word
 *   "Components" above the menu, which does not look like a link and is easy to
 *   miss. It becomes a row of its own and the heading above it stops being
 *   clickable.
 * - **The component groups stay.** They are what say that a PlTextField is an
 *   input and a Card is a surface. What is flattened is only what is *inside* a
 *   group, so a folder that gains a subfolder does not push its pages a level
 *   deeper.
 * - **Design and Discover more** are named here rather than by an `index.md`,
 *   for the reason `groupLabels` explains.
 *
 * Inside a group the pages are sorted by name rather than by their `order`
 * frontmatter, because nobody remembers where a component sits in a curated
 * order. `order` still decides inside Design.
 */
function arrangeSidebar<T extends GeneratedSidebarItem>(items: T[], lang: string): T[] {
  const labels = groupLabels[lang] ?? groupLabels[defaultLocale];

  const guide = items.find(startsWith('guide/'));
  const components = items.find(startsWith('components/'));
  const design = items.find(startsWith('design/'));
  const changelog = items.find(startsWith('changelog'));

  if (components) {
    // A child with children of its own is a group folder; a child with only a
    // link is a page sitting loose in `components/`, which stays where it is.
    const children = components.items ?? [];
    const groups = children.filter((item) => item.items?.length) as T[];
    const loose = children.filter((item) => !item.items?.length) as T[];

    for (const group of groups) {
      group.items = flattenItems(group.items ?? []).sort(byText);
    }
    groups.sort(byText);

    const overview = components.link
      ? ({ text: labels.overview, link: components.link } as unknown as T)
      : undefined;
    delete components.link;

    components.items = [...([overview].filter(Boolean) as T[]), ...loose, ...groups];
  }

  if (design) {
    design.text = labels.design;
  }

  // A loose page has no group of its own, so it is given one — the place
  // anything that is neither a guide nor a component ends up.
  const more = changelog ? ({ text: labels.more, items: [changelog] } as unknown as T) : undefined;

  const moved = new Set([guide, components, design, changelog].filter(Boolean));

  return [
    ...([guide, components, design, more].filter(Boolean) as T[]),
    ...items.filter((item) => !moved.has(item))
  ];
}

const config = withSidebar(withI18n(vitePressConfig, vitePressI18nConfig), vitePressSidebarConfig);

const sidebar = config.themeConfig?.sidebar as
  Record<string, { items?: GeneratedSidebarItem[] } | GeneratedSidebarItem[]> | undefined;

if (sidebar) {
  for (const [path, group] of Object.entries(sidebar)) {
    // `/` is the default locale and `/{lang}/` is every other one — the same
    // mapping `localeBase` makes, read back the other way.
    const lang = path === '/' ? defaultLocale : path.replaceAll('/', '');

    if (Array.isArray(group)) {
      sidebar[path] = arrangeSidebar(cleanUpItems(group), lang);
    } else if (group?.items) {
      group.items = arrangeSidebar(cleanUpItems(group.items), lang);
    }
  }
}

export default defineConfig(config);
