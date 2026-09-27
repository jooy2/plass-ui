# Audit TODO

The open findings of a full audit of both packages, the documentation site and the repository, taken at `148a20e4` on 2026-09-13, and of the batches that have worked through it since. The work goes in batches of twenty. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again. Batches 1 to 32 closed 584 items between `148a20e4` and `abf75ea0`; those items and the notes of batches 1 to 29 are in the history of this file.

**13 items are open, and the last number used is 599.**

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

None. Every question batch 32 asked was answered with an item, or with the test fix the batch made itself.

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
- `PlRadioGroup` and `PlSegmentedButton`: in a read-only Flutter set, the focus stop the arrows moved goes back to the chosen option when `value` changes from outside or `readOnly` is lifted; Base UI keeps the highlighted item (`useCompositeRoot` reads `ACTIVE_COMPOSITE_ITEM` only on its first `onMapChange`), in a live group too.
- `PlCombobox`: taking a chip off with its × while the list is open leaves that value's row lit in Flutter (`_remove` never clears `_highlighted`), so `Enter` puts it straight back; Base UI clears the highlight with `clearActiveIndexForRemovedItem`.
- `PlNumberField`: a step on an empty Flutter field adds a step to `min` or zero (`final from = _read(_controller.text) ?? widget.min ?? 0;`), where Base UI sets zero held inside the range (`NumberFieldRoot.js` ~224), so with a `min` of 3 Flutter gives 4 and React 3; and Flutter rounds a typed value to ten decimals as it settles (`toStringAsFixed(10)` in `_settle`), where Base UI keeps typed input as it is.
- Fields: a press on the text of a disabled Flutter field still moves its selection (the bare `EditableText` handles the tap itself, and `enableInteractiveSelection: false` does not stop it); no text changes, and a React `<input disabled>` ignores the click.

## Items

Each item was raised in a batch report and approved. Its line numbers are from the commit that raised it and drift as the code changes; when one no longer matches, search for the symbol.

- [ ] **587.** A Flutter arrow-key control holds a D-pad user in (Accessibility · Flutter · Low)
  - Location: the key handlers of `components/radio_group/pl_radio_group.dart` (`_onKey` ~253), `segmented_button/pl_segmented_button.dart` (~352), `tabs/pl_tabs.dart` (~310), `tree/pl_tree.dart` (~325) and `slider/pl_slider.dart` (~392)
  - Problem: Each returns `KeyEventResult.handled` for an arrow whether or not it did anything, and the radio group, segmented button and tabs wrap at both ends. Under `NavigationMode.directional`, where the arrows are the only way to move the focus, a user who reaches a radio group or segmented set cannot leave it; a disabled set swallows the arrows while doing nothing (a disabled option can hold the focus there), as do tabs with no `onChanged`, a tree at its first or last row and a slider at `min` or `max`. Flutter's own `RadioGroup` behaves the same way.
  - Proposal (approved): under `NavigationMode.directional` only, stop wrapping and return `KeyEventResult.ignored` for an arrow that moved nothing, so the focus system takes it to the next control; leave the keyboard behaviour in the traditional mode as it is. Sweep the package for other arrow handlers of the same shape and test each in both modes.

- [ ] **588.** An empty React donut draws its centre over the empty message (Bug · React · Low)
  - Location: `packages/react/src/components/pie-chart/PlPieChart.tsx` (`const centred = Boolean(center) && inner > 0;` ~228, `{centred ? (` ~496)
  - Problem: `centred` does not look at `nothing`, so an empty `donut` or `semi` pie with a `center` draws the centre on top of the empty state's words. The Flutter pie returns only the empty box (`if (nothing || outer <= 0) {`).
  - Proposal (approved): draw no centre while the pie is empty, as Flutter does, with a test.

- [ ] **589.** An empty gauge announces a reading it does not draw (Accessibility · Both · Low)
  - Location: `packages/react/src/components/gauge-chart/PlGaugeChart.tsx` (`aria-label` ~367); `packages/flutter/lib/src/components/gauge_chart/pl_gauge_chart.dart` (`label:` ~256)
  - Problem: A named `PlGaugeChart` whose `min` equals `max` draws only its empty state, but is announced "Quota: 5 / 10" in both builds, followed by the empty words.
  - Proposal (approved): name an empty gauge by its label alone, with the empty words after it, in both builds, with a test in each.

- [ ] **590.** Switching a Flutter data table's `selection` moves its cells' state one column over (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/data_table/pl_data_table.dart` (`if (_ticks)` ~663); the unkeyed cells of each `TableRow` in `internal/table.dart`
  - Problem: Turning `selection` on or off puts a checkbox column in front of every row or takes it away, and since the cells have no keys each data cell is matched with the element of its neighbour: a cell of a different type is built again from scratch, and one of the same type hands its `State` to the next column.
  - Proposal (approved): key each cell by its column, so its state follows it, with a test that a stateful cell keeps its `State` as `selection` changes both ways.

- [ ] **591.** A Flutter table built again whole as its parent's height becomes bounded or unbounded (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/table/pl_table.dart` (`if (bounded) Flexible(child: grid) else grid,` ~293) and `data_table/pl_data_table.dart` (~818), with the comments above each
  - Problem: The grid is wrapped in a `Flexible` only under a bounded height, so moving between the two builds the whole grid again (scroll offset, measured widths, every cell's state). The comment says a `Flexible` asserts under an unbounded height, which is not so for a loose `Flexible` in a `MainAxisSize.min` column (`rendering/flex.dart` ~1121 asserts only for `MainAxisSize.max` or a tight fit).
  - Proposal (approved): always wrap the grid in the `Flexible`, correct the comments, and test that the grid keeps its state across the switch.

- [ ] **592.** A Flutter table's pinned header drifts from its columns as the rows change (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/table.dart` (`if (widget.stickyHeader && _measuredAt != constraints.maxWidth) {` ~541; the only reset, `if (widget.columns.length != oldWidget.columns.length) {` ~209)
  - Problem: The band that pins the header is a copy laid out with widths measured only when the width or the number of columns changes. The grid's columns are intrinsic, so a longer cell widens a column and the band's headers stop lining up (reproduced at x=524 against 416); header content, the text scale and turning `stickyHeader` off and on leave it stale too. React pins the real `<th>` with `position: sticky`.
  - Proposal (approved): measure again whenever the rows, the columns or the header change, and when `stickyHeader` is turned on, with a test that the band lines up after a row widens a column.

- [ ] **593.** A Flutter chip's label is built again as icons change on both sides of it (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/chip/pl_chip.dart` (the inner `Row`, `?startIcon,` ~288)
  - Problem: The label is an unkeyed child between the start icon and the end icon and count, so when both sides change in one build, as a filter chip that gains a check and a count when chosen does, the label is built again from scratch and a stateful label starts over.
  - Proposal (approved): give the label a key of its own, with a test.

- [ ] **594.** A disabled chip that can be pressed stops being a button, and React mounts its content again (Accessibility · Both · Low)
  - Location: `packages/react/src/components/chip/PlChip.tsx` (`const interactive = Boolean(onClick) && !disabled;` ~221, `{interactive ? (<button …>{label}</button>) : (label)}` ~291); `packages/flutter/lib/src/components/chip/pl_chip.dart` (`final interactive = onPressed != null && !disabled;` ~164)
  - Problem: A chip with `onClick` is a button only while enabled. In React the label, icons and count move in and out of the `<button>` as `disabled` changes, so they are mounted again and a `PlAvatar` in `startIcon` loads again, showing its initials until it does; in both builds a disabled chip that can be pressed is not announced as an unavailable button, as a disabled `PlButton` is.
  - Proposal (approved): keep a chip that has `onClick` or `onPressed` a button while disabled, a `<button disabled>` in React and `button: true, enabled: false` in Flutter, so `disabled` no longer mounts the content again; update the docs and test both builds.

- [ ] **595.** A disabled colour picker's value field is only read-only (Accessibility · Both · Low)
  - Location: `packages/react/src/components/color-picker/PlColorPicker.tsx` (`readOnly={inert}` ~543, beside the swatches' `disabled={inert}`); `packages/flutter/lib/src/components/color_picker/pl_color_picker.dart` (`readOnly: inert,` ~749, and `_textFocus`, never excluded from the focus)
  - Problem: In both builds the value field of a disabled picker stays in the Tab order and is announced as read-only rather than unavailable, while its swatches are disabled; inside a disabled `<fieldset>` the React input is natively disabled, so the two ways of disabling the picker disagree.
  - Proposal (approved): make the value field disabled while the picker is `disabled` (out of the Tab order, announced as unavailable) and keep it read-only while it is `readOnly`, in both builds, with a test in each.

- [ ] **596.** Pressing a focused Flutter field does not bring its keyboard back (Bug · Flutter · Low)
  - Location: the shell's `onTap: _disabled ? null : _focusNode.requestFocus,` in `text_field/pl_text_field.dart` (~583) and `number_field/pl_number_field.dart` (~1203), and `_pressField` in `combobox/pl_combobox.dart` (~786)
  - Problem: With the keyboard put away while the field holds the focus (Android's back, for one), a press on the field does nothing, because the focus is already there; a press on the text helps only if it moves the caret. Material's `TextField` calls `requestKeyboard` on every tap.
  - Proposal (approved): have the press call `plassTapEditor` from `internal/editor.dart` (added by item 586), with a test that a press after `TextInput.hide` shows the keyboard again.

- [ ] **597.** Twenty-two Flutter controls still do not say they can take the focus (Accessibility · Flutter · Low)
  - Location: the nodes built inside `PlassInteractive`'s builder in `PlChip`, `PlListItem`, `PlTabs` tabs, `PlSegmentedButton`, `PlAccordion`, `PlCollapsible`, `PlSelect`, `internal/picker.dart`, the `PlNumberField` steppers, `PlBottomNavigation`, `PlFloatingBottomNavigation`, `PlMenubar`, the `PlWindowPane` caption buttons, `PlAppLogo`, `PlNavigationMenu` links, the `PlChatBubble` preview, the `PlToast` action, `PlPill`, `PlTextLink`, `PlBreadcrumb` and `internal/dismiss.dart`
  - Problem: Item 584 added `focusSemantics` for a component whose `Semantics` sits outside the builder, and `plassFocusSemanticsOf` for one whose node is inside it, and used the second only on `PlCard`. These nodes offer a tap and no `focus` action, and never say they are focusable or focused.
  - Proposal (approved): put `plassFocusSemanticsOf(context)` on each of these nodes, and test each with a check of the node that names it.

- [ ] **598.** Three Flutter buttons cannot be pressed from a screen reader (Accessibility · Flutter · Low)
  - Location: `components/code_block/pl_code_block.dart` (the bar button's `Semantics(button: true, toggled: …, label: …)` ~1199), `gallery/pl_gallery.dart` (the tile's `Semantics(button: true, …)` ~672), `toast/pl_toast.dart` (the action's `Semantics(container: true, button: true, …)` ~854)
  - Problem: Each node says it is a button but has no `onTap`, and `PlassInteractive`'s press is kept off the semantics tree, so the node offers only `focus`: a screen reader can reach Copy and Raw, a gallery tile and a toast's action but not press them.
  - Proposal (approved): give each node the tap its press has, sweep the package for another `button: true` node over a press it does not carry, and test each.

- [ ] **599.** A Flutter anchor row draws no focus ring (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/anchor/pl_anchor.dart` (the row's builder ~323, which never reads `state.focusVisible`)
  - Problem: A row reached with the keyboard shows nothing, where the React row draws the house ring (`focusRingClasses`, `PlAnchor.tsx` ~258).
  - Proposal (approved): draw the house focus ring on a row while `state.focusVisible`, with a test.
