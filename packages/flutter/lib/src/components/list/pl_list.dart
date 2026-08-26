/// A stack of rows.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A row's vertical padding.
///
/// Its own ladder rather than a sheet's, because a row is a line of text in a
/// stack of them and a sheet is a container: the same `md` that gives a card
/// 20px of air would give a list of eight rows the height of a page.
const Map<PlassDensity, Map<PlassSize, double>> _rowPaddingY =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 4,
        PlassSize.sm: 6,
        PlassSize.md: 8,
        PlassSize.lg: 10,
        PlassSize.xl: 12,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 2,
        PlassSize.sm: 2,
        PlassSize.md: 4,
        PlassSize.lg: 6,
        PlassSize.xl: 8,
      },
    };

/// A row sits one step down the radius ladder from the sheet it is inside — a
/// tile cut out of a sheet cannot have the same corner as the sheet, or the two
/// curves fight along the edge.
const Map<PlassSize, PlassSize> _rowRadiusScale = <PlassSize, PlassSize>{
  PlassSize.xs: PlassSize.xs,
  PlassSize.sm: PlassSize.xs,
  PlassSize.md: PlassSize.sm,
  PlassSize.lg: PlassSize.sm,
  PlassSize.xl: PlassSize.md,
};

/// The hair of padding a sheet keeps around untiled rows, so a hovered row does
/// not run into the edge.
const double _sheetInset = 4;

/// What a [PlListItem] inherits from the [PlList] around it.
///
/// A row is meaningless on its own — it is a row *of* something — so [size],
/// [density] and whether the rows are separated by hairlines belong to the list,
/// not to the member. Passing them on every item would be three chances per row
/// to get one of them wrong, and the failure is silent: a list where item four
/// is a size bigger than the rest.
class _PlListScope extends InheritedWidget {
  const _PlListScope({
    required this.size,
    required this.density,
    required this.color,
    required this.dividers,
    required super.child,
  });

  final PlassSize size;
  final PlassDensity density;
  final PlassColor color;
  final bool dividers;

  static _PlListScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_PlListScope>();

    assert(scope != null, 'PlListItem must be inside a PlList');

    return scope!;
  }

  @override
  bool updateShouldNotify(_PlListScope oldWidget) {
    return oldWidget.size != size ||
        oldWidget.density != density ||
        oldWidget.color != color ||
        oldWidget.dividers != dividers;
  }
}

/// A stack of rows.
///
/// ```dart
/// PlList(
///   dividers: true,
///   children: <Widget>[
///     PlListItem(onPressed: open, child: const Text('Billing')),
///     PlListItem(onPressed: open, child: const Text('Members')),
///   ],
/// )
/// ```
///
/// The list is a sheet and the rows are what is on it, which is the whole reason
/// the two are separate widgets: [size] and [density] are properties of the
/// stack, not of any one line in it, and an inherited scope is what carries them
/// down.
///
/// The sheet is never dyed. A list holds other people's content, and that
/// content arrives with its own colours; the family reaches a row's wash and its
/// focus ring and stops.
class PlList extends StatelessWidget {
  /// Creates a list.
  const PlList({
    required this.children,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.dividers = false,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The rows.
  final List<Widget> children;

  /// What the sheet is made of.
  ///
  /// [PlassVariant.ghost] is the one to reach for inside a card: the card is
  /// already a sheet, and a second bordered rectangle inside it is a second
  /// rectangle.
  final PlassVariant variant;

  /// The rows' type scale and padding. A property of the stack, not of a row.
  final PlassSize size;

  /// Semantic colour role. It reaches a row's wash and its focus ring, never the
  /// sheet.
  final PlassColor color;

  /// How tightly the rows pack.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — a list is a sheet lying flat, not a key resting on
  /// one.
  final PlassElevation elevation;

  /// Separates the rows with a hairline instead of with space.
  ///
  /// It changes more than it sounds like: with dividers the rules have to reach
  /// both edges of the sheet, so the list gives up its inner padding and the
  /// rows give up their rounded corners. A row cannot be a floating tile and a
  /// ruled line at the same time.
  final bool dividers;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final surface = sheetSurface(tokens, variant: variant, elevation: elevation);

    final rows = <Widget>[
      for (var index = 0; index < children.length; index += 1)
        if (dividers && index > 0)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: tokens.divider, width: hairline),
              ),
            ),
            child: children[index],
          )
        else
          children[index],
    ];

    return _PlListScope(
      size: size,
      density: density,
      color: color,
      dividers: dividers,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: PlassSurfaceBox(
          surface: surface,
          borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
          child: Padding(
            // Without dividers the rows are tiles and the sheet keeps a hair of
            // padding so a hovered row does not run into the edge. With them the
            // rules have to reach the edge, so the padding goes.
            padding: EdgeInsets.all(dividers ? 0 : _sheetInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: rows,
            ),
          ),
        ),
      ),
    );
  }
}

/// One row.
///
/// A row that can be pressed and an [action] pinned to its end are two separate
/// focus stops, and neither is inside the other — the same shape a chip uses, for the same reason: a row that both navigates and holds a toggle has
/// two things to press.
class PlListItem extends StatelessWidget {
  /// Creates a row.
  const PlListItem({
    this.child,
    this.onPressed,
    this.startIcon,
    this.endIcon,
    this.description,
    this.action,
    this.selected = false,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The label.
  final Widget? child;

  /// Called when the row is activated. Passing it is what makes the row
  /// pressable — and gives it a focus stop of its own.
  final VoidCallback? onPressed;

  /// Content before the label — an icon, an avatar, a status dot.
  final Widget? startIcon;

  /// Content after the label, inside the pressable area.
  final Widget? endIcon;

  /// A second line under the label, one step down the type scale and muted.
  final Widget? description;

  /// A control pinned to the end of the row — a switch, a menu button.
  ///
  /// Deliberately outside the pressable area.
  final Widget? action;

  /// Marks the row as the chosen one — the open page, the current filter.
  final bool selected;

  /// Unavailable. The light goes out, the same way it does everywhere else.
  final bool disabled;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final scope = _PlListScope.of(context);
    final tokens = PlassTheme.of(context);
    final family = tokens.family(scope.color);
    final interactive = onPressed != null && !disabled;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: interactive
              ? PlassInteractive(
                  onTap: onPressed,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  builder: (BuildContext context, PlassInteraction state) {
                    return Semantics(
                      container: true,
                      button: true,
                      selected: selected,
                      onTap: onPressed,
                      child: _body(tokens, family, scope, state: state),
                    );
                  },
                )
              : Semantics(
                  container: true,
                  enabled: !disabled,
                  selected: selected,
                  child: _body(tokens, family, scope, state: const PlassInteraction()),
                ),
        ),
        if (action != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingX[scope.density]![scope.size]!),
            child: action!,
          ),
      ],
    );
  }

  Widget _body(
    PlassTokens tokens,
    PlassColorFamily family,
    _PlListScope scope, {
    required PlassInteraction state,
  }) {
    final size = scope.size;
    final body = sheetBody[size]!;
    final interactive = onPressed != null && !disabled;

    // Hover deepens the same tint `selected` already uses, one step down, so a
    // hovered row and the chosen row are the same idea at two strengths.
    final fill = disabled
        ? null
        : selected
        ? family.softPress
        : state.hovered || state.pressed
        ? family.soft
        : null;

    final radius = BorderRadius.circular(
      // Squared off when the rows are ruled: a tile and a line are two different
      // ideas about what a row is.
      scope.dividers ? 0 : PlassTokens.radius[_rowRadiusScale[size]!]!,
    );

    Widget slot(Widget content) {
      return SizedBox(
        height: body.line,
        child: Center(
          child: IconTheme.merge(
            data: IconThemeData(color: tokens.mutedFg, size: body.size * iconScale),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg),
              child: content,
            ),
          ),
        ),
      );
    }

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: gap[size]!,
      children: <Widget>[
        if (startIcon != null) slot(startIcon!),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (child != null)
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: selected && !disabled ? family.accent : tokens.fg,
                    fontWeight: selected ? FontWeight.w500 : null,
                  ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  child: child!,
                ),
              if (description != null)
                DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  child: description!,
                ),
            ],
          ),
        ),
        if (endIcon != null) slot(endIcon!),
      ],
    );

    content = DefaultTextStyle.merge(
      style: TextStyle(
        color: tokens.fg,
        fontSize: body.size,
        height: body.height,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: paddingX[scope.density]![size]!,
          vertical: _rowPaddingY[scope.density]![size]!,
        ),
        child: content,
      ),
    );

    Widget surface = AnimatedContainer(
      duration: PlassTokens.duration,
      curve: PlassTokens.ease,
      decoration: BoxDecoration(color: fill, borderRadius: radius),
      child: content,
    );

    surface = plassStateFilter(child: surface, disabled: disabled, lit: false);

    if (state.focusVisible) {
      surface = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(
          color: family.ring,
          borderRadius: radius,
          // A row lives inside a sheet that clips, so its ring turns inward
          // rather than being sliced off at the sheet's edge.
          offset: scope.dividers ? -focusRingWidth : focusRingOffset,
        ),
        child: surface,
      );
    }

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      child: surface,
    );
  }
}
