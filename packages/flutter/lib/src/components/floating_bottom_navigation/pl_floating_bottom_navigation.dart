/// A row of round destinations floating clear of the bottom edge.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// One destination, as a disc.
///
/// A **description rather than a widget**, for the reason a
/// [PlBottomNavigationItem] is: the bar has to know which destination is
/// current and how many there are.
@immutable
class PlFloatingBottomNavigationItem<T> {
  /// Creates a destination.
  const PlFloatingBottomNavigationItem({
    required this.value,
    required this.label,
    this.icon,
    this.disabled = false,
  });

  /// Identifies the destination. What `onChanged` reports.
  final T value;

  /// The destination's name.
  ///
  /// Required, and **never drawn**. A disc with a glyph in it has no accessible
  /// name at all, and a row of glyphs with no names is exactly the defect
  /// [PlIconButton]'s `label` exists to make impossible — it would be just as
  /// easy to ship here.
  final String label;

  /// The glyph. It is the whole of what a reader sees.
  final Widget? icon;

  /// Unavailable, but still part of the set.
  final bool disabled;
}

/// How far off the floor the capsule sits, on the size ladder.
const Map<PlassSize, double> _floatGap = <PlassSize, double>{
  PlassSize.xs: 8,
  PlassSize.sm: 12,
  PlassSize.md: 16,
  PlassSize.lg: 20,
  PlassSize.xl: 24,
};

/// The air inside the capsule, around the discs.
const Map<PlassDensity, Map<PlassSize, double>> _capsulePadding =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 4,
        PlassSize.sm: 4,
        PlassSize.md: 6,
        PlassSize.lg: 8,
        PlassSize.xl: 10,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 2,
        PlassSize.sm: 2,
        PlassSize.md: 4,
        PlassSize.lg: 4,
        PlassSize.xl: 6,
      },
    };

/// Between two discs.
const Map<PlassDensity, Map<PlassSize, double>> _discGap = <PlassDensity, Map<PlassSize, double>>{
  PlassDensity.standard: <PlassSize, double>{
    PlassSize.xs: 4,
    PlassSize.sm: 4,
    PlassSize.md: 6,
    PlassSize.lg: 8,
    PlassSize.xl: 10,
  },
  PlassDensity.compact: <PlassSize, double>{
    PlassSize.xs: 2,
    PlassSize.sm: 2,
    PlassSize.md: 4,
    PlassSize.lg: 4,
    PlassSize.xl: 6,
  },
};

/// A row of round destinations floating clear of the bottom edge of the screen.
///
/// ```dart
/// PlFloatingBottomNavigation<String>(
///   value: where,
///   onChanged: (String next) => setState(() => where = next),
///   items: const <PlFloatingBottomNavigationItem<String>>[
///     PlFloatingBottomNavigationItem<String>(value: 'home', label: 'Home', icon: HomeGlyph()),
///     PlFloatingBottomNavigationItem<String>(value: 'search', label: 'Search', icon: SearchGlyph()),
///   ],
/// )
/// ```
///
/// The other half of [PlBottomNavigation], and a different widget rather than a
/// flag on one. That bar is **attached** to the edge of the screen: full width,
/// a hairline against the content it is over, its sheet running under the home
/// indicator, and flat, because a thing lying against an edge does not cast a
/// shadow onto it. This one is **not part of the screen at all**. Everything
/// that follows comes from that single difference — the capsule, the gap under
/// it, the shadow it defaults to, and the pill corners it is allowed.
///
/// The current destination is a key of **tinted glass** riding in the clear
/// sheet, which is the design language's own sentence with nothing added.
class PlFloatingBottomNavigation<T> extends StatelessWidget {
  /// Creates a floating bar.
  const PlFloatingBottomNavigation({
    required this.items,
    required this.value,
    this.onChanged,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 2,
    this.safeArea = true,
    this.disabled = false,
    this.label,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The destinations.
  final List<PlFloatingBottomNavigationItem<T>> items;

  /// The destination the reader is on, or `null` for none of them.
  final T? value;

  /// Called with the destination that was chosen. Leaving it out freezes the
  /// bar where it is.
  final ValueChanged<T>? onChanged;

  /// What the capsule is made of.
  ///
  /// `glass` is the default and the whole point: a clear sheet over a blurred
  /// backdrop with a hairline around it. `solid` is the same sheet at its most
  /// opaque, for a bar that sits over photography. `ghost` has no capsule at
  /// all — the discs float on their own.
  final PlassVariant variant;

  /// The disc's diameter and the gap under the bar, on the control ladder — so
  /// a floating bar at `md` is a row of 40px discs.
  final PlassSize size;

  /// Semantic colour role, carried by the one disc that is current.
  final PlassColor color;

  /// Changes the air inside the capsule and the gap between discs.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`. `2`, against the `0` almost everything else
  /// takes.
  ///
  /// Not an inconsistency: every other sheet in the library rests on the screen
  /// and earns its separation from the glass edge, so a shadow is opt-in. This
  /// one hovers over whatever is underneath it, and a capsule lying flat on the
  /// content it is floating over reads as a mistake.
  final PlassElevation elevation;

  /// Adds the window's own bottom inset to the gap under the bar, so it clears
  /// the home indicator.
  final bool safeArea;

  /// Every destination stops answering.
  final bool disabled;

  /// The name the bar is announced by — "Main", "Sections".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final double disc = controlHeight[size]!;
    final double air = _capsulePadding[density]![size]!;
    final double inset = safeArea ? MediaQuery.paddingOf(context).bottom : 0;

    // A pill, and one of the very few the library allows. It is allowed for the
    // reason a segmented button's groove is: the house fillet is about a sheet
    // with its corners cut, and a sheet that is not lying on anything has no
    // corners to cut.
    final BorderRadius capsule = BorderRadius.circular(disc / 2 + air);

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: _discGap[density]![size]!,
      children: <Widget>[
        for (final PlFloatingBottomNavigationItem<T> item in items)
          _disc(context, item, tokens, disc),
      ],
    );

    row = Padding(padding: EdgeInsets.all(air), child: row);

    Widget bar = variant == PlassVariant.ghost
        ? row
        : PlassSurfaceBox(
            surface: sheetSurface(tokens, variant: variant, elevation: elevation),
            borderRadius: capsule,
            duration: PlassTokens.durationSlow,
            child: row,
          );

    if (disabled) {
      bar = Opacity(opacity: disabledOpacity, child: bar);
    }

    bar = Semantics(container: true, explicitChildNodes: true, label: label, child: bar);

    // Centred, as tall as the capsule, and held off the floor. There is no
    // strip across the screen to build here — the React build needs one because
    // a fixed element has to span something, and a Flutter app puts this
    // wherever it wants it.
    return Padding(
      padding: EdgeInsets.only(bottom: _floatGap[size]! + inset),
      child: Align(alignment: Alignment.bottomCenter, heightFactor: 1, child: bar),
    );
  }

  Widget _disc(
    BuildContext context,
    PlFloatingBottomNavigationItem<T> item,
    PlassTokens tokens,
    double disc,
  ) {
    final PlassColorFamily family = tokens.family(color);
    final bool unavailable = disabled || item.disabled || onChanged == null;
    final bool selected = value != null && value == item.value;
    final BorderRadius round = BorderRadius.circular(disc / 2);

    return PlassInteractive(
      enabled: !unavailable,
      interactive: !unavailable,
      cursor: unavailable ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onTap: () => onChanged?.call(item.value),
      builder: (BuildContext context, PlassInteraction state) {
        // The chosen disc is a *control* surface and every other one is bare:
        // the current destination is the one key of tinted glass in a clear
        // sheet, and nothing else in the row is pressed-looking until it is
        // under the pointer.
        final PlassSurface surface = selected && !unavailable
            ? controlSurface(
                tokens,
                family,
                variant: PlassVariant.solid,
                elevation: 1,
                hovered: state.hovered,
                pressed: state.pressed,
              )
            : PlassSurface(
                fill: unavailable
                    ? null
                    : state.hovered
                    ? tokens.glassHover
                    : null,
                ink: unavailable ? tokens.mutedFg : (state.hovered ? tokens.fg : tokens.mutedFg),
              );

        Widget content = SizedBox(
          width: disc,
          height: disc,
          child: PlassSurfaceBox(
            surface: surface,
            borderRadius: round,
            child: Center(
              child: item.icon == null
                  ? const SizedBox.shrink()
                  : IconTheme.merge(
                      data: IconThemeData(color: surface.ink, size: iconSize[size]!),
                      child: item.icon!,
                    ),
            ),
          ),
        );

        content = plassStateFilter(
          child: content,
          disabled: unavailable,
          hovered: state.hovered,
          pressed: state.pressed,
          lit: selected && !unavailable,
        );

        if (state.focusVisible) {
          content = CustomPaint(
            // Offset rather than flush, which is the exception the rest of the
            // library does not make: a flush ring on a circle is the circle's
            // own edge thickening, and that reads as a border rather than as
            // focus.
            foregroundPainter: PlassFocusRingPainter(
              color: family.ring,
              borderRadius: round,
              offset: 2,
            ),
            child: content,
          );
        }

        return Semantics(
          button: true,
          enabled: !unavailable,
          selected: selected,
          // Never drawn, always read.
          label: item.label,
          onTap: unavailable ? null : () => onChanged?.call(item.value),
          child: ExcludeSemantics(child: content),
        );
      },
    );
  }
}
