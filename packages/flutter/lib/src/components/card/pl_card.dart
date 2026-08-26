/// The sheet everything else on a screen is grouped onto.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far an interactive card lifts under the pointer.
///
/// This is the one place the library allows a translation, and the exception is
/// the rule rather than a hole in it: what may not move is the thing under the
/// finger — a key whose label resamples as it scales. A sheet that *holds*
/// content is the other kind of surface, and lifting one is how a pane of glass
/// says it can be picked up.
const double _lift = 2;

/// The sheet everything else on a screen is grouped onto, with the parts a card
/// is made of laid out on it: a title, a subtitle, a body and a footer.
///
/// ```dart
/// PlCard(
///   title: const Text('Billing'),
///   subtitle: const Text('Visa ending 4242'),
///   footer: PlButton(onPressed: change, child: const Text('Change')),
///   child: const Text('Your next invoice is on 1 March.'),
/// )
/// ```
///
/// The sections are parameters rather than sub-widgets — `PlCard.header`,
/// `PlCard.title` — for the same reason a text field takes `label` and
/// `description` as parameters: the arrangement is fixed, and what a caller
/// wants to decide is what goes in each slot, not what order the slots come in.
///
/// The sheet is never dyed. What a card holds arrives with its own colours, and
/// tinting the sheet under them puts every one on a background it was not chosen
/// against; the family reaches the hairline and the focus ring and stops.
class PlCard extends StatelessWidget {
  /// Creates a card.
  const PlCard({
    this.child,
    this.title,
    this.subtitle,
    this.headerAction,
    this.footer,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 1,
    this.dividers = false,
    this.padded = true,
    this.onPressed,
    this.interactive = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The card's body.
  final Widget? child;

  /// The card's heading.
  ///
  /// Styled as the title. Wrap it in a `Semantics(header: true, …)` when the
  /// card belongs in the screen's outline — the typography is the card's either
  /// way.
  final Widget? title;

  /// A second line under the title, one step down the type scale and muted.
  final Widget? subtitle;

  /// Content pinned to the end of the header row — a menu button, a status
  /// chip. Stays on the title's line while the title wraps beside it.
  final Widget? headerAction;

  /// The bottom area — a pair of buttons, a status line.
  ///
  /// One widget, so a footer with several things in it brings its own [Row] or
  /// [Wrap]. Which is the difference from the React build, where a fragment of
  /// children is laid out for you: there is no fragment here to lay out.
  final Widget? footer;

  /// What the sheet is made of. See [PlassVariant].
  final PlassVariant variant;

  /// Type scale, radius and padding.
  final PlassSize size;

  /// Semantic colour role. It reaches the hairline and the focus ring, never the
  /// sheet.
  final PlassColor color;

  /// How tightly the card packs its content.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `1` is the default: a card is a sheet lying **on** the page wash rather
  /// than printed into it, and the small amount of grey under it is what says
  /// so.
  final PlassElevation elevation;

  /// Scores the sheet between sections with a hairline instead of separating
  /// them with space.
  ///
  /// The rules run the full width, so the padding moves from the card onto each
  /// section.
  final bool dividers;

  /// Inner padding, on the [size] / [density] scale.
  ///
  /// Turn it off for full-bleed content — an image, a table, a list that draws
  /// its own rows.
  final bool padded;

  /// Called when the card is activated.
  ///
  /// Passing it makes the card a real focus stop, announced as a button and
  /// reachable from a keyboard — which is the difference between a card that
  /// *looks* clickable and one that is.
  final VoidCallback? onPressed;

  /// Lifts the sheet under the pointer and adds a level of elevation, without
  /// making the card do anything.
  ///
  /// For a card whose interactive parts are inside it. Passing [onPressed]
  /// implies this.
  final bool interactive;

  /// The name a screen reader gives a pressable card. Left out, the card is
  /// named by what is in it.
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  bool get _lifts => interactive || onPressed != null;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return _sheet(context, const PlassInteraction());
    }

    return PlassInteractive(
      onTap: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      builder: (BuildContext context, PlassInteraction state) {
        return Semantics(
          container: true,
          button: true,
          label: semanticLabel,
          onTap: onPressed,
          child: _sheet(context, state),
        );
      },
    );
  }

  Widget _sheet(BuildContext context, PlassInteraction state) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final radius = BorderRadius.circular(PlassTokens.radius[size]!);

    var surface = sheetSurface(tokens, variant: variant, elevation: elevation);

    // Hover lifts the sheet and puts a level of shadow under it; the press sets
    // it back down. No brightness is involved — a card is not a coloured
    // surface, so there is nothing to turn up.
    if (_lifts && (state.hovered || state.pressed)) {
      final level = state.pressed ? elevation - 1 : elevation + 1;

      switch (variant) {
        case PlassVariant.solid:
          surface = surface.withShadows(tokens.elevation(level));
        case PlassVariant.glass:
          surface = PlassSurface(
            fill: state.pressed ? tokens.glassPress : tokens.glassHover,
            border: Border.all(color: family.line, width: hairline),
            insets: surface.insets,
            ink: surface.ink,
            blur: true,
            shadows: tokens.elevation(level),
          );
        case PlassVariant.ghost:
          surface = PlassSurface(
            fill: state.pressed ? family.softHover : family.soft,
            ink: surface.ink,
          );
      }
    }

    Widget card = PlassSurfaceBox(
      surface: surface,
      borderRadius: radius,
      reduceMotion: reduceMotion,
      child: _body(tokens),
    );

    if (_lifts) {
      card = TweenAnimationBuilder<double>(
        tween: Tween<double>(end: state.hovered && !state.pressed ? -_lift : 0),
        duration: reduceMotion ? Duration.zero : PlassTokens.duration,
        curve: PlassTokens.ease,
        child: card,
        builder: (BuildContext context, double dy, Widget? child) {
          return dy == 0 ? child! : Transform.translate(offset: Offset(0, dy), child: child);
        },
      );
    }

    if (state.focusVisible) {
      card = CustomPaint(
        foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
        child: card,
      );
    }

    return card;
  }

  Widget _body(PlassTokens tokens) {
    final insetX = padded ? sheetPaddingX[density]![size]! : 0.0;
    final insetY = padded ? sheetPaddingY[density]![size]! : 0.0;
    final body = sheetBody[size]!;

    final hasHeader = title != null || subtitle != null || headerAction != null;

    final sections = <Widget>[
      if (hasHeader)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            if (title != null || subtitle != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: sheetHeaderGap[size]!,
                  children: <Widget>[
                    if (title != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          color: tokens.fg,
                          fontSize: sheetTitle[size]!.size,
                          height: sheetTitle[size]!.height,
                          fontWeight: FontWeight.w600,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        child: title!,
                      ),
                    if (subtitle != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                        child: subtitle!,
                      ),
                  ],
                ),
              )
            else
              const Spacer(),
            ?headerAction,
          ],
        ),
      ?child,
      if (footer != null)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[footer!],
        ),
    ];

    // Scored, the rules have to reach both edges, so the sheet gives up its
    // vertical padding and every section takes it on instead. Unscored, the
    // sheet keeps it and the sections are told apart by a gap.
    final rows = <Widget>[
      for (var index = 0; index < sections.length; index += 1)
        DecoratedBox(
          decoration: BoxDecoration(
            border: dividers && index > 0
                ? Border(
                    top: BorderSide(color: tokens.divider, width: hairline),
                  )
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: insetX, vertical: dividers ? insetY : 0),
            child: sections[index],
          ),
        ),
    ];

    return DefaultTextStyle.merge(
      style: TextStyle(
        color: tokens.fg,
        fontSize: body.size,
        height: body.height,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dividers ? 0 : insetY),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: dividers ? 0 : sheetSectionGap[size]!,
          children: rows,
        ),
      ),
    );
  }
}
