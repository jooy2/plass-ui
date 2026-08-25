# Changelog

## 0.0.1

The first release of the Flutter package, and a preview rather than a product. One component ships; what is actually being released is the shape everything after it will be poured into — the tokens, the scales, the theme and the test setup.

The design language itself is not new: it is the one the [React package](https://www.npmjs.com/package/plass-ui) already ships, ported value for value. The [documentation](https://plass-ui.cdget.com) is one site for both, with a framework switch in the sidebar.

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
