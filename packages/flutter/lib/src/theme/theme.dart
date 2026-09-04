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

import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/theme/defaults.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

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
  PlassTheme({
    required Brightness brightness,
    required super.child,
    this.defaults = PlassDefaults.none,
    super.key,
  }) : tokens = PlassTokens.of(brightness);

  /// Pins [child] and its subtree to a token set you resolved yourself.
  const PlassTheme.tokens({
    required this.tokens,
    required super.child,
    this.defaults = PlassDefaults.none,
    super.key,
  });

  const PlassTheme._({required this.tokens, required this.defaults, required super.child});

  /// Sets defaults for a subtree, keeping whatever the theme above it decided.
  ///
  /// This is the one to reach for. The plain constructors **replace** the
  /// defaults in scope, exactly as `DefaultTextStyle` replaces a style and
  /// `DefaultTextStyle.merge` merges one — and for the same reason: an
  /// `InheritedWidget` has no context of its own to read an ancestor with, so
  /// merging has to happen where there *is* one.
  ///
  /// It keeps the brightness in scope too, so a section of a dark screen can be
  /// made compact without going light.
  ///
  /// ```dart
  /// PlassTheme.merge(
  ///   defaults: const PlassDefaults(size: PlassSize.sm, density: PlassDensity.compact),
  ///   child: const SettingsPanel(),
  /// )
  /// ```
  static Widget merge({required PlassDefaults defaults, required Widget child}) {
    return Builder(
      builder: (BuildContext context) {
        return PlassTheme._(
          tokens: maybeOf(context),
          defaults: defaults.merge(defaultsOf(context)),
          child: child,
        );
      },
    );
  }

  /// The resolved tokens this subtree reads, or `null` when this theme only
  /// carries [defaults] and the brightness is still the platform's.
  final PlassTokens? tokens;

  /// What every widget under this theme starts from.
  ///
  /// Every field is optional and nothing is decided until something decides it —
  /// see [PlassDefaults], including why `variant` and `elevation` are not in it.
  final PlassDefaults defaults;

  /// The tokens in scope, or the platform's own theme if none were pinned.
  ///
  /// Reading `MediaQuery` rather than a stored default is what makes an
  /// unwrapped widget follow the system switch: the dependency is registered,
  /// so a device flipped to dark rebuilds the button.
  static PlassTokens of(BuildContext context) {
    final pinned = context.dependOnInheritedWidgetOfExactType<PlassTheme>();

    if (pinned?.tokens != null) {
      return pinned!.tokens!;
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

  /// What the nearest theme above [context] decided.
  ///
  /// The **nearest**, not the chain: a plain [PlassTheme] replaces the defaults
  /// under it, and [PlassTheme.merge] is what keeps the ones above. Every widget
  /// in the library reads this and resolves in the same order — **the widget's
  /// own parameter, then whatever set it is in, then the theme, then the
  /// widget's own default.**
  static PlassDefaults defaultsOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlassTheme>()?.defaults ?? PlassDefaults.none;
  }

  /// The size in scope, or `null`.
  static PlassSize? sizeOf(BuildContext context) => defaultsOf(context).size;

  /// The family in scope, or `null`.
  static PlassColor? colorOf(BuildContext context) => defaultsOf(context).color;

  /// The density in scope, or `null`.
  static PlassDensity? densityOf(BuildContext context) => defaultsOf(context).density;

  /// The words in scope, or the English ones where nothing said otherwise.
  ///
  /// Two layers: the defaults above, and whatever a [PlassTheme] set. A widget's
  /// own `*Label` parameter is the third and narrowest, and it is applied at the
  /// call site rather than here — which is what lets an application translate
  /// the vocabulary once and one button still say something else.
  static PlassLabels labelsOf(BuildContext context) =>
      defaultsOf(context).labels ?? PlassLabels.english;

  @override
  bool updateShouldNotify(PlassTheme oldWidget) {
    return oldWidget.tokens != tokens || oldWidget.defaults != defaults;
  }
}
