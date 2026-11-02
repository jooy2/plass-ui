# Changelog

> This package's unreleased changes and its latest release. Every earlier release is in [`CHANGELOG.archive.md`](https://github.com/jooy2/plass-ui/blob/main/packages/flutter/CHANGELOG.archive.md), and [plass.cdget.com/changelog](https://plass.cdget.com/changelog) shows the whole history on one page. The React package keeps its own at [`packages/react/CHANGELOG.md`](https://github.com/jooy2/plass-ui/blob/main/packages/react/CHANGELOG.md), because the two version independently.

## vNext (2026--)

## 1.9.0 (2026-11-02)

### Added

- **A selection in a field has handles and a menu on a touch screen.** Those parts come from Material and Cupertino, which this package imports neither of, so a word taken with a long press could not be adjusted or copied and nothing could be pasted in. `PlTextField`, `PlNumberField` and `PlCombobox` now draw handles in the field's colour, and those three, `PlColorPicker` and `PlCommandPalette` offer the platform's menu: the system's own on iOS, and a sheet of glass elsewhere. A press, a long press, a double tap and a drag now do what they do in a `TextField` on every platform. A field with no `Overlay` above it goes on working without them.

### Changed

- **`PlConfirmProvider` brings its own `Overlay` in a `builder`.** Placed there without `Overlay.wrap`, the first question threw "No Overlay widget found" and filled the screen with the error. The `Overlay.wrap` an app already has keeps working, and the provider no longer needs it.

### Fixed

- **An invalid field has a red edge at rest.** The edge stayed neutral until the pointer or the focus reached the field, and a `solid` or a `ghost` field had none at all, so only the message said anything was wrong. This holds for `PlTextField`, `PlNumberField`, `PlSelect`, `PlCombobox`, `PlOtpField` and the date and time pickers, in all three variants.
- **`PlColorPicker` and `PlCommandPalette` have selection handles.** Their fields had the menu and no way to adjust a selection with a finger.
- **A word selected a second time keeps its handles.** A long press on a word still selected from before the field lost the focus brought up the menu and no handles.
- **A painted `PlWindowPane` title bar keeps its fill.** The `macosx`, `windows7` and `windowsxp` bars lost their colour under their gloss, so the page showed through and a title on a dark page could hardly be read. Their gloss also now passes through the same colours as the React build, where it had a grey band across it.
- **A reference line's label stays clear of the data.** `Budget` on a `PlLineChart` sat on the plot, where the line could run straight through it. The label now sits past the end of the line, or above it on a horizontal chart, and the plot gives up the room. A long label is cut.
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
- **A horizontal `PlBarChart` shows the whole of its longest value.** A bar that reached the end of the plot had its value cut off at the edge of the chart. The plot now keeps room for it.
- **A popup stays on the screen along its anchor.** A `PlMenu`, `PlPopover` or tooltip by the edge of a phone ran off it, because a popup flipped only to the other side of its anchor. It now lines up with the anchor's other end as well.
- **The system back closes a question from a provider in a `builder`.** A layer above the navigator had no route to hold, so Android's back left the question up and popped the page under it. A `PlConfirmProvider` there now closes first, as any other layer does.
- **The keyboard's done key closes a `PlCombobox` on a phone.** With no row lit it kept the focus, so the keyboard stayed up over the screen with nothing to put it away.
- **A `PlIcon` shows on a dark page.** With no `IconTheme` above it an icon took Flutter's fallback black. It now takes the colour of the text around it, as `currentColor` does.
- **A `PlSidebar` takes the `width` it is given.** One under `minWidth` came out at `minWidth` even when it could not be resized, which left a narrow page no room for its content. The bounds now apply only to a sidebar that can be dragged, as in the React build.
- **The example app runs on iOS and Android.** It stacked every demo in one column, so a single failed layout left the screen black, plain text came out white on a light canvas, and pictures named by a website's path threw. It now builds its demos as it scrolls, sets the colour of plain text, and names pictures by their full address, so a snippet copied from the documentation works in an app too.
