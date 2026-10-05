/// The sheet everything else on a screen is grouped onto.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
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
    this.headingLevel,
    this.subtitle,
    this.headerAction,
    this.footer,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
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
       ),
       assert(
         headingLevel == null || (headingLevel >= 1 && headingLevel <= 6),
         'headingLevel must be between 1 and 6',
       );

  /// The card's body.
  final Widget? child;

  /// The card's heading.
  ///
  /// Styled as the title, and a heading only when [headingLevel] says how deep
  /// in the screen's outline it is.
  final Widget? title;

  /// The title's depth in the screen's outline, `1` to `6`.
  ///
  /// Left out, the title is styled as the title and is not a heading. Set it
  /// when the card belongs in the outline: `2` for a card under the screen's
  /// main heading, as `title={<h2>…</h2>}` is in the React build. The typography
  /// is the card's either way.
  ///
  /// A pressable card is a button, and its title is the button's name rather
  /// than a heading inside it, so the level is not applied to one.
  final int? headingLevel;

  /// A second line under the title, one step down the type scale and muted.
  final Widget? subtitle;

  /// Content pinned to the end of the header row — a menu button, a status
  /// chip. Centred on the title's first line, and stays there while the title
  /// wraps beside it. The header grows to hold whichever of the two is taller.
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
  final PlassSize? size;

  /// Semantic colour role. It reaches the hairline and the focus ring, never the
  /// sheet.
  final PlassColor? color;

  /// How tightly the card packs its content.
  final PlassDensity? density;

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
  ///
  /// Given one, the card is named by it alone, and what the card holds keeps
  /// nodes of its own inside the card rather than being read as part of the
  /// name.
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  bool get _lifts => interactive || onPressed != null;

  @override
  Widget build(BuildContext context) {
    final pressable = onPressed != null;

    // The same widgets above the content whether the card is pressable, only
    // lifts, or does neither, with the difference in their flags. A card handed
    // `onPressed` later, or `interactive`, used to be wrapped in a different
    // tree, and Flutter builds a changed shape from scratch: a field inside
    // lost what was typed into it.
    //
    // A card that only lifts is still not something to press or to tab to: it
    // takes no focus and claims no tap, so a press on it reaches whatever is
    // around it, and it is told only whether a mouse is over it.
    return PlassInteractive(
      onTap: onPressed,
      enabled: pressable,
      interactive: _lifts,
      pressable: pressable,
      cursor: pressable ? SystemMouseCursors.click : MouseCursor.defer,
      focusNode: focusNode,
      autofocus: autofocus,
      builder: (BuildContext context, PlassInteraction state) {
        // Said on the card's own node, which is in here: folded in from round
        // the surface it would be said above the node, and under a named
        // card, which keeps what it holds apart, it would be a node of its own.
        final focus = plassFocusSemanticsOf(context);

        return Semantics(
          container: pressable,
          button: pressable ? true : null,
          label: pressable ? semanticLabel : null,
          // Named, the card is called by that name alone, and what it holds is
          // read after it rather than run on into it: "Team plan", then the
          // title and the body, where one node used to say all three as its
          // name. Unnamed, what it holds is its name, as before.
          explicitChildNodes: pressable && semanticLabel != null,
          // Nothing while the card cannot be pressed, which is when the
          // surface takes no focus.
          focused: focus.focused,
          onFocus: focus.onFocus,
          expanded: focus.expanded,
          onTap: onPressed,
          child: _sheet(context, state),
        );
      },
    );
  }

  Widget _sheet(BuildContext context, PlassInteraction state) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final radius = BorderRadius.circular(tokens.radii[size]!);

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
      child: _body(context, tokens),
    );

    card = TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _lifts && state.hovered && !state.pressed ? -_lift : 0),
      duration: reduceMotion ? Duration.zero : tokens.motionDuration,
      curve: tokens.motionEase,
      child: card,
      // Translated by nothing at rest rather than left unwrapped, and on a card
      // that never lifts as well: a wrapper that comes and goes with the hover,
      // or with `interactive`, changes the shape of the tree above the content,
      // and Flutter rebuilds a changed shape from scratch — an entry animation
      // inside replays, and the shadow's own easing is cut off halfway.
      builder: (BuildContext context, double dy, Widget? child) {
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
    );

    // The same reason: the ring is switched off by leaving out its painter, not
    // by leaving out the widget that paints it.
    return CustomPaint(
      foregroundPainter: state.focusVisible
          ? PlassFocusRingPainter(color: family.ring, borderRadius: radius)
          : null,
      child: card,
    );
  }

  Widget _body(BuildContext context, PlassTokens tokens) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final insetX = padded ? sheetPaddingX[density]![size]! : 0.0;
    final insetY = padded ? sheetPaddingY[density]![size]! : 0.0;
    final body = sheetBody[size]!;

    final hasHeader = title != null || subtitle != null || headerAction != null;
    final heading = headingLevel != null && onPressed == null;

    final titleText = TextStyle(
      color: tokens.fg,
      fontSize: sheetTitle[size]!.size,
      height: sheetTitle[size]!.height,
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
    );
    final subtitleText = TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!);

    // The line the action is centred on: the title's first, or the subtitle's
    // when there is no title.
    final firstLine = title != null ? titleText : (subtitle != null ? subtitleText : null);

    final sections = <Widget>[
      if (hasHeader)
        Row(
          // The two sides line up on their baselines, and the action's side
          // offers only the baseline of the line it is centred on.
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
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
                        style: titleText,
                        // What an `<h2>` buys on the web: a screen reader can
                        // list the headings on a screen, jump between them, and
                        // tell a section from the one inside it by its level.
                        // Always wrapped, and switched off by leaving its
                        // properties empty, for the same reason as the lift.
                        child: Semantics(
                          header: heading ? true : null,
                          headingLevel: heading ? headingLevel : null,
                          child: title!,
                        ),
                      ),
                    if (subtitle != null)
                      DefaultTextStyle.merge(style: subtitleText, child: subtitle!),
                  ],
                ),
              )
            else
              const Spacer(),
            // Wrapped whether or not there is a line to centre on, so a title
            // that comes or goes leaves the action's state where it was.
            if (headerAction != null) _OnFirstLine(line: firstLine, child: headerAction!),
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

/// Centres the header action on the first line of the text beside it.
///
/// The header row lines its two sides up on their baselines, and this side
/// offers one that is not the action's: the baseline of an empty line set in
/// [line], centred with the action. So the action's middle lands on the middle
/// of the first line across the row, and a label inside the action, which would
/// otherwise offer a baseline of its own, does not line itself up with the
/// title instead. This is what the React card does with a strut in the action's
/// slot.
///
/// The box is as tall as the action or the line, whichever is taller. A taller
/// action pushes the title down by half the difference rather than hanging out
/// of the header, where the part outside would take no press.
class _OnFirstLine extends SingleChildRenderObjectWidget {
  const _OnFirstLine({required this.line, required Widget super.child});

  /// The type of the line the action is centred on, or `null` with no text
  /// beside it, which leaves the action at the top of the row.
  final TextStyle? line;

  @override
  _RenderOnFirstLine createRenderObject(BuildContext context) {
    return _RenderOnFirstLine(
      style: _styleOf(context),
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
      textHeightBehavior: _heightBehaviorOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderOnFirstLine renderObject) {
    renderObject
      ..style = _styleOf(context)
      ..textScaler = MediaQuery.textScalerOf(context)
      ..textDirection = Directionality.of(context)
      ..textHeightBehavior = _heightBehaviorOf(context);
  }

  /// [line] on top of the type around it, which is how a `Text` beside it is
  /// set.
  TextStyle? _styleOf(BuildContext context) {
    return line == null ? null : DefaultTextStyle.of(context).style.merge(line);
  }

  TextHeightBehavior? _heightBehaviorOf(BuildContext context) {
    return DefaultTextStyle.of(context).textHeightBehavior ??
        DefaultTextHeightBehavior.maybeOf(context);
  }
}

class _RenderOnFirstLine extends RenderShiftedBox {
  _RenderOnFirstLine({
    required TextStyle? style,
    required TextScaler textScaler,
    required TextDirection textDirection,
    required TextHeightBehavior? textHeightBehavior,
  }) : _strut = TextPainter(
         text: _lineIn(style),
         textScaler: textScaler,
         textDirection: textDirection,
         textHeightBehavior: textHeightBehavior,
       ),
       super(null);

  /// The line, laid out on its own and never painted.
  final TextPainter _strut;

  /// A space in [style]: a character every font has, so the line is measured
  /// in the font the text beside it is set in rather than in a fallback.
  static TextSpan? _lineIn(TextStyle? style) {
    return style == null ? null : TextSpan(text: ' ', style: style);
  }

  set style(TextStyle? value) {
    final TextSpan? text = _lineIn(value);

    if (_strut.text == text) {
      return;
    }

    _strut.text = text;
    markNeedsLayout();
  }

  set textScaler(TextScaler value) {
    if (_strut.textScaler == value) {
      return;
    }

    _strut.textScaler = value;
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (_strut.textDirection == value) {
      return;
    }

    _strut.textDirection = value;
    markNeedsLayout();
  }

  set textHeightBehavior(TextHeightBehavior? value) {
    if (_strut.textHeightBehavior == value) {
      return;
    }

    _strut.textHeightBehavior = value;
    markNeedsLayout();
  }

  /// How tall the line is, or nothing without one.
  double get _lineHeight {
    if (_strut.text == null) {
      return 0;
    }

    _strut.layout();

    return _strut.height;
  }

  /// The action's size, made as tall as the line when it is shorter.
  Size _around(BoxConstraints constraints, Size action) {
    return constraints.constrain(Size(action.width, math.max(action.height, _lineHeight)));
  }

  /// Where the line's baseline falls in a box of [height], with the line
  /// centred in it.
  double? _baselineIn(double height, TextBaseline baseline) {
    if (_strut.text == null) {
      return null;
    }

    _strut.layout();

    return (height - _strut.height) / 2 + _strut.computeDistanceToActualBaseline(baseline);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(super.computeMinIntrinsicHeight(width), _lineHeight);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return math.max(super.computeMaxIntrinsicHeight(width), _lineHeight);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _around(constraints, child?.getDryLayout(constraints.loosen()) ?? Size.zero);
  }

  @override
  double? computeDryBaseline(BoxConstraints constraints, TextBaseline baseline) {
    return _baselineIn(getDryLayout(constraints).height, baseline);
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;

    if (child == null) {
      size = _around(constraints, Size.zero);
      return;
    }

    child.layout(constraints.loosen(), parentUsesSize: true);
    size = _around(constraints, child.size);
    (child.parentData! as BoxParentData).offset = Offset(0, (size.height - child.size.height) / 2);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return _baselineIn(size.height, baseline);
  }

  @override
  void dispose() {
    _strut.dispose();
    super.dispose();
  }
}
