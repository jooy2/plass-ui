# TODO

What is left of the gap between this library and the `neba` component library
it was compared against, written so that the next session can pick it up
without the previous one's context. Paths under `neba/` below refer to that
checkout.

## The gap is closed

**2026-09-05.** Every component the comparison found missing is on `main`.
Eleven commits, one per component, in this order:

| Commit    | Component                                      |
| --------- | ---------------------------------------------- |
| `2dfd988` | `PlTreeSelect`                                 |
| `aeabee5` | `fix:` a read-only `PlSelect` opened its popup |
| `48b9149` | `PlCodeBlock`                                  |
| `723941f` | `PlGallery`                                    |
| `b3cc940` | `PlLineChart`, and the whole chart foundation  |
| `97c547d` | `PlAreaChart`                                  |
| `2233e32` | `PlBarChart`                                   |
| `559226c` | `PlPieChart`                                   |
| `4afe246` | `PlScatterChart`                               |
| `b87a17b` | `PlSparkline`                                  |
| `95eb375` | `PlGaugeChart`                                 |
| `db6fb4b` | `PlHeatmapChart`                               |
| `a696481` | `PlTimelineChart`                              |
| `ddb08b7` | `PlMockup`                                     |
| `53ea57d` | `PlWindowPane`                                 |

The library is **a hundred and twenty-seven components** in both packages.

### The decisions that were open, and what they became

- **The charts are SVG on React and `CustomPainter` on Flutter**, with the pure
  arithmetic shared function-for-function between `internal/chart.ts` and
  `internal/chart.dart` so the two builds cannot disagree about a tick.
- **The chart palette is its own ladder**, `--plass-chart-1…8` plus five-step
  sequential and diverging ramps, because a series is not a meaning and
  `danger` is not a colour a fourth series can have. The eight hues were
  measured against this library's own grounds rather than inherited: ≥4.0:1 on
  white, ≥4.9:1 on `#141b30`, and a minimum neighbour ΔE of 10.4 under
  deuteranopia.
- **A chart is never only a picture.** Every one carries its name, a text
  summary of what it says, and — on React — the same numbers as a table under
  it, clipped from view but never hidden from the accessibility tree.
- **`PlCodeBlock` takes `highlight.js`** as a second React runtime dependency,
  reached only through per-language dynamic imports. Flutter has no highlighter
  and takes pre-tokenised `lines`.

### Four bugs the batch found in already-shipped code

Worth knowing about, because none of them failed a build:

1. **Three frame tokens were never declared.** An unresolvable `var()` on a
   `stroke` computes to `none`, so `PlLineChart` and `PlAreaChart` shipped with
   no gridlines, no axis rule and no baseline at all.
2. **Nine more slot names came from the library the frame was ported from.**
   The chart tooltip had no glass, no shadow and a `currentColor` border; a
   switched-off legend entry was the same ink as the rest; a line chart's
   markers had no ring cut out of them.
3. **A read-only `PlSelect` opened its popup again** under Base UI 1.8.
4. **`CartesianChart` ignored the `size` and `locale` a provider set.**

**Two tests were added so the token class cannot happen again**:
`test/package/tokens.test.ts` now asserts that every `--plass-*` a source file
reads is declared in `styles.css`, and `test/styles/standalone.test.tsx` — the
one file in the suite that loads real CSS — renders a chart and asserts that
nothing it paints computes to `none`. Neither asserts a shade.

## What is worth doing next

Nothing on this list is a gap against `neba`. They are the loose ends the batch
left.

- **`PlPanes` still has its own copy of the drag scaffold.** `internal/drag.ts`
  arrived with `PlWindowPane` and is the shared version — three listeners, a
  `data-dragging`, the document's text selection, a teardown an unmount can
  call. Folding `PlPanes` into it is a small change with its own tests already
  in place, and it was deliberately left out of the window's commit.
- **The Flutter `PlWindowPane` has no `resizable`.** Eight drag handles are a
  pointer affordance a Flutter caller would more naturally build around the
  window; if that turns out to be wrong, the React handles are the reference.
- **`examples/`** — the fifth sidebar group `neba` has and this does not. There
  are now enough components for a whole fictional screen to say something.

## The per-component workflow

Every component in this batch went through the same list, and a component that
skips a step shows up as a broken docs build or a stale number. In order:

1. `packages/react/src/components/<kebab>/PlX.tsx` and its `index.ts`.
2. Export it from `packages/react/src/index.ts`.
3. Anything shared goes in `packages/react/src/internal/` rather than being
   written twice — the pure arithmetic especially, because the Dart build needs
   the same answers.
4. `packages/react/src/styles.css` if it needs a token, a keyframe or a chained
   rule. **A new `--plass-*` also goes in `PlassToken` in `src/types.ts`**, or
   `test/package/tokens.test.ts` fails.
5. `packages/react/test/components/<kebab>/PlX.test.tsx`, plus
   `test/internal/<name>.test.ts` for anything pure.
6. The Flutter widget under `packages/flutter/lib/src/components/<snake>/`, its
   export in `lib/plass_ui.dart`, and its test.
7. Flutter demos under `packages/flutter/example/lib/demos/<snake>/`, each one
   registered in `example/lib/demos/registry.dart` (import, map entry **and**
   builder function — three places).
8. React demos under `docs/.vitepress/demos/<kebab>/`, one file per example.
9. `docs/en/components/<group>/<kebab>.md` and the `docs/ko/` twin. The `order:`
   in the frontmatter is the next free number in that group — check it, because
   a clash is silent.
10. Props tables in `docs/.vitepress/data/props.ts`, then
    `docs/.vitepress/data/props-flutter.ts` — the Flutter table is **derived**
    from the React one with `from()`, which throws if the React row is missing.
11. A card in `docs/.vitepress/demos/component-index/all.tsx`.
12. An entry in `docs/public/llms.txt`, in the right group.
13. The component count, which appears in **six** places: `README.md` (twice),
    `docs/public/llms.txt`, `docs/en/index.md`, `docs/ko/index.md`,
    `docs/en/guide/getting-started.md`, `docs/ko/guide/getting-started.md`. It
    is spelled in words (`a hundred and twenty-seven` / `백스물일곱 개`). The
    component's name also joins its group's list in `README.md`.
14. Both changelogs, under `## Unreleased` → `### Added`.
15. `cd packages/react && npm run build && npm run size -- --update`.
16. Verify everything (below), then one commit per component, authored by
    `leejooy96 <leejooy96@gmail.com>` with **no co-author trailer**.

## Verifying

```bash
cd packages/react && npm run lint && npm run typecheck && npx prettier --check src test
cd packages/flutter && dart format --line-length 100 lib test example/lib && flutter analyze && flutter test
cd packages/flutter/example && flutter analyze lib
cd docs && npx prettier --write "**/*.{ts,tsx,md}" && npx vitepress build
```

Then look at it in a browser, or through the CSS-loading test harness described
below. Real bugs in this batch were invisible to every one of the commands
above and obvious the moment a stylesheet was in the room.

### Things that will waste an hour otherwise

- **The React suite no longer survives one run.** At a hundred and forty-odd
  files the browser page dies partway through, naming a different unrelated
  file each time ("Browser connection was closed"). `pkill -f vitest` does not
  fix it any more. **Run it in three slices** — this passes every time:

  ```bash
  npx vitest run test/components/a* test/components/b* test/components/c* test/components/d* test/components/e* test/components/f* test/components/g* test/components/h* test/components/i* test/components/l*
  npx vitest run test/components/m* test/components/n* test/components/o* test/components/p* test/components/r* test/components/s* test/components/t* test/components/v* test/components/w*
  npx vitest run test/hooks test/internal test/styles test/package test/theme
  ```

- **Nothing loads Tailwind into the ordinary test run**, so a control has no
  size and Playwright cannot click it. Assert classes, not layout. Two things
  follow from this that cost real time: a chart's tooltip is neither positioned
  nor `pointer-events-none` there, so it lands over whatever is under it and
  swallows the click; and `getBoundingClientRect` measures a box with no
  stylesheet behind it.
- **To check anything visual, load the stylesheet in a test.**
  `test/styles/standalone.test.tsx` shows the pattern: import
  `src/standalone.css?inline`, put it in a `<style>`, render, and read computed
  values. It is faster and more reliable than the browser preview, which
  hides its own pane and then never mounts a `<Demo>` because nothing
  intersects.
- **Vue interpolation in Markdown.** `{{` anywhere in a docs page or in a
  changelog (the changelog is copied into the site) breaks the VitePress build.
  Wrap it in `<code v-pre>`.
- **A stale Vite dep-optimizer cache** after adding a new `@base-ui/react`
  subpath shows up as `Cannot read properties of null (reading 'useState')`.
  `rm -rf packages/react/node_modules/.vite`.
- **`flutter analyze` runs `dart format` first, so format before you analyse.**
  A `python3` rewrite of a Dart file followed by a format will move the lines
  you were about to match on.
- **A Flutter `Semantics(container: true)` swallows its children's labels.** A
  container over a title, three buttons and a body is announced as one long
  name. `explicitChildNodes: true` is the fix, and it is what `aria-labelledby`
  does on the React side.

## The label set

`PlassLabels` is the library's own vocabulary, and it is **75 keys in React and
77 in Dart**. The two extra are `sortedAscending` and `sortedDescending`, which
exist only on the Flutter side: `aria-sort` carries the same meaning on the web
without a word, and Flutter's semantics have no sort direction, so the word has
to be said and therefore translated.

A new component that says a word of its own adds a key to
`packages/react/src/internal/labels.ts` **and** to
`packages/flutter/lib/src/internal/date.dart` (the class, its `copyWith`, and
the field declaration are three separate edits), then to all six packs in
`packages/react/src/locales/` and `packages/flutter/lib/src/locales/`, then to
`packages/flutter/test/package/labels_test.dart`'s `words()` list. The counts
above appear in the two `guide/locales.md` pages and in `llms.txt`; the numbers
in the two changelogs are historical and stay as they are.
