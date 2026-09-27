# Audit TODO

The open findings of a full audit of both packages, the documentation site and the repository, taken at `148a20e4` on 2026-09-13, and of the batches that have worked through it since. The work goes in batches of twenty. When no item is left, delete this file in a commit of its own.

A closed item is deleted from this file, not ticked, and its number is not used again. Batches 1 to 33 closed 604 items between `148a20e4` and `a63f7c3d`; those items and the notes of batches 1 to 29 are in the history of this file.

**7 items are open, and the last number used is 613.**

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

None. Every question batch 33 asked was answered with an item, with a fix the batch made itself, or with a line under Noted differences.

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
- `PlPieChart` and `PlGaugeChart`: in a box too small to draw in (`outer <= 0`), Flutter draws the empty state's words even with data (`pl_pie_chart.dart`, `if (nothing || outer <= 0) {`; `pl_gauge_chart.dart`, `if (box.outer <= 0 || range == 0) {`), so a named gauge is read "Quota: 68 / 100" and then "Nothing here"; React draws nothing there (`width > 0 && outer > 0 ? (`).
- `PlColorPicker`: the Flutter value field's inset inside its border (`EdgeInsets.symmetric(horizontal: 6, vertical: 4)`) is outside the editor and takes no press, where the React `<input>` owns its border and padding, so a click there focuses it (read from the code).
- `PlChip`: a disabled chip with no `onClick` shows `cursor-not-allowed` and carries `aria-disabled` on its shell in React, where the Flutter chip defers the cursor and its node says nothing about being disabled.
- `PlChip`: the React label, icons and count are mounted again as `onClick` comes or goes (`{pressable ? (<button …>{label}</button>) : (label)}`), so a `PlAvatar` in `startIcon` loads again; the Flutter chip keeps them.
- React pickers: inside a native `<fieldset disabled>` the trigger is disabled by the browser but does not look disabled, since `PickerShell` reads only `useDisabled` (the `PlFieldset` context); `PlColorPicker`'s panel reads both since item 600.
- Arrow keys: an arrow at an end still reports the unchanged value through `PlSlider`'s callbacks (`_report(index, value, ended: true);`), the `PlPanes` and `PlSidebar` `onResize`/`onResizeEnd`, the `PlWindowPane` corner's `onResize` and the `PlColorPicker` square and rails, in both navigation modes; not compared with React.

## Items

Each item was raised in a batch report and approved. Its line numbers are from the commit that raised it and drift as the code changes; when one no longer matches, search for the symbol.

- [ ] **603.** Every Flutter menu trigger sits in an unnamed focus stop that holds the focus while the menu is open (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/menu/pl_menu.dart` (`final Widget trigger = Focus(focusNode: _focusNode, onKeyEvent: _onKey,` ~693; `_focusNode` ~385; `_focusNode.requestFocus();` in `_openMenu` ~466)
  - Problem: The `Focus` round the trigger leaves `includeSemantics` at `true`, so every `PlMenu` trigger, a `PlButton` for one, sits in a focusable node with no name whose focus action moves the focus to the menu's own node rather than to the trigger. While the menu is open the primary focus is on that node, so the named trigger is never announced as focused. The comment at ~689 ("Focus stays on the trigger while the popup is up") says otherwise. React's trigger is one Base UI `Menu.Trigger` button.
  - Proposal (approved): take the wrapper's semantics away (`includeSemantics: false`) and have the named trigger's node say it holds the focus while the menu is open, checking what a screen reader reads while it is; correct the comment, and test the tree with the menu shut and open. The `PlMenubar` case in `test/package/focus_semantics_test.dart` passes `alone: false` because of this node.

- [ ] **607.** A Flutter table wider than its sheet is cut off, and its pinned header overflows (Bug · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/table.dart` (the grid's vertical `SingleChildScrollView` ~537, `PlassKeyboardScroll(vertical: _scroll,` ~631, `_PinnedHeader.build`'s `IntrinsicHeight(child: Row(` ~980); the sheet's `ClipRRect` in `internal/surface.dart` ~305; `docs/en/components/display/table.md` ~343 and the `ko` twin
  - Problem: The grid scrolls only up and down. Once the columns cannot shrink further, the sheet clips them, and with `stickyHeader` the band's `Row` overflows (a `RenderFlex` overflow in debug, reproduced with a 640-wide `PlTable` headed 'Build, with where it ran and why'). The docs tell a Flutter reader to wrap the table in a horizontal `SingleChildScrollView`, which gives the stretched `Column` of `PlTable` and of the grid an unbounded width (read from the code, not run). React scrolls the sheet sideways (`overflow-x-auto`, `PlTable.tsx` ~275).
  - Proposal (approved): scroll the grid sideways, as React does, when its columns need more room than the sheet has, with the pinned band moving with it and the keyboard scroll given the horizontal controller; take the workaround out of the docs (en and ko, table and data table pages) and say the table scrolls sideways; test a wide table in `PlTable` and `PlDataTable`, with and without `stickyHeader`.

- [ ] **609.** Under directional navigation, an arrow across a control's axis still changes its value (Accessibility · Flutter · Low)
  - Location: `components/slider/pl_slider.dart` (~368-376, no orientation check), `segmented_button/pl_segmented_button.dart` (~364-365), `radio_group/pl_radio_group.dart` (~266-267), `rating/pl_rating.dart` (~326, ~328), `color_picker/pl_color_picker.dart` (the rails' `_nudges`, ~921-926 and ~1001-1004), `panes/pl_panes.dart` (~496-501)
  - Problem: A horizontal `PlSegmentedButton`, `PlSlider` or colour-picker rail takes up and down, a vertical `PlRadioGroup` left and right, a `PlRating` up and down, and a `PlPanes` handle all four, so a D-pad reader leaves only after driving the value to an end. Material's `Slider` binds only the arrows along its axis under `NavigationMode.directional` (`material/slider.dart` ~655-660, ~962-966); `PlSidebar`'s handle already binds only its own axis.
  - Proposal (approved): under `NavigationMode.directional` only, take the arrows along the control's axis and hand the others on to the focus system (through `internal/arrows.dart`), leaving the traditional mode as it is; test each in both modes. `PlPanes` also flips up and down on a horizontal split in RTL (`final int steps = widget.horizontal && rtl ? -intent.steps : intent.steps;` ~508); check that on the way.

- [ ] **610.** Under directional navigation, some arrows never run out, so a D-pad reader cannot leave (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/calendar.dart` (the day grid's `_onDayKey` ~921-938 and the month and year grids' `_onCursorKey` ~1064-1081), the `PlColorPicker` hue rail (~651-661, it wraps), `PlWindowPane`'s corner (`_nudge` ~593-599, no ceiling on right and down)
  - Problem: The calendar grids move across months and years without an end (`minDate` and `maxDate` only draw a day as disabled), the hue rail goes round, and the window corner grows to the right and down without a limit, so every arrow there moves something and none is handed on.
  - Proposal (approved): under `NavigationMode.directional` only, treat what is shown as the end: the calendar stops at the edge of the month or page shown (the month changes with the header's buttons and Page keys; check what Material's `CalendarDatePicker` does and follow it where it fits), the hue rail stops at either end instead of wrapping, and the window corner stops at the edge of its area; an arrow past that goes on to the next control. Leave the traditional mode as it is, and test each in both modes.

- [ ] **611.** Under directional navigation, a closed select or combobox takes up and down (Accessibility · Flutter · Low)
  - Location: `components/select/pl_select.dart` (`if (!_open) {` / `_openList();` ~300-303), `combobox/pl_combobox.dart` (`_move` ~857-859, `_MoveIntent: CallbackAction<_MoveIntent>(` ~1485, `if (!_openable || _open) {` ~725)
  - Problem: A closed `PlSelect` or `PlCombobox` opens its list on up or down in directional mode too, so a D-pad reader cannot move up or down past it; the combobox's `CallbackAction` reports the arrows handled even when it cannot open.
  - Proposal (approved): under `NavigationMode.directional` only, open with Enter or Select rather than with up and down, and hand those arrows on while the list is shut; move the combobox onto `PlassArrowAction`; keep an open list's arrows and the traditional mode as they are; test both.

- [ ] **612.** Under directional navigation, a scroll box scrolls to its end before the focus leaves a control inside it (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/internal/keyboard_scroll.dart` (`onKeyEvent: _onKey,` ~242; `_onKey` ~156-223 never reads `hasPrimaryFocus`)
  - Problem: `PlassKeyboardScroll` (`PlScrollArea`, `PlScrollZone`, `PlTable`, `PlDataTable`) answers arrows that bubble up from a focused descendant, a sortable `PlDataTable` heading or a control that hands an arrow on at its end (item 587), so in directional mode the box scrolls 40px a press to its end before the focus moves.
  - Proposal (approved): under `NavigationMode.directional` only, scroll with the arrows only while the box itself holds the focus, and let a descendant's arrow go to focus traversal, which brings the newly focused control into view; keep the traditional mode as it is, as a browser does; test both.

- [ ] **613.** A disabled Flutter tree row is a focus stop under directional navigation (Accessibility · Flutter · Low)
  - Location: `packages/flutter/lib/src/components/tree/pl_tree.dart` (`focusNode: node.disabled ? null : _nodeFor(node.id),` ~431); `_decide` in `internal/interaction.dart` (`NavigationMode.directional => true,`)
  - Problem: A disabled row gets no node from the tree, so its `PlassInteractive` makes one of its own, which is not `skipTraversal` and, under `NavigationMode.directional`, can take the focus, as every unavailable control can there. An arrow the tree hands on past its last reachable row (item 587) can land on a disabled row below it, although the tree's own walk skips disabled rows and `docs/en/components/display/tree.md` ~134 says a disabled row "is not a stop for the arrow keys".
  - Proposal (approved): keep a disabled tree row out of the focus order in every navigation mode, as the exception to the directional rule for an item inside one composite control, with a screen reader still reading it; test it in both modes.
