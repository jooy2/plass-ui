/// How a Plass widget finds its tokens.
///
/// There is deliberately nothing to install. A [PlButton] dropped into an app
/// with no Plass ancestor anywhere works, and works in the right theme, because
/// [PlassTheme.of] falls back to the platform's own brightness. A theme is
/// something you reach for when you want to *override* that — a preview pinned
/// to dark, a screen that is always light — rather than a provider you have to
/// remember before anything renders.
///
/// This is the same bargain the CSS makes: `styles.css` declares both themes on
/// `:root` and answers `prefers-color-scheme`, and `[data-theme]` on any
/// ancestor overrides it.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/tokens.dart';

/// Pins everything below it to one theme.
///
/// ```dart
/// PlassTheme(
///   brightness: Brightness.dark,
///   child: const PlButton(child: Text('Save')),
/// )
/// ```
class PlassTheme extends InheritedWidget {
  /// Pins [child] and its subtree to [brightness].
  PlassTheme({required Brightness brightness, required super.child, super.key})
    : tokens = PlassTokens.of(brightness);

  /// Pins [child] and its subtree to a token set you resolved yourself.
  const PlassTheme.tokens({required this.tokens, required super.child, super.key});

  /// The resolved tokens this subtree reads.
  final PlassTokens tokens;

  /// The tokens in scope, or the platform's own theme if none were pinned.
  ///
  /// Reading `MediaQuery` rather than a stored default is what makes an
  /// unwrapped widget follow the system switch: the dependency is registered,
  /// so a device flipped to dark rebuilds the button.
  static PlassTokens of(BuildContext context) {
    final pinned = context.dependOnInheritedWidgetOfExactType<PlassTheme>();

    if (pinned != null) {
      return pinned.tokens;
    }

    return PlassTokens.of(MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light);
  }

  /// The tokens pinned by an ancestor, or `null` if the platform's are in use.
  ///
  /// For the rare caller that needs to know whether a theme was *asked for* —
  /// [of] deliberately cannot tell you, because for every widget in the library
  /// the answer does not matter.
  static PlassTokens? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlassTheme>()?.tokens;
  }

  @override
  bool updateShouldNotify(PlassTheme oldWidget) => oldWidget.tokens != tokens;
}
