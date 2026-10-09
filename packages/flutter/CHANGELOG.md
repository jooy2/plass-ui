# Changelog

> This package's unreleased changes and its latest release. Every earlier release is in [`CHANGELOG.archive.md`](https://github.com/jooy2/plass-ui/blob/main/packages/flutter/CHANGELOG.archive.md), and [plass.cdget.com/changelog](https://plass.cdget.com/changelog) shows the whole history on one page. The React package keeps its own at [`packages/react/CHANGELOG.md`](https://github.com/jooy2/plass-ui/blob/main/packages/react/CHANGELOG.md), because the two version independently.

## vNext (2026--)

## 1.8.1 (2026-10-09)

### Changed

- **`PlConfirmProvider` asks its questions in an alert dialog.** The layer `confirm` and `alert` open claims `SemanticsRole.alertDialog` beside its route, as the React question is a `role="alertdialog"`, so a screen reader that reads roles announces the question as an alert. A `PlModal` of its own claims nothing more than its route, as before.

### Fixed

- **A toast and a confirmation in `MaterialApp`'s `builder` no longer take its yellow double underline.** What `builder` returns sits above every page's `Material`, where the text style in scope is the one `MaterialApp` marks text outside a `Material` with, so the words of a `PlToastProvider`'s toasts and of a `PlConfirmProvider`'s questions were drawn underlined in monospace. A toast and a `PlModal`'s sheet now clear any inherited decoration. The font is the app's to give, so the getting-started guide and both providers now show a `Material` of `MaterialType.transparency` round the provider under `MaterialApp`.
- **A full-width `PlSegmentedButton` whose labels are wider than equal parts no longer overflows.** Every segment took an equal part of the row, so a label wider than its part ran out of its segment: `1,000`, `10,000` and `100,000` at `PlassSize.sm` in a 240-pixel card overflowed the last one. A segment whose label needs more than its part now keeps the width it needs and the others share what is left, as the React set already does, so those three fit. Only labels that together need more than the row are cut short, each with an ellipsis.
- **A `PlDataTable` or `PlTable` with its header pinned no longer overflows when its rows narrow the columns.** The pinned header takes the columns' widths from the grid after the frame that laid them out, so in the frame where a filter or a page left narrower cells it still held the wider ones and its row overflowed, which a debug build drew as stripes for a frame and `flutter_test` reported as an error. The header now lays its row out at the widths it holds, and moves to the new ones a frame later as before.
