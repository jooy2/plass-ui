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
/// current and how many there are — and, since the key that marks the current
/// one travels between them, where each of them is.
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
///
/// The key is **one widget that travels**: its rectangle is measured off
/// whichever disc is current and animated between them, the way a
/// [PlSegmentedButton]'s tile is. It is not a surface that fades up on one disc
/// while it fades out of another — two discs cross-fading is two objects, and a
/// bar with a key in it has one, so what a reader follows is where the key went
/// rather than which two things changed colour. Nothing is transformed either:
/// the key is an empty box, and no glyph in the row is resampled while it
/// moves.
class PlFloatingBottomNavigation<T> extends StatefulWidget {
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
  ///
  /// It says nothing about the key. A key of tinted glass riding in a clear
  /// sheet is the design language's own sentence, and a `ghost` bar is a row of
  /// discs with no sheet behind them — the one that is current is still the one
  /// that is current.
  final PlassVariant variant;

  /// The disc's diameter and the gap under the bar, on the control ladder — so
  /// a floating bar at `md` is a row of 40px discs.
  final PlassSize size;

  /// Semantic colour role, carried by the key.
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
  State<PlFloatingBottomNavigation<T>> createState() => _PlFloatingBottomNavigationState<T>();
}

class _PlFloatingBottomNavigationState<T> extends State<PlFloatingBottomNavigation<T>> {
  /// One key per disc, so the travelling key can be measured off the current
  /// one.
  ///
  /// Measured rather than worked out from the size ladder. Every disc is the
  /// same square and the arithmetic would be right today — and wrong the first
  /// time a row is laid out somewhere that changes it. What is actually on the
  /// screen cannot drift from itself.
  final List<GlobalKey> _keys = <GlobalKey>[];
  final GlobalKey _row = GlobalKey();

  /// Where the key is, in the row's own coordinates.
  Rect? _rect;

  int get _chosen => widget.value == null
      ? -1
      : widget.items.indexWhere(
          (PlFloatingBottomNavigationItem<T> item) => item.value == widget.value,
        );

  @override
  void initState() {
    super.initState();
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
  }

  @override
  void didUpdateWidget(PlFloatingBottomNavigation<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _measure());
  }

  void _syncKeys() {
    while (_keys.length < widget.items.length) {
      _keys.add(GlobalKey());
    }

    if (_keys.length > widget.items.length) {
      _keys.removeRange(widget.items.length, _keys.length);
    }
  }

  /// Reads the current disc's box, in the row's own coordinates.
  void _measure() {
    if (!mounted) {
      return;
    }

    final chosen = _chosen;
    final row = _row.currentContext?.findRenderObject() as RenderBox?;
    final disc = chosen >= 0
        ? _keys[chosen].currentContext?.findRenderObject() as RenderBox?
        : null;

    final next = disc != null && row != null && disc.hasSize && row.hasSize
        ? (disc.localToGlobal(Offset.zero, ancestor: row) & disc.size)
        : null;

    if (next != _rect) {
      setState(() => _rect = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(widget.color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final disc = controlHeight[widget.size]!;
    final air = _capsulePadding[widget.density]![widget.size]!;
    final inset = widget.safeArea ? MediaQuery.paddingOf(context).bottom : 0.0;
    final chosen = _chosen;

    // A pill, and one of the very few the library allows. It is allowed for the
    // reason a segmented button's groove is: the house fillet is about a sheet
    // with its corners cut, and a sheet that is not lying on anything has no
    // corners to cut.
    final capsule = BorderRadius.circular(disc / 2 + air);

    Widget row = Row(
      key: _row,
      mainAxisSize: MainAxisSize.min,
      spacing: _discGap[widget.density]![widget.size]!,
      children: <Widget>[
        for (var index = 0; index < widget.items.length; index += 1)
          _disc(widget.items[index], tokens, family, disc, index),
      ],
    );

    // The key rides *behind* the glyphs, which is why this is a stack rather
    // than a surface on the current disc: a surface would fade up on one disc
    // as it faded out of another, and this one travels.
    row = Stack(
      children: <Widget>[
        if (_rect != null)
          AnimatedPositioned(
            duration: reduceMotion ? Duration.zero : PlassTokens.duration,
            curve: PlassTokens.ease,
            left: _rect!.left,
            top: _rect!.top,
            width: _rect!.width,
            height: _rect!.height,
            child: _Key(
              family: family,
              tokens: tokens,
              // The light goes out on the key the same way it goes out on the
              // disc over it, or an unavailable destination is a dimmed glyph
              // on a fully lit gradient.
              quiet: widget.onChanged == null || (chosen >= 0 && widget.items[chosen].disabled),
            ),
          ),
        row,
      ],
    );

    row = Padding(padding: EdgeInsets.all(air), child: row);

    Widget bar = widget.variant == PlassVariant.ghost
        ? row
        : PlassSurfaceBox(
            surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
            borderRadius: capsule,
            duration: PlassTokens.durationSlow,
            child: row,
          );

    if (widget.disabled) {
      bar = Opacity(opacity: disabledOpacity, child: bar);
    }

    bar = Semantics(container: true, explicitChildNodes: true, label: widget.label, child: bar);

    // Centred, as tall as the capsule, and held off the floor. There is no
    // strip across the screen to build here — the React build needs one because
    // a fixed element has to span something, and a Flutter app puts this
    // wherever it wants it.
    return Padding(
      padding: EdgeInsets.only(bottom: _floatGap[widget.size]! + inset),
      child: Align(alignment: Alignment.bottomCenter, heightFactor: 1, child: bar),
    );
  }

  Widget _disc(
    PlFloatingBottomNavigationItem<T> item,
    PlassTokens tokens,
    PlassColorFamily family,
    double disc,
    int index,
  ) {
    final unavailable = widget.disabled || item.disabled || widget.onChanged == null;
    final selected = widget.value != null && widget.value == item.value;
    final round = BorderRadius.circular(disc / 2);

    return PlassInteractive(
      key: _keys[index],
      enabled: !unavailable,
      interactive: !unavailable,
      cursor: unavailable ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onTap: () => widget.onChanged?.call(item.value),
      builder: (BuildContext context, PlassInteraction state) {
        // No surface of its own on the current disc. What is under its glyph is
        // the key, which belongs to the bar; a disc that drew a fill of its own
        // would be a second key appearing wherever the first had just left.
        final PlassSurface surface = selected && !unavailable
            ? PlassSurface(ink: family.onSolid)
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
                      data: IconThemeData(color: surface.ink, size: iconSize[widget.size]!),
                      child: item.icon!,
                    ),
            ),
          ),
        );

        // `lit` is off on every disc, the current one included: the light a
        // filled surface answers the pointer with belongs to the surface, and
        // the only filled surface in the row is the key.
        content = plassStateFilter(child: content, disabled: unavailable, lit: false);

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
          onTap: unavailable ? null : () => widget.onChanged?.call(item.value),
          child: ExcludeSemantics(child: content),
        );
      },
    );
  }
}

/// The key that slides.
///
/// Always the family's own gradient with that family's tinted shadow under it,
/// whatever the capsule is made of.
///
/// It carries no hover and no press light, which is the one thing it gave up by
/// moving off the disc — and giving it up is right rather than a compromise: a
/// [PlSegmentedButton]'s tile is the same object solving the same problem and
/// has none either, and the current destination is the one a reader is already
/// on.
class _Key extends StatelessWidget {
  const _Key({required this.family, required this.tokens, required this.quiet});

  final PlassColorFamily family;
  final PlassTokens tokens;

  /// Whether the destination under it is unavailable.
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final Widget key = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: family.fill,
        boxShadow: <BoxShadow>[...tokens.elevation(1), tokens.lift(family)],
      ),
    );

    return quiet ? plassStateFilter(child: key, disabled: true, lit: false) : key;
  }
}
