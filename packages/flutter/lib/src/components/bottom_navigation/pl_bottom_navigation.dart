/// A row of destinations held against the bottom edge of the screen.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Which names are drawn.
enum PlBottomNavigationLabels {
  /// Every destination is named. The default, and the only one that works for a
  /// reader who has not used the app before.
  all,

  /// Only the destination that is current. The bar keeps its height either way,
  /// because the named one is always the tallest; what changes is how much of
  /// the row is words.
  selected,

  /// Glyphs only, with every name read out but never drawn.
  none,
}

/// One destination.
///
/// A **description rather than a widget**, the idiom this package uses for an
/// accordion's folds and a table's columns: the bar has to know which
/// destination is current and how many there are, and a `Widget` is opaque.
@immutable
class PlBottomNavigationItem<T> {
  /// Creates a destination.
  const PlBottomNavigationItem({
    required this.value,
    required this.label,
    this.icon,
    this.disabled = false,
  });

  /// Identifies the destination. What `onChanged` reports.
  final T value;

  /// The destination's name.
  ///
  /// A `String` rather than a widget, and required. It is drawn when `labels`
  /// says so and it is **always** the name a screen reader announces — a glyph
  /// on its own has no accessible name at all, and a name that could be a
  /// widget could not also be a semantics label.
  final String label;

  /// The glyph above the name. Sized on the standalone-glyph ladder.
  final Widget? icon;

  /// Unavailable, but still part of the set.
  final bool disabled;
}

/// The row's floor.
///
/// `md` is 56, which is the height a bottom navigation has had since the first
/// one — tall enough for a glyph with a word under it, short enough that it is
/// not competing with the screen it is on.
const Map<PlassSize, double> _rowMinHeight = <PlassSize, double>{
  PlassSize.xs: 40,
  PlassSize.sm: 48,
  PlassSize.md: 56,
  PlassSize.lg: 64,
  PlassSize.xl: 72,
};

/// The air inside the sheet, around the row of items.
const Map<PlassDensity, Map<PlassSize, double>> _rowPadding =
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

/// Between the glyph and the name under it.
const Map<PlassSize, double> _itemGap = <PlassSize, double>{
  PlassSize.xs: 2,
  PlassSize.sm: 2,
  PlassSize.md: 4,
  PlassSize.lg: 4,
  PlassSize.xl: 6,
};

/// A row of destinations held against the bottom edge of the screen.
///
/// ```dart
/// PlBottomNavigation<String>(
///   value: where,
///   onChanged: (String next) => setState(() => where = next),
///   items: const <PlBottomNavigationItem<String>>[
///     PlBottomNavigationItem<String>(value: 'home', label: 'Home', icon: HomeGlyph()),
///     PlBottomNavigationItem<String>(value: 'search', label: 'Search', icon: SearchGlyph()),
///   ],
/// )
/// ```
///
/// Each destination is a plain pressable rather than a tab. That is a
/// deliberate choice about what is being promised: a tab set owes a keyboard
/// reader one focus stop for the whole thing and arrow keys within it, and owes
/// a screen reader a panel per tab. A bottom navigation switches what the
/// *screen* is, not which panel of one is showing, and claiming the behaviour
/// without meaning it is worse than never claiming it. Every item is its own
/// focus stop, in order, which is what a set of destinations should be.
///
/// The sheet is never dyed, exactly as on a [PlCard]. What carries the colour
/// family is the one item that is current.
class PlBottomNavigation<T> extends StatelessWidget {
  /// Creates a bar.
  const PlBottomNavigation({
    required this.items,
    required this.value,
    this.onChanged,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.labels = PlBottomNavigationLabels.all,
    this.divider = true,
    this.safeArea = true,
    this.disabled = false,
    this.label,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The destinations.
  final List<PlBottomNavigationItem<T>> items;

  /// The destination the reader is on, or `null` for none of them.
  final T? value;

  /// Called with the destination that was chosen. Leaving it out freezes the
  /// bar where it is.
  final ValueChanged<T>? onChanged;

  /// What the sheet is made of. Never dyed — see the class doc.
  final PlassVariant variant;

  /// The row's floor, the glyph's size, and the type scale of the name under
  /// it.
  final PlassSize size;

  /// Semantic colour role, carried by the one item that is current.
  final PlassColor color;

  /// Changes the air inside the sheet and nothing else.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` and flat is right: the bar is attached to the edge of the screen
  /// rather than floating over the middle of it, and [divider] is what
  /// separates it from the content. A bar that floats over the screen is a
  /// different widget, and it says so with a shadow.
  final PlassElevation elevation;

  /// Which names are drawn. An undrawn name is still announced.
  final PlBottomNavigationLabels labels;

  /// Draws a hairline along the top edge, against the content the bar is over.
  ///
  /// On by default: a bar over a scrolling screen has content passing
  /// underneath it at every moment, and a translucent sheet with nothing
  /// marking its edge reads as part of that.
  final bool divider;

  /// Keeps the row clear of the home indicator, by adding the window's own
  /// bottom inset under it.
  ///
  /// The sheet still reaches the bottom of the screen; only the items move up.
  /// A bar that stopped above the indicator would leave a stripe of screen
  /// showing under the glass.
  final bool safeArea;

  /// Every destination stops answering.
  final bool disabled;

  /// The name the bar is announced by — "Main", "Sections".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);
    final double inset = safeArea ? MediaQuery.paddingOf(context).bottom : 0;

    Widget row = Padding(
      padding: EdgeInsets.all(_rowPadding[density]![size]!).copyWith(bottom: null),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: _rowMinHeight[size]!),
        // `stretch` is what makes every item the height of the row, so the
        // wash behind the current one is a full-height key rather than a
        // rectangle round the words. It needs a height to stretch to, and the
        // one it wants is the tallest item's — which is what `IntrinsicHeight`
        // is for. Left to itself the row would stretch to the whole screen.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final PlBottomNavigationItem<T> item in items)
                Expanded(child: _item(context, item, tokens)),
            ],
          ),
        ),
      ),
    );

    row = Padding(
      // The inset goes under the row and inside the sheet, which is what keeps
      // the glass running to the bottom of the screen.
      padding: EdgeInsets.only(bottom: inset + _rowPadding[density]![size]!),
      child: row,
    );

    Widget bar = PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: variant, elevation: elevation),
      // A bar spanning an edge of the screen has nothing behind its corners.
      borderRadius: BorderRadius.zero,
      duration: PlassTokens.durationSlow,
      child: divider
          ? DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: tokens.divider, width: hairline),
                ),
              ),
              child: row,
            )
          : row,
    );

    if (disabled) {
      bar = Opacity(opacity: disabledOpacity, child: bar);
    }

    return Semantics(container: true, explicitChildNodes: true, label: label, child: bar);
  }

  Widget _item(BuildContext context, PlBottomNavigationItem<T> item, PlassTokens tokens) {
    final PlassColorFamily family = tokens.family(color);
    final bool unavailable = disabled || item.disabled || onChanged == null;
    final bool selected = value != null && value == item.value;
    final bool named =
        labels == PlBottomNavigationLabels.all ||
        (labels == PlBottomNavigationLabels.selected && selected);

    final BorderRadius radius = BorderRadius.circular(PlassTokens.radius[size]!);

    return PlassInteractive(
      enabled: !unavailable,
      interactive: !unavailable,
      cursor: unavailable ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onTap: () => onChanged?.call(item.value),
      builder: (BuildContext context, PlassInteraction state) {
        final Color ink = unavailable
            ? tokens.mutedFg
            : selected
            ? family.accent
            : state.hovered
            ? tokens.fg
            : tokens.mutedFg;

        final Color? wash = unavailable
            ? null
            : selected
            ? (state.hovered ? family.softHover : family.soft)
            : (state.hovered ? tokens.glassHover : null);

        Widget content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: _itemGap[size]!,
            children: <Widget>[
              if (item.icon != null)
                IconTheme.merge(
                  data: IconThemeData(color: ink, size: iconSize[size]!),
                  child: item.icon!,
                ),
              // Undrawn is not unsaid: the name is the item's semantics label
              // whatever `labels` says, and only the drawing is taken away.
              if (named)
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ink,
                    fontSize: metaText[size]!,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    height: 1.2,
                  ),
                ),
            ],
          ),
        );

        content = DecoratedBox(
          decoration: BoxDecoration(color: wash, borderRadius: radius),
          child: Center(child: content),
        );

        if (state.focusVisible) {
          content = CustomPaint(
            // Inward: the item is inside a sheet that clips, and a ring drawn
            // outside it would have its top sliced off.
            foregroundPainter: PlassFocusRingPainter(
              color: family.ring,
              borderRadius: radius,
              offset: -focusRingWidth,
            ),
            child: content,
          );
        }

        return Semantics(
          button: true,
          enabled: !unavailable,
          selected: selected,
          label: item.label,
          onTap: unavailable ? null : () => onChanged?.call(item.value),
          child: ExcludeSemantics(child: content),
        );
      },
    );
  }
}
