# Differences between the builds

Small differences between the React and the Flutter builds of the same component, found during the audit of both packages from 2026-09-13 to 2026-09-28. Each was recorded rather than fixed, because a reader would not call either build broken: a pixel of size, a colour a step apart, a change that eases in one build and happens at once in the other, or a detail of the keyboard or the semantics that only a close comparison shows.

Line numbers are from the commit that found each difference and drift as the code changes; when one no longer matches, search for the symbol. A difference that is closed later is deleted from this list.

- `PlWindowPane`: over a draggable bar Flutter shows `SystemMouseCursors.move` (`pl_window_pane.dart` ~797), React `cursor-grab` and `active:cursor-grabbing` (`PlWindowPane.tsx` ~872); both show that cursor over the caption buttons' column outside the buttons, where nothing drags.
- Charts: Flutter draws no category-axis rule (`tokens.chartAxis` is read nowhere), where React draws one at the zero line in `--plass-chart-axis` (`ChartAxes` in `chart-frame.tsx`).
- Charts: React draws the zero gridline in `--plass-chart-baseline`, Flutter every gridline in `chartGrid` (`chart_frame.dart` ~1794-1810).
- `PlScatterChart`: Flutter draws no vertical gridlines, React draws them when the x axis measures (`categoryGrid`).
- `PlAreaChart`: a stacked Flutter area has no 2px surface line between bands (React `chart-line.tsx` ~235).
- Charts: a faded series' value labels fade in React (inside the series `<g>`) and stay whole in Flutter (`_paintValueLabels`, `chart_line.dart` ~220).
- Charts: Flutter replaces the alpha of a series or point colour it is given (`chart_line.dart` ~89, the scatter fill, `pl_bar_chart.dart` ~351, `pl_pie_chart.dart` ~752), where React keeps it.
- `PlHeatmapChart`: the Flutter card sits 8px higher than the React one (`pl_heatmap_chart.dart` ~468 and `chart_frame.dart` ~2724, against `chart-frame.tsx` ~715).
- Charts: `markers: auto` counts each series' own points in React (`chart-line.tsx` ~266) and the chart's categories in Flutter (`chart_line.dart` ~58-60), so a short series on a long chart has markers in React only.
- `PlHeader`: with no middle, the Flutter row keeps a gap on each side of its empty `Expanded` middle (`pl_header.dart` ~219-233), so its narrowest width is one gap wider than React's.
- `PlSegmentedButton`: a segment disabled on its own in a live set fades by opacity only in React (`data-[disabled]:opacity-50`), where Flutter also drains its colour (`plassStateFilter`).
- `PlSegmentedButton`: the chosen segment of a disabled set draws its label in `mutedFg` in Flutter (`pl_segmented_button.dart` ~624) and in its on-fill or accent ink in React (`PlSegmentedButton.tsx` ~153-155).
- `PlTable` and `PlDataTable`: every cell of an interactive Flutter row carries its own tap that presses the row (`internal/table.dart` ~293), where the React row is one stop.
- Charts: when the legend lets go, the React `mask` that keeps a faded line out of its markers goes at once while the series' opacity eases back, so the line shows through its markers for about 150ms (`chart-line.tsx`, the band `<g>`).
- `PlAppLogo`: the React logo rendered as a link (`render={<a href="/" />}`) draws no house focus ring (`PlAppLogo.tsx` ~171-175 sets `controlSlots` but not `focusRingClasses`), so it shows the browser's own outline where the Flutter logo draws the family's ring; `PlAspectRatio` documents the same link `render` (`PlAspectRatio.tsx` ~53).
- `PlAppLogo`: a pressable Flutter logo is a button that `Space` presses as well as `Enter` (`pl_app_logo.dart` ~264), where the React logo is usually a link that only `Enter` follows.
- `PlSegmentedButton`: when `value` changes from outside while the arrows of a read-only Flutter set have moved the focus, the focus stop goes back to the chosen segment; React leaves it where the arrows put it.
- `PlCombobox` chips: each Flutter × is a Tab stop and there is no `Backspace` or arrow handling for chips, where React reaches the chips with the arrows (the × has `tabIndex: -1`) and `Backspace` in an empty input removes the last chip; the chips of a disabled or read-only Flutter combobox carry no enabled or read-only state, where React's carry `aria-disabled` or `aria-readonly`.
- Fields: a Flutter field's adornments are read after the field, as children of its node, where React's start adornment comes before the input.
- `PlRadioGroup` and `PlSegmentedButton`: in a read-only Flutter set, the focus stop the arrows moved goes back to the chosen option when `value` changes from outside or `readOnly` is lifted; Base UI keeps the highlighted item (`useCompositeRoot` reads `ACTIVE_COMPOSITE_ITEM` only on its first `onMapChange`), in a live group too.
- `PlChip`: a disabled chip with no `onClick` shows `cursor-not-allowed` and carries `aria-disabled` on its shell in React, where the Flutter chip defers the cursor and its node says nothing about being disabled.
- `PlChip`: the React label, icons and count are mounted again as `onClick` comes or goes (`{pressable ? (<button …>{label}</button>) : (label)}`), so a `PlAvatar` in `startIcon` loads again; the Flutter chip keeps them.
- React pickers: inside a native `<fieldset disabled>` the trigger is disabled by the browser but does not look disabled, since `PickerShell` reads only `useDisabled` (the `PlFieldset` context); `PlColorPicker`'s panel reads both since item 600.
- `PlWindowPane`: a corner grown past the box the window is laid out in reports through `onResize` a size the Flutter window is not drawn at, since the box's constraints win (`_resizeTo` in `pl_window_pane.dart`); the React window overflows its container at the size it reports.
- Arrow keys: an arrow at an end still reports the unchanged value through `PlSlider`'s callbacks (`_report(index, value, ended: true);`), the `PlPanes` and `PlSidebar` `onResize`/`onResizeEnd`, the `PlWindowPane` corner's `onResize` and the `PlColorPicker` square and rails, in both navigation modes; not compared with React.
