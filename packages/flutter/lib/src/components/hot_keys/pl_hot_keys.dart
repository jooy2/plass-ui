/// A keyboard key, a combination of them, or the four movement keys as they sit
/// on the keyboard.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Which keyboard the shortcut is being read on.
enum PlHotKeysOS {
  /// Ask the platform, which is right for a shortcut a reader is about to
  /// press.
  auto,

  /// macOS and iOS: modifiers as glyphs, and no separator between them.
  mac,

  /// Windows.
  windows,

  /// Linux, and anything else.
  linux,
}

/// Four keys laid out as an inverted T: one on top, three beneath.
@immutable
class PlHotKeysCluster {
  /// Creates a cluster.
  const PlHotKeysCluster({
    required this.up,
    required this.left,
    required this.down,
    required this.right,
  });

  /// The key on top.
  final String up;

  /// The one to its lower left.
  final String left;

  /// The one directly beneath.
  final String down;

  /// The one to its lower right.
  final String right;

  @override
  bool operator ==(Object other) {
    return other is PlHotKeysCluster &&
        other.up == up &&
        other.left == left &&
        other.down == down &&
        other.right == right;
  }

  @override
  int get hashCode => Object.hash(up, left, down, right);
}

/// What a key is called, and what it is drawn as.
///
/// The two differ on exactly the keys macOS draws as glyphs — `⌘` announced by
/// its Unicode name is "place of interest sign", which is not a key anybody has
/// on their keyboard.
@immutable
class _KeyLabel {
  const _KeyLabel(this.symbol, this.name);

  const _KeyLabel.word(String text) : symbol = text, name = text;

  final String symbol;
  final String name;

  bool get speaks => symbol != name;
}

/// One entry per key that is spelled differently somewhere, keyed by the token
/// with its case, spaces and punctuation taken off.
///
/// `mod` is the entry the rest exist for. It is the only token whose *meaning*
/// changes with the platform rather than just its spelling — the modifier a
/// shortcut is actually built on, which is Command on a Mac and Control
/// everywhere else. Writing `Ctrl` and hoping is what makes a documentation
/// page wrong for half its readers.
const Map<String, Map<PlHotKeysOS, _KeyLabel>> _keyLabels = <String, Map<PlHotKeysOS, _KeyLabel>>{
  'mod': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('⌘', 'Command'),
    PlHotKeysOS.windows: _KeyLabel.word('Ctrl'),
    PlHotKeysOS.linux: _KeyLabel.word('Ctrl'),
  },
  'meta': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('⌘', 'Command'),
    PlHotKeysOS.windows: _KeyLabel.word('Win'),
    PlHotKeysOS.linux: _KeyLabel.word('Super'),
  },
  'ctrl': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('⌃', 'Control'),
    PlHotKeysOS.windows: _KeyLabel.word('Ctrl'),
    PlHotKeysOS.linux: _KeyLabel.word('Ctrl'),
  },
  'alt': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('⌥', 'Option'),
    PlHotKeysOS.windows: _KeyLabel.word('Alt'),
    PlHotKeysOS.linux: _KeyLabel.word('Alt'),
  },
  'shift': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('⇧', 'Shift'),
    PlHotKeysOS.windows: _KeyLabel.word('Shift'),
    PlHotKeysOS.linux: _KeyLabel.word('Shift'),
  },
  'enter': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('↩', 'Enter'),
    PlHotKeysOS.windows: _KeyLabel.word('Enter'),
    PlHotKeysOS.linux: _KeyLabel.word('Enter'),
  },
  'tab': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('⇥', 'Tab'),
    PlHotKeysOS.windows: _KeyLabel.word('Tab'),
    PlHotKeysOS.linux: _KeyLabel.word('Tab'),
  },
  'escape': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('⎋', 'Escape'),
    PlHotKeysOS.windows: _KeyLabel.word('Esc'),
    PlHotKeysOS.linux: _KeyLabel.word('Esc'),
  },
  'backspace': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('⌫', 'Backspace'),
    PlHotKeysOS.windows: _KeyLabel.word('Backspace'),
    PlHotKeysOS.linux: _KeyLabel.word('Backspace'),
  },
  'delete': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('⌦', 'Delete'),
    PlHotKeysOS.windows: _KeyLabel.word('Del'),
    PlHotKeysOS.linux: _KeyLabel.word('Del'),
  },
  'capslock': <PlHotKeysOS, _KeyLabel>{
    PlHotKeysOS.mac: _KeyLabel('⇪', 'Caps Lock'),
    PlHotKeysOS.windows: _KeyLabel.word('Caps Lock'),
    PlHotKeysOS.linux: _KeyLabel.word('Caps Lock'),
  },
};

/// The tokens that name one key by more than one word.
///
/// Deliberate rather than generous: `Cmd`, `Command` and `Meta` are three names
/// one key already has, and a component that accepted only one of them would be
/// a component every caller has to look up.
const Map<String, String> _keyAliases = <String, String>{
  'cmdorctrl': 'mod',
  'commandorcontrol': 'mod',
  'cmd': 'meta',
  'command': 'meta',
  'super': 'meta',
  'win': 'meta',
  'windows': 'meta',
  'control': 'ctrl',
  'option': 'alt',
  'opt': 'alt',
  'return': 'enter',
  'esc': 'escape',
  'del': 'delete',
  'caps': 'capslock',
};

/// The keys drawn as arrows on every platform, not just on a Mac. An arrow is
/// not a Mac convention — it is what is printed on the key.
const Map<String, _KeyLabel> _arrowLabels = <String, _KeyLabel>{
  'up': _KeyLabel('↑', 'Arrow up'),
  'down': _KeyLabel('↓', 'Arrow down'),
  'left': _KeyLabel('←', 'Arrow left'),
  'right': _KeyLabel('→', 'Arrow right'),
  'arrowup': _KeyLabel('↑', 'Arrow up'),
  'arrowdown': _KeyLabel('↓', 'Arrow down'),
  'arrowleft': _KeyLabel('←', 'Arrow left'),
  'arrowright': _KeyLabel('→', 'Arrow right'),
};

/// A key cap sits one step down the control ladder: it is a token inside a line
/// of text, not a control the line lines up against.
const Map<PlassSize, PlassSize> _keyScale = <PlassSize, PlassSize>{
  PlassSize.xs: PlassSize.xs,
  PlassSize.sm: PlassSize.xs,
  PlassSize.md: PlassSize.sm,
  PlassSize.lg: PlassSize.md,
  PlassSize.xl: PlassSize.lg,
};

/// The width a single-letter cap is held to, so `⌘` and `K` are the same square.
const Map<PlassSize, double> _keyMinWidth = <PlassSize, double>{
  PlassSize.xs: 24,
  PlassSize.sm: 32,
  PlassSize.md: 40,
  PlassSize.lg: 48,
  PlassSize.xl: 56,
};

/// How deep the lip under a key cap is.
///
/// Not the gloss line the design language rules out — a gloss line is a
/// highlight *on* a surface, claiming a lamp. This is a hard-edged shadow
/// *under* it, which is the one thing every printed manual has used to mean
/// "this is a key you press". A picture of a key is allowed to look like a key;
/// a control is not allowed to look like a picture of one.
const double _lip = 2;

/// One key cap.
///
/// Exported so a caller can compose a layout this component does not draw — a
/// numeric keypad, a row of function keys — out of the same object the shortcut
/// strip is made of.
class PlKbd extends StatelessWidget {
  /// Creates a key cap.
  const PlKbd({
    required this.child,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.secondary,
    this.density = PlassDensity.compact,
    this.elevation = 0,
    this.semanticLabel,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// What is printed on it.
  final Widget child;

  /// What the cap is made of. See [PlHotKeys.variant].
  final PlassVariant variant;

  /// The cap's own step of the ladder — one below a control's.
  final PlassSize size;

  /// Semantic colour role.
  final PlassColor color;

  /// How tightly the cap packs its label.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default. A key cap already has a lip under it — this is a
  /// picture of a key, not a key, and raising it off the page as well is one
  /// depth cue too many.
  final PlassElevation elevation;

  /// What a screen reader says instead of what is printed. `⌘` read out is
  /// "place of interest sign", which is not a key anybody has.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final step = _keyScale[size]!;
    final radius = BorderRadius.circular(PlassTokens.radius[step]!);

    final surface = _capSurface(tokens, family, variant);

    Widget cap = ConstrainedBox(
      constraints: BoxConstraints(minWidth: _keyMinWidth[step]!, minHeight: controlHeight[step]!),
      child: PlassSurfaceBox(
        surface: surface,
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingX[density]![step]!),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: surface.ink,
                fontSize: controlText[step]!,
                fontWeight: FontWeight.w500,
                height: 1,
                leadingDistribution: TextLeadingDistribution.even,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
              maxLines: 1,
              softWrap: false,
              child: child,
            ),
          ),
        ),
      ),
    );

    if (semanticLabel != null) {
      cap = Semantics(
        container: true,
        label: semanticLabel,
        child: ExcludeSemantics(child: cap),
      );
    }

    return cap;
  }

  /// The cap's own reading of the three materials.
  ///
  /// Not [markSurface]: the lip under it is a shadow no other surface in the
  /// library draws, and [PlassVariant.glass] is the default here rather than
  /// the exception — a hairline box is what a key cap has looked like in every
  /// manual ever printed. Its edge is the neutral hairline, or a cap set on a
  /// light card would have no edge at all.
  PlassSurface _capSurface(PlassTokens tokens, PlassColorFamily family, PlassVariant variant) {
    switch (variant) {
      case PlassVariant.solid:
        return PlassSurface(
          gradient: family.fill,
          ink: family.onSolid,
          shadows: <BoxShadow>[
            ...tokens.elevation(elevation),
            // A hard edge: no blur and no spread, so it is a lip rather than a
            // shadow.
            BoxShadow(color: family.tint, offset: const Offset(0, _lip)),
          ],
        );
      case PlassVariant.glass:
        return PlassSurface(
          fill: tokens.glass,
          border: Border.all(color: tokens.border, width: hairline),
          ink: family.accent,
          blur: true,
          shadows: <BoxShadow>[
            ...tokens.elevation(elevation),
            BoxShadow(color: tokens.shadowAmbient, offset: const Offset(0, _lip)),
          ],
        );
      case PlassVariant.ghost:
        return PlassSurface(fill: family.soft, ink: family.accent);
    }
  }
}

/// A keyboard key, a combination of them, or the four movement keys as they sit
/// on the keyboard.
///
/// ```dart
/// const PlHotKeys(keys: 'Mod+K')
/// ```
///
/// Two things make this more than a styled box, and both are about the label
/// rather than the box around it.
///
/// The first is `Mod`. A shortcut written as `Ctrl+K` is wrong for every Mac
/// reader and one written as `⌘K` is wrong for everybody else, so the token that
/// means "the modifier shortcuts are built on" resolves per platform — and [os]
/// is there for the pages that have to name a platform rather than the reader's.
///
/// The second is that `⌘` is not a word. A screen reader reads it as "place of
/// interest sign", so every key drawn as a glyph carries its name instead. What
/// is announced is "Command K", which is what the shortcut is called.
class PlHotKeys extends StatelessWidget {
  /// Creates a shortcut.
  const PlHotKeys({
    this.keys,
    this.cluster,
    this.os = PlHotKeysOS.auto,
    this.separator,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.secondary,
    this.density = PlassDensity.compact,
    this.elevation = 0,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The keys, innermost punctuation and all.
  ///
  /// A `String` is split on `+` — `'Mod+Shift+P'` — which covers everything
  /// except a shortcut whose key *is* a plus. For that one, pass a
  /// `List<String>`: `keys: ['Ctrl', '+']`.
  ///
  /// Typed as [Object] rather than as a union, which Dart does not have.
  final Object? keys;

  /// Draws the four movement keys as an inverted T instead of an inline combo —
  /// `WASD`, or the arrow cluster. Takes precedence over [keys].
  ///
  /// It is its own parameter rather than a layout on [keys], because the two are
  /// different objects: a combo is keys pressed *together*, and a cluster is
  /// four keys pressed one at a time whose arrangement on the keyboard is the
  /// point.
  final PlHotKeysCluster? cluster;

  /// Which keyboard to name the modifiers for.
  final PlHotKeysOS os;

  /// What goes between two keys.
  ///
  /// Omit it for the platform's own convention: a `+` on Windows and Linux, and
  /// nothing at all on macOS, where a shortcut is written as a run of symbols —
  /// `⇧⌘P`, never `⇧+⌘+P`.
  final Widget? separator;

  /// What the caps are made of.
  final PlassVariant variant;

  /// The cap ladder's step.
  final PlassSize size;

  /// Semantic colour role.
  final PlassColor color;

  /// How tightly a cap packs its label.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`. See [PlKbd.elevation].
  final PlassElevation elevation;

  /// What the platform says it is running on.
  ///
  /// Coarse on purpose — the question is which of three key caps to print, and
  /// getting it slightly wrong is a label rather than a bug. Read from
  /// [defaultTargetPlatform], so a `debugDefaultTargetPlatformOverride` in a
  /// test or a preview moves it.
  static PlHotKeysOS get platform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.iOS:
        return PlHotKeysOS.mac;
      case TargetPlatform.windows:
        return PlHotKeysOS.windows;
      case TargetPlatform.linux:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return PlHotKeysOS.linux;
    }
  }

  /// Resolves one token into what to draw and what to announce.
  static _KeyLabel _labelFor(String token, PlHotKeysOS os) {
    final normalized = token.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    final canonical = _keyAliases[normalized] ?? normalized;

    final arrow = _arrowLabels[canonical];

    if (arrow != null) {
      return arrow;
    }

    final known = _keyLabels[canonical];

    if (known != null) {
      return known[os]!;
    }

    // Everything else is printed as it was written, with the one courtesy that a
    // single letter is capitalised: `keys: 'mod+k'` should draw a K, because
    // that is what is on the key.
    return _KeyLabel.word(token.length == 1 ? token.toUpperCase() : token);
  }

  /// Splits the string form. Empty segments are what `'Ctrl++'` leaves behind,
  /// and dropping them is why the list form exists for that case.
  List<String> get _tokens {
    final raw = keys;

    if (raw == null) {
      return const <String>[];
    }

    final parts = raw is List<String> ? raw : (raw as String).split('+');

    return parts.map((String key) => key.trim()).where((String key) => key.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resolved = os == PlHotKeysOS.auto ? platform : os;
    final spacing = size == PlassSize.xs || size == PlassSize.sm ? 4.0 : 6.0;

    Widget cap(String text, {String? name}) {
      return PlKbd(
        variant: variant,
        size: size,
        color: color,
        density: density,
        elevation: elevation,
        semanticLabel: name,
        child: Text(text),
      );
    }

    if (cluster != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        spacing: spacing,
        children: <Widget>[
          cap(cluster!.up),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing,
            children: <Widget>[cap(cluster!.left), cap(cluster!.down), cap(cluster!.right)],
          ),
        ],
      );
    }

    final labels = _tokens.map((String token) => _labelFor(token, resolved)).toList();

    // macOS writes a shortcut as a run of symbols with nothing between them; the
    // other two join theirs with a `+`. A caller who passes one gets theirs.
    final joiner = separator ?? (resolved == PlHotKeysOS.mac ? null : const Text('+'));

    final tokens = PlassTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 4,
      children: <Widget>[
        for (var index = 0; index < labels.length; index += 1) ...<Widget>[
          if (index > 0 && joiner != null)
            ExcludeSemantics(
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: tokens.mutedFg,
                  fontSize: controlText[_keyScale[size]!],
                  height: 1,
                ),
                child: joiner,
              ),
            ),
          cap(labels[index].symbol, name: labels[index].speaks ? labels[index].name : null),
        ],
      ],
    );
  }
}
