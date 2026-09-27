# Audit TODO

The open findings of a full audit of both packages, the documentation site and the repository, taken at `148a20e4` on 2026-09-13, and of the batches that have worked through it since. The work goes in batches of twenty. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again. Batches 1 to 29 closed 553 items between `148a20e4` and `14a63305`; those items and each batch's notes are in the history of this file.

**7 items are open, and the last number used is 562.**

## Working through a batch

When the Prompter asks to continue the audit, run a batch as written here, without asking how.

1. **Answers first.** Do what the Prompter approved under [Waiting for an answer](#waiting-for-an-answer) before the batch; that work does not count towards its twenty. Delete an item the Prompter declined, and name it in the report. Remove every answered question from that section.
1. **Pick twenty items.** Take open items by severity, High before Medium before Low, and by number within one severity. Skip an item flagged `Decision needed` or `Breaking change`, and an item that turns out to need a decision once the work starts, and take the next one instead.
1. **Confirm before fixing.** Check the finding against the code first, because the audit can be wrong or already out of date. An item that no longer reproduces gets no commit; delete it, and name it in the report.
1. **One item, one commit.** For each item:
   - Fix every package the item names, following `CLAUDE.md` and the code around the change.
   - Add a test that fails without the fix, and prove it: commit first, then check the sources out of the parent commit with `git checkout HEAD~1 -- <paths>`, run the test, and check them back with `git checkout HEAD -- <paths>`. Never `git stash`; every worktree of a repository shares one stash, and a batch worked in several worktrees at once loses another agent's entry that way. When a test cannot show the difference, say so in the report.
   - Add a user-facing entry under `## vNext` in `packages/react/CHANGELOG.md`, `packages/flutter/CHANGELOG.md` or both, at the top of `Fixed`, `Changed` or `Breaking changes`. A change no user can notice gets no entry. The site copies both changelogs, so write `{{` in either inside `<code v-pre>`.
   - Update the documentation pages, `docs/en` and `docs/ko` together, and the props tables when documented behaviour changes.
   - Commit with the tags in `CONTRIBUTING.md`: `[javascript]` or `[dart]` for one package and no prefix for both. No `Co-Authored-By` trailer.
1. **Stay inside the item.** A problem found in passing is not fixed; note it for the report. The exception is a problem the item's own change caused, such as a test exemption the change made unnecessary.
1. **Verify the batch** with the commands below, all of them.
1. **Ask, then update this file and push.** Ask every question the batch raised through the prompt, as the standing decision below says, and record the answers: a bug the Prompter wants fixed becomes a new item under [Items](#items), numbered on from the last number used, an approved change goes under [Waiting for an answer](#waiting-for-an-answer), and a question answered "keep" is dropped. Delete the batch's closed items, update the count at the top, commit this file on its own and push.
1. **Report in Korean and stop.** Give a table of the items with their number, package and what changed, the verification results, and the notes the Prompter needs.

Standing decisions that apply to every batch:

- React 18 stays in the peer range, but only React 19 is tested. Do not add a React 18 job or test run.
- Questions go to the Prompter through the prompt (AskUserQuestion), all of them at once: several calls of four questions in one message. Each question says what the problem is and how it would be fixed, each option carries its pros and cons, and one option is marked recommended. Check the facts in the code before writing a recommendation.
- An entry under [Waiting for an answer](#waiting-for-an-answer) has been answered and is approved: do it at the start of the next batch without asking again.
- From batch 27, a problem found in passing is asked, and can become an item, only when it is wrong behaviour (a crash, wrong data, a control that does not do what it says, a state that sticks) or an accessibility problem. A small difference between the builds that a reader would not call broken, such as a pixel of size, a colour a step apart or a change that eases in one build and at once in the other, is not asked: it goes under [Noted differences](#noted-differences) with a line saying where it is, and is not worked. When the last item is closed, ask the Prompter what to do with that list before deleting this file.

### Verifying a batch

```bash
cd packages/react && npm run lint && npm run typecheck && npx prettier --check src test CHANGELOG.md scripts && npm test && npm run build && npm run size
cd packages/flutter && dart format --line-length 100 lib test example/lib && flutter analyze && flutter test
cd packages/flutter/example && flutter analyze lib
cd docs && npm run typecheck && npm run lint && npx prettier --check . && npm run build
```

- `npm run size` allows 2% of drift per scenario. When a batch moves a number past that on purpose, run `npm run size -- --update` and commit the budget on its own.
- `npm run build` in `docs` takes a few minutes and compiles the Flutter demos first. Run it last.
- CI formats the Flutter package with Flutter 3.41.0 and with the newest stable, and the newest formatter lays some code out differently from older ones. Check with it too: `dart pub global activate dart_style`, then `dart pub global run dart_style:format --page-width=100 --language-version=3.11 --output=none --set-exit-if-changed .` in `packages/flutter`. A named argument after a closure, as in `testWidgets('…', (tester) async {…}, variant: …)`, is laid out in opposite ways by the two, so avoid it.

## Waiting for an answer

None. Every question batch 29 asked was answered with an item, a change made in the batch, or to keep what is there.

## Passed over and not yet asked

None. Every flagged item passed over so far is asked above.

## Noted differences

Small differences between the builds found in passing from batch 27 on. They are not items and are not worked; see the standing decisions above.

- `PlWindowPane`: over a draggable bar Flutter shows `SystemMouseCursors.move` (`pl_window_pane.dart` ~797), React `cursor-grab` and `active:cursor-grabbing` (`PlWindowPane.tsx` ~872); both show that cursor over the caption buttons' column outside the buttons, where nothing drags.
- Charts: Flutter draws no category-axis rule (`tokens.chartAxis` is read nowhere), where React draws one at the zero line in `--plass-chart-axis` (`ChartAxes` in `chart-frame.tsx`).
- Charts: React draws the zero gridline in `--plass-chart-baseline`, Flutter every gridline in `chartGrid` (`chart_frame.dart` ~1794-1810).
- `PlScatterChart`: Flutter draws no vertical gridlines, React draws them when the x axis measures (`categoryGrid`).
- `PlAreaChart`: a stacked Flutter area has no 2px surface line between bands (React `chart-line.tsx` ~235).
- Charts: a faded series' value labels fade in React (inside the series `<g>`) and stay whole in Flutter (`_paintValueLabels`, `chart_line.dart` ~220).
- Charts: Flutter replaces the alpha of a series or point colour it is given (`chart_line.dart` ~89, the scatter fill, `pl_bar_chart.dart` ~351, `pl_pie_chart.dart` ~752), where React keeps it.
- `PlHeatmapChart`: the Flutter card sits 8px higher than the React one (`pl_heatmap_chart.dart` ~468 and `chart_frame.dart` ~2724, against `chart-frame.tsx` ~715).
- `PlassChartSeries`: the Flutter class has an `id` documented as what identifies a series (`types.dart` ~733) that nothing reads; the React type has none.
- `PlCombobox` and `PlTextField`: the arrow keys that move a Flutter combobox list's highlight (`_MoveIntent`) do not put the pointer light out, where React's keydown does, and nor does `Enter` in a single-line Flutter text field (read from the code).
- `packages/react/src/types.ts` ~858-866: an orphaned JSDoc block above `PlassChartTooltipMode` describes `item` as "the one mark being pointed at", against the comment that belongs to it.
- Charts: `markers: auto` counts each series' own points in React (`chart-line.tsx` ~266) and the chart's categories in Flutter (`chart_line.dart` ~58-60), so a short series on a long chart has markers in React only.
- `PlHeader`: with no middle, the Flutter row keeps a gap on each side of its empty `Expanded` middle (`pl_header.dart` ~219-233), so its narrowest width is one gap wider than React's.
- `PlSegmentedButton`: a segment disabled on its own in a live set fades by opacity only in React (`data-[disabled]:opacity-50`), where Flutter also drains its colour (`plassStateFilter`).
- `PlSegmentedButton`: the chosen segment of a disabled set draws its label in `mutedFg` in Flutter (`pl_segmented_button.dart` ~624) and in its on-fill or accent ink in React (`PlSegmentedButton.tsx` ~153-155).
- `PlTextField` and `PlNumberField`: a mouse press on the padding or an adornment of a focused Flutter field blurs the editor and focuses it again through the shell; the React text field keeps the focus (`preventDefault` on pointer-down), and the React number field loses it.
- `PlTable` and `PlDataTable`: every cell of an interactive Flutter row carries its own tap that presses the row (`internal/table.dart` ~293), where the React row is one stop.
- Charts: the Flutter frame names its easing keys by series index, so when a series ahead of the one being read leaves, the read mark eases up again from unlit.
- Charts: when the legend lets go, the React `mask` that keeps a faded line out of its markers goes at once while the series' opacity eases back, so the line shows through its markers for about 150ms (`chart-line.tsx`, the band `<g>`).
- Docs: in the home showcase the "Danger zone" card's "Export first" button sticks out about 33px past the card at 1440px (`docs/.vitepress/demos/showcase/app.tsx` ~352).
- Stale comments: `PlBlockquote.tsx` ~141-145 still says the wrapper lets the docs undo VitePress's blockquote, and `docs/.vitepress/theme/styles/scope.css` ~31 says nothing portals yet.

## Items

Each item was raised in a batch report and approved. Its line numbers are from the commit that raised it and drift as the code changes; when one no longer matches, search for the symbol.

- [ ] **556.** A Flutter number field settles its value on every blur (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/number_field/pl_number_field.dart` (`_onFocusChanged` → `_commit`)
  - Problem: A blur calls `onCommitted` whether or not anything was typed, where the doc says "on blur after typing" and Base UI commits on blur only after typed input or a change not yet committed. So a Tab through the field commits the value it already had, a press on the padding or an adornment of a focused field blurs and refocuses it and commits, and since item 554 a mouse press on a stepper of an unfocused field followed by a blur commits the same value twice.
  - Proposal: On blur, commit only when text was typed since the value was last settled or the settled value differs from `value`, with a test for each case.

- [ ] **557.** The system back over an open Flutter layer closes the page under it (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/portal.dart` (nothing handles `didPopRoute`, `PopScope` or `BackButtonListener`)
  - Problem: With a `PlModal`, `PlDrawer`, `PlOverlay`, `PlCommandPalette`, image preview or gallery viewer open, the Android back button, TalkBack's back gesture and VoiceOver's escape pop the page under the layer, and `onOpenChanged` is never called, so the caller's `open` stays true; on the root route Android leaves the app. Since item 550 took the backdrop off the semantics tree, a touch-only screen reader user also has no way to close a dismissible layer that draws no close button.
  - Proposal: Have the topmost dismissible layer close on the system back, as `Escape` closes it, with a test in a `WidgetsApp` with two routes.

- [ ] **558.** A Flutter combobox's chevron and clear buttons merge into its text field's node (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/combobox/pl_combobox.dart` (`adornment()`, `Semantics(button: true, label:, onTap:)` with no `container: true`)
  - Problem: The chevron's and the ×'s semantics merge into the editor's node, so the field is announced as a button named "Open" even with a `semanticLabel`, and a screen reader's tap on the field runs the chevron's action and closes an open list.
  - Proposal: Give each its own node, check the other fields' adornment buttons for the same, and test that the field keeps its name and its own tap.

- [ ] **559.** A Flutter tooltip adds a long press and a stop of its own to what it wraps (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/tooltip/pl_tooltip.dart` (the trigger's `GestureDetector(onLongPress: …)` and `Semantics(tooltip: …)`)
  - Problem: The long press that shows the tooltip on a touch screen becomes a semantics action on the wrapped node, announced as "double-tap and hold", and over a control that is its own node, such as a `PlButton`, the tooltip's words and the long press sit on an unnamed wrapper round it, a stop of their own rather than part of the control's announcement. React describes the trigger with the tooltip.
  - Proposal: Keep the long press off the semantics tree and put the tooltip's words on the control's own node, with a test.

- [ ] **560.** A pressable Flutter `PlAppLogo` cannot be reached from the keyboard (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/app_logo/pl_app_logo.dart` (`onPressed`)
  - Problem: With `onPressed`, the logo is a button node with a tap but takes no focus and answers neither `Enter` nor `Space`, so a keyboard cannot press it. The React logo is usually rendered as a link, which is a tab stop.
  - Proposal: Give it the focus, the focus ring and the keys the other buttons have, with a test.

- [ ] **561.** The search field of a Flutter command palette has no name (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/command_palette/pl_command_palette.dart` (the search `EditableText`)
  - Problem: The field is an unnamed text field; its placeholder, "Search commands" by default, is a separate text node that leaves once something is typed. The React `<input>` takes its name from the placeholder.
  - Proposal: Name the field's node with the same words, with a test.

- [ ] **562.** A React read-only segmented button still answers the pointer (Bug · React · Low)
  - Location: `packages/react/src/components/segmented-button/PlSegmentedButton.tsx` (`lit`, the label's hover)
  - Problem: A read-only set keeps the pointer light on its segments and darkens their labels under the pointer, since `lit` reads only the disabled states and the hover guard only `data-disabled`, where both changelogs say the light goes out on a read-only control and the Flutter segments of a read-only set show neither.
  - Proposal: Put the light out and keep the labels muted on a read-only set, with a test.
