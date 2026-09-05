# TODO

What is left of the gap between this library and the `neba` component library it
was compared against, written so that the next session can pick it up without
the previous one's context. Paths under `neba/` below refer to that checkout.

## What has landed since

**2026-09-05.** Three commits, on top of everything below.

- **`PlTreeSelect`** — a `PlTree` behind the picker shell, in both packages.
  `selectableBranches` is off by default, and turning a branch press down is
  deliberately not the same as clearing.
- **`PlCodeBlock`** — in both packages. The decision that was open is made:
  **React takes `highlight.js` as a second runtime dependency**, reached only
  through a dynamic import, thirty-five grammars one chunk each; Flutter has no
  highlighter and takes pre-tokenised `lines` instead. `scripts/size.mjs` was
  changed to bundle with splitting on and count only the entry chunk, because
  inlining every grammar reported a cost no page has ever paid.
- **`fix:` a read-only `PlSelect` opened its popup again** — Base UI 1.8
  redefined `readOnly` on a select. Found by the suite while verifying the
  above; unrelated to either component.

## What was asked for and is now done

The requested batch was: `DataTable`, `DataList`, `Anchor`, `AppLogo`, `Meter`,
`Tour`, `FloatingActionButton`, `ToggleGroup`, `Flex`, `ScrollArea`, `Portal`,
`HoverCard`, `HowToSteps`, every transition, every hook, and the locale bundles
— for React, and for Flutter wherever a Flutter equivalent makes sense.

All of it is on `main`. Two notes worth carrying forward:

- **`PlToggleGroup` already existed** when the list was written, at
  `packages/react/src/components/toggle/PlToggleGroup.tsx` and
  `packages/flutter/lib/src/components/toggle/pl_toggle_group.dart`, fully
  documented. It was a false positive in the original gap list. What landed
  instead was `72e62b6`, a refactor sharing `groupJoinClasses` /
  `groupOverlapClasses` / `groupBaseClasses` out of `internal/button-group.ts`
  so that `PlButtonGroup` and `PlToggleGroup` draw one run of keys rather than
  two copies of it.
- **`PlFlex` and `PlPortal` are React-only** on purpose. Flutter's `Row`,
  `Column` and `Overlay` already are those two, and a widget wrapping them
  would be a second name for a framework primitive.

## What is still missing

Compared against `neba/src/components` on the day this was written. Line counts
are neba's, as a rough measure of the work rather than a target.

### The charts

Nine components that all sit on one foundation, which is why they are one item
rather than nine. Neba's is `src/internal/chart.ts` (1,650 lines),
`chart-frame.tsx` (1,912) and `chart-line.tsx` (342) — the scales, the ticks,
the axes, the grid, the legend, the tooltip and the shared frame every chart is
drawn inside.

| Component        | neba lines |
| ---------------- | ---------- |
| `line-chart`     | 120        |
| `area-chart`     | 141        |
| `sparkline`      | 257        |
| `scatter-chart`  | 359        |
| `bar-chart`      | 381        |
| `pie-chart`      | 430        |
| `timeline-chart` | 435        |
| `gauge-chart`    | 493        |
| `heatmap-chart`  | 637        |

**The foundation questions are answered.** Asked and decided on 2026-09-05:

- **SVG, and both packages get them.** React draws SVG; Flutter draws the same
  shapes from the same numbers with `CustomPainter`. SVG keeps the marks in the
  accessibility tree and in the DOM where a test can read them, and it is the
  only one of the two a Flutter build can be a genuine sibling of. No new
  dependency on either side — `fl_chart` is not an option, because this package
  has none.
- **The pure arithmetic goes in `internal/chart.ts` and `internal/chart.dart`**
  so the two builds cannot disagree about a tick position.
- **Still open: where the colour comes from.** A chart with six series needs six
  colours that work together, and the six semantic families are named after
  meanings — `danger` is not a series. That is a token decision (a
  `--plass-chart-1…n` ladder, presumably, with a Dart twin) and it has to be
  made before the first chart, not after the third.
- **Still open: accessibility.** A chart that is only a picture is a chart half
  the readers cannot use. Neba's answer is worth reading before inventing one.

### The rest

- **`PlGallery`** (568) — a grid of images that opens into a lightbox.
- **`PlMockup`** (409) — a device frame (phone, browser, window) drawn round a
  screenshot or a live subtree.
- **`PlWindowPane`** (409) — a desktop window frame with real controls, in the
  three platform arrangements. Neba keeps the chrome in
  `src/internal/window.ts`; the same split would be right here.

### Not gaps

These looked missing when the names were compared and are not:

| neba             | here                              |
| ---------------- | --------------------------------- |
| `grid-container` | `PlGrid`                          |
| `grid`           | `PlGridItem`                      |
| `dialog`         | `PlModal`                         |
| `statistic`      | `PlStat`                          |
| `shortcut`       | `PlHotKeys` / `usePlHotKeys`      |
| `tree-view`      | `PlTree`                          |
| `toggle-group`   | `PlToggleGroup`, inside `toggle/` |
| `provider`       | `src/provider/`                   |
| `useShortcut`    | `usePlHotKeys`                    |

## The per-component workflow

Every component in this batch went through the same list, and a component that
skips a step shows up as a broken docs build or a stale number. In order:

1. `packages/react/src/components/<kebab>/PlX.tsx` and its `index.ts`.
2. Export it from `packages/react/src/index.ts`.
3. Anything shared goes in `packages/react/src/internal/` rather than being
   written twice — the pure arithmetic especially, because the Dart build needs
   the same answers.
4. `packages/react/src/styles.css` if it needs a keyframe or a chained rule.
5. `packages/react/test/components/<kebab>/PlX.test.tsx`, plus
   `test/internal/<name>.test.ts` for anything pure.
6. The Flutter widget under `packages/flutter/lib/src/components/<snake>/`, its
   export in `lib/plass_ui.dart`, and its test.
7. Flutter demos under `packages/flutter/example/lib/demos/<snake>/`, each one
   registered in `example/lib/demos/registry.dart` (import, map entry **and**
   builder function — three places).
8. React demos under `docs/.vitepress/demos/<kebab>/`, one file per example.
9. `docs/en/components/<group>/<kebab>.md` and the `docs/ko/` twin. The `order:`
   in the frontmatter is the next free number in that group.
10. Props tables in `docs/.vitepress/data/props.ts`, then
    `docs/.vitepress/data/props-flutter.ts` — the Flutter table is **derived**
    from the React one with `from()`, which throws if the React row is missing.
11. A card in `docs/.vitepress/demos/gallery/all.tsx`.
12. An entry in `docs/public/llms.txt`, in the right group.
13. The component count, which appears in **six** places: `README.md` (twice),
    `docs/public/llms.txt`, `docs/en/index.md`, `docs/ko/index.md`,
    `docs/en/guide/getting-started.md`, `docs/ko/guide/getting-started.md`. It
    is spelled in words (`a hundred and thirteen` / `백열세 개`).
14. Both changelogs, under `## Unreleased` → `### Added`.
15. `cd packages/react && npm run build && npm run size -- --update`, then put
    the measured delta in the React changelog.
16. Verify everything (below), then one commit per component with no co-author
    trailer.

## Verifying

```bash
cd packages/react && npm test && npm run lint && npm run typecheck && npx prettier --check src test
cd packages/flutter && dart format --line-length 100 lib test example/lib && flutter analyze && flutter test
cd docs && npm run build && npm run lint && npm run typecheck && npx prettier --check en ko .vitepress
```

Then look at it in a browser. Two real bugs in this batch were invisible to
every one of the commands above and obvious on the page: `PlTour`'s mask was
contained by the card it was written inside (`position: fixed` is relative to
the nearest ancestor with a `backdrop-filter`, and every glass surface here has
one), and `PlMeter` had been hand-rolled before anyone noticed Base UI ships a
`Meter` primitive.

### Things that will waste an hour otherwise

- **The React suite runs as frames of one browser page.** If a previous run was
  interrupted, its `vitest` and headless Chromium processes stay alive and the
  next full run dies partway through with "Browser connection was closed" in
  some file that has nothing to do with the change. `pkill -f vitest` first. A
  clean process table passes 136 files every time.
- **Nothing loads Tailwind into the test run.** Assert classes, not layout;
  `getBoundingClientRect` in a browser test measures a box with no stylesheet
  behind it. Inline styles are the exception and can be read.
- **Vue interpolation in Markdown.** `{{` anywhere in a docs page or in a
  changelog (the changelog is copied into the site) breaks the VitePress build.
  Wrap it in `<code v-pre>`.
- **A stale Vite dep-optimizer cache** after adding a new `@base-ui/react`
  subpath shows up as `Cannot read properties of null (reading 'useState')`.
  `rm -rf packages/react/node_modules/.vite`.
- **`flutter analyze` runs `dart format` first, so format before you analyse.**
  A `python3` rewrite of a Dart file followed by a format will move the lines
  you were about to match on.

## The label set

`PlassLabels` is the library's own vocabulary, and it is **64 keys in React and
66 in Dart**. The two extra are `sortedAscending` and `sortedDescending`, which
exist only on the Flutter side: `aria-sort` carries the same meaning on the web
without a word, and Flutter's semantics have no sort direction, so the word has
to be said and therefore translated.

A new component that says a word of its own adds a key to
`packages/react/src/internal/labels.ts` **and** to
`packages/flutter/lib/src/internal/date.dart` (the class, its `copyWith`, and
the field declaration are three separate edits), then to all seven packs in
`packages/react/src/locales/` and `packages/flutter/lib/src/locales/`, then to
`packages/flutter/test/package/labels_test.dart`'s `words()` list. The counts
above appear in the two `guide/locales.md` pages, `llms.txt` and both
changelogs.

A key is named after **a meaning, not a component**. `close` is the × on a
modal, a drawer, a popover and a toast, and it is translated once.
