# Audit TODO

The open findings of a full audit of both packages, the documentation site and the repository, taken at `148a20e4` on 2026-09-13, and of the batches that have worked through it since. The work goes in batches of twenty. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again. Batches 1 to 30 closed 560 items between `148a20e4` and `ba2e8cee`; those items and the notes of batches 1 to 29 are in the history of this file.

**12 items are open, and the last number used is 574.**

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

None. Every question batch 30 asked was answered with an item or with the change the batch had already made.

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
- `PlAppLogo`: the React logo rendered as a link (`render={<a href="/" />}`) draws no house focus ring (`PlAppLogo.tsx` ~171-175 sets `controlSlots` but not `focusRingClasses`), so it shows the browser's own outline where the Flutter logo draws the family's ring; `PlAspectRatio` documents the same link `render` (`PlAspectRatio.tsx` ~53).
- `PlAppLogo`: a pressable Flutter logo is a button that `Space` presses as well as `Enter` (`pl_app_logo.dart` ~264), where the React logo is usually a link that only `Enter` follows.
- `PlNumberField`: `Enter` with nothing typed calls `onCommitted` with the value the Flutter field already had (`onSubmitted`, `pl_number_field.dart` ~747); Base UI commits nothing on `Enter`.
- Docs: the Accessibility section of the command palette page (`docs/en/components/navigation/command-palette.md` and the `ko` twin) is shared by both frameworks but written for React only ("wired with `aria-activedescendant` by Base UI", "portalled to the end of `<body>`"), and it sits after "Differences from the React build", out of the page skeleton's order.

## Items

Each item was raised in a batch report and approved. Its line numbers are from the commit that raised it and drift as the code changes; when one no longer matches, search for the symbol.

- [ ] **563.** The system back over a running Flutter tour closes the page under it (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/tour/pl_tour.dart` (its own `OverlayPortal` ~466, `Escape` ~531)
  - Problem: The tour lifts its own layer rather than going through `PlassPortal`, so item 557's `PlassBackGuard` does not reach it. With a tour running, Android's back, TalkBack's back and VoiceOver's escape pop the page under it, and `onOpenChanged` is never called, so the caller's `open` stays true; `Escape` closes a `dismissible` tour.
  - Proposal: Register a `PlassBackGuard` while the tour is open and `dismissible`, closing it as `Escape` does, with a test in a `WidgetsApp` with two routes, as `test/internal/back_test.dart` does.

- [ ] **564.** A read-only Flutter segmented button tells a screen reader it is disabled (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/segmented_button/pl_segmented_button.dart` (`_interactive` ~204, the set's `enabled: _interactive` ~466, each segment's `enabled: onPressed != null` ~727)
  - Problem: A read-only set and each of its segments report `enabled: false` and no `readOnly`, so a screen reader announces them as unavailable. React puts `aria-readonly` on the group and keeps the radios enabled, and the Flutter `PlRadioGroup` reports `enabled: !disabled` and `readOnly: readOnly` on the group and each option (`pl_radio_group.dart` ~279-280, ~427-428). It is the only control where the two builds disagree on this.
  - Proposal: Report `enabled` and `readOnly` apart, as `PlRadioGroup` does, with a test.

- [ ] **565.** A Flutter command palette built open never focuses its search field (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/command_palette/pl_command_palette.dart` (`initState` ~229, the focus request only in `didUpdateWidget` ~243)
  - Problem: A palette whose first build has `open: true` leaves the focus on the portal's scope, so the arrows, `Enter` and `Escape` work through the hardware handler but typed characters go nowhere until the field is tapped. An app that builds the palette only while it is open always meets this. React's input has `autoFocus` (`PlCommandPalette.tsx` ~364).
  - Proposal: Ask for the field's focus when the palette is built open too, with a test.

- [ ] **566.** A Flutter field's placeholder and adornment text join its name (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/text_field/pl_text_field.dart` (the placeholder `Text` ~414 and the adornments under the field's `Semantics(container: true, label: widget.semanticLabel)` ~580-587); the same placeholder in `combobox/pl_combobox.dart` ~1139 and `number_field/pl_number_field.dart` ~782
  - Problem: The drawn placeholder merges into the field's node, so a field whose `placeholder` and `semanticLabel` are the same words is read twice ("Search\nSearch": the search fields of `PlTransfer` ~687-688, `PlTreeSelect` ~475-476, and `PlDataTable` ~808-809 with its defaults), and a field named only by its placeholder loses its name as soon as something is typed. Text in an adornment joins the name as well: `PlTextField(semanticLabel: 'Name', endIcon: Text('@'))` is "Name\n@". React names an input by `aria-label` over its placeholder, keeps the placeholder name after typing, and leaves an adornment out of the name.
  - Proposal: Do what item 561 did for the command palette: keep the drawn placeholder off the semantics tree and name the editor by the placeholder only when the field has no label; give an adornment's content a node of its own beside the field rather than excluding it. Test each field.

- [ ] **567.** A Flutter text field's name and value sit on two nodes (Accessibility · Flutter · Low)
  - Location: `text_field/pl_text_field.dart` ~582, `combobox/pl_combobox.dart` ~1047 and `color_picker/pl_color_picker.dart` ~723 (`Semantics(textField: true, …)` round an `EditableText`); `number_field/pl_number_field.dart` ~1113-1125 copies the text into `value:` on purpose
  - Problem: `EditableText`'s render object sets `isTextField` itself, and two text-field configurations never merge (`isCompatibleWith`), so the field's name is on an outer text-field node that takes no input focus and its value on an unnamed editor node under it. A screen reader may stop on the field twice, or read the value without the name. Seen in semantics dumps in batch 30; not yet checked with TalkBack or VoiceOver.
  - Proposal: Check how TalkBack and VoiceOver read the pair first, then make each field one node that carries its name, its value and its actions, and test it.

- [ ] **568.** Some Flutter components build their content again when they become pressable (Bug · Flutter · Low)
  - Location: `app_logo/pl_app_logo.dart` (`if (onPressed == null) { return content; }` ~246), `list/pl_list.dart` (`PlListItem`, `final interactive = …` ~272 and the two trees after it), `breadcrumb/pl_breadcrumb.dart` (`_Step` ~323, also when an item becomes current or disabled)
  - Problem: Being handed `onPressed`, or losing it, changes the shape of the tree above the content, so Flutter builds the content from scratch and anything stateful in it starts over: a `PlImage` decoding again, a field losing what was typed. `PlCard` had the same bug and now always wraps in `PlassInteractive` with `pressable` and `enabled` flags (see its comment on a card "handed `onPressed` later").
  - Proposal: Keep one tree shape in each, as `PlCard` does, with a test that the content's `State` survives the change.

- [ ] **569.** A value handed to a focused Flutter number field is dropped (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/number_field/pl_number_field.dart` (`if (widget.value != oldWidget.value && !_focused) {` ~411)
  - Problem: While the field holds the focus, a new `value` never reaches the box even when nothing has been typed, and the next blur writes the old number back through `onChanged`: a field at 5 whose parent sets 9 while it is focused goes back to 5 on blur. Base UI syncs the box whenever nothing has been typed.
  - Proposal: Skip the sync only while typed text is unsettled (`_focused && _unsettled`), with a test.

- [ ] **570.** A read-only Flutter number field changes its value, and a step that changes nothing is committed (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/number_field/pl_number_field.dart` (`_edge` ~563, the blur ~436, `_commit`'s `onCommitted` ~526)
  - Problem: `Home` and `End` set a read-only field to its `min` or `max`, since `_edge` has no `_editable` check. A blur settles a read-only field too, so a value outside the range handed to it is clamped through `onChanged` and `onCommitted`. And a key step, `Home`, `End` or a wheel turn that leaves the value where it was still calls `onCommitted`. Base UI does nothing in any of the three.
  - Proposal: Guard `_edge` and the blur's settle on `_editable`, and commit a step only when it changed the value, with a test for each.

- [ ] **571.** A screen reader cannot press a Flutter number field's steppers (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/number_field/pl_number_field.dart` (the stepper's `Semantics(container: true, button: true, enabled: !inert, label: …)` with no `onTap`, ~927)
  - Problem: `PlassInteractive` keeps its own tap off the semantics tree, so the "Increase" and "Decrease" nodes are named buttons with no action, and the field's node offers no increase or decrease either. React's steppers are Base UI `<button>`s.
  - Proposal: Give each stepper's node the tap it has for the pointer, and consider `onIncrease` and `onDecrease` on the field's node, with a test.

- [ ] **572.** The chips of a multiple Flutter combobox name its editor (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/combobox/pl_combobox.dart` (the chip's `child: Text(_labelOf(value))` ~1188); `chip/pl_chip.dart` forms a node only when the chip is interactive (~181-182)
  - Problem: A chip that cannot be pressed forms no node, so its text merges into the editor's node, and the editor is announced by the chosen values ("Seoul"). React keeps the chips in Base UI's `role: 'toolbar'`, apart from the input's name.
  - Proposal: Give each chip, or the row of chips, a node of its own, with a test that the editor keeps the field's name.

- [ ] **573.** A Flutter `semanticLabel` is read before a button's text instead of replacing it (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/button/pl_button.dart` (`label: widget.semanticLabel,` ~564 inside the button's `MergeSemantics`, with the child's `Text` still on the tree)
  - Problem: `PlButton(semanticLabel: 'Copy', child: Text('⧉'))` is announced "Copy\n⧉"; the tooltip hero demo (`example/lib/demos/tooltip/hero.dart` ~25-27) is this case. The dartdoc calls `semanticLabel` the name a screen reader announces, and React's `aria-label` replaces the content as the name.
  - Proposal: Keep the child's text out of the name when a `semanticLabel` is given, and sweep the package for components that pair a `semanticLabel` with a text child the same way, with a test for each.

- [ ] **574.** A disabled Flutter tooltip still describes its trigger (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/tooltip/pl_tooltip.dart` (`tooltip: spoken,` ~479, which does not read `widget.disabled`)
  - Problem: A tooltip turned off still puts its words on the trigger, and since item 559 merges the trigger with them. For the documented use, a tooltip on only while a label is cut short, a label that fits is read twice. React never opens a disabled tooltip, so its trigger is never described.
  - Proposal: Say nothing, and merge nothing, while the tooltip is disabled, with a test.
