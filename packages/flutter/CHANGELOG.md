# Changelog

## Unreleased

The rest of the library. `PlButton` shipped first and everything else follows it, ported from the React package the same way it was — value for value, with the places where "the same number" would have been wrong written down where the conversion happens.

### Added

- **`PlTypography`.** The type scale on its own, so a page can use it without wrapping its prose in a card. `level` sets the size *and* whether the line is announced as a heading; there is no `size` beside it, because a `size` would let a caller ask for an `h1` at `xs`. `PlTypography.rich` is the span form.
- **`PlAvatar`.** A picture, or the initials, or a silhouette — never an empty box. `image` is an `ImageProvider` rather than a URL, which is the shape every image in Flutter has, and the fallback is shown until the first frame arrives and for good if none ever does.
- **`PlBadge`.** `content` and `count` are two parameters rather than one, because `max` and `showZero` only mean anything for a number: the type is the question the React build has to ask at runtime.
- **`PlChip`.** A pressable chip and its delete affordance are two separate focus stops, neither inside the other's gesture recogniser — the same shape the React build reaches for, there because a `<button>` inside a `<button>` is invalid and here because a nested recogniser would take one tap twice.
- **`PlCard`.** The sheet, with the title, subtitle, header action, body and footer laid out on it. `onPressed` is what `render={<a href>}` was mostly reached for: it makes the card a real focus stop, announced and keyboard-reachable, and it lifts.
- **`PlAlert`.** The three shapes, the six severities and their marks. Flutter has one live region rather than two politeness levels, so `role="alert"` against `role="status"` becomes whether the alert is a live region at all.
- **`PlCheckbox`**, **`PlRadioGroup`** and **`PlSwitch`.** Every one of them is **controlled** — handed a value, reporting what the value should become — which is how Flutter's own controls work and why there is no `defaultChecked` anywhere in the package. A radio group is generic in its option's type, so `value` and `onChanged` are checked rather than `dynamic`, and it owns the roving tab index: exactly one option is in the tab order, the rest are wrapped in an `ExcludeFocus`, and the arrow keys move the choice with wrapping.
- **`PlTextLink`.** A line under a word, and no `href`: Flutter has no navigation of its own, so where a link goes is the app's and `onPressed` is where it is decided. Announced as a link rather than as a button, which is what puts it in a screen reader's list of links.
- **`PlHotKeys`** and **`PlKbd`.** `Mod` resolves per platform from `defaultTargetPlatform`, and every key drawn as a glyph announces its real name — `⌘` read out is "place of interest sign", which is not a key anybody has.
- **`PlList`** and **`PlListItem`.** The list is the sheet and the rows are what is on it, so `size`, `density`, `color` and `dividers` reach a row through an `InheritedWidget`. A row's `action` is a separate focus stop from the row itself.
- **`PlBreadcrumb`** and **`PlTimeline`.** Both take their members as **descriptions rather than widgets** — Flutter's own idiom, the one `DataColumn` uses. The reason is that both have to reason about their members: which step is the current page, how many there are, which the fold takes out, which connector is the last. A `Widget` is opaque and none of that can be asked of one.
- **`PlDivider`.** A rule between two things, horizontal or vertical, with an optional label set into it. `length` wins over a tight parent — a divider very often sits in a `Column` with `crossAxisAlignment: stretch`, where a bare `SizedBox` would be handed a tight width and lose.
- **`PlSkeleton`.** The shape of something that has not loaded yet, in the three shapes a layout is made of. The travelling highlight is one gradient slid across the box by a `GradientTransform` rather than a second widget laid out per placeholder, and it becomes a colour pulse where the platform has asked for less movement — kept running either way, because a skeleton that holds still is indistinguishable from an empty box that finished loading with nothing in it.
- **`PlBlockquote`.** The rule, the quotation mark and the attribution. The mark is drawn rather than typed, unit for unit out of the same 16-unit box the React package's SVG uses.
- **`PlHighlight`.** The search as well as the styling. It takes a `String` rather than a widget tree, which is the one real difference from the React build: a `Widget` is opaque, and there is no reaching the text inside one you were handed.
- **`PlIcon`.** A glyph at a known size in a known colour, for whichever icon set the app chose. The glyph is told how big it is three ways at once — through `IconTheme`, through `DefaultTextStyle`, and by the box it is laid into — so an `Icon`, a `CustomPaint` that reads the ambient theme and a bare character all come out the same size. `color` is nullable and defaults to `null`, which is how "inherit" is spelled in a language with no such keyword.

## 0.0.2

A packaging release. No component changed, and no code in `lib/` did either — everything here is about what pub.dev was shown, and what it was shown was wrong in three ways.

### Fixed

- **The homepage pointed at a host that does not exist.** The documentation is at [plass.cdget.com](https://plass.cdget.com); `pubspec.yaml` claimed `plass-ui.cdget.com`, which resolves to nothing. pub.dev checks the URL, so this cost the package its pubspec points outright.
- **The description was 195 characters**, and pub.dev's ceiling is 180. Shortened to 174 without dropping anything it was actually saying.
- **The gallery was not in the published archive.** `.pubignore` excluded `example/`, so the directory 0.0.1's notes describe as shipping was in the repository and nowhere else — and pub.dev reported the package as having no example. It ships now, along with an `example/README.md` that is a whole running app in forty lines, since the gallery's own `main.dart` opens on the machinery that lets the documentation site embed it rather than on anything a reader wants first.

## 0.0.1

The first release of the Flutter package, and a preview rather than a product. One component ships; what is actually being released is the shape everything after it will be poured into — the tokens, the scales, the theme and the test setup.

The design language itself is not new: it is the one the [React package](https://www.npmjs.com/package/plass-ui) already ships, ported value for value. The [documentation](https://plass.cdget.com) is one site for both, with a framework switch in the sidebar.

### Added

- **`PlButton`.** `variant` (`solid` · `glass` · `ghost`), `size`, `color`, `density` and `elevation` off the shared vocabulary, plus `startIcon`, `endIcon`, `loading`, `readOnly`, `disabled`, `fullWidth`, `semanticLabel` and the usual `focusNode` / `autofocus` / `onLongPress`. `onPressed: null` disables the button, as it does everywhere else in Flutter.
- **`PlassTheme`**, and the fact that you do not need it. A component resolves its tokens from the nearest one and falls back to `MediaQuery.platformBrightness` when there is none, so a button dropped into any app is already in the right theme and follows the system switch. The theme is an override, not a prerequisite.
- **`PlassTokens`** — the whole token sheet as Dart: six colour families, three glass strengths, the elevation ladder, the tinted lift, the radii, the durations and the two curves. Four values are hand-picked per family and everything else is derived, so adding a family is one entry in `PlassColor` plus its colours.
- **The shared vocabulary** — `PlassSize`, `PlassColor`, `PlassVariant`, `PlassDensity`, `PlassElevation`, `PlassOrientation`, `PlassSide`, `PlassAlign`, `PlassCorner`. An `md` is 40px on everything, and it is the same 40px the React package means.
- **Nothing from `material.dart` or `cupertino.dart`.** The package is built on `package:flutter/widgets.dart` alone, which is what lets it sit inside a Material app, a Cupertino app or a bare `WidgetsApp` without dragging a second design system in behind it — and what makes it indifferent to those two libraries moving out of the framework.
- **No dependencies at all**, and no assets or platform channels.
- **A gallery**, under `example/`. It runs as an app on any device, and its web build is what the documentation site embeds behind every Flutter preview — so the previews on the site are the real package, not a screenshot.

### Matched to the React build on purpose

Three things do not port across as the same number, and each is converted rather than copied:

- **Shadow blur.** CSS defines a shadow's blur radius as twice the Gaussian standard deviation; Flutter's `BoxShadow.blurRadius` converts with `σ = r × 0.57735 + 0.5`. Handing Flutter the CSS number makes every shadow about a fifth softer than the one it is copying, so the ladder is converted on the way in.
- **The `solid` gradient.** `LinearGradient(topLeft → bottomRight)` runs along the box's diagonal, which is only 135° on a square; on a wide button the sweep visibly flattens. The endpoints are computed per paint the way `linear-gradient(135deg, …)` specifies instead.
- **The glass hairline.** `BoxShadow` only casts outward, and the light along a sheet's top edge is an inset shadow. It is reproduced exactly — the shape minus the same shape moved down a pixel, clipped back to the shape.

And two visible differences that are not bugs: the font is whatever the host uses (neither package sets one), and `PlassDensity.standard` is spelled `'default'` in React, because `default` is a reserved word in Dart.
