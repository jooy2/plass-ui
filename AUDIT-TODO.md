# Audit TODO

The findings of a full audit of both packages, the documentation site and the repository, taken at `148a20e4` on 2026-09-13, and how far fixing them has got. The work goes in batches of twenty. When every item below is ticked, delete this file in a commit of its own.

**118 of 345 items are ticked.** Line numbers in the items are from `148a20e4` and drift as the code changes; when one no longer matches, search for the symbol.

## Working through a batch

When the Prompter asks to continue the audit, run a batch as written here, without asking how.

1. **Answers first.** Do what the Prompter approved under [Waiting for an answer](#waiting-for-an-answer) before the batch; that work does not count towards its twenty. Tick an item the Prompter declined and append `— declined`. Remove every answered question from that section.
1. **Pick twenty items.** Take open items by severity, High before Medium before Low, and by number within one severity. Skip an item flagged `Decision needed` or `Breaking change`, and an item that turns out to need a decision once the work starts, and take the next one instead.
1. **Confirm before fixing.** Check the finding against the code first, because the audit can be wrong or already out of date. An item that no longer reproduces is ticked with `— no longer reproduces` and gets no commit.
1. **One item, one commit.** For each item:
   - Fix every package the item names, following `CLAUDE.md` and the code around the change.
   - Add a test that fails without the fix, and prove it: revert the source (for example `git stash push <paths>`), run the test, and restore. When a test cannot show the difference, say so in the report.
   - Add a user-facing entry under `## vNext` in `packages/react/CHANGELOG.md`, `packages/flutter/CHANGELOG.md` or both, at the top of `Fixed`, `Changed` or `Breaking changes`. A change no user can notice gets no entry. The site copies the React changelog, so write `{{` there inside `<code v-pre>`.
   - Update the documentation pages, `docs/en` and `docs/ko` together, and the props tables when documented behaviour changes.
   - Commit with the tags in `CONTRIBUTING.md`: `[javascript]` or `[dart]` for one package and no prefix for both. No `Co-Authored-By` trailer.
1. **Stay inside the item.** A problem found in passing is not fixed; note it for the report. The exception is a problem the item's own change caused, such as a test exemption the change made unnecessary.
1. **Verify the batch** with the commands below, all of them.
1. **Update this file and push.** Tick the batch's items (`- [x]`), update the count at the top, and add every question from the report to [Waiting for an answer](#waiting-for-an-answer). Commit this file on its own and push.
1. **Report in Korean and stop.** Give a table of the items with their number, package and what changed, the verification results, the notes the Prompter needs, and one numbered list of every question: the flagged items the batch passed over, the ones listed under [Passed over and not yet asked](#passed-over-and-not-yet-asked), and anything found in passing.

Standing decisions that apply to every batch:

- React 18 stays in the peer range, but only React 19 is tested. Do not add a React 18 job or test run.
- Items 39, 180 and 258 are security findings. The repository is public, so their details are kept out of this file, in the local memory note `audit-security-items`. If that note is not available, ask the Prompter for the details rather than working from the title.

### Verifying a batch

```bash
cd packages/react && npm run lint && npm run typecheck && npx prettier --check src test CHANGELOG.md scripts && npm test && npm run build && npm run size
cd packages/flutter && dart format --line-length 100 lib test example/lib && flutter analyze && flutter test
cd packages/flutter/example && flutter analyze lib
cd docs && npm run typecheck && npm run lint && npx prettier --check . && npm run build
```

- `npm run size` allows 2% of drift per scenario. When a batch moves a number past that on purpose, run `npm run size -- --update` and commit the budget on its own.
- The full `flutter test` includes `test/package/rtl_test.dart`, which also fails on a physical-side exemption that is no longer used.
- `npm run build` in `docs` takes a few minutes and compiles the Flutter demos first. Run it last.

## Batches so far

| Batch | Commits              | Items                                                                                                     |
| ----- | -------------------- | --------------------------------------------------------------------------------------------------------- |
| 1     | `148a20e4..16d59107` | The High items: 1, 2, 4, 6, 18, 40, 43, 44, 68, 87, 121, 126, 144, 145, 154, 156, 188, 196, 202, 237      |
| 2     | `16d59107..c37ec085` | 3, 5, 7, 8, 9, 10 (part), 11, 13, 14, 15, 16, 17 (part), 22, 24, 142, 143, 152, 197, 268                  |
| 3     | `c37ec085..4885268c` | The rest of 10 and 17, 25, 26, 27, 28, 37, 38, 41, 42, 45, 46, 47, 48, 50, 51, 53, 54, 60, 64, 66, 69     |
| 4     | `4885268c..c99f09c1` | 72, 75, 76, 85, 86, 88, 90, 91, 92, 94, 95, 98, 101, 103, 113, 114, 116, 122, 123, 127                    |
| 5     | `29684cc1..8e75337c` | 82, 129, 132, 135, 146, 147, 149, 155, 157, 158, 159, 163, 166, 167, 174, 175, 176, 177, 182, 183         |
| 6     | `012573fb..b869de54` | 185, 186, 187 (part), 189, 190, 191, 193, 198, 200, 203, 205, 206, 207, 209, 211, 214, 215, 220, 221, 222 |

The answers to batch 4's questions went in as `363c243b..2a8fb470`: the decode half of item 100, the `PlAnimateTyping` caret, and a `headingLevel` for `PlCard` with the card page corrected.

The approved Flutter text input fix went in first in batch 6, as `86acd2ef`, and the React changelog entry for item 211 was corrected for the site build afterwards.

## Waiting for an answer

Asked at the end of batches 5 and 6. The flagged items are the ones batches 1 to 6 passed over; each item's own entry below has the details and the proposal.

1. **Item 12, values inside translatable strings.** Add function-valued keys such as `(n, total) => string` to both packages and all seven packs, with top-level tear-offs so the Dart packs stay `const`? Item 178 waits on the same shape.
1. **Item 19, the reset in `plass-ui/styles.css`.** Move the list and heading resets into the components that need them, which changes how host pages render, or keep the reset and document it?
1. **Item 20, derived tokens on a non-root element.** Add a hook class such as `.plass-theme` to the derived block, or document that a base token changes the derived ones only on the root?
1. **Item 21, Flutter tokens.** Make `PlassTokens.copyWith` and a way to replace a colour family public, or document that a Flutter app cannot change them?
1. **Item 32, `BackdropFilter.grouped`.** Should the library set the group boundaries, or leave them to the app?
1. **Item 39, the documentation deploy workflow.** A security finding; the details are in the local note. Go ahead with the proposal there?
1. **Item 52, the chart's `aria-describedby`.** Point it at a short summary and keep the data table as a sibling. Which summary text, and how should the table be linked?
1. **Item 59, reaching every value in a Flutter line, bar or area chart.** A focus node with arrow keys, or a semantics node per column? `CLAUDE.md` currently says Flutter carries only the summary.
1. **Item 63, `PlassChartSeries.dashed` in Flutter.** Implement it, and add it to React, or remove the field and its table row?
1. **Item 84, a `RegExp` in `PlHighlight`'s `query` list.** Match it as a pattern, or restrict the list to strings and fix the docs?
1. **Item 89, `PlDataTable` row keys and callback `index`.** Base both on the row's position in `rows`, which is a breaking change?
1. **Item 93, `PlGallery` masonry order.** Rebuild the layout as one flat list placed with CSS grid, so focus and reading follow the original order?
1. **Item 107, `PlMockup` hidden until hydration.** Compute the scale on the server when `width` and `height` are numbers, and what should show before the measurement otherwise?
1. **Item 109, `PlTree` rebuilding every row on a focus move.** Build a closed branch's children only while it is open or closing, which changes how the closing animation gets its rows?
1. **Item 128, a Flutter toast with `low` priority.** Make every toast a live region and express the priority with `Assertiveness`? The docs and a test currently say `low` is not a live region on purpose.
1. **Item 168, the floating action button and the safe area.** Should the component add the safe area to its offset, or should the caller?
1. **Item 178, a name for each `PlOtpField` cell.** A name such as "Character 2 of 6" needs a translated string with values in it, so it waits on item 12. Take it with item 12?
1. **Found in passing: the Flutter calendar header names.** The month and year buttons pass `semanticLabel: labels.chooseMonth` and `chooseYear`, which are merged ahead of the drawn text, so they read "Choose a month, July". This is item 146 on the Flutter side. Put the drawn text first and the purpose in a hint?
1. **Found in passing: the `PlFilePicker` button name runs two words together.** Chromium joins the title and the hint with no space, so the name ends "…click to browsePDF only". Describe the button with the hint through `aria-describedby`, or keep it in the name with a separator?
1. **Found in passing: the Korean pagination page.** The Flutter Accessibility block in `docs/ko/components/inputs/pagination.md` has a bullet about fewer than two pages that the English block does not. Move it to match the English page?
1. **Item 100, the rest of the gallery decodes.** Building only the tiles near the view changes how the board is laid out, and item 93 changes the same layout in React. Decide the layout together with item 93?
1. **Item 180, a finding in Flutter `PlOtpField`.** A security finding, and the local memory note `audit-security-items` is not on this machine, so the details are missing. Where are they?
1. **Item 181, `PlPagination` focus on a page change.** Keep the current page the same element type as the others, which reverses the documented decision that it is a `<button>`, and use `focusableWhenDisabled` on the steppers?
1. **Item 187, the rest of the width sample.** Leave labels that are not strings out of a trigger without `fullWidth`, which lets it change width with its value, or sample only a number of them, and which number?
1. **Item 192, `PlTransfer` after a move.** Moving the focus to the target list can be done now, but announcing how many items moved is a translated string with a count in it, which waits on item 12. Take the focus half now and the announcement with item 12?
1. **Item 195, a `PlTransfer` list of thousands.** Virtualising the React rows needs a windowing implementation or a dependency. Write one in `internal`, add a dependency, or only memoise the rows?
1. **Item 201, a nested `PlPageLayout`.** Render a `div` and turn the skip link off inside another layout, or correct the sentence that says there is exactly one per page?
1. **Item 213, `PlAnchor` in a scroll container.** Add a `target` prop, as `PlBackTop` has, which adds to the API?
1. **Item 216, Flutter `PlBackTop` without a `controller` on desktop.** Document the limitation and point to `controller`, or add a debug assert?
1. **Found in passing: `CLAUDE.md`.** The batch rules follow it, but it is not in the working tree; it is listed in `.gitignore` and missing. Batch 6 followed `CONTRIBUTING.md` and the code around each change. Where does it live?
1. **Found in passing: `PlDateRangePicker` width samples.** It renders a `WidthSizer` the same way `PlSelect` did before item 187, including with `fullWidth`. Make the same change there?
1. **Found in passing: the Flutter `PlSlider` run.** The filled run is drawn along the whole rail while a thumb is placed along the rail less its own size, so the run's end sits under the thumb's centre only in the middle. Line the two up?
1. **Found in passing: `PlChip` reads its child's words with a private `_childText`.** It is the same as the new `plassTextOf` in `internal/text.dart`. Use the shared one?
1. **Found in passing: `formatValue` and the Flutter `PlSlider` value a screen reader hears.** Item 190 no longer reproduces, because the value is read in the step's decimals, but `formatValue` takes the whole list and so still does not reach a single thumb. Leave it, or add a per-thumb formatter?

## Passed over and not yet asked

None. Every flagged item passed over so far is asked above.

## Items

### 1. Across components

- [x] **1.** `inert` never reaches the DOM on React 18 (Accessibility · React · High)
- [x] **2.** In Flutter tabs, radios and segmented buttons, one arrow key press throws focus out of the group (Accessibility · Flutter · High)
- [x] **3.** Flutter horizontal arrow keys are not reversed in RTL (Accessibility · Flutter · Medium)
- [x] **4.** Pressable rows in Flutter have no tap action in their semantics (Accessibility · Flutter · High)
- [x] **5.** Flutter floating layers do not close on Escape (Accessibility · Flutter · Medium)
- [x] **6.** Flutter modal layers do not hide the screen behind them from screen readers (Accessibility · Flutter · High)
- [x] **7.** Flutter layers do not account for the safe area or the soft keyboard (Bug · Flutter · Medium)
- [x] **8.** In Flutter lists, the row highlighted with the arrow keys moves out of view (Accessibility · Flutter · Medium)
- [x] **9.** Flutter builds long lists all at once and rebuilds every item on each hover (Performance · Flutter · Medium)
- [x] **10.** Default strings ignore label pack keys that already exist for them (Bug · Both · Medium)
- [x] **11.** Fixed strings have no key in the label pack (Bug · Both · Medium)
- [ ] **12.** Accessibility strings that contain a value cannot be translated (Accessibility · Both · Medium)
  - Location: `pagination/PlPagination.tsx:232`, `:237`, `pl_pagination.dart:199`("Page 3", "Page 3 of 12"), `rating/PlRating.tsx:94`, `pl_rating.dart:125`("3 out of 5"), `carousel/PlCarousel.tsx:162`, `:287`, `pl_carousel.dart:186`("Slide n of m", `aria-roledescription`), `PlFilePicker.tsx:280`, `PlCombobox.tsx:325`, `:630`("Remove …", "Add “…”"), `how_to_steps/pl_how_to_steps.dart:171`("Step n of m")
  - Problem: The landmark is read in Korean, while the buttons and states inside it are read in English. The comment in `PlPagination.tsx:84` and `pl_pagination.dart:176` that says "there is no message catalogue" is also out of date.
  - Proposal: Add function-valued keys such as `(n, total) => string` to both packages and all seven packs. Dart can keep its packs const by using top-level function tear-offs.
  - Flag: Decision needed — this is the first time a label pack would hold a function value, so its shape has to be decided. Differences in word order are part of this decision.
- [x] **13.** A partial `labels` on a nested `PlassProvider` replaces the whole outer pack (Bug · React · Medium)
- [x] **14.** Shortcut matching fails for macOS `Alt+letter` and for Shift symbols (Bug · React · Medium)
- [x] **15.** Key presses during IME composition are not filtered out (Accessibility · React · Medium)
- [x] **16.** Focus ring contrast is about 2.2:1, below WCAG 1.4.11 (3:1) (Accessibility · Both · High)
- [x] **17.** In forced-colours mode (Windows High Contrast), the edges of `solid` controls disappear (Accessibility · React · Medium)
- [x] **18.** The per-component Tailwind scan manifests leave out components used internally (Bug · React · High)
- [ ] **19.** The reset in `plass-ui/styles.css` wipes the host page's default styles (Bug · React · Medium)
  - Location: `packages/react/src/reset.css:33`, `:77`, `:83`
  - Problem: Author styles beat UA defaults even at specificity 0. In an existing app without Tailwind, the bullets on body text lists, heading sizes, `<hr>` and native input borders disappear. This goes against the principle in the file header, "do not touch other people's pages".
  - Proposal: Move the list and heading resets into the utilities of the components that need them, and reduce the element selector rules.
  - Flag: Decision needed, Breaking change — the scope of the move has to be decided, and host pages will render differently.
- [ ] **20.** Changing a base token on a non-root element does not update the derived tokens (Bug · React · Medium)
  - Location: `packages/react/src/styles.css:569`
  - Problem: Derived values such as `-fill`, `-tint`, `-ring` and `--plass-shadow-*` are computed only on `:root, .dark, .light, [data-theme]`. A button inside `<div style={{ '--plass-primary-solid': … }}>` keeps its gradient and ring unchanged, but `design/color.md` says tokens "can be set on any element".
  - Proposal: Add a hook class such as `.plass-theme` to the selector of the derived block and document it, or state in the docs and the type comments that this works on the root only.
  - Flag: Decision needed
- [ ] **21.** A Flutter app has no way to change the palette, radius or blur tokens (Bug · Flutter · Medium)
  - Location: `packages/flutter/lib/src/theme/tokens.dart:192`, `theme/theme.dart:40`
  - Problem: `PlassTokens` has only a private constructor and `light()`/`dark()`, so the only values that can be passed to `PlassTheme.tokens` are the two default sets. The "Overriding a family" section of `color.md` is outside any `fw` block, so Flutter readers see it too.
  - Proposal: Make `copyWith` and a way to replace a family public, or state the Flutter limitation in the docs.
  - Flag: Decision needed — it has to be decided which tokens to open up as public API.
- [x] **22.** In the Flutter dark theme, the chart grid, axis and baseline colours differ from the CSS (Bug · Flutter · Medium)
- [ ] **23.** `PlCodeBlock theme="auto"` is painted dark on a page that forces light with `.light` (Bug · React · Low)
  - Location: `packages/react/src/styles.css:1931`
  - Problem: The token block checks `:not(.light)`, but the code block rule checks only `[data-theme='light']`.
  - Proposal: Add `:not(.light)` to the selector.
- [x] **24.** The interaction light on a clickable `PlPill` spreads to the size of the nearest positioned ancestor (Bug · React · Medium)
- [x] **25.** `PlColorSchemeScript` does not escape `</script>` in its inline script (Security · React · Medium)
- [x] **26.** `usePlColorScheme` throws during render where storage access is blocked (Bug · React · Medium)
- [x] **27.** `usePlElementSize` and `usePlOnScreen` never observe an element that is attached later (Bug · React · Medium)
- [x] **28.** Resize and drag handles have no `touch-action: none` (Accessibility · React · Medium)
- [ ] **29.** `PlSidebar` reimplements the drag handling in `internal/drag.ts` (Optimisation · React · Low)
  - Location: `sidebar/PlSidebar.tsx:329-378`, `scroll-zone/PlScrollZone.tsx:535`
  - Problem: Its capture, three listeners, `data-dragging`, and taking and restoring the selection match `beginPointerDrag` line for line. `PlScrollZone` also implements taking the selection on its own.
  - Proposal: Make `PlSidebar` use `beginPointerDrag`, and export `takeSelection` so that `PlScrollZone` uses it too.
- [ ] **30.** The popup arrow is duplicated in three components, and the copies already draw it differently (Optimisation · React · Low)
  - Location: `popover/PlPopover.tsx:286`, `hover-card/PlHoverCard.tsx:230`, `tooltip/PlTooltip.tsx:240`
  - Problem: The tooltip stacks two triangles, while the other two stroke only the slanted edges, so their hairlines differ.
  - Proposal: Put a shared `PopupArrow` in `internal/picker.tsx`.
- [ ] **31.** The statement "one listener per query" is wrong (Docs · Both · Low)
  - Location: `packages/react/src/internal/media.ts:18`, `docs/en/hooks/use-media-query.md:77`, `docs/en/hooks/use-breakpoint.md:87`(same in ko)
  - Problem: Only the `MediaQueryList` is shared. A `change` listener is added for each subscription.
  - Proposal: Change it to "one `MediaQueryList` is shared per query".
- [ ] **32.** Each Flutter glass surface's `BackdropFilter` reads the backdrop separately (Performance · Flutter · Medium)
  - Location: `packages/flutter/lib/src/internal/surface.dart:175`
  - Problem: With dozens of glass surfaces, as in a list of cards, the σ22 blur reads the backdrop once per surface. `BackdropFilter.grouped` is available in the minimum version, 3.41, but it is not used.
  - Proposal: Group surfaces that do not overlap, and give overlapping glass, such as a field inside a card, a new group.
  - Flag: Decision needed — it has to be decided whether the library or the app sets the group boundaries.
- [ ] **33.** `PlassLabels` and `PlDateNames` have no `==`, so the theme causes needless full rebuilds (Performance · Flutter · Low)
  - Location: `packages/flutter/lib/src/theme/defaults.dart:87`
  - Problem: When `labels: ko.copyWith(...)`, which the docs recommend, is written inside build, `updateShouldNotify` returns true on every parent rebuild.
  - Proposal: Add field-based `==` and `hashCode` to both classes.
- [ ] **34.** Every paint of an inset shadow runs `Path.combine` (Optimisation · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/inset_shadow.dart:92`
  - Problem: Every glass sheet and field runs a path boolean operation each time it repaints. During a hover transition this repeats on every frame.
  - Proposal: Replace it with `canvas.drawDRRect(outer, hole, paint)`.
- [ ] **35.** The Flutter label pack test does not catch a single missing translation (Test · Flutter · Low)
  - Location: `packages/flutter/test/package/labels_test.dart:118`, `:139`
  - Problem: The length of `words()` is fixed, so the length comparison always passes. The allowance of "fewer than 6 values equal to English" also passes when a new key is left untranslated in `de` or `fr`, which already have 4.
  - Proposal: List, for each pack, the keys that may equal English, and compare exactly.
- [ ] **36.** `size.mjs` does not check as much as its comments say (Test · React · Low)
  - Location: `packages/react/scripts/size.mjs:20`, `:104`
  - Problem: The comment says it catches the worse of esbuild and Rollup, but it runs only esbuild. The Node resolution check also leaves out `plass-ui/locales`.
  - Proposal: Add `locales`, and either add a Rollup measurement or correct the comment.
- [x] **37.** The React format check in CI always passes (Bug · CI · Medium)
- [x] **38.** The documentation site is not verified on PRs (Test · CI · Medium)
- [ ] **39.** A finding in the documentation deploy workflow (Security · CI · Medium)
  - Security finding. The details are kept out of this public file, in the local memory note `audit-security-items`. Decision needed.

### 2. Charts

- [x] **40.** Mark charts redraw everything every time the pointer moves (Performance · React · High)
- [x] **41.** With large data, O(N) work repeats every time the active column changes (Performance · React · Medium)
- [x] **42.** Flutter charts rebuild and repaint everything with `setState` on every 1px of movement (Performance · Flutter · Medium)
- [x] **43.** At narrow widths, Flutter category labels are always cut to `J…` and `…` (Bug · Flutter · High)
- [x] **44.** In Flutter, a series that starts with `hidden: true` cannot be turned back on from the legend (Bug · Flutter · High)
- [x] **45.** Flutter date categories appear as ISO strings on the axis and in the tooltip (Bug · Flutter · Medium)
- [x] **46.** Flutter tooltips are clipped at the chart edges (Bug · Flutter · Medium)
- [x] **47.** A Flutter legend with `side: left/right` lays out in one horizontal row and overflows (Bug · Flutter · Medium)
- [x] **48.** A Flutter cartesian chart throws when `empty` is given `Text.rich`, and ignores any other widget (Bug · Flutter · Medium)
- [ ] **49.** Flutter tooltip `mode: item` is ignored, and pie also ignores `none` (Bug · Flutter · Low)
  - Location: `internal/chart_frame.dart:743`, `pie_chart/pl_pie_chart.dart:245`
  - Problem: `item` behaves the same as `column`, and pie shows a tooltip even with `mode: none`.
  - Proposal: For `item`, keep only the nearest series, and add a `none` check to pie.
- [x] **50.** On an axis with one end fixed, the axis opens past the fixed value when every value equals it (Bug · React · Medium)
- [x] **51.** The SSR output of pie and gauge shows the empty-state text instead of the data (Bug · React · Medium)
- [ ] **52.** `aria-describedby` uses the whole data table as the description, so every value is read on each focus (Accessibility · React · Medium)
  - Location: `internal/chart-frame.tsx:1470`(same structure in pie and heatmap)
  - Problem: NVDA and JAWS read hundreds of values on every focus, and the arrow key instructions are pushed to the end. The same table is also in the reading order, so it is heard twice.
  - Proposal: Point `aria-describedby` at a short summary, and keep the table only as a sibling element.
  - Flag: Decision needed — the form of the summary text and the way the table is linked have to be decided.
- [x] **53.** The tooltip, table and summary of a 100% stacked chart ignore `format` or treat the share as the value (Bug · Both · Medium)
- [x] **54.** Arrow key navigation in cartesian charts is effectively untested (Test · React · Medium)
- [ ] **55.** Hovering the legend entry of a hidden series dims every drawn mark (Bug · Both · Low)
  - Location: `PlBarChart.tsx:230`, `PlScatterChart.tsx:255`, `PlPieChart.tsx:330`, `pl_scatter_chart.dart:334`, `pl_pie_chart.dart:553`
  - Problem: These check only `hovered !== index`. `chart-line.tsx:151` and the Flutter bars guard against this with `visible[hovered]`.
  - Proposal: Put the same condition into one helper.
- [ ] **56.** Chart arithmetic that both languages should share gives different values (Bug · Both · Low)
  - Location: `internal/chart.ts:129`, `internal/chart.dart:106`, `:953`
  - Problem: `barBandRatio` is `0.62/0.82` in React and `0.68/0.84` in Dart. Dart's `markPath` does not keep the area equal across shapes, so in a bubble chart the same value looks a different size for each shape.
  - Proposal: Bring Dart in line with the React values and the `shapeScale` factor.
- [ ] **57.** In RTL, a legend with `side: left/right` is drawn on the opposite side (Bug · Both · Low)
  - Location: `internal/chart-frame.tsx:267`, `internal/chart_frame.dart:924`
  - Problem: `rtl.md:68` defines `PlassSide` as a physical direction, but both platforms place the legend by flex or `Row` order, which follows the writing direction.
  - Proposal: Fix this layout alone to LTR.
- [ ] **58.** `tickFormat` prints `[object Object]` when it returns a ReactNode (Bug · React · Low)
  - Location: `packages/react/src/types.ts:849`, `internal/chart-frame.tsx:1007`
  - Problem: The type allows ReactNode, but the result is passed through `String()`.
  - Proposal: Narrow the return type to `string | number`.
  - Flag: Breaking change — the public type becomes narrower.
- [ ] **59.** In Flutter line, bar and area charts, only the last value can be reached by screen reader or keyboard (Accessibility · Flutter · Medium)
  - Location: `packages/flutter/lib/src/internal/chart_frame.dart:936`
  - Problem: The summary holds only the last value of each series, and the frame has no focus or key handling. Scatter and heatmap in the same package carry every value.
  - Proposal: Add a focus node and arrow key navigation, or give each column its own semantics node.
  - Flag: Decision needed — `CLAUDE.md` specifies that Flutter carries only the summary.
- [x] **60.** The site has no descriptions of the fields of `PlassChartAxis`, `PlassChartLegend` and `PlassChartTooltip` (Docs · Docs · Medium)
- [ ] **61.** The chart Accessibility sections describe the per-series summary, which only Flutter has, as if both packages had it (Docs · Docs · Low)
  - Location: `docs/en/components/charts/line-chart.md:174`, `bar-chart.md:122`, `area-chart.md:110` (same in ko)
  - Problem: React has only the `aria-label` and the table.
  - Proposal: Move that sentence into `::: fw flutter`.
- [ ] **62.** `PlassTimelinePoint` and `PlassTimelineSeries` are declared twice, and their comments contradict each other (Optimisation · React · Low)
  - Location: `packages/react/src/types.ts:710`, `:740`
  - Problem: One comment says overlapping spans are drawn over each other. The other says they are moved into lanes. The second one matches the actual behaviour.
  - Proposal: Delete the first declaration.
- [ ] **63.** Flutter `PlassChartSeries.dashed` does nothing (Bug · Flutter · Medium)
  - Location: `lib/src/types.dart:694`, `internal/chart_line.dart:161`, `docs/.vitepress/data/props-flutter.ts:1735`
  - Problem: The field description and the props table say the line is drawn dashed, but the line drawing code never reads this value. The React type has no such field.
  - Proposal: Implement it and add it to React too, or remove the field and its table row.
  - Flag: Decision needed — removing it changes the public API.
- [x] **64.** Flutter `smooth` and `step` stacked areas have a straight lower edge, so the bands pull apart or overlap (Bug · Flutter · Medium)
- [ ] **65.** With `valueLabels="last"`, no label appears when the last value is a gap, and `extremes` is O(n²) (Bug · Both · Low)
  - Location: `bar-chart/PlBarChart.tsx:302`, `:363`, `bar_chart/pl_bar_chart.dart:383`, `:384`
  - Problem: The code compares against `one.length - 1`, so the 20 in `[10, 20, null]` gets no label. A calculation that rescans the whole series for every bar runs again on every hover render. The line chart (`chart-line.tsx:306`, `:314`) already solves both problems.
  - Proposal: Share the line chart's `labelledPoints` and its extreme-value calculation.
- [x] **66.** When a scatter chart's `x` is a `Date`, the x-axis shows millisecond numbers (Bug · Both · Medium)
- [ ] **67.** The Flutter scatter summary leaves out `z` and reads series that were switched off in the legend (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/scatter_chart/pl_scatter_chart.dart:292`
  - Problem: The docs (`scatter-chart.md:98`) say `z` is added in parentheses. The summary also decides visibility from the initial value.
  - Proposal: Add `z` as `_readout` does, and use the frame's `visible`.
- [x] **68.** Flutter treemap tiles, tooltips and summary carry the first group's name (Bug · Flutter · High)
- [x] **69.** The React treemap's hidden table puts other groups' values under the first group's column name (Accessibility · React · Medium)
- [ ] **70.** In a React heatmap grid, ↑/↓ do not move between rows (Accessibility · React · Low)
  - Location: `heatmap-chart/PlHeatmapChart.tsx:412`
  - Problem: `ArrowDown` does the same as `ArrowRight`, so in a 7×24 grid it takes 24 presses to reach the cell directly below.
  - Proposal: In a grid, make ↑/↓ move to the neighbouring row in the same column.
- [ ] **71.** The heatmap column-name stride is set separately for each label, so labels overlap their neighbours (Bug · Both · Low)
  - Location: `PlHeatmapChart.tsx:546`, `pl_heatmap_chart.dart:717`
  - Problem: Each label computes the stride from its own width, so the labels around a long label overlap.
  - Proposal: Compute `tickStride` once, from the widest label.
- [x] **72.** When a timeline range is slightly longer than a day, the axis, tooltip and table show no date (Bug · Both · Medium)
- [ ] **73.** In a timeline, spans outside a fixed `min`/`max` can be selected with hover and the keyboard (Bug · Both · Low)
  - Location: `PlTimelineChart.tsx:170`, `pl_timeline_chart.dart:187`
  - Problem: Drawing skips these spans, but they stay in the mark list. Navigation lands on spans that cannot be seen, and the tooltip appears outside the plot.
  - Proposal: Drop spans that do not overlap the plot, and clip the x of spans that cross its edge.
- [ ] **74.** A `PlSparkline` `bar` with all-negative values is drawn above the strip, outside it (Bug · Both · Low)
  - Location: `sparkline/PlSparkline.tsx:213`, `sparkline/pl_sparkline.dart:256`
  - Problem: The baseline is `y(Math.max(low, 0))`, so the y of 0 falls outside the box and the bars cover the content next to it.
  - Proposal: Clamp the baseline into the range with `Math.min(Math.max(low, 0), high)`.

### 3. Display

- [x] **75.** When `PlCodeBlock`'s `code` or `language` changes, the old code stays visible until the new highlighting finishes (Bug · React · Medium)
- [x] **76.** `PlCodeBlock`'s trailing-whitespace regular expression `\s+$` takes quadratic time on long runs of whitespace (Security · Both · Medium)
- [ ] **77.** `highlightLines` ranges have no upper bound, so a single typo freezes the tab (Bug · Both · Low)
  - Location: `PlCodeBlock.tsx:286`, `pl_code_block.dart:518`
  - Problem: `'1-100000000'` builds a `Set` of 100 million entries. In Flutter, `int.parse` throws on a very large number and the build fails.
  - Proposal: Limit the loop to the actual line range, and use `int.tryParse` in Dart.
- [ ] **78.** When `PlCodeBlock`'s `title` is not a string, the focusable region has no name (Accessibility · React · Low)
  - Location: `PlCodeBlock.tsx:555`, `:636`
  - Problem: A title given as an element cannot produce an `aria-label`.
  - Proposal: Give the title `<span>` an id and link it with `aria-labelledby`.
- [ ] **79.** A name registered with `registerLanguage` is ignored when it matches a built-in alias (Bug · React · Low)
  - Location: `packages/react/src/internal/highlight.ts:202`
  - Problem: Aliases are checked first, so `language="vue"` is still highlighted as `xml` after `registerLanguage('vue', vue)`. The JSDoc says a registration replaces the built-in.
  - Proposal: Check registered keys before aliases.
- [ ] **80.** The Flutter `PlCodeBlock` region name uses `codeLabel` before the language (Bug · Flutter · Low)
  - Location: `pl_code_block.dart:842`
  - Problem: With `language: 'dart', codeLabel: 'Code'`, the name is `dart` in React and `Code` in Flutter.
  - Proposal: Use the order `languageName ?? codeLabel ?? labels.code`, and document that the Flutter name cannot come from `title`, as it can on React.
- [ ] **81.** Flutter `PlCodeBlock` does not pass the raw toggle state or the copy result to screen readers (Accessibility · Flutter · Low)
  - Location: `pl_code_block.dart:1151`
  - Problem: There is no `toggled`, and nothing is announced after a copy. React uses `aria-pressed` and `aria-live`.
  - Proposal: Add `toggled: raw` and a live region announcement.
- [x] **82.** The code-block page's Accessibility section promises behaviour for both packages that Flutter does not have (Docs · Docs · Medium)
- [ ] **83.** The `copyFailedLabel` JSDoc gives the wrong default (Docs · React · Low)
  - Location: `PlCodeBlock.tsx:178`
  - Problem: The JSDoc says `'Copy failed'`, but the actual default is `'Could not copy'`.
  - Proposal: Fix the JSDoc.
- [ ] **84.** A `RegExp` in the `query` list of Flutter `PlHighlight` is escaped and matched as literal text (Bug · Flutter · Medium)
  - Location: `packages/flutter/lib/src/components/highlight/pl_highlight.dart:177`, `:187`
  - Problem: `query: [RegExp(r'\d+')]` looks for the literal text `\d+` and marks nothing. The docs say the list accepts both String and RegExp values.
  - Proposal: Join a `RegExp` in the list without escaping it, or restrict the list to `List<String>` and fix the docs.
  - Flag: Decision needed
- [x] **85.** Scaling up the text size in Flutter `PlHighlight` enlarges only the marked words twice (Accessibility · Flutter · Medium)
- [x] **86.** Expanding the collapsed steps of `PlBreadcrumb` loses keyboard focus (Accessibility · React · Medium)
- [x] **87.** The sort headers of Flutter `PlDataTable` cannot be reached with the keyboard (Accessibility · Flutter · High)
- [x] **88.** In descending order, `PlDataTable` puts empty values first (Bug · Both · Medium)
- [ ] **89.** `PlDataTable`'s default row key and callback `index` are relative to the current page, so selection lands on the wrong row (Bug · Both · Medium)
  - Location: `PlDataTable.tsx:443`, `:494`, `:757`, `pl_data_table.dart:409`, `:522`, `:546`, `docs/en/components/display/data-table.md:328`
  - Problem: Without `getRowKey`, the key is the position in the visible list, but `onSelectedChange` looks the row up by its position in `rows`. Checking the first row on page 2 also shows the first row on page 1 as checked, and the callback passes `rows[0]`. The same happens after sorting or searching.
  - Proposal: Attach the original index before filtering and sorting, and use it for the default key and for every callback `index`.
  - Flag: Breaking change — the meaning of the callback `index` and the default key both change.
- [x] **90.** An uncontrolled Flutter `PlDataTable` never calls `onPageChanged` (Bug · Flutter · Medium)
- [x] **91.** Setting a controlled Flutter `sort` back to `null` brings back the sort still held internally (Bug · Flutter · Medium)
- [x] **92.** Flutter `PlDataTable` sorting is not stable, so rows with equal values change order (Bug · Flutter · Medium)
- [ ] **93.** React `PlGallery` masonry follows columns for focus and reading order, and tiles remount when the column count changes (Accessibility · React · Medium)
  - Location: `packages/react/src/components/gallery/PlGallery.tsx:330`, `:498-518`
  - Problem: Tiles go into one `<ul>` per lane, so with 3 columns and 12 images the Tab order is 1, 4, 7, 10, 2…, and the numbers skip, as in "4 of 12". When the lane count changes (at a breakpoint, or from `xs` to the real column count right after SSR), tiles move into a different `<ul>` and their `PlImage` state is reset.
  - Proposal: Keep the DOM as a flat list in the original order, and do the placement with CSS grid `grid-row: span`.
  - Flag: Decision needed — the layout has to be implemented a different way.
- [x] **94.** When an arrow button of `PlGalleryViewer` is disabled at either end, focus and the arrow keys stop working (Accessibility · React · Medium)
- [x] **95.** The large image in the Flutter `PlGallery` viewer has no name (Accessibility · Flutter · Medium)
- [ ] **96.** On a pressable gallery tile, `title` and `description` do not reach screen readers (Accessibility · Both · Low)
  - Location: `PlGallery.tsx:472-476`, `pl_gallery.dart:600-601`
  - Problem: The button name is fixed as `alt — n of m`, and the caption is hidden.
  - Proposal: Link the caption with `aria-describedby` in React and with `hint` in Flutter.
- [ ] **97.** The React props table for `PlGallery` has no `classNames` row (Docs · Docs · Low)
  - Location: `docs/.vitepress/data/props.ts:12975`
  - Problem: It is a public prop and the page text describes it, but the table does not list it.
  - Proposal: Add the row, following the shared `classNames` row definition.
- [x] **98.** Every `PlChip` remove button has the same name, "Remove" (Accessibility · Both · Medium)
- [ ] **99.** The × inside chips, comboboxes and picker triggers is about 15px, below WCAG 2.5.8 (24px) (Accessibility · Both · Low)
  - Location: `packages/react/src/internal/styles.ts:448-455`, `internal/picker.tsx:315`, `chip/pl_chip.dart:301-306`
  - Problem: It sits 2px from the label button or the trigger, so it does not qualify for the spacing exception either. On touch screens it is easy to mix up opening and clearing.
  - Proposal: Keep the visible size, and widen only the hit area to 24px with a pseudo-element or transparent padding.
- [ ] **100.** Flutter `PlAvatar` and `PlGallery` decode images at full resolution (Performance · Flutter · Medium)
  - Location: `gallery/pl_gallery.dart` (`LayoutBuilder` board and `_tile`)
  - Done in `eaabbe83`: `PlAvatar`, `PlImage` and the gallery viewer decode at the size they are drawn, through `internal/decode.dart`.
  - Problem left: the gallery builds every tile at once, so a gallery of 60 pictures asks for 60 decodes before any of them is on screen.
  - Proposal: Build only the tiles near the view, and take the item when that is done.
- [x] **101.** The `rel` merge for new-tab links is skipped on some code paths (Security · React · Medium)
- [ ] **102.** The `PlTextLink` `icon` row in the Flutter props table inherits React's true/false description (Docs · Docs · Low)
  - Location: `docs/.vitepress/data/props-flutter.ts:5297`
  - Problem: In Flutter, `icon` is a Widget, and `showIcon` decides whether it is drawn.
  - Proposal: Replace it with a Flutter-only description.
- [x] **103.** Changing `PlImage`'s `src` to a new image that is already cached does not call `onStatusChange` (Bug · React · Medium)
- [ ] **104.** A `placement: 'tile'` watermark does not cover the corners of wide or tall photos (Bug · Both · Low)
  - Location: `packages/react/src/internal/watermark.tsx:117-121`, `packages/flutter/lib/src/internal/watermark.dart:204-205`
  - Problem: The rotated layer has a fixed size, such as 150% of the box, so empty triangles appear in the diagonal corners from 16:9 (React) and 2:1 (Flutter) onwards. This contradicts the comment.
  - Proposal: Size the layer from the diagonal of the box.
- [ ] **105.** A tile watermark `color` given as a token or `currentColor` is drawn black (Bug · React · Low)
  - Location: `internal/watermark.tsx:72`
  - Problem: `var()` does not resolve inside an SVG data URI. The value is also not escaped, so a `"` in it breaks the tile.
  - Proposal: Draw the tile with `mask-image` and `background-color` together, or document that only literal colours are accepted and escape the value.
- [ ] **106.** The Flutter `PlImage` preview photo has no description, the decorative-image flag merges into the parent, and the failure label is read twice (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/image/pl_image.dart:548`, `:711-717`, `:733-738`
  - Problem: The photo in the open overlay has `excludeFromSemantics: true`, so only "Preview" is heard. The `image: true` of an unlabelled image merges into a parent node such as `PlButton`. When loading fails, the label is read as "X X".
  - Proposal: Give the overlay a `semanticLabel`, use `ExcludeSemantics` when there is no label, and exclude the default fallback text as well.
- [ ] **107.** On an SSR page, the whole `PlMockup` is `visibility: hidden` until hydration (Performance · React · Medium)
  - Location: `packages/react/src/components/mockup/PlMockup.tsx:231-235`, `:313-316`
  - Problem: The measurement is `null` on the server, so `hidden` is baked into the SSR HTML. A mockup in a landing hero drops out of the LCP candidates, and it looks empty when JS loads late.
  - Proposal: Compute the scale on the server when numeric `width`/`height` are given. Otherwise, decide what to show before the measurement.
  - Flag: Decision needed
- [ ] **108.** Screen readers read the clock in the Flutter `PlMockup` system bar (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/mockup.dart:664-667`
  - Problem: In React the whole chrome is `aria-hidden`, and the docs say both packages hide it, but Flutter reads "9:41".
  - Proposal: Wrap the chrome and the cutout in `ExcludeSemantics`.
- [ ] **109.** React `PlTree` rebuilds the whole loaded tree every time focus moves one step (Performance · React · Medium)
  - Location: `packages/react/src/components/tree/PlTree.tsx:182`, `:228`, `:306`, `:360`
  - Problem: `setTabStop` re-renders the whole tree, and `renderRow` recursively builds even the children of closed branches, so the cost grows with the number of loaded nodes. In a tree of 10,000 nodes, key repeat stutters.
  - Proposal: Split rows out with `React.memo`, and build a closed branch's children only while it is open or closing.
  - Flag: Decision needed — this conflicts with the choice to build closed rows for the closing animation.
- [ ] **110.** Pressing → on an open branch with no visible children moves to the next sibling (Bug · Both · Low)
  - Location: `PlTree.tsx:253`, `tree/pl_tree.dart:290`
  - Problem: With `children: []`, or when every child is `disabled`, the next row is a sibling. Under the APG, nothing happens in this case.
  - Proposal: Move only when the next row's level is the current level + 1.
- [ ] **111.** The tree docs' advice to leave "`children: undefined` until opened" cannot be followed (Docs · Both · Low)
  - Location: `docs/en/components/display/tree.md:123` (same in ko), `PlTree.tsx:32-34`
  - Problem: `undefined` makes a leaf that cannot be opened. Line 113 of the same page recommends `children: []`.
  - Proposal: Change all three places to `children: []`.
- [ ] **112.** The map of row `FocusNode`s in Flutter `PlTree` is never cleaned up (Performance · Flutter · Low)
  - Location: `pl_tree.dart:183`, `:196-197`
  - Problem: Nodes for ids removed from `items` stay until dispose, and each node's key closure holds on to the old list.
  - Proposal: After build, dispose the nodes whose ids are not in the current rows.
- [x] **113.** `PlTypography` cuts a `lines` value above 6 to 6 lines, and truncation with an ellipsis does not work on `caption`/`overline` (Bug · React · Medium)
- [x] **114.** Flutter `PlTypography` does not pass on the heading level, and the docs explain that "Flutter has no depth" (Accessibility · Flutter · Medium)
- [ ] **115.** The typography docs' claim that "Flutter `lines` actually discards the cut text" is wrong (Docs · Flutter · Low)
  - Location: `docs/en/components/display/typography.md:187` (same in ko)
  - Problem: `RenderParagraph` builds the semantics label from the whole string, so screen readers get the full text.
  - Proposal: Change it to "cuts the text visually only".
- [x] **116.** Hovering or focusing one Flutter `PlTable` row rebuilds the whole table and recomputes the intrinsic layout (Performance · Flutter · Medium)
- [ ] **117.** The `PlTable` `stickyHeader` JSDoc claim that it "also works inside an outer pane" is wrong (Docs · React · Low)
  - Location: `packages/react/src/components/table/PlTable.tsx:95-99`
  - Problem: The `overflow-x-auto` wrapper becomes the sticky scroll container, so the header does not stick without `maxHeight`. The description on the docs page is correct.
  - Proposal: Change the JSDoc to say "`maxHeight` is required".
- [ ] **118.** The scroll area of a horizontally overflowing `PlTable` cannot be reached with the keyboard (Safari) (Accessibility · React · Low)
  - Location: `PlTable.tsx:255-266`
  - Problem: In a wide table with no focusable cells, the remaining columns cannot be reached (WCAG 2.1.1).
  - Proposal: Give the scroll wrapper `tabIndex={0}`, `role="region"` and a name based on the caption.
  - Flag: Decision needed — decide whether to add these always or only when the table overflows (which needs a hook).
- [ ] **119.** React `PlStat` prints `change` unformatted, so floating-point errors show and the output differs from Flutter (Bug · React · Low)
  - Location: `packages/react/src/components/stat/PlStat.tsx:185`
  - Problem: `change={0.1 + 0.2}` renders as `+0.30000000000000004%`. Flutter `formatChange` rounds to one decimal place.
  - Proposal: Add the same `formatChange` to React, and make both packages hide the arrow when the value rounds to 0.
- [ ] **120.** Inserting an item at the start of `PlTimeline` remounts every item (Performance · React · Low)
  - Location: `packages/react/src/components/timeline/PlTimeline.tsx:339`, `:364`
  - Problem: The Provider key is `index`, so adding a new event to the front of an activity feed wipes the item state and images fade in again.
  - Proposal: Use `item.key ?? index`.

### 4. Feedback

- [x] **121.** `PlTour` leaves the card beside the first target after moving to the next step, and shows no card on a step without a target (Bug · React · High)
- [x] **122.** Flutter `PlTour` does not move focus to the card when it opens, so Escape does not work (Accessibility · Flutter · Medium)
- [x] **123.** `PlTour` does not pass the new title and content to screen readers when the step changes (Accessibility · Both · Medium)
- [ ] **124.** `PlTour` scrolling ignores reduced motion (Accessibility · Both · Low)
  - Location: `PlTour.tsx:318`, `pl_tour.dart:327`
  - Problem: It always scrolls smoothly. `PlBackTop`, `PlCarousel` and `PlScrollZone` follow the setting.
  - Proposal: Move instantly when reduced motion is on.
- [ ] **125.** `PlTour` cuts no hole when the target is an SVG element (Bug · React · Low)
  - Location: `PlTour.tsx:313`
  - Problem: It measures the position only when the target is an `instanceof HTMLElement`. When the tour points at a chart bar, the whole page goes dark and the target cannot be pressed either.
  - Proposal: Check with `instanceof Element`.
- [x] **126.** A Flutter toast that is already closing gets a new timer, which throws on a disposed controller 5 seconds later (Bug · Flutter · High)
- [x] **127.** The loading toast of Flutter `showFuture` closes on its timeout, so the result toast never appears (Bug · Flutter · Medium)
- [ ] **128.** Screen readers never read a Flutter toast with the default `low` priority (Accessibility · Flutter · Medium)
  - Location: `pl_toast.dart:611`
  - Problem: `liveRegion` is turned on only for `high`, so a default toast such as "Saved" disappears without being announced. React reads `low` as polite as well.
  - Proposal: Make every toast a live region, and express the priority with `Assertiveness`.
  - Flag: Decision needed — the documentation and the tests currently fix the present behaviour as intended.
- [x] **129.** The Flutter toast timer does not pause on keyboard focus, on touch, or when the app goes to the background (Accessibility · Flutter · Medium)
- [ ] **130.** A React toast dismissed with a swipe jumps back to its original place before it disappears (Bug · React · Low)
  - Location: `packages/react/src/components/toast/PlToast.tsx:289`
  - Problem: When the finger is lifted, Base UI clears the inline `transform` and leaves the position to the swipe variables, but this component handles only the opacity.
  - Proposal: Keep the position with the swipe variables in `data-[ending-style]`, or turn swiping off.
  - Flag: Decision needed — keeping the position adds one more exception to the no-transform rule.
- [ ] **131.** The toast docs say "the × is not in the tab order", which does not match the actual behaviour (Docs · React · Low)
  - Location: `docs/en/components/feedback/toast.md:200`(same in ko)
  - Problem: Base UI `Toast.Root` has `tabIndex=0` and `Close` is an ordinary button, so Tab reaches it.
  - Proposal: Correct it to say that both Tab and F6 reach it.
- [x] **132.** `initialFocus` is not applied again for the next question in the `PlConfirmProvider` queue (Accessibility · Both · Medium)
- [ ] **133.** The Flutter confirm dialog empties its content and resets its buttons to the defaults while it closes (Bug · Flutter · Low)
  - Location: `pl_confirm.dart:248`
  - Problem: The comment says the request is kept until the fade ends, but the code sets it to `null` at once. The title disappears for 260ms, and an alert gains a Cancel button.
  - Proposal: Keep the request being drawn separate from the request waiting for an answer, and change only `_open` when closing.
- [ ] **134.** The confirm docs wrongly say "there is no difference matching `dismissible: false`" (Docs · Flutter · Low)
  - Location: `docs/en/components/feedback/confirm.md:64`(same in ko)
  - Problem: Flutter also has `dismissible`. The Flutter confirm dialog has no ×, but the React confirm dialog draws one because of the `PlModal` default.
  - Proposal: Delete the sentence, and decide whether React should also match with `showClose={false}`.
  - Flag: Decision needed
- [x] **135.** While a Flutter `dismissible` popover is open, the screen behind it cannot be pressed or scrolled (Bug · Flutter · Medium)
- [ ] **136.** When `disabled` turns on while a Flutter tooltip is open, every tooltip in the same group then opens with no delay (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/tooltip/pl_tooltip.dart:229`
  - Problem: `didUpdateWidget` turns off only `_open` and does not call `_release()`, so the provider's open count is left behind.
  - Proposal: Keep `_hold`/`_release` in step with every change of the open state, and cancel the pending timer.
- [ ] **137.** Pressing the × on a React uncontrolled `inline` drawer does not close it (Bug · React · Low)
  - Location: `packages/react/src/components/drawer/PlDrawer.tsx:390`, `:442`
  - Problem: Inline mode has no internal state and only reads `open ?? defaultOpen ?? true`.
  - Proposal: Give inline mode uncontrolled state as well, or do not draw the × when `open` is not given.
- [ ] **138.** The segment of a Flutter indeterminate progress bar moves only inside the track and jumps at the end (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/progress_linear/pl_progress_linear.dart:290`
  - Problem: `AlignmentDirectional(-1…1)` only aligns the segment to the inner ends of the track, so it jumps instantly from the right end to the left end. In React the segment enters from outside the track and leaves past it.
  - Proposal: Widen the x range to about ±2.64 to match the React path.
- [ ] **139.** Giving React `PlSkeleton` a `label` does not announce it to screen readers (Accessibility · React · Low)
  - Location: `packages/react/src/components/skeleton/PlSkeleton.tsx:196`
  - Problem: A `role="status"` with only an `aria-label` and no text is mounted in that form from the start, so no announcement happens.
  - Proposal: Put the label in as visually hidden text, or correct the docs.
- [ ] **140.** Flutter `PlSkeleton` runs a separate `AnimationController` and clip for every bar (Performance · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/skeleton/pl_skeleton.dart:234`, `:267`
  - Problem: A list of 12 rows runs 36 separate tickers, and their phases drift apart.
  - Proposal: Share the controller, and use the `borderRadius` of `BoxDecoration` instead of `ClipRRect`.
- [ ] **141.** The three React progress components do not use the `locale` from `PlassProvider` (Bug · React · Low)
  - Location: `packages/react/src/internal/progress.ts:217`, `progress-linear/PlProgressLinear.tsx:75`(same in Circular and Box)
  - Problem: Unlike `PlMeter`, they do not pass the locale, so the SSR display can mismatch, and the default percentage is fixed to `${n}%`. The comment "the Base UI default is `${value}%`" also does not match 1.8.
  - Proposal: Pass `locale={defaults.locale}` and use Base UI's `formattedValue`.

### 5. Inputs

- [x] **142.** The pickers, `PlCalendar`, `PlColorPicker` and `PlFilePicker` do not take part in `PlForm` (Bug · React · High)
- [x] **143.** The pickers' hidden input has no `required` and no `disabled` (Bug · React · Medium)
- [x] **144.** A picker trigger with a label does not read out the selected value (Accessibility · React · High)
- [x] **145.** The time column (`TimeGrid`) cannot be used with the keyboard (Accessibility · Both · High)
- [x] **146.** The names of the month and year buttons in the calendar header override the text on screen (Accessibility · React · Medium)
- [x] **147.** Keyboard focus on a Flutter calendar cell does not appear in the semantics tree (Accessibility · Flutter · Medium)
- [ ] **148.** The × on a Flutter picker trigger does not take focus (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/picker.dart:267`
  - Problem: It is only a `GestureDetector`, so the value cannot be cleared with the keyboard. `PlColorPicker` has no Clear in its footer, so it has no way to be emptied with the keyboard at all.
  - Proposal: Replace it with a focusable interactive widget.
- [x] **149.** The calendar keyboard model and the date arithmetic have no tests (Test · Both · Medium)
- [ ] **150.** The range picker comments say the opposite of what the code does (Optimisation · Both · Low)
  - Location: `date-range-picker/PlDateRangePicker.tsx:170`, `date_range_picker/pl_date_range_picker.dart:267`
  - Problem: The comments say "a range with only one end is never passed", but the first click passes `{ start: day, end: null }`, and the tests expect that too.
  - Proposal: Correct the comments.
- [ ] **151.** The Flutter formula that builds the display samples is copied into four files (Optimisation · Flutter · Low)
  - Location: `date_picker/pl_date_picker.dart:55`, `date_range_picker/pl_date_range_picker.dart:18`, `date_time_picker/pl_date_time_picker.dart:18`, `time_picker/pl_time_picker.dart:19`
  - Problem: If only one copy changes, the trigger width differs from one component to another. React has a single `displaySamples`.
  - Proposal: Move it to `internal/date.dart`.
- [x] **152.** Choosing a day in `PlDateTimePicker` commits a moment outside `minDate`/`maxDate` (Bug · Both · High)
- [ ] **153.** The `::: fw react` in the date-time-picker docs is stuck to the end of a list line and breaks (Docs · Docs · Low)
  - Location: `docs/en/components/inputs/date-time-picker.md:157`(same in ko)
  - Problem: The container does not open, so `:::` shows as text, and the hidden input item is visible to Flutter readers too.
  - Proposal: Move `::: fw react` onto a line of its own, and fix the sentence about the time column together with item 145.
- [x] **154.** The files `PlFilePicker` submits with a form differ from the list on screen (Bug · React · High)
- [x] **155.** The field `label` of `PlFilePicker` is not included in the name of the drop zone button (Accessibility · Both · Medium)
- [x] **156.** The value input of Flutter `PlColorPicker` loses focus after every character (Bug · Flutter · High)
- [x] **157.** The hue and opacity rails ignore ↑/↓ and Home/End (Accessibility · Both · Medium)
- [x] **158.** The `label` and `error` of an `inline` colour picker are not connected to the panel (Accessibility · Both · Medium)
- [x] **159.** Flutter colour swatches do not receive keyboard focus (Accessibility · Flutter · Medium)
- [ ] **160.** A swatch that fails to parse remains as a button that does nothing when pressed (Bug · Both · Low)
  - Location: `PlColorPicker.tsx:498`, `:515`, `pl_color_picker.dart:943`
  - Problem: `swatches={['red']}` draws an active red button in React, but its clicks are ignored. In Flutter it becomes a transparent circle. React puts the raw string into the inline `backgroundColor`.
  - Proposal: Skip swatches that fail to parse, and paint with a colour built from the parsed value.
- [ ] **161.** A React inline colour picker can still be operated inside a disabled `fieldset` (Bug · React · Low)
  - Location: `PlColorPicker.tsx:318`, `:676`
  - Problem: The square and the rails are `div` elements with `tabIndex={0}`, so `<fieldset disabled>` does not affect them.
  - Proposal: Check whether the picker is inside a disabled fieldset, and merge that into the disabled state.
- [ ] **162.** The Flutter colour picker calculates the thumb position with the `md` size (Bug · Flutter · Low)
  - Location: `pl_color_picker.dart:832`
  - Problem: At `xs` and `xl`, the centre of the thumb is 2px off the value.
  - Proposal: Pass the actual thumb size.
- [x] **163.** Choosing an option with Enter in Flutter `PlCombobox` makes the input lose focus (Bug · Flutter · Medium)
- [ ] **164.** Flutter `PlCalendar` does not become disabled when there is no `onChanged` (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/calendar/pl_calendar.dart:206`, `:226`
  - Problem: The docs say the calendar is inert when `onChanged` is null, but its cells are read as active buttons and take focus and taps.
  - Proposal: Apply `ExcludeFocus` and `IgnorePointer`.
- [ ] **165.** The Accessibility section of the calendar docs promises React-only keys to Flutter as well (Docs · Both · Low)
  - Location: `docs/en/components/inputs/calendar.md:163`(same in ko), `internal/calendar.dart:845`, `:978`
  - Problem: `role="grid"` and moving by year with Shift+PageUp/PageDown are listed with no fw split, but Flutter does not handle them.
  - Proposal: Add the key handling to Flutter, and wrap the React-only items in `::: fw react`.
- [x] **166.** In Flutter `PlForm` `onSubmit` mode, errors remain after a failed submit even when the values are corrected (Bug · Flutter · Medium)
- [x] **167.** Flutter `PlFloatingActionButton` reads its name twice when `extended` (Accessibility · Flutter · Medium)
- [ ] **168.** The floating action button position ignores the device safe area (Accessibility · Both · Medium)
  - Location: `floating-action-button/PlFloatingActionButton.tsx:133`, `pl_floating_action_button.dart:148`
  - Problem: The offset is fixed at `1.5rem`/`24`, so on an edge-to-edge screen the button overlaps the navigation bar or the home indicator.
  - Proposal: Add `MediaQuery.paddingOf` in Flutter and `env(safe-area-inset-*)` in React.
  - Flag: Decision needed — decide whether the component or the caller is responsible for the safe area.
- [ ] **169.** The FAB docs promise props that Flutter does not have, and leave props it does have out of the table (Docs · Flutter · Low)
  - Location: `docs/en/components/inputs/floating-action-button.md:40`, `docs/.vitepress/data/props-flutter.ts:3121`
  - Problem: The docs say it "accepts everything PlButton accepts", but Flutter has no `readOnly`, `onLongPress`, `focusNode` or `autofocus`. The table is missing `color`, `loading` and `disabled`, which Flutter does have. The `corner` and `floating` examples exist only in TSX.
  - Proposal: Split the sentence with fw, add the three rows to the table, and add Dart examples.
- [ ] **170.** `PlButton` does not tell assistive technology when it changes to `loading` (Accessibility · Both · Low)
  - Location: `button/PlButton.tsx:256`, `button/pl_button.dart:546`
  - Problem: React only changes `aria-busy`, and the spinner is `aria-hidden`, so the start and the end of the work are not heard.
  - Proposal: While loading, announce it with hidden status text or a polite live region.
  - Flag: Decision needed — decide whether to add a new label key, and how to announce it.
- [ ] **171.** Flutter reads a `readOnly` checkbox as disabled (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/checkbox/pl_checkbox.dart:292`
  - Problem: Because of `enabled: _interactive`, a read-only checkbox that takes focus is announced as "disabled".
  - Proposal: Split it into `enabled: !_disabled` and `readOnly`.
- [ ] **172.** Disabled Flutter input fields stay in the Tab order and even draw a focus ring (Accessibility · Flutter · Low)
  - Location: `text_field/pl_text_field.dart:288`, `:394`, `number_field/pl_number_field.dart:540`, `otp_field/pl_otp_field.dart:395`
  - Problem: `disabled` is carried over only to `readOnly`, so keyboard users stop on disabled fields. This differs from the rule in React and in Flutter `PlButton`.
  - Proposal: Apply `ExcludeFocus` or `canRequestFocus: false` when `disabled`.
- [ ] **173.** The ko toggle page's `## size` is at a different level from `### size` in en, so the examples after it fall outside Examples (Docs · Docs · Low)
  - Location: `docs/ko/components/inputs/toggle.md:108`
  - Problem: The structure of the two locales does not match.
  - Proposal: Change it to `###` to match.
- [x] **174.** With `allowWheelScrub` in Flutter `PlNumberField`, the wheel moves both the value and the page (Bug · Flutter · Medium)
- [x] **175.** Flutter `PlNumberField` has two overlapping text field semantics nodes (Accessibility · Flutter · Medium)
- [x] **176.** In Flutter `PlNumberField`, the visible number and the value drift apart when the parent rejects a value (Bug · Flutter · Medium)
- [x] **177.** Holding a Flutter `PlNumberField` stepper calls `onCommitted` every 60ms, even after the limit is reached (Bug · Flutter · Medium)
- [ ] **178.** Every cell of React `PlOtpField` is read with the same name (Accessibility · React · Medium)
  - Location: `packages/react/src/components/otp-field/PlOtpField.tsx:332`
  - Problem: Every cell has the same `aria-labelledby`, so "Verification code" is read six times and the user cannot tell which cell they are on.
  - Proposal: Give each cell a name that states its position (together with the interpolation key in item 12).
- [ ] **179.** The otp-field docs' statement that "every cell has `autocomplete="one-time-code"`" is not true (Docs · Docs · Low)
  - Location: `docs/en/components/inputs/otp-field.md:191`(same in ko)
  - Problem: Base UI gives `one-time-code` only to the first cell, and the rest get `off`.
  - Proposal: Change "every cell" to "the first cell".
- [ ] **180.** A finding in Flutter `PlOtpField` (Security · Flutter · Medium)
  - Security finding. The details are kept out of this public file, in the local memory note `audit-security-items`. Decision needed.
- [ ] **181.** React `PlPagination` loses focus on the pressed button when the page changes (Accessibility · React · Medium)
  - Location: `packages/react/src/components/pagination/PlPagination.tsx:292-300`, `:350`, `:416`
  - Problem: When `getPageHref` is set, the pressed page changes from an `<a>` to a `<button>` and is mounted again. On the last page, Next becomes `disabled` and focus falls to `body`.
  - Proposal: Keep the same element type for the current page too, and use `focusableWhenDisabled` or `aria-disabled` on the steppers.
  - Flag: Decision needed — it is tied to the documented decision that "the current page is a `<button>`".
- [x] **182.** Flutter `PlPagination` does not mark the current page for screen readers (Accessibility · Flutter · Medium)
- [x] **183.** React `PlRadioGroup` `disabled` is not reflected in how the options look (Bug · React · Medium)
- [ ] **184.** Flutter `PlRating` drops to 0 when End is pressed at the top score (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/rating/pl_rating.dart:175`, `:272`, `:283`
  - Problem: With the default `clearable: true`, End is handled as "picking the same score again".
  - Proposal: Ignore Home/End when the value is already the same.
- [x] **185.** Flutter `PlSegmentedButton` does not measure the tile position again when its size changes (Bug · Flutter · Medium)
- [x] **186.** Flutter `PlSelect` trigger name leaves out the field `label` and reads the selected value twice (Accessibility · Flutter · Medium)
- [ ] **187.** `PlSelect` trigger always renders every option label to work out its width (Performance · Both · Medium)
  - Location: `select/PlSelect.tsx` (`sizerSamples`), `internal/sizer.tsx`, `pl_select.dart` (`_value`)
  - Done in `998d019d`: a `fullWidth` trigger renders no samples in either package.
  - Problem left: a trigger without `fullWidth` still renders every label, so a list of 250 countries with a flag in each still requests 250 images.
  - Proposal: Leave labels that are not strings out of the sample, or limit how many are sampled.
  - Flag: Decision needed — leaving them out lets such a trigger change width with its value, and a limit needs a number.
- [x] **188.** Flutter `PlSlider` cannot be adjusted with a screen reader (Accessibility · Flutter · High)
- [x] **189.** Tapping a Flutter `PlSlider` thumb moves the value by the thumb's radius (Bug · Flutter · Medium)
- [x] **190.** Flutter `PlSlider` rounds the value it reads out to an integer and ignores `formatValue` (Accessibility · Flutter · Medium) — no longer reproduces
- [x] **191.** React `PlSlider` has no way to give each thumb its own name and `aria-valuetext` (Accessibility · React · Medium)
- [ ] **192.** Pressing a `PlTransfer` move button loses focus and does not announce the result (Accessibility · Both · Medium)
  - Location: `transfer/PlTransfer.tsx:377-401`, `transfer/pl_transfer.dart:289-310`
  - Problem: After the move, the button that was just pressed becomes disabled, so focus is lost. The number of items moved is not announced.
  - Proposal: Move focus to the target list and announce the result at polite priority.
- [x] **193.** `PlTransfer` arrows point the wrong way in RTL (Bug · Both · Medium)
- [ ] **194.** The "Select all" checkboxes of the two `PlTransfer` lists have the same name (Accessibility · Both · Low)
  - Location: `PlTransfer.tsx:141`, `pl_transfer.dart:358`
  - Problem: By ear, there is no way to tell which list a checkbox belongs to.
  - Proposal: Add the panel title to the name.
- [ ] **195.** One tick in `PlTransfer` redraws every row of both lists (Performance · Both · Medium)
  - Location: `PlTransfer.tsx:181-192`, `:275`, `pl_transfer.dart:377-406`
  - Problem: Every row renders a `PlCheckbox` with no virtualisation, so in lists of thousands of items, input stalls on every tick.
  - Proposal: Wrap rows in `React.memo` and virtualise long lists (`ListView.builder` in Flutter).

### 6. Layout

- [x] **196.** A responsive slot set by a parent is inherited by nested children (Bug · React · High)
- [x] **197.** Flutter `PlGrid` throws when a cell contains a widget that uses `LayoutBuilder` (Bug · Flutter · High)
- [x] **198.** Flutter `PlScrollArea` and `PlScrollZone` cannot be scrolled with the keyboard (Accessibility · Flutter · Medium)
- [ ] **199.** The pointer drag path has no tests (Test · React · Low)
  - Location: `internal/drag.ts`, `test/components/scroll-zone/`, `panes/`, `sidebar/`
  - Problem: A regression in restoring the selection when unmounting during a drag, in `pointercancel`, or in `PlScrollZone` suppressing the click after a drag would go unnoticed.
  - Proposal: Verify the teardown and the click suppression with pointer events.
- [x] **200.** `PlHeader` and `PlFooter` inside the body take over the `PlPageLayout` slot registration (Bug · React · Medium)
- [ ] **201.** Nesting `PlPageLayout` duplicates `<main>`, `id="main"` and the skip link (Accessibility · React · Medium)
  - Location: `PlPageLayout.tsx:401`, `docs/en/components/layout/page-layout.md:176`
  - Problem: `height="auto"` is meant for a layout that is not the page, but used that way it creates a `<main>` inside a `<main>` and a second "Skip to content". The docs say the layout guarantees exactly one per page, and the docs demo also duplicates the id inside VitePress's `<main>`.
  - Proposal: When there is an outer layout, render a `div` and turn off the skip link, or fix the sentence in the docs.
  - Flag: Decision needed
- [x] **202.** Flutter `PlSidebar` resets the dragged width to the default on every parent rebuild (Bug · Flutter · High)
- [x] **203.** The focusable separator in React `PlSidebar` has no `aria-valuenow` (Accessibility · React · Medium)
- [ ] **204.** React `PlSidebar` drawer direction ignores `PlassProvider direction` (Bug · React · Low)
  - Location: `packages/react/src/internal/page-layout.ts:193-201`
  - Problem: It reads only the document's `direction`, so a collapsed start sidebar in an RTL subtree of an LTR document opens from the opposite side. Flutter follows the surrounding `Directionality`.
  - Proposal: Use the value from Base UI `useDirection()`.
- [x] **205.** React `PlPanes` handles have no way to take an accessible name (Accessibility · React · Medium)
- [x] **206.** In React `PlScrollZone`, an unfinished mouse drag makes the strip move on hover alone (Bug · React · Medium)
- [x] **207.** React `PlScrollZone` scroller is always a tab stop, even with nothing to scroll (Accessibility · React · Medium)
- [ ] **208.** React `PlScrollArea` scrolls horizontally with `orientation="vertical"` (Bug · React · Low)
  - Location: `scroll-area/PlScrollArea.tsx:176-190`
  - Problem: The Base UI viewport has `overflow: scroll` on both axes, so a `<pre>` or a long URL scrolls sideways with no scrollbar. Flutter scrolls vertically only.
  - Proposal: For a single axis, set `overflow-*-hidden` on the other axis.
- [x] **209.** `PlShow` docs say that descendants which portal out are hidden too (Docs · React · Medium)
- [ ] **210.** `PlShow` is always a `<div>`, which causes a hydration error in inline contexts (Bug · React · Low)
  - Location: `PlShow.tsx:67-76`
  - Problem: With SSR inside a `<p>`, the parser closes the `<p>` and causes a mismatch. There is no `render` prop to switch it to a `span`.
  - Proposal: Add a `render` prop based on `useRender`.
- [x] **211.** Passing `style` to `PlContainer` loses `maxWidth` (Bug · React · Medium)
- [ ] **212.** The size-tracking test for `usePlElementSize` does not verify tracking (Test · React · Low)
  - Location: `packages/react/test/hooks/usePlElementSize.test.tsx:49-57`
  - Problem: The second `render` mounts a new root, so the test passes even if ResizeObserver updates break.
  - Proposal: Change the style of one element, then poll the same output.

### 7. Navigation

- [ ] **213.** React `PlAnchor` follows only the window scroll, so no row becomes active inside a scroll container (Bug · React · Low)
  - Location: `packages/react/src/components/anchor/PlAnchor.tsx:88-93`, `:183-184`
  - Problem: In an app shell where `<main>` scrolls on its own, no row becomes active, and the hero demo reimplements the tracking itself. The demo's `href="#install"` points to an id that is not on the page.
  - Proposal: Accept a `target` as `PlBackTop` does and judge by that element's scroll, and have the demo use that prop.
  - Flag: Decision needed — it adds to the API.
- [x] **214.** Pressing a Flutter `PlAnchor` row ignores `offset` and the setting that turns animations off (Bug · Flutter · Medium)
- [x] **215.** Focus stays on a hidden button after React `PlBackTop` is pressed (Accessibility · React · Medium)
- [ ] **216.** Flutter `PlBackTop` never shows its button on desktop or desktop web when `controller` is left out (Bug · Flutter · Medium)
  - Location: `back_top/pl_back_top.dart:109`, `docs/en/components/navigation/back-top.md:47`
  - Problem: `PrimaryScrollController` is inherited automatically only on mobile platforms, so `hasClients` is always false. This default path has no test either.
  - Proposal: Document the limitation and point to `controller`, or add a debug assert.
  - Flag: Decision needed
- [ ] **217.** React `PlBackTop` `floating` position does not account for the safe area or bottom navigation (Accessibility · React · Low)
  - Location: `PlBackTop.tsx:173`
  - Problem: When used with `PlBottomNavigation`, it overlaps the last destination and sits over the iPhone home indicator.
  - Proposal: Add the safe-area value to `bottom`, and document how to use it with a bottom bar.
- [ ] **218.** The back-top page has no `## Accessibility` section, and its `label` tooltip description is wrong (Docs · Docs · Low)
  - Location: `docs/en/components/navigation/back-top.md:88` (same in ko)
  - Problem: It is the only component page without this section. `PlIconButton` does not set `title`, so no tooltip appears.
  - Proposal: Move the content into an Accessibility section and delete the tooltip sentence.
- [ ] **219.** Flutter `PlBottomNavigation` stops marking the current destination when `onChanged` is left out (Bug · Flutter · Low)
  - Location: `bottom_navigation/pl_bottom_navigation.dart:268`, `:282-294`
  - Problem: Every item becomes `unavailable`, so even the selected item is drawn without its background. The dartdoc says it "stops where it is".
  - Proposal: Keep the wash and the accent on the selected item, and apply only the dimming.
- [x] **220.** React `PlFloatingBottomNavigation` leaves the key under the previous disc when `value` matches no item (Bug · React · Medium)
- [x] **221.** React `PlCommandPalette` keeps the search text when it is closed by running a command or by the parent (Bug · React · Medium)
- [x] **222.** The keyboard run path of React `PlCommandPalette` has no tests (Test · React · Medium)
- [ ] **223.** React `PlCommandPalette` renders every filtered result without virtualisation (Performance · React · Low)
  - Location: `PlCommandPalette.tsx:336-393`
  - Problem: At around 2,000 commands, the first open and typing a short search become slow.
  - Proposal: Add a result cap (`limit`) or virtualisation.
  - Flag: Decision needed — whether to set a default cap has to be decided.
- [ ] **224.** Flutter `PlCommandPalette` row names are read twice (Accessibility · Flutter · Low)
  - Location: `command_palette/pl_command_palette.dart:549`, `:558`
  - Problem: The `Text` under `Semantics(label:)` is not excluded.
  - Proposal: Exclude the children, and put the description and the shortcut in the label or the hint.
- [ ] **225.** React `PlMenuItem` ignores `disabled` when it has `href` (Bug · React · Medium)
  - Location: `packages/react/src/components/menu/PlMenu.tsx:379-393`
  - Problem: The link branch does not pass `disabled`, so `<PlMenuItem href="/admin" disabled>` is drawn as enabled and navigates when pressed.
  - Proposal: When it is `disabled`, drop `href` and apply `aria-disabled` and the disabled style, or render a plain `Item`.
- [ ] **226.** Submenus open on the wrong side in RTL, and the chevron is not flipped (Bug · Both · Medium)
  - Location: `PlMenu.tsx:573`, `:592`, `menu/pl_menu.dart:824`, `:910`
  - Problem: `side` is fixed to the physical `right`, so in RTL a submenu opens to the right while the key that opens it is ArrowLeft. This differs from `rtl.md:62`, and Flutter `PlNavigationMenu` chooses the side by direction.
  - Proposal: Choose the side by direction, and apply the chevron rotation per direction too.
- [ ] **227.** The docs say disabled Flutter `PlMenu` rows can be found by typeahead, which does not match the code (Docs · Flutter · Low)
  - Location: `pl_menu.dart:97`, `:612`, `docs/en/components/navigation/menu.md:239`
  - Problem: `_typeahead` skips disabled rows. React finds them.
  - Proposal: Make the code match React, or fix the docs.
- [ ] **228.** Flutter `PlMenubar` claims the `menuBar` role but has no arrow-key movement (Accessibility · Flutter · Medium)
  - Location: `packages/flutter/lib/src/components/menubar/pl_menubar.dart:146-151`
  - Problem: On the web it is output as `role="menubar"`, so screen readers expect arrow-key operation. Instead, Tab stops on every word, and in an open menu the left and right keys only close it. This goes against the library principle of "not claiming a role without the behaviour".
  - Proposal: Implement roving focus and left and right movement, or remove the role until that is implemented.
  - Flag: Decision needed
- [ ] **229.** Links inside React `PlNavigationMenu` panels are not in the HTML until a panel is opened (SEO · React · Medium)
  - Location: `packages/react/src/components/navigation-menu/PlNavigationMenu.tsx:284-293`
  - Problem: `Content` has no `keepMounted`, so the links are missing from both the SSR output and the DOM after hydration, and crawlers that do not hover cannot find them. The docs (`navigation-menu.md:74`) promise that crawlers index them.
  - Proposal: Pass `keepMounted`, or fix the sentence in the docs.
  - Flag: Decision needed — it is a trade-off against DOM size.
- [ ] **230.** Top-level navigation links have no way to mark the current page (Accessibility · Both · Medium)
  - Location: `PlNavigationMenu.tsx:70-105`, `:260-270`, `PlNavigationMenuItem` in `navigation_menu/pl_navigation_menu.dart`
  - Problem: There is no `active` and no pass-through of other attributes, so `aria-current="page"` cannot be set. Flutter items have no `selected`.
  - Proposal: Add `active` (`selected` in Flutter) and connect it to `aria-current` and the styling.
- [ ] **231.** The `aria-labelledby` on React `PlStepper` horizontal panels is on a `div` with no role, so it is not read (Accessibility · React · Low)
  - Location: `packages/react/src/components/stepper/PlStepper.tsx:242-250`
  - Problem: A generic element cannot have a name, so the step name is not announced when focus enters the panel. The docs (`stepper.md:167`) say it is announced.
  - Proposal: Add `role="group"` as well.
- [ ] **232.** In vertical React `PlStepper`, a `status` override also changes which panel is shown (Bug · React · Low)
  - Location: `PlStepper.tsx:439`
  - Problem: The condition is `resolved === 'current'`, so giving a failed step `status="current"` opens two panels. The horizontal orientation and Flutter go by `active`.
  - Proposal: Base the condition on `index === active`.
- [ ] **233.** A `fixed` bottom bar covers the end of the page, with no way to reserve space and no guidance (Accessibility · React · Medium)
  - Location: `bottom-navigation/PlBottomNavigation.tsx:140-144`, `PlFloatingBottomNavigation.tsx:155-159`
  - Problem: The default is `position="fixed"`, so the last 56px or more is always covered. When Tab reaches the footer links, focus hides under the bar (WCAG 2.4.11).
  - Proposal: Add a `padding-bottom` and `scroll-padding-bottom` example to the docs, and expose the bar height as a CSS variable.
  - Flag: Decision needed — whether to add a token has to be decided.
- [ ] **234.** Nothing says that `safeArea` needs `viewport-fit=cover` to work (Docs · React · Low)
  - Location: `docs/en/components/navigation/bottom-navigation.md`, `floating-bottom-navigation.md:147`
  - Problem: Without this meta tag, `env(safe-area-inset-bottom)` is 0.
  - Proposal: Add the one meta line to the setup example.
- [ ] **235.** The floating-bottom-navigation page's Accessibility list shows React-only sentences to Flutter readers too (Docs · Docs · Low)
  - Location: `docs/en/components/navigation/floating-bottom-navigation.md:167-169` (same in ko)
  - Problem: The sentences about `<nav>`, `aria-current` and the clipped box are outside `::: fw react`. React has no default `label` either, so "it has a name" is true only when the caller provides one.
  - Proposal: Move them into a React block, and add a Flutter block and guidance on `label`.

### 8. Surfaces

- [ ] **236.** `PlSpoiler` and `PlWindowPane` lose focus when the pressed button is hidden (Accessibility · Both · Medium)
  - Location: `packages/react/src/components/spoiler/PlSpoiler.tsx:262`, `:305`, `spoiler/pl_spoiler.dart:291`, `:348`, `window-pane/PlWindowPane.tsx:777`
  - Problem: When Reveal, Hide or close is pressed from the keyboard, that button immediately becomes `inert`/`invisible` (`ExcludeFocus` in Flutter), and focus falls to body.
  - Proposal: On reveal, move focus to the content or the Hide button. On hide, move it to the Reveal button.
- [x] **237.** React `PlCarousel` scrolls the whole page every time it moves to another slide (Bug · React · High)
- [ ] **238.** Carousel `autoPlay` has no stop control, and its pause is released too easily (Accessibility · Both · Medium)
  - Location: `PlCarousel.tsx:293`, `carousel/pl_carousel.dart:311`
  - Problem: There is no stop button, which WCAG 2.2.2 and the APG carousel pattern require. Hover and focus share one flag, so a mouse passing over it starts playback again even while keyboard focus is inside. Flutter does not stop on focus at all.
  - Proposal: Add a stop/play button, stay stopped once focus enters until playback is started explicitly, and separate the two flags.
  - Flag: Decision needed — the button placement and the restart rule have to be decided.
- [ ] **239.** Carousel `autoPlay` does not advance when the parent redraws often (Bug · Both · Medium)
  - Location: `PlCarousel.tsx:278`, `pl_carousel.dart:202`
  - Problem: In React, `go` in the effect dependencies changes along with an inline `onValueChange`. Flutter restarts on every `didUpdateWidget`. Inside a parent that updates every second, a 5-second interval therefore never completes.
  - Proposal: In React, read `go` through a ref. In Flutter, restart only when the relevant values change.
- [ ] **240.** Carousel dot indicators have a hit area of 4–8px (Accessibility · Both · Medium)
  - Location: `PlCarousel.tsx:92`, `pl_carousel.dart:412`
  - Problem: This falls short of WCAG 2.5.8, and with `arrows={false}` it is hard to go to a specific slide on a phone.
  - Proposal: Keep the visible dots as they are and enlarge only the hit area to 24px or more.
- [ ] **241.** No tests for carousel `autoPlay` (Test · React · Medium)
  - Location: `packages/react/test/components/carousel/PlCarousel.test.tsx`
  - Problem: The tests do not check the pause on hover and focus, reduced motion, `document.hidden` or page scrolling, so the defects in items 237 and 239 got through.
  - Proposal: Use fake timers to check advancing, pausing, and that `window.scrollY` does not change.
- [ ] **242.** The carousel slide wrapper is keyed by index, so inserting a slide at the front remounts every slide (Bug · React · Low)
  - Location: `PlCarousel.tsx:329`
  - Problem: Contrary to the comment on line 164, the key is `key={slideIndex}`, so state such as a video's is reset.
  - Proposal: Use `slide.key ?? slideIndex`.
- [ ] **243.** The carousel docs item "it needs somewhere to report the move" does not match React's behaviour (Docs · Docs · Low)
  - Location: `docs/en/components/surfaces/carousel.md:121` (same in ko)
  - Problem: React still moves, uncontrolled, without `onValueChange`.
  - Proposal: Move the item inside a `::: fw flutter` block.
- [ ] **244.** In React `PlTabs`, a `PlTabPanel` inside a Fragment or a wrapper renders inside the tablist (Bug · React · Medium)
  - Location: `packages/react/src/components/tabs/PlTabs.tsx:501`
  - Problem: `Children.forEach` does not unwrap Fragments and only compares `child.type === PlTabPanel`. With `items.map(i => <Fragment><PlTab/><PlTabPanel/></Fragment>)`, the panel is clipped inside the `role="tablist"` strip.
  - Proposal: Unwrap Fragments recursively. State in the docs and in a dev warning that wrappers cannot be detected.
- [ ] **245.** In an overflowing tab bar, the initially selected tab is off screen (Bug · Both · Low)
  - Location: `PlTabs.tsx:527`, `tabs/pl_tabs.dart:384`
  - Problem: On a narrow screen, if `defaultValue` is the 8th tab, the reader cannot see which tab is selected.
  - Proposal: On the first selection and on every change, scroll only the strip to that tab.
- [ ] **246.** The tabs docs difference table wrongly says "every panel renders and only one is visible" (Docs · Docs · Low)
  - Location: `docs/en/components/surfaces/tabs.md:287` (same in ko)
  - Problem: React `PlTabPanel` defaults `keepMounted` to false, so closed panels are not rendered.
  - Proposal: Delete the row, or rewrite it as a difference in `keepMounted`.
- [ ] **247.** With the defaults, closed content of React `PlAccordion` and `PlCollapsible` is not in the HTML (SEO · React · Medium)
  - Location: `accordion/PlAccordion.tsx:215`, `collapsible/PlCollapsible.tsx:155`
  - Problem: `hiddenUntilFound` and `keepMounted` are both false, so FAQ answers are missing from the server HTML and from find-in-page. The accordion docs cover this prop in a single Accessibility line.
  - Proposal: Consider changing the default of `hiddenUntilFound` to true. At the least, add an example section.
  - Flag: Decision needed, Breaking change — DOM size and behaviour change.
- [ ] **248.** React `PlAccordion` headers are always `<h3>` (Accessibility · React · Medium)
  - Location: `PlAccordion.tsx:309`
  - Problem: An FAQ placed directly under an `h1` makes the heading structure skip `h2`. The APG requires a level that fits the page.
  - Proposal: Expose a `headingLevel` prop or the Header's `render`.
  - Flag: Decision needed — the shape of the API has to be chosen.
- [ ] **249.** Flutter `PlAccordion` headers have no heading semantics (Accessibility · Flutter · Low)
  - Location: `accordion/pl_accordion.dart:420`
  - Problem: The headers do not appear in screen reader heading navigation.
  - Proposal: Add `header: true`.
- [ ] **250.** When Flutter `PlAccordion` collapses, the content disappears at once and only the empty space shrinks (Bug · Flutter · Low)
  - Location: `pl_accordion.dart:446`
  - Problem: The moment `open` becomes false, the child is replaced with a `SizedBox`. React and `PlCollapsible` clip the content as they close.
  - Proposal: Use `PlassFold`, and keep the content until the animation ends.
- [ ] **251.** The accordion `action` is described as "before the chevron", the opposite of where it is placed (Docs · Both · Low)
  - Location: `PlAccordion.tsx:113`, `pl_accordion.dart:110`, `docs/.vitepress/data/props.ts:826`
  - Problem: `action` is attached at the end, outside the trigger, so it sits after the chevron.
  - Proposal: Change the description to "after the chevron, at the end of the header".
- [ ] **252.** Flutter `PlCollapsible` loses the panel State on every close, even with `keepMounted` (Bug · Flutter · Medium)
  - Location: `collapsible/pl_collapsible.dart:295`
  - Problem: The child is wrapped in `ExcludeSemantics(ExcludeFocus(...))` only while closed, so the child type changes and entered values are lost. The test only covers a panel that starts closed.
  - Proposal: Always wrap the child and toggle the wrappers with `excluding: !open`. Add a test that opens, types, closes and opens again.
- [ ] **253.** `PlCollapsible` lacks `PlAccordion`'s title wrap option and the space above the body (Bug · Both · Low)
  - Location: `PlCollapsible.tsx:223`, `:278`, `pl_collapsible.dart:281`, `:381`
  - Problem: The title is always cut to one line, and with the default header there is no space above the body. A comment in the same file (line 97) says the space is needed.
  - Proposal: Match the accordion, or leave a comment explaining why the two differ.
  - Flag: Decision needed — someone has to judge whether the difference is intended.
- [ ] **254.** Flutter `PlCard` remounts all of its content when hover starts and ends (Bug · Flutter · Medium)
  - Location: `card/pl_card.dart:225`, `:229`
  - Problem: `dy == 0 ? child : Transform.translate(...)` changes the widget type. A chart's entry animation or a fade-in image inside the card replays on every hover, and the shadow transition is cut off.
  - Proposal: Always keep `Transform.translate` and `CustomPaint` in the tree, and change only their values.
- [ ] **255.** Flutter `PlCard` does not lift when only `interactive` is set (Bug · Flutter · Medium)
  - Location: `pl_card.dart:155`
  - Problem: Without `onPressed`, the card does not track hover. The docs say it gives the same lift.
  - Proposal: When `interactive` is set, track hover alone with a `MouseRegion`, and add a test.
- [ ] **256.** The whole-card link pattern that the React `PlCard` docs recommend creates nested interactive elements (Accessibility · React · Medium)
  - Location: `card/PlCard.tsx:73`, `docs/en/components/surfaces/card.md:161`
  - Problem: Using `render={<a>}` together with `footer={<PlButton>}` or `headerAction` produces `<a><button>`. An `<h2>` inside a `<button>` is invalid, and the accessible name becomes the whole text of the card.
  - Proposal: When a slot holds a control, document the pattern that stretches the title link with `::after`, or add a dedicated prop.
  - Flag: Decision needed
- [ ] **257.** The React `PlCard` `interactive` lift still moves under reduced motion (Accessibility · React · Low)
  - Location: `PlCard.tsx:113`
  - Problem: `hover:-translate-y-0.5` has no `motion-reduce` handling. Flutter handles it.
  - Proposal: Use a `motion-reduce:` variant to set the transition to 0.
- [ ] **258.** A finding in React `PlChatBubble` (Security · React · Medium)
  - Security finding. The details are kept out of this public file, in the local memory note `audit-security-items`.
- [ ] **259.** The ko chat-bubble page was not updated after the Flutter port (Docs · Docs · Medium)
  - Location: `docs/ko/components/surfaces/chat-bubble.md:12`
  - Problem: The page is missing the hero's `::: fw` blocks and Flutter snippet, the fw paragraph under Props, and the per-framework paragraphs for media and actions. A reader who chose Flutter sees React code and wrong descriptions.
  - Proposal: Restore the page to match the en structure.
- [ ] **260.** React `PlChatBubble` loads every preview image immediately (Performance · React · Low)
  - Location: `PlChatBubble.tsx:490`
  - Problem: In a long conversation with many link cards, it requests images that are off screen too.
  - Proposal: Add `loading="lazy"` and `decoding="async"`.
- [ ] **261.** Flutter `PlChatBubble` typing dots stop under reduced motion (Bug · Flutter · Low)
  - Location: `chat_bubble/pl_chat_bubble.dart:486`
  - Problem: React only slows the dots down, because stopping them would reverse their meaning. Flutter calls `stop()`.
  - Proposal: Only lengthen the duration.
- [ ] **262.** Flutter `PlSpoiler` resets the child's State when the cover is removed (Bug · Flutter · Medium)
  - Location: `spoiler/pl_spoiler.dart:196`
  - Problem: The child is wrapped in several widgets only while hidden, so the shape of the tree changes.
  - Proposal: Use the `excluding:`, `ignoring:` and `enabled:` arguments so the tree has the same shape in both states.
- [ ] **263.** The button that opens and closes `PlPill`'s `details` has no expanded state (Accessibility · Both · Medium)
  - Location: `pill/PlPill.tsx:349`, `pill/pl_pill.dart:291`
  - Problem: There is no `aria-expanded` or `expanded`. In React, `...props` goes to the outer div, so a consumer has no way to set it on the button either.
  - Proposal: When `details` is present, add `aria-expanded` and `aria-controls` in React, and `expanded` in Flutter.
- [ ] **264.** In Flutter `PlPill`, pressing the expanded `details` or the `endIcon` also calls `onPressed` (Bug · Flutter · Medium)
  - Location: `pl_pill.dart:241`
  - Problem: The press area is the whole pill, so in the demo, pressing the text inside `details` collapses it at once. In React, only the centre button responds.
  - Proposal: Limit the press area to the centre row.
- [ ] **265.** React `PlPill` recreates its `ResizeObserver` on every render (Performance · React · Low)
  - Location: `PlPill.tsx:268`
  - Problem: Inline JSX `details` is an effect dependency. For a pill that updates every second, disconnect, observe and setState repeat every second.
  - Proposal: Change the dependency to `hasContent(details)`, and take the first measurement in a layout effect.
- [ ] **266.** The `list-none` `<ol>` in React `PlHowToSteps` has no `role="list"` (Accessibility · React · Medium)
  - Location: `packages/react/src/components/how-to-steps/PlHowToSteps.tsx:176`
  - Problem: Safari and VoiceOver remove the semantics of a list whose list-style is removed. The number discs are also `aria-hidden`, so the order is not announced. `PlStepper.tsx:232` already sets the role.
  - Proposal: Add `role="list"`.
- [ ] **267.** A React `PlHoverCard` comment describes an `aria-describedby` link that does not exist (Optimisation · React · Low)
  - Location: `hover-card/PlHoverCard.tsx:41`, `:153`
  - Problem: Base UI `PreviewCard` does not add describedby.
  - Proposal: Make the comment match the actual behaviour.
- [x] **268.** When a controlled Flutter `PlWindowPane` passes `offset` back, the window runs away faster than the pointer (Bug · Flutter · High)
- [ ] **269.** The React props table for `PlWindowPane` is missing the state callbacks and label props (Docs · Docs · Medium)
  - Location: `docs/.vitepress/data/props.ts:14926`
  - Problem: There are no rows for `defaultOpen`, `onOpenChange`, `defaultMinimized`, `onMinimizedChange`, `defaultMaximized`, `onMaximizedChange`, `maximizeLabel`, `restoreLabel` and `closeLabel`.
  - Proposal: Add the missing rows.
- [ ] **270.** Moving a `PlWindowPane` has no keyboard or single-pointer alternative (Accessibility · Both · Low)
  - Location: `PlWindowPane.tsx:679`, `pl_window_pane.dart:513`
  - Problem: Resizing works with the arrow keys, but a `draggable` pane moves only by dragging (WCAG 2.5.7).
  - Proposal: Add a focusable move handle, or document how to build an alternative with `offset` control.
  - Flag: Decision needed — how much a decorative frame should provide has to be decided.
- [ ] **271.** Minimising a Flutter `PlWindowPane` removes the body from the tree (Bug · Flutter · Low)
  - Location: `pl_window_pane.dart:286`
  - Problem: The docs for both packages (`window-pane.md:125`) say the body stays in the tree as inert. Flutter unmounts it, so its state is lost on restore.
  - Proposal: Keep the body in the tree, wrapped in `ExcludeFocus` and `ExcludeSemantics`, or split the docs with fw.
- [ ] **272.** A `PlWindowPane` comment gives the wrong number of OSes (Optimisation · React · Low)
  - Location: `PlWindowPane.tsx:236`
  - Problem: `PlWindowOs` has eight values, but the comment says "one of four systems" and "on all four".
  - Proposal: Correct the numbers.

### 9. Transitions

- [ ] **273.** With `trigger="hover"`, the caller's pointer and focus handlers are lost, or the hover trigger stops working (Bug · React · Medium)
  - Location: `packages/react/src/components/animate-fade/PlAnimateFade.tsx:106-109` (same in Blink, Grow, Rotate, Slide, Reveal, Zoom, Float, Shake, Lighting, Appear, Split), `animate-marquee/PlAnimateMarquee.tsx:204`, `animate-headline/PlAnimateHeadline.tsx:203`, `animate-typing/PlAnimateTyping.tsx:287`, `animate-counter/PlAnimateCounter.tsx:197`, `animate-scramble/PlAnimateScramble.tsx:175`
  - Problem: The first 11 spread `run.handlers` after `...props`, so `onPointerEnter={prefetch}` is never called. The other 5 use the opposite order, so when the caller passes `onFocus`, the hover trigger no longer starts on focus.
  - Proposal: Combine the handlers with `mergeProps` so both are called.
- [ ] **274.** Restarting an animation also rewinds other `PlAnimate*` components nested inside it (Bug · React · Medium)
  - Location: `packages/react/src/internal/animate.ts:326-339`
  - Problem: `querySelectorAll('.plass-anim, .plass-marquee-track')` matches the whole subtree. An error message in a `PlAnimateFade` that has already appeared inside `<PlAnimateShake replay>` fades in again from transparent on every shake.
  - Proposal: Mark the elements each instance attached itself with a data attribute, and rewind only those.
- [ ] **275.** The JS-driven Counter, Scramble and Typing do not replay from the second hover with `trigger="hover"` (Bug · React · Medium)
  - Location: `internal/animate.ts:405-423`, `PlAnimateScramble.tsx:168`, `PlAnimateCounter.tsx:188`, `PlAnimateTyping.tsx:270`
  - Problem: A hover only increments the `run` counter, and the effect only reads `run.started`, which is already `true`. `<PlAnimateScramble trigger="hover">Menu</PlAnimateScramble>` scrambles on the first hover only. Flutter replays every time.
  - Proposal: Have `useAnimationRun` return the `run` value, and add it to the dependencies of the three effects.
- [ ] **276.** Counter and Scramble start over instead of continuing when `paused` is released (Bug · React · Medium)
  - Location: `PlAnimateCounter.tsx:160-187`, `PlAnimateScramble.tsx:138-167`
  - Problem: On resume, the start time is taken again, so the number drops back to `from`. The animation also returns to the beginning if the parent passes an inline `easing` while it counts. The docs say it stops in place, and Flutter continues.
  - Proposal: Keep the progress in a ref and work the start time back from it on resume. Read `easing` through a ref as well.
- [ ] **277.** Flutter `trigger: hover` adds an unnamed Tab stop (Accessibility · Flutter · Medium)
  - Location: `packages/flutter/lib/src/internal/animate.dart:338-345`
  - Problem: Because of the `FocusableActionDetector` defaults, every decorative image with a hover animation gets an invisible tab stop, and screen readers read an unnamed node. React does not add a `tabIndex`.
  - Proposal: Combine `MouseRegion` with `Focus(canRequestFocus: false, skipTraversal: true, onFocusChange:)` so that only focus from descendants is received.
- [ ] **278.** Flutter `trigger: visible` only watches the nearest `Scrollable` (Bug · Flutter · Medium)
  - Location: `internal/animate.dart:262-275`, `:293-305`
  - Problem: A `PlAnimateCounter` in a horizontal scroll row near the bottom of a vertical page is visible by the horizontal viewport, so it starts counting on the first frame. React's `IntersectionObserver` measures against the document viewport.
  - Proposal: Subscribe to every ancestor `Scrollable`, and start when the element overlaps all of the viewports.
- [ ] **279.** The `PlAnimateHeadline` timer is reset on every parent render, so the line may never advance (Bug · Both · Medium)
  - Location: `PlAnimateHeadline.tsx:127-178`, `animate_headline/pl_animate_headline.dart:217-231`
  - Problem: In React, `advance` depends on an inline `onIndexChange`. In Flutter, `didUpdateWidget` calls `_schedule()` unconditionally. Under a parent that renders every second, the 2600ms timer never finishes.
  - Proposal: Store the time of the next change, and reset the timer only when index, interval or running changes.
- [ ] **280.** No guidance that an effect moving for more than 5 seconds needs a way to stop it (Accessibility · Docs · Medium)
  - Location: Accessibility sections of `docs/{en,ko}/components/transitions/animate-blink.md`, `animate-float.md`, `animate-lighting.md`, `animate-rotate.md`, `animate-headline.md`, `animate-typing.md`, `animate-marquee.md`
  - Problem: Effects that loop forever by default start on their own, but nothing tells the caller to put a stop control on the page, which WCAG 2.2.2 requires. `prefers-reduced-motion` does not replace that control.
  - Proposal: Add an item and an example saying "if it runs for more than 5 seconds, add a stop control and connect it to `paused`".
- [ ] **281.** 20 files in the transitions docs have unpaired code fences that render empty code blocks (Docs · Docs · Medium)
  - Location: appear, blink, grow, headline, lighting, marquee, rotate, slide, typing and zoom in `docs/{en,ko}/components/transitions/`
  - Problem: Each file has one extra ` ``` ` line after the Flutter quick-start block and another at the end of the file. All 20 files were checked with a script, and the build output contains an empty `<pre>` with `tabindex="0"`. Prettier also treats the text between the two lines as code, so it does not align the difference table.
  - Proposal: Delete the two lines.
- [ ] **282.** Under reduced motion, an animation falls to its start state instead of its end state (Bug · Both · Low)
  - Location: `packages/react/src/styles.css:2424-2429`, `internal/animate.dart:527-529`
  - Problem: React `<PlAnimateRotate from={0} to={90}>` shows 0deg, and Flutter shows 90°. With `mode="out"`, the element does not disappear in either package. In React, `animationend` never fires, so a caller that unmounts on that event gets stuck.
  - Proposal: Decide whether to apply the end frame statically under reduced motion or to keep the current behaviour.
  - Flag: Decision needed — the docs state that an exit is "not a way to hide", so there are two possible directions.
- [ ] **283.** The sr-only copy in text effects makes copied text appear twice (Accessibility · React · Low)
  - Location: `animate-split/PlAnimateSplit.tsx:156-157` (same in Scramble, Counter, Typing), `docs/{en,ko}/components/transitions/animate-split.md`
  - Problem: The selection becomes "Internationalization is longInternationalization is long". The docs say that copying gives the whole line.
  - Proposal: Set `user-select: none` on one of the copies, and fix the docs.
- [ ] **284.** Default values and rows in the transitions props tables do not match the code (Docs · Docs · Low)
  - Location: `docs/.vitepress/data/props.ts:1554`, `:1641`, `props-flutter.ts:223`, `:312`, `:505`, `:574`
  - Problem: The Shake `trigger` default is listed as `'mount'`, but it is actually `manual`. React Split's `stagger` default is `40`, not `0`, and its `mode` row is missing. Flutter Split, Shake and Float have `repeat`/`alternate` rows for props they do not have.
  - Proposal: Pass default overrides and `omit` to `animateProps`/`animateFlutterProps` to make the tables match.
- [ ] **285.** With a `PlAnimateMarquee` `speed` of 0 or less, Flutter throws and React renders a stopped strip (Bug · Both · Low)
  - Location: `animate_marquee/pl_animate_marquee.dart:174`, `PlAnimateMarquee.tsx:160`
  - Problem: In Flutter, `double.infinity.round()` throws an exception. In React, `Infinityms` is an invalid value.
  - Proposal: Treat `speed <= 0` like `paused`, or set a lower bound.
- [ ] **286.** The transitions bugs above have no regression tests (Test · Both · Low)
  - Location: `packages/react/test/components/animate-*/`, `packages/react/test/hooks/`, `packages/flutter/test/components/animate_typing/pl_animate_typing_test.dart:176`
  - Problem: Nothing tests hover replay of the JS effects, resuming from `paused`, handler merging, nested rewinding, storage exceptions or `storageKey` escaping. The Typing test for unwrapping elements only passes an array of strings. The Flutter reduced motion test uses `caret: false`, so it avoids the exception in item 295.
  - Proposal: Add each case in the same commit as its fix.
- [ ] **287.** Tab reaches links and buttons inside the hidden copies of `PlAnimateMarquee` (Accessibility · Both · Medium)
  - Location: `PlAnimateMarquee.tsx:162-171`, `pl_animate_marquee.dart:242-246`
  - Problem: `aria-hidden`/`ExcludeSemantics` does not block focus. On a strip of 10 chip links, a keyboard user passes through 30 stops, and in the copies focus lands on elements with no name.
  - Proposal: Give the copies `inert` in React (the helper from item 1) and `ExcludeFocus` in Flutter.
- [ ] **288.** Under reduced motion there is no way to see `PlAnimateMarquee` items outside the box, but the docs say they can be reached (Accessibility · Both · Medium)
  - Location: `packages/react/src/styles.css:1715-1719`, `pl_animate_marquee.dart:198`, `:215-220`, `docs/{en,ko}/components/transitions/animate-marquee.md`
  - Problem: The track stops, but the box keeps `overflow: hidden`. With 10 headlines in a 400px box, only the first one or two are visible.
  - Proposal: Under reduced motion, allow horizontal scrolling or wrapping, and draw only one copy.
- [ ] **289.** `PlAnimateMarquee` forces a layout and reconnects its `ResizeObserver` on every parent render (Performance · React · Low)
  - Location: `PlAnimateMarquee.tsx:127-155`
  - Problem: `children` in the dependencies is a new reference on every render.
  - Proposal: Remove `children` from the dependencies.
- [ ] **290.** `PlAnimateSplit` with `effect="slide"` does not move, and `zoom` is the same as `grow` (Bug · React · Medium)
  - Location: `PlAnimateSplit.tsx:137-139`
  - Problem: No `x`/`y`/`scale` is set in the slots, so the effects run on the keyframe defaults. The hero demo's `effect="slide"` also shows only a fade.
  - Proposal: For each effect, fill in the default start values of the matching component.
- [ ] **291.** `PlAnimateSplit` `by="character"` breaks lines in the middle of a word (Bug · Both · Medium)
  - Location: `PlAnimateSplit.tsx:173-175`, `animate_split/pl_animate_split.dart:133-139`
  - Problem: An atomic inline always has a line break opportunity before and after it, so at 120px wide the word breaks as "Internationali / zation". Flutter's per-character `Wrap` does the same.
  - Proposal: Wrap the characters of each word once more in a `whitespace-nowrap` inline-block (a `Row` per word in Flutter).
- [ ] **292.** Flutter character splitting and scramble cut text by UTF-16 code units, which breaks emoji (Bug · Flutter · Medium)
  - Location: `packages/flutter/lib/src/internal/scramble.dart:20`, `:41-42`, `:89`
  - Problem: `split('')` splits surrogate pairs, so the rocket in `'Ship it 🚀'` stays a broken glyph even after the animation ends.
  - Proposal: Split by `characters` (graphemes), or at least by `runes`.
- [ ] **293.** `PlAnimateTyping` drops the text of elements in its children, but the docs say the opposite (Bug · React · Medium)
  - Location: `PlAnimateTyping.tsx:55-65`, `:101-103`, `docs/{en,ko}/components/transitions/animate-typing.md`, `docs/public/llms.txt:217`
  - Problem: `Ship <strong>faster</strong>` leaves only "Ship ", both on screen and in the sr-only copy.
  - Proposal: Unwrap the children of elements recursively, or fix the docs and the JSDoc.
- [ ] **294.** `PlAnimateTyping` grows while typing and pushes the content around it, but the docs say there is no reflow (Bug · React · Medium)
  - Location: `PlAnimateTyping.tsx:290-294`, the lede and Accessibility section of `animate-typing.md`, `llms.txt:217`
  - Problem: The visible span holds only the characters that have arrived. A two-line phrase pushes the content below it down when the second line starts (CLS), and the span is empty in SSR too. Flutter lays the whole string underneath, transparent, to reserve the space.
  - Proposal: Draw the remaining characters as well, in a `visibility: hidden` span.
- [ ] **295.** Flutter `PlAnimateTyping` throws a debug exception when it disposes the caret under reduced motion (Bug · Flutter · Medium)
  - Location: `animate_typing/pl_animate_typing.dart:390`, `:395`, `:401`
  - Problem: The build does not read `_blink`, so `dispose` creates the `late final` controller for the first time, and `TickerMode.getNotifier` throws on an inactive element. With the default `caret: true`, this happens every time the widget leaves the screen.
  - Proposal: Create the controller in `initState`, and do not call `repeat()` under reduced motion.
- [ ] **296.** `PlAnimateTyping` does not retype a new string that has the same number of characters (Bug · React · Low)
  - Location: `PlAnimateTyping.tsx:169-171`, `:270`
  - Problem: The reset depends only on `total`, so when "design" changes to "deploy", the new text appears all at once. Flutter starts over.
  - Proposal: Add the source text to the dependencies.
- [ ] **297.** `PlAnimateHeadline`'s `repeat` has no effect but is documented as a setting shared by both packages (Optimisation · Both · Low)
  - Location: `PlAnimateHeadline.tsx:71`, `:96`, `docs/.vitepress/data/props.ts:1241`
  - Problem: Only `loop` decides whether the animation repeats.
  - Proposal: Remove `repeat` with `Omit` and drop it from the table.
  - Flag: Breaking change — it removes a public prop.
- [ ] **298.** `PlAnimateSlide` with `trigger="visible"` does not start inside an `overflow: hidden` box (Bug · React · Medium)
  - Location: `internal/animate.ts:356-371`, `animate-slide/PlAnimateSlide.tsx:84`, `:94`
  - Problem: While it waits, `translate: 0 100%` is already applied, so `IntersectionObserver` sees a box clipped by an ancestor's overflow and keeps reporting false. The documentation recommends this box. Flutter works correctly.
  - Proposal: Observe the parent or an untransformed sentinel instead of the element.
- [ ] **299.** `PlAnimateLighting` ignores `easing` (Bug · React · Low)
  - Location: `packages/react/src/styles.css:1681`
  - Problem: `linear` is fixed on `::before`. Flutter follows `curve`.
  - Proposal: Change it to `var(--p-anim-ease, linear)`.
- [ ] **300.** A hover or `play` restart does not rewind `PlAnimateLighting` when `repeat` is finite (Bug · React · Low)
  - Location: `internal/animate.ts:326-339`
  - Problem: The inline `animationName = 'none'` applies only to the root and does not reach `::before`.
  - Proposal: Toggle a rewind attribute on the root that turns the `animation-name` of `::before` off and on again.
- [ ] **301.** `PlAnimateCounter` creates a new `Intl.NumberFormat` on every frame when given an inline `format` (Performance · React · Low)
  - Location: `PlAnimateCounter.tsx:135-138`, `docs/.vitepress/demos/animate-counter/hero.tsx:14`
  - Problem: While it renders at 60fps, the object reference changes every time, which breaks the memo. The hero demo also uses it this way.
  - Proposal: Memoise on a key built by serialising the options, or pin the first value in a ref.
- [ ] **302.** `PlAnimateScramble` mixes halves of surrogate pairs into its noise, so broken glyphs flicker (Bug · React · Low)
  - Location: `packages/react/src/internal/scramble.ts:60`
  - Problem: The pool is collected by code point but indexed by code unit.
  - Proposal: Index into the array that `Array.from(pool)` returns.
- [ ] **303.** `PlAnimateFloat`'s string `distance` does not work with `calc()`, `var()` or negative values (Bug · React · Low)
  - Location: `animate-float/PlAnimateFloat.tsx:92-94`
  - Problem: The sign is put in front of the value, which produces `-calc(...)` and `--8px`.
  - Proposal: Use the `calc(-1 * …)` approach from `slideOffsets`.

### 10. Docs, repository and site

- [ ] **304.** The root `README.md` component list is missing 17 components (Docs · Docs · Medium)
  - Location: `README.md:130-160`
  - Problem: `PlAppLogo`, `PlDataList`, `PlDataTable`, `PlMeter`, `PlTour`, `PlFloatingActionButton`, `PlFlex`, `PlPortal`, `PlScrollArea`, `PlAnchor`, `PlHoverCard`, `PlHowToSteps`, `PlAnimateCounter`, `PlAnimateFloat`, `PlAnimateScramble`, `PlAnimateShake` and `PlAnimateSplit` are missing, and the React-only mark † appears only on `PlVisuallyHidden`.
  - Proposal: Match the list to `docs/en/components/<group>/`, and add † to `PlFlex` and `PlPortal`.
- [ ] **305.** The `README.md` Hooks table does not match the hooks that are actually exported (Docs · Docs · Medium)
  - Location: `README.md:180-191`
  - Problem: `usePlDisclosure`, `usePlElementSize` and `usePlOnScreen` are missing, and the table includes `usePlassDefaults` and `usePlToast`, which are not in `plass-ui/hooks`.
  - Proposal: Match it to `src/hooks/index.ts`, and give the import path of the other two separately.
- [ ] **306.** Following the instruction to "run `npm run flutter:demos` again" does not rebuild the Flutter previews (Docs · Docs · Medium)
  - Location: `README.md:224`, `CLAUDE.md:72`, `:395`, `docs/scripts/build-flutter-demos.mjs:34`
  - Problem: When `public/flutter/version.json` exists, the script does nothing without `--force`.
  - Proposal: Change the three places to `npm run flutter:demos -- --force`, and state that `npm run build` reuses the existing build.
- [ ] **307.** `packages/react/README.md` gives the wrong component count and the wrong runtime dependency count (Docs · Docs · Medium)
  - Location: `packages/react/README.md:25`, `:52`, `:97`
  - Problem: "all 74 components" appears twice, but the real count is 130. It says "a single runtime dependency", but there are two: `@base-ui/react` and `highlight.js`. The npm page shows this text as it is.
  - Proposal: Change them to 130 and "two runtime dependencies".
- [ ] **308.** The `packages/react/README.md` component list has only 75 components and no Charts group (Docs · Docs · Medium)
  - Location: `packages/react/README.md:117-147`
  - Problem: 55 components are missing. The `CLAUDE.md` checklist names only the root README list as something to update, so the two lists keep drifting apart.
  - Proposal: Match it to the root list and add it to the checklist, or remove the list and link to the documentation site instead.
  - Flag: Decision needed
- [ ] **309.** The second example in `packages/flutter/README.md` does not compile with only the import above it (Docs · Docs · Low)
  - Location: `packages/flutter/README.md:51`
  - Problem: `Icons.add` is in `material.dart`, but the earlier example imports only `widgets.dart` and makes a point of working without Material.
  - Proposal: Replace it with an icon that does not come from `Icons`, or add a comment.
- [ ] **310.** The `CONTRIBUTING.md` commit rules lack the codebase prefix and "one commit per component" (Docs · Docs · Low)
  - Location: `CONTRIBUTING.md:54-79`, `CLAUDE.md:469`
  - Problem: `CLAUDE.md` says CONTRIBUTING is the rule and requires both rules, but CONTRIBUTING itself does not contain them.
  - Proposal: Add both rules to the commit section of CONTRIBUTING.
- [ ] **311.** The list in `CLAUDE.md` of places that state the component count is incomplete (Docs · Docs · Medium)
  - Location: `CLAUDE.md:140`
  - Problem: "eight files, twelve times" covers only the shared count, 127. The React count, 130, also appears in `docs/{en,ko}/guide/getting-started.md:90`, `:101`, `docs/{en,ko}/components/index.md:13` and `packages/react/README.md`.
  - Proposal: Add the places where 130 appears, and the React README list, to step 13.
- [ ] **312.** `CLAUDE.md` gives the number of `internal/` modules as 40, but it is 41 (Docs · Docs · Low)
  - Location: `CLAUDE.md:60`
  - Problem: `image.ts` was added, which makes 41.
  - Proposal: Change it to 41.
- [ ] **313.** The `order:` instruction in the `CLAUDE.md` checklist has no effect on component pages (Docs · Docs · Low)
  - Location: `CLAUDE.md:136`, `docs/.vitepress/config.ts:739-762`
  - Problem: `arrangeSidebar` sorts the pages inside a component group by name, so `order` is used only in Design. The "a clash is silent" warning belongs to a step with nothing to do. During the audit, this sentence also led to a number clash in the inputs group being reported as a defect.
  - Proposal: Remove the `order:` instruction from step 9, or state that pages inside a group are sorted by name.
- [ ] **314.** The claim in `CLAUDE.md` that "CI requires both lockfiles through `npm ci`" does not match the documentation workflow (Docs · Docs · Low)
  - Location: `CLAUDE.md:493`, `.github/workflows/publish-documentation.yml`
  - Problem: The documentation workflow caches `node_modules` and runs `npm install` only when there is no cache, so it does not fail when a lockfile is out of sync.
  - Proposal: Make the sentence match what actually happens, or change the workflow to `npm ci`.
- [ ] **315.** `CLAUDE.md` and `llms.txt` describe the slider rail and the switch track as `--plass-well` (Docs · Docs · Low)
  - Location: `CLAUDE.md:175`, `docs/public/llms.txt:136`, `:137`
  - Problem: Both components have already moved to `--plass-track` (`PlSlider.tsx:100-118`, `PlSwitch.tsx:99-160`), and the switch thumb is white, not `--plass-surface`. Only the segmented button still uses `--plass-well`.
  - Proposal: Update the three places to match the current implementation.
- [ ] **316.** Three claims in the vNext Documentation entries of the React `CHANGELOG.md` are false (Docs · Docs · Low)
  - Location: `packages/react/CHANGELOG.md:67`, `:69`, `:71`
  - Problem: The rule it cites as "the heading form that CONTRIBUTING.md requires" is not in CONTRIBUTING. "133 previews" is actually 130. It says em dashes remain only in table cells, but 53 lines outside tables in `docs/en` still have them.
  - Proposal: Remove the sentence that cites the source, and make the number and the em dash sentence match the facts.
- [ ] **317.** The Flutter getting-started list of components that need an `Overlay` is incomplete, and the provider placement example throws when followed (Docs · Flutter · Medium)
  - Location: `docs/{en,ko}/guide/getting-started.md:124`, `docs/en/components/feedback/confirm.md:38`, `toast.md:34` (same in ko)
  - Problem: It lists only four, but `PlCombobox`, `PlCommandPalette`, `PlDrawer`, `PlHoverCard`, `PlMenu`, `PlNavigationMenu`, `PlPopover`, the pickers, `PlTour` and `PlConfirmProvider` also need one. The English sentence breaks off after the list. Placing the provider outside the app, as in `PlConfirmProvider(child: MyApp())`, fails an assert because it cannot find `Directionality`. Placing it inside `builder` still makes `confirm()` fail, because there is no `Overlay` above it.
  - Proposal: Describe the components by category, and show a placement that actually works, such as `Overlay.wrap(child: PlConfirmProvider(child: child!))` in `MaterialApp.builder`.
- [ ] **318.** The browser support summary in getting started does not match the browser support page (Docs · Docs · Low)
  - Location: `docs/{en,ko}/guide/getting-started.md:314`
  - Problem: It says "Chrome, Safari and Firefox from 2023 onward", but `browser-support.md` puts full Firefox support at version 128 (July 2024).
  - Proposal: State the exact versions, or keep only the link.
- [ ] **319.** The React-only `usePlassDefaults` example in `defaults.md` is also shown to Flutter readers (Docs · Docs · Low)
  - Location: `docs/{en,ko}/guide/defaults.md:117-125`
  - Problem: It is outside `::: fw`, so Flutter mode shows the TSX and never shows `PlassTheme.defaultsOf(context)`.
  - Proposal: Split the section into two fw blocks.
- [ ] **320.** The sentence in `locales.md` that explains the difference in Flutter label counts says the opposite of what it means (Docs · Docs · Low)
  - Location: `docs/en/guide/locales.md:40`
  - Problem: "`aria-sort` carries a meaning here…" inside the Flutter block reads as if Flutter had `aria-sort`. The ko page translates it correctly.
  - Proposal: Rewrite it with the web and Flutter as separate subjects.
- [ ] **321.** `'--plass-blur': '10px'` in the `color.md` example removes the glass blur (Docs · Docs · Medium)
  - Location: `docs/{en,ko}/design/color.md:135`
  - Problem: `--plass-blur` is a filter list such as `blur(22px) saturate(160%)`, so `10px` is an invalid value. The type is `string | number`, so the type check does not catch it either.
  - Proposal: Change it to `'blur(10px) saturate(160%)'`.
- [ ] **322.** The base colour `#3558ef` is not in any token, and the radius ratio of 29% does not match the calculation (Docs · Docs · Low)
  - Location: `docs/{en,ko}/design/design-language.md:75`, `:131`, `docs/.vitepress/config.ts:476-478` (`theme-color`)
  - Problem: `--plass-primary-solid` is `#3f63f2`, and the md radius, 12px on a 40px height, is 30%. `theme-color` also uses the same wrong value.
  - Proposal: Change them to `#3f63f2` and 30%.
- [ ] **323.** "Adding a colour family takes two edits" does not match the actual work (Docs · Docs · Low)
  - Location: `docs/{en,ko}/design/design-language.md:95`, `docs/{en,ko}/design/color.md:46`
  - Problem: The derived tokens are written out for each family in `styles.css` (`:596-611`), `accent` goes into two dark blocks, and the Flutter tokens also have to change.
  - Proposal: Remove the sentence, or list the places to change.
- [ ] **324.** "The library ships no translations" in `rtl.md` contradicts the translation guide (Docs · Docs · Medium)
  - Location: `docs/{en,ko}/design/rtl.md:134`
  - Problem: It still describes the state before the label packs for seven languages existed.
  - Proposal: Keep only the point that direction is read separately from the label pack, and link to the locales page.
- [ ] **325.** React-only content appears in Flutter mode as empty sections or "No Flutter version" frames (Docs · Docs · Low)
  - Location: `docs/{en,ko}/design/prop-conventions.md:84-149`, `docs/{en,ko}/examples/dashboard.md`, `landing.md`, `signup.md`, `docs/en/components/layout/flex.md:10`, `:78`, `:104`, `show.md:89`, `docs/en/hooks/use-breakpoint.md:10`, `use-media-query.md:10` (same in ko)
  - Problem: Some sections have only their heading outside fw, some React-only demos lack `:flutter="false"`, and the example pages do not explain what is shown. The flex page says "it is React-only and not missing", then shows three frames that say it is missing.
  - Proposal: Put the headings inside the fw blocks too, add `:flutter="false"` to the demos, and add one sentence for Flutter readers to each example page.
- [ ] **326.** The `PlStack` named in the landing example's description is not in the code (Docs · Docs · Low)
  - Location: `docs/{en,ko}/examples/landing.md:20`
  - Problem: The overlapping avatars are the `<div className="flex -space-x-2">` at `examples/landing.tsx:221`.
  - Proposal: Make the description match the code.
- [ ] **327.** The component list page gives the preview count as 133, but there are 130 (Docs · Docs · Low)
  - Location: `docs/{en,ko}/components/index.md:13`
  - Problem: `entries` in `component-index/all.tsx` has 130 items.
  - Proposal: Change it to 130, or remove the number.
- [ ] **328.** Replacing em dashes with full stops left broken sentences (Docs · Docs · Low)
  - Location: `docs/en/guide/getting-started.md:217`, `docs/en/design/design-language.md:274`, `docs/en/design/breakpoints.md:56`, `docs/ko/guide/getting-started.md:232`, `docs/en/components/inputs/date-picker.md:68`
  - Problem: Sentences such as "A `page.tsx` or a `layout.tsx` in Next.js's App Router, and it renders." and "…a toast. Is painted at…" lack a subject or a verb.
  - Proposal: Merge them with the sentence before, or fill in the missing part.
- [ ] **329.** On ko pages, particles after italic text appear with a space before them (Docs · Docs · Low)
  - Location: `docs/ko/design/design-language.md:35`, `:59`, `:73`, `docs/ko/design/prop-conventions.md:24`, `docs/ko/design/color.md:117`, `docs/ko/guide/defaults.md:70`
  - Problem: `_왜_ 에` and `_같은 밝기_ 입니다` appear on screen as "왜 에" and "밝기 입니다". The space was added because `_` cannot close emphasis inside a word.
  - Proposal: Switch to `*`, as in `*왜*에`.
- [ ] **330.** "훑기" on the ko colour page does not make sense, and colour names are spelled inconsistently (Docs · Docs · Low)
  - Location: `docs/ko/design/color.md:14`, `:23`, `:30`, `:35`, `docs/ko/design/design-language.md:84`, `:89`
  - Problem: It is a table header translated literally from "sweep", and the same colour is written both as "애저" and as "azure".
  - Proposal: Replace it with a phrase such as "그러데이션 양 끝" (both ends of the gradient), and use one spelling.
- [ ] **331.** The group structure of `llms.txt` is wrong (Docs · Site · Medium)
  - Location: `docs/public/llms.txt:21`, `:48`, `:71-87`, `:94`, `:111`
  - Problem: There is no `### Charts` heading, so the 9 charts sit under Display. `PlWindowPane` (surfaces) is under Display, and `PlMockup` (display) is under Feedback. A blank line after that splits `PlModal` and the entries that follow into a separate list.
  - Proposal: Add `### Charts`, move the three sets of entries to their own groups, and delete the blank line.
- [ ] **332.** `llms.txt` has no links to Breakpoints or the changelog, and the description on line 21 does not match the actual layout (Docs · Site · Low)
  - Location: `docs/public/llms.txt:21`, `:25-34`
  - Problem: Of the design pages, only `design/breakpoints` is missing. The description says the React-only components are gathered at the end, but they are inside each group.
  - Proposal: Add the links and fix line 21.
- [ ] **333.** At 190KB, `llms.txt` is closer to the full documentation than to a summary list (Optimisation · Site · Low)
  - Location: `docs/public/llms.txt`
  - Problem: The description on a single link line has a median length of about 1,100 characters and a maximum of about 4,500. The `llms.txt` format is a short summary and a list of links.
  - Proposal: Split it into a short `llms.txt` and an `llms-full.txt` that holds the current content.
  - Flag: Decision needed
- [ ] **334.** Several component pages have design rationale sections that are not part of the page skeleton (Docs · Docs · Low)
  - Location: `docs/en/components/feedback/drawer.md:79`, `:109`, `confirm.md:68`, `inputs/date-picker.md:66`, `:107`, `inputs/color-picker.md:48`, `inputs/floating-action-button.md:42`, `:66`, `:72`, `:96`, `inputs/fieldset.md:123`, `transitions/animate-split.md` (no Examples) (same in ko)
  - Problem: The page rules in `CLAUDE.md` set the order as Props → Examples → Accessibility and say that design rationale does not belong on the page. animate-split has only prose sections and one hero demo instead of `## Examples`.
  - Proposal: Keep only the necessary facts under Props, and move the rationale to the design documents or delete it. For animate-split, move the `by`, `effect` and `stagger` examples into Examples, each with a demo.
  - Flag: Decision needed — decide whether to move the rationale or delete it.
- [ ] **335.** The changelog page's description is an unrelated paragraph from the middle of the body (SEO · Site · Medium)
  - Location: `docs/scripts/copy-changelog.mjs:33-35`, `docs/.vitepress/config.ts:338-350`
  - Problem: The generated frontmatter has no `description`, so the description and `og:description` of `docs-dist/changelog.html` are the text of the `PlWindowPane` entry ("It is not a real window…").
  - Proposal: Have `copy-changelog.mjs` write a `description` for each locale.
- [ ] **336.** The site changelog covers only React, and `/ko/changelog` carries the English original marked as `ko-KR` (SEO · Site · Low)
  - Location: `docs/scripts/copy-changelog.mjs:27`
  - Problem: The site covers both frameworks but publishes only the React changelog, and the same English text is indexed under two languages.
  - Proposal: Publish the Flutter changelog as well, or limit the title to React. For the ko copy, point its canonical at the English page, or do not generate it.
  - Flag: Decision needed
- [ ] **337.** The generated `robots.txt` does not treat AI training crawlers separately (SEO · Site · Low)
  - Location: `docs/.vitepress/config.ts:506-511`
  - Problem: It writes only `User-agent: *` and `Allow: /`. The shared SEO rules say to block `GPTBot`, `ClaudeBot` and `Google-Extended` by default.
  - Proposal: Add blocks for those crawlers.
  - Flag: Decision needed — the maintainer decides whether the open source documentation may be used for training.
- [ ] **338.** Changing the preview theme reloads the Flutter iframe (Performance · Site · Medium)
  - Location: `docs/.vitepress/theme/components/Demo.vue:268-272`, `:457`
  - Problem: `frameSrc` is a computed that reads `theme.value`, so every change to the site's dark mode or to the preview theme changes the URL and boots the engine again. This is the behaviour the comment at `:296-297` was meant to avoid.
  - Proposal: Put only the initial theme in the URL, and send later changes with `postMessage`.
- [ ] **339.** Every page loads the props data for all 130 components (Performance · Site · Medium)
  - Location: `docs/.vitepress/theme/components/PropsTable.vue:6-7`, `docs/.vitepress/theme/index.js:5`
  - Problem: `props.ts` (524KB) and `props-flutter.ts` are imported statically and the component is registered globally, so the theme chunk is 719KB (about 211KB gzipped) and is modulepreloaded on every page, including the home page.
  - Proposal: Split the data per component, and have `PropsTable` dynamically import only the piece that matches `name`.
- [ ] **340.** Pages with no preview still download ReactDOM (Performance · Site · Low)
  - Location: `docs/.vitepress/theme/components/Demo.vue:21-32`
  - Problem: `reactRuntime()` at the top level of the module requests `react-dom/client` (57KB gzipped) as soon as the theme loads. This contradicts the comment.
  - Proposal: Request it when the first `Demo` is set up.
- [ ] **341.** The framework selection group is named "Language"/"언어" (Accessibility · Site · Low)
  - Location: `docs/.vitepress/data/i18n.ts:53`, `theme/components/FrameworkSelect.vue:62-63`
  - Problem: It reads as a switch for the site locale, but it actually chooses between React and Flutter.
  - Proposal: Rename it to "Framework"/"프레임워크".
- [ ] **342.** The required marker in the props table carries its meaning only in the `title` attribute (Accessibility · Site · Low)
  - Location: `docs/.vitepress/theme/components/PropsTable.vue:61-63`
  - Problem: Screen readers read `<span title="Required">*</span>` as "star" or skip it, and it is not visible to touch users.
  - Proposal: Give the `*` `aria-hidden`, and add a visually hidden "Required"/"필수".
- [ ] **343.** All Flutter iframes on a page use the same `title` (Accessibility · Site · Low)
  - Location: `theme/components/Demo.vue:459`, `data/i18n.ts:63`
  - Problem: Screen reader users who move through the list of frames cannot tell them apart.
  - Proposal: Add the demo name or the nearest heading to the title.
- [ ] **344.** The home hero logo's `alt` repeats the heading right after it, and the file is larger than its display size (Accessibility · Site · Low)
  - Location: `theme/components/Layout.vue:70-77`
  - Problem: `alt="Plass"` is followed by an `<h1>` that starts with "Plass", so the name is read twice. A 256px file (44KB) is loaded with `fetchpriority="high"` for a 96px display.
  - Proposal: Change it to `alt=""` and use a 128px file.
- [ ] **345.** Values in the site config and CSS comments do not match the facts (Docs · Site · Low)
  - Location: `docs/.vitepress/config.ts:131`, `:712-722`, `docs/.vitepress/theme/styles/framework.css:68`
  - Problem: The `arrangeSidebar` comment leaves out Hooks and gives the page count as "fifty-odd", and `framework.css` describes the menu as "fifty entries" (the real number is 130). The `localeBase` comment on line 131 is wrongly placed above `slugify`.
  - Proposal: Fix the numbers and the position.
