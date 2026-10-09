# Changelog

> This package's unreleased changes and its latest release. Every earlier release is in [`CHANGELOG.archive.md`](https://github.com/jooy2/plass-ui/blob/main/packages/flutter/CHANGELOG.archive.md), and [plass.cdget.com/changelog](https://plass.cdget.com/changelog) shows the whole history on one page. The React package keeps its own at [`packages/react/CHANGELOG.md`](https://github.com/jooy2/plass-ui/blob/main/packages/react/CHANGELOG.md), because the two version independently.

## vNext (2026--)

### Breaking changes

- **Escape no longer empties a `PlCombobox` whose list is closed.** One stray Escape took every chip off a `PlCombobox.multiple`, or the chosen value off a single one. The value now stays, and the `DismissIntent` goes on to whatever the field sits in, so a `PlModal` round the field closes. Escape on an open list still closes it. Pass `clearOnEscape: true` to have Escape empty the field as before.

### Added

- **`PlCombobox` takes `filter`, so a list a server has already searched is shown as it came.** Options were filtered again by their labels, so an option the server matched on another spelling was hidden. `filter: (_, _) => true` keeps every option as given, and any other function decides which options a query keeps. The row that offers what was typed always stays.
- **`PlCombobox` takes `autoHighlight`, and `PlComboboxHighlight.always` lights the options that arrive after the query changed.** The first row lit up only as the query changed, so options a caller handed in a moment later had nothing lit and Enter closed the list without taking one. `PlComboboxHighlight.always` lights the first row whenever the open list has rows and none is lit. `PlComboboxHighlight.query` stays the default, and `PlComboboxHighlight.none` lights nothing until an arrow key or the pointer does.
- **A `PlComboboxOption` takes `content`, which its row draws in place of the label.** A row could only show its label, so a picture or a second line had nowhere to go. The label is still what is filtered, written into the field and put on the chip.

### Changed

- **Enter on a `PlCombobox` list with no rows keeps the list open and the query in the field.** A list still waiting for its options, or matching nothing, closed on Enter and put the text back, which emptied the query, so the reader had to type it again. Enter there now does nothing. A list with rows and none lit still closes on Enter.

### Fixed

- **A chosen `PlCombobox` value keeps its label once `options` no longer lists it.** A chip, and the text of a single field, read the label off the current `options`, so in a list a server answers, a value the latest query did not find was shown by its value. The field now keeps the label each chosen value was last listed with, including one taken from options that the next query emptied in the same press.

## 1.8.1 (2026-10-09)

### Changed

- **`PlConfirmProvider` asks its questions in an alert dialog.** The layer `confirm` and `alert` open claims `SemanticsRole.alertDialog` beside its route, as the React question is a `role="alertdialog"`, so a screen reader that reads roles announces the question as an alert. A `PlModal` of its own claims nothing more than its route, as before.

### Fixed

- **A toast and a confirmation in `MaterialApp`'s `builder` no longer take its yellow double underline.** What `builder` returns sits above every page's `Material`, where the text style in scope is the one `MaterialApp` marks text outside a `Material` with, so the words of a `PlToastProvider`'s toasts and of a `PlConfirmProvider`'s questions were drawn underlined in monospace. A toast and a `PlModal`'s sheet now clear any inherited decoration. The font is the app's to give, so the getting-started guide and both providers now show a `Material` of `MaterialType.transparency` round the provider under `MaterialApp`.
- **A full-width `PlSegmentedButton` whose labels are wider than equal parts no longer overflows.** Every segment took an equal part of the row, so a label wider than its part ran out of its segment: `1,000`, `10,000` and `100,000` at `PlassSize.sm` in a 240-pixel card overflowed the last one. A segment whose label needs more than its part now keeps the width it needs and the others share what is left, as the React set already does, so those three fit. Only labels that together need more than the row are cut short, each with an ellipsis.
- **A `PlDataTable` or `PlTable` with its header pinned no longer overflows when its rows narrow the columns.** The pinned header takes the columns' widths from the grid after the frame that laid them out, so in the frame where a filter or a page left narrower cells it still held the wider ones and its row overflowed, which a debug build drew as stripes for a frame and `flutter_test` reported as an error. The header now lays its row out at the widths it holds, and moves to the new ones a frame later as before.
