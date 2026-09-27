# Audit TODO

The open findings of a full audit of both packages, the documentation site and the repository, taken at `148a20e4` on 2026-09-13, and of the batches that have worked through it since. The work goes in batches of twenty. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again. Batches 1 to 31 closed 572 items between `148a20e4` and `8a5c11ad`; those items and the notes of batches 1 to 29 are in the history of this file.

**12 items are open, and the last number used is 586.**

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

None. Every question batch 31 asked was answered with an item or with the change the batch had already made.

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
- `PlSegmentedButton`: when `value` changes from outside while the arrows of a read-only Flutter set have moved the focus, the focus stop goes back to the chosen segment; React leaves it where the arrows put it.
- `PlCombobox` chips: each Flutter × is a Tab stop and there is no `Backspace` or arrow handling for chips, where React reaches the chips with the arrows (the × has `tabIndex: -1`) and `Backspace` in an empty input removes the last chip; the chips of a disabled or read-only Flutter combobox carry no enabled or read-only state, where React's carry `aria-disabled` or `aria-readonly`.
- `PlNumberField`: an editable Flutter field tabbed through clamps a value handed in outside the range (`pl_number_field.dart`, `if (_unsettled || next != _held) {`), where Base UI's blur with nothing typed keeps it; `Home` and `End` are always taken, even with no `min` or `max`, so the caret does not move; and the wheel always steps by `step`, where Base UI takes `Shift` for `largeStep`, `Alt` for `smallStep` and a `Shift`+wheel's horizontal delta.
- `PlCalendar`: the Flutter weekday headers are read "Sun" (`internal/calendar.dart`, `weekdayRow`), React's "Sunday" (`role="columnheader"` with the long name).
- `PlAnchor`: the label is a heading only in Flutter (`pl_anchor.dart`, `Semantics(header: true, …)`); React draws a plain `<span>`.
- Fields: a Flutter field's adornments are read after the field, as children of its node, where React's start adornment comes before the input.

## Items

Each item was raised in a batch report and approved. Its line numbers are from the commit that raised it and drift as the code changes; when one no longer matches, search for the symbol.

- [ ] **575.** A disabled Flutter field is no longer announced as a text field (Accessibility · Flutter · Low)
  - Location: the editors' `readOnly` in `text_field/pl_text_field.dart` (`readOnly: widget.readOnly || _disabled` ~369), `combobox/pl_combobox.dart` (~1103), `number_field/pl_number_field.dart` (`readOnly: !_editable`) and the `PlColorPicker` value field
  - Problem: Since item 567 made each field one node, a disabled field reports the editor's read-only flag, as a Material `TextField` does. On iOS a read-only text field is not a text input (`accessibility_bridge.mm` ~269) and on Android it does not get the `EditText` class (`AccessibilityBridge.java` ~781), so a disabled field is read as "Name, dimmed" rather than as a dimmed text field. React's `<input disabled>` keeps its role.
  - Proposal: Stop passing the disabled state into the editor's `readOnly` in the four fields and keep typing out with the `ExcludeFocus` they already have; check nothing else (scribble, stylus handwriting) reaches the editor, and test the role and that no text gets in.

- [ ] **576.** The arrow keys do nothing in a read-only Flutter radio group (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/radio_group/pl_radio_group.dart` (`_move`, `if (!_interactive || widget.options.isEmpty) {` ~187)
  - Problem: A read-only group keeps its focus stop but its arrow keys neither move the focus nor the choice, so the other options cannot be reached from the keyboard. React's read-only Base UI group moves the focus and leaves the choice, and since item 564 the Flutter `PlSegmentedButton` does too.
  - Proposal: Do what item 564 did (`a8643c1b`): a highlight index the arrows move in a read-only group, kept through `keepStop`, with a test.

- [ ] **577.** A Flutter surface that cannot be pressed is still a directional stop when it is handed a focus node (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/interaction.dart` (`focusNode: widget.focusNode ?? _ownNode,` ~280)
  - Problem: Item 568 gave `PlassInteractive` a focus node of its own that refuses the focus while there is nothing to press, since `FocusableActionDetector` makes its node focusable under `NavigationMode.directional` even when disabled. A node the component was handed (`PlListItem`, `PlCard`, `PlChip`) bypasses it, so `PlListItem(focusNode: n, disabled: true, onPressed: …)` takes the focus from a remote, which it did not before item 568.
  - Proposal: Build `PlassInteractive` on `Focus`, `Actions`, `Shortcuts` and its own highlight tracking instead of `FocusableActionDetector`, so it decides whether any node can take the focus, with tests in both navigation modes.

- [ ] **578.** A disabled Flutter tooltip still takes the long press from its trigger (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/tooltip/pl_tooltip.dart` (`onLongPress: () => _schedule(true),` ~466, while `_schedule` returns at once when disabled ~360)
  - Problem: The long-press recogniser is registered whether or not the tooltip is disabled, so holding a `PlButton` under a disabled tooltip for a second and letting go shows nothing and does not press the button either.
  - Proposal: Register the long press only while the tooltip is enabled, with a test that the control under a disabled tooltip is pressed.

- [ ] **579.** A tooltip turned off while it is open stays open in React, and closes without a word in Flutter (Bug · Both · Low)
  - Location: `packages/react/src/components/tooltip/PlTooltip.tsx` (`disabled={disabled}` on the trigger only ~207); `packages/flutter/lib/src/components/tooltip/pl_tooltip.dart` (`didUpdateWidget`, `if (widget.disabled) {` ~259)
  - Problem: In React, a tooltip opened by hover stays up with `aria-describedby` set after `disabled` turns on, and `onOpenChange` never reports the close; a controlled `open` opens a disabled tooltip, against its JSDoc ("Stops the tooltip from opening at all"). Base UI's `Root` closes only on its own `disabled`. In Flutter the plate goes, but `onOpenChanged` is not called, so a caller mirroring the state keeps `true`.
  - Proposal: Pass `disabled` to the React `Root` as well, and report the close through `onOpenChanged(false)` in Flutter, with a test in each.

- [ ] **580.** Removing a chip of a multiple Flutter combobox from the keyboard leaves the focus in the wrong place (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/combobox/pl_combobox.dart` (the chips, unkeyed, `for (final value in widget.values)` ~1196; `_remove` ~972 never moves the focus)
  - Problem: With a chip's × focused, `Enter` removes it and the focus stays on the same slot, which now removes the next chip, so a second `Enter` removes a value the reader never chose; after the last chip the focus goes back to whatever was before the field. React moves the focus to the input (Base UI `ComboboxChipRemove.js` ~74).
  - Proposal: Key the chips by value and move the focus to the editor after a remove, with a test.

- [ ] **581.** A Flutter number field's `snapOnStep` snaps to the nearest multiple on every settle (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/number_field/pl_number_field.dart` (`next = (next / widget.step).roundToDouble() * widget.step;` ~534)
  - Problem: Base UI's `toValidatedNumber` snaps only on a step, by the amount stepped and in its direction from `min` (to the nearest only for a small step), and never on blur. Flutter snaps to the nearest multiple of `step` whatever moved it: with a step of 5, `ArrowUp` from 8 gives 15 where React gives 10; with a step of 1, `Alt+ArrowUp` from 5 does nothing where React gives 5.1; and 7 typed and left settles to 5 where React keeps 7.
  - Proposal: Snap as Base UI does, with a test for each case.

- [ ] **582.** A second key in the same frame steps a Flutter number field from a stale value (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/number_field/pl_number_field.dart` (`final changed = next != widget.value;` ~559)
  - Problem: A step compares against `widget.value`, which the parent has not rebuilt yet when a second key arrives in the same frame: `ArrowUp` then `ArrowDown` from 5 ends at 6, because the step down to 5 matches the old value and reports nothing.
  - Proposal: Compare against the value the field last reported (`_held`), with a test that sends two keys in one frame.

- [ ] **583.** Flutter table cells and a chip's label are built again when they become pressable (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/table.dart` (`if (_interactive) {` ~292, `if (_interactive || widget.hoverable) {` ~300, the `FocusableActionDetector` ~313); `packages/flutter/lib/src/components/chip/pl_chip.dart` (`if (onDeleted != null) {` ~302)
  - Problem: The item 568 bug in more places: a `PlTable` or `PlDataTable` cell is wrapped only when `onRowPressed` or `hoverable` asks for it, and a `PlChip`'s label moves under a `Row` when `onDeleted` comes, so toggling either builds the content again from scratch and anything stateful in it starts over.
  - Proposal: Keep one tree shape in each, as item 568 did, with a test that the content's `State` survives.

- [ ] **584.** A Flutter toggle and a pressable card do not say they can take the focus (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/interaction.dart` (`includeFocusSemantics: false,` ~279)
  - Problem: `PlassInteractive` keeps the detector's focus semantics off, which is right where the component's `Semantics` sits inside the builder, but a `PlToggle` and a pressable `PlCard` put theirs outside it, so their node offers a tap and no `focus` action and is not `isFocusable`, where a `PlButton`'s node has both.
  - Proposal: Let a component whose `Semantics` is outside the builder ask for the focus semantics, sweep the users of `PlassInteractive` for it, and test each with a dump.

- [ ] **585.** A React pie chart's centre and a chart's empty message are not read (Accessibility · React · Low)
  - Location: `packages/react/src/components/pie-chart/PlPieChart.tsx` (`{center}` ~499 inside the `role="img"` element ~351), and each chart's `empty` content inside its `role="img"` host
  - Problem: The children of an element with `role="img"` are presentational, so "Total 30" in a pie's centre and "Nothing yet" in an empty chart are never read. Flutter reads both as part of the chart's name.
  - Proposal: Put the centre and the empty message into what the chart says, through `aria-describedby` or the text summary, in every chart that takes them, with a test.

- [ ] **586.** A screen reader cannot tap or focus a Flutter text field (Accessibility · Flutter · Low)
  - Location: the editors' `Focus(... includeSemantics: false)` (`editable_text.dart` ~5806 in the SDK) and the shells' gesture detectors with `excludeFromSemantics: true` (`text_field/pl_text_field.dart` ~562, `number_field/pl_number_field.dart` ~1125), in `PlTextField`, `PlNumberField`, the `PlColorPicker` value field and the `PlCommandPalette` field
  - Problem: The field's node carries the cursor, selection and set-text actions only, with no `tap` or `focus`. On the web, a screen reader focusing the semantic `<input>` dispatches `SemanticsAction.focus`, which nothing takes, so the editor never gets the focus; Android's `ACTION_CLICK` dispatches a tap nothing answers. Material's `TextField` gives its node `onTap` and `onFocus`. Not yet checked on a device.
  - Proposal: Give each field's node `onTap` and `onFocus` that focus the editor, as Material does, and test the actions.
