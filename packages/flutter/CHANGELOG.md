# Changelog

> This package's unreleased changes and its latest release. Every earlier release is in [`CHANGELOG.archive.md`](https://github.com/jooy2/plass-ui/blob/main/packages/flutter/CHANGELOG.archive.md), and [plass.cdget.com/changelog](https://plass.cdget.com/changelog) shows the whole history on one page. The React package keeps its own at [`packages/react/CHANGELOG.md`](https://github.com/jooy2/plass-ui/blob/main/packages/react/CHANGELOG.md), because the two version independently.

## vNext (2026--)

### Fixed

- **A `PlAvatar` in a `PlListItem` stays round.** A slot was one line tall, so anything taller, such as an avatar beside a two-line row, was squashed into an oval. A slot is now at least a line tall, and as tall as what it holds.
- **A side `PlDrawer` starts at the top of the screen.** Its title, its content and its actions were packed together and centred down the panel. The title now sits at the top and the actions at the bottom, as the React drawer's do.
- **A list in a `PlCard` of a set height scrolls.** The body was given an endless height whatever the card had, so a `ListView` in it threw "Vertical viewport was given unbounded height" and took the screen with it. The body now takes the height the card has left. A card as tall as what it holds is unchanged.
- **A `fullWidth` `PlTabs` lays out.** Its tabs share the width out and the bar scrolled them as well, which threw at every width and left nothing on the screen.
- **A clamped `PlSpoiler` reports no overflow.** `maxHeight` was handed to the content as its own limit, so a column taller than the clamp drew the overflow stripes. The clamp now cuts the box the content is seen through.
- **A `PlAnimateAppear` works where the cross axis has no end.** A horizontal set in a page that scrolls, and a vertical one in a `Row`, threw "BoxConstraints forces an infinite height" or "width". It still fills a cross axis that has an end.
- **A narrow `PlGaugeChart` reports no overflow.** On a dial as narrow as a phone, a reading and a caption are taller than the hole. They now stay centred on it.
- **A `PlPagination` fits a phone.** The row of pages overflowed a narrow screen. It now goes onto a second line.
- **A `PlDataTable` footer fits a phone.** The count and the pager shared a row that overflowed. The pager now takes a line of its own when they do not fit.
- **A `PlNavigationMenu` fits a phone.** A row of items wider than the screen overflowed. It now wraps.
- **A `PlHeader` fits a phone.** A middle wider than the room the brand and the actions left it overflowed. It now scrolls along the bar.
- **A `PlStat` keeps its figure whole.** In a card two to a row on a phone, `£48,120` beside a change was cut to `£4…`. The change now goes under the figure when the two do not fit on one line, and a long label no longer overflows.
- **A `PlSegmentedButton` fits a phone.** Labels wider than the room overflowed. The set now scrolls, as a bar of tabs does.
- **A long `PlOtpField` fits a phone.** A row of eight slots overflowed. The slots now come out smaller where the row does not fit.
- **A horizontal `PlStepper` breaks no label in two.** The step and its connector took half the width each, which broke a label as short as `Account` on a phone, and a step whose label wrapped pushed the other bullets out of line. The connector now takes what the step leaves, and the bullets stay on one line.
- **A `PlPill` that fills its width keeps its end slot at the end.** Its parts were packed at the start, with the rest of the pill empty. The words now take the room left over, as the React pill's do.
- **Code is monospaced on iOS.** `monospace` is a family only Android and the web resolve, so a `PlCodeBlock` and the value in a `PlColorPicker` came out in the proportional system font on iOS and macOS, where a three-digit line number was also too wide for its gutter and wrapped. They now fall back to `Menlo` and the other platforms' monospace faces, and a line number no longer wraps.
- **A chart's horizontal value axis stays readable on a phone.** Every label was drawn however little room there was, so the dates under a `PlTimelineChart` and the numbers under a horizontal chart ran into each other. Labels are now skipped until they clear each other, as in the React build, and the first and last are anchored inward.

## 1.8.2 (2026-10-09)

### Breaking changes

- **Escape no longer empties a `PlCombobox` whose list is closed.** One stray Escape took every chip off a `PlCombobox.multiple`, or the chosen value off a single one. The value now stays, and the `DismissIntent` goes on to whatever the field sits in, so a `PlModal` round the field closes. Escape on an open list still closes it. Pass `clearOnEscape: true` to have Escape empty the field as before.

### Added

- **`PlCombobox` takes `filter`, so a list a server has already searched is shown as it came.** Options were filtered again by their labels, so an option the server matched on another spelling was hidden. `filter: (_, _) => true` keeps every option as given, and any other function decides which options a query keeps. The row that offers what was typed always stays.
- **`PlCombobox` takes `autoHighlight`, and lights the options that arrive after the query changed.** The first row lit up only as the query changed, so options a caller handed in a moment later had nothing lit and Enter closed the list without taking one. `PlComboboxHighlight.query` stays the default and now lights the first of those options as they arrive, as Base UI 1.9.0 does for the React field. `PlComboboxHighlight.always` also lights the first row whenever the open list has rows and none is lit, as when it opens with nothing typed, and `PlComboboxHighlight.none` lights nothing until an arrow key or the pointer does.
- **A `PlComboboxOption` takes `content`, which its row draws in place of the label.** A row could only show its label, so a picture or a second line had nowhere to go. The label is still what is filtered, written into the field and put on the chip.

### Changed

- **Enter on a `PlCombobox` list with no rows keeps the list open and the query in the field.** A list still waiting for its options, or matching nothing, closed on Enter and put the text back, which emptied the query, so the reader had to type it again. Enter there now does nothing. A list with rows and none lit still closes on Enter.

### Fixed

- **A chosen `PlCombobox` value keeps its label once `options` no longer lists it.** A chip, and the text of a single field, read the label off the current `options`, so in a list a server answers, a value the latest query did not find was shown by its value. The field now keeps the label each chosen value was last listed with, including one taken from options that the next query emptied in the same press.
