# Changelog

> This package's unreleased changes and its latest release. Every earlier release is in [`CHANGELOG.archive.md`](https://github.com/jooy2/plass-ui/blob/main/packages/flutter/CHANGELOG.archive.md), and [plass.cdget.com/changelog](https://plass.cdget.com/changelog) shows the whole history on one page. The React package keeps its own at [`packages/react/CHANGELOG.md`](https://github.com/jooy2/plass-ui/blob/main/packages/react/CHANGELOG.md), because the two version independently.

## vNext (2026--)

### Fixed

- **A `PlAvatar` in a `PlListItem` stays round.** A slot was one line tall, so anything taller, such as an avatar beside a two-line row, was squashed into an oval. A slot is now at least a line tall, and as tall as what it holds.
- **A side `PlDrawer` starts at the top of the screen.** Its title, its content and its actions were packed together and centred down the panel. The title now sits at the top and the actions at the bottom, as the React drawer's do.
- **A list in a `PlCard` of a set height scrolls.** The body was given an endless height whatever the card had, so a `ListView` in it threw "Vertical viewport was given unbounded height" and took the screen with it. The body now takes the height the card has left. A card as tall as what it holds is unchanged.
- **A `fullWidth` `PlTabs` lays out.** Its tabs share the width out and the bar scrolled them as well, which threw at every width and left nothing on the screen.

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
