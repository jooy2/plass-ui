/// Content that is covered until somebody asks for it.
library;

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How much of the page's own surface goes over the blur.
///
/// Blur alone is not cover. It takes a paragraph apart but leaves its colour and
/// its rhythm — a photograph blurred at 10 is still recognisably a photograph of
/// a face — and it leaves the button standing on whatever happened to be
/// underneath it. Mixing the screen's own surface over the top settles both.
const double _scrim = 0.55;

/// The gap between the notice and the button under it.
const double _coverGap = 8;

/// Content that is covered until somebody asks for it.
///
/// ```dart
/// PlSpoiler(
///   revealed: showing,
///   onRevealedChanged: (bool next) => setState(() => showing = next),
///   reversible: true,
///   child: const Text('Rosebud was the name painted on the sled he had as a child.'),
/// )
/// ```
///
/// The cover is a **blur** rather than a hidden box, which is the whole point: a
/// reader can see that there is something there, roughly how much of it there
/// is, and — with [maxHeight] — that it has been clamped. What they cannot do is
/// read it by accident, which is the one thing a spoiler is for.
///
/// While it is covered the content is taken out of the focus order, off the
/// semantics tree and out of reach of the pointer. A spoiler somebody can tab
/// into is not a spoiler.
///
/// The sheet is never dyed, exactly as on a [PlCard]: what a spoiler holds is a
/// photograph, a paragraph, a plot twist, and it arrives with its own colours.
/// The family shows up on the button and in the hairline and stops there.
///
/// **The box is the same height covered and uncovered**, which takes every one
/// of the things that could move it. The cover is an unpositioned child of the
/// same stack as the content rather than something laid over it, so a cover
/// taller than a one-line spoiler makes the sheet taller instead of being
/// clipped by it; and neither the cover nor the [reversible] Hide row is ever
/// taken out of the tree — both are built from the start and merely held
/// invisible, so their space is paid for once instead of arriving on the way in
/// and leaving again on the way out.
///
/// [maxHeight] is the one exception, and it is deliberate: a clamp is released
/// on reveal, so a spoiler that was holding back four screens of text grows to
/// fit them. Keeping the clamp would leave the reader a scrollbar where they
/// asked for the content.
class PlSpoiler extends StatefulWidget {
  /// Creates a spoiler.
  const PlSpoiler({
    this.child,
    this.revealed,
    this.onRevealedChanged,
    this.label,
    this.hideLabel,
    this.description = const _Warning(),
    this.action,
    this.reversible = false,
    this.maxHeight,
    this.blur = 10,
    this.padded = true,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// What is being covered.
  final Widget? child;

  /// Whether the content is uncovered.
  ///
  /// The one widget in the package that is happy **uncontrolled**, and the
  /// reason is what the state is: not a value the screen owns but a thing the
  /// reader did to this box. A page of a dozen spoilers should not be a dozen
  /// booleans on a `State` somewhere else. Pass it — with
  /// [onRevealedChanged] — for the cases where the screen genuinely does own it.
  final bool? revealed;

  /// Called when the reveal or hide button is pressed.
  final ValueChanged<bool>? onRevealedChanged;

  /// The name a screen reader gives the reveal button, and what it says.
  final String? label;

  /// The same for the hide button, when [reversible] is on.
  final String? hideLabel;

  /// The line above the button, saying why the content is covered. `null` is a
  /// cover with nothing written on it.
  ///
  /// Left out, it is the label pack's `spoilerWarning`.
  final Widget? description;

  /// Replaces the default reveal button entirely.
  ///
  /// The replacement is yours to wire up: pass [revealed] and
  /// [onRevealedChanged] and drive it from your own control.
  final Widget? action;

  /// Keeps the content coverable: once revealed, a hide button appears under it.
  final bool reversible;

  /// Clamps the covered box to this height, in logical pixels.
  ///
  /// Revealing releases it and the content takes whatever height it needs — the
  /// clamp is only ever on the covered state, because revealing something and
  /// leaving it in a box with a scrollbar is answering the wrong question. That
  /// makes this the one thing that changes the sheet's height between the two
  /// states.
  final double? maxHeight;

  /// How hard the content is blurred.
  ///
  /// The same unit the React build writes as a CSS `blur()` radius, which is a
  /// Gaussian standard deviation either way — so the two packages smear the
  /// same amount for the same number.
  final double blur;

  /// Inner padding around the content. Turn it off for something that should
  /// reach the edges — a picture, a video.
  final bool padded;

  /// What the sheet is made of. Never dyed. [PlassVariant.ghost] draws no box at
  /// all, which is what a spoiler inside running prose usually wants.
  final PlassVariant variant;

  /// The sheet's radius, and the size of the button on it.
  final PlassSize? size;

  /// Semantic colour role. It reaches the button and the hairline.
  final PlassColor? color;

  /// Padding around the cover's own text and button.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`. `0` and flat.
  final PlassElevation elevation;

  @override
  State<PlSpoiler> createState() => _PlSpoilerState();
}

class _PlSpoilerState extends State<PlSpoiler> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  late bool _uncontrolled = widget.revealed ?? false;

  bool get _open => widget.revealed ?? _uncontrolled;

  /// Where the focus is put on reveal: the content itself, so a keyboard reader
  /// lands on what they asked to see and the next Tab goes on to the first thing
  /// inside it. Out of the traversal, because Tab should never stop on a
  /// paragraph.
  final FocusNode _contentFocus = FocusNode(debugLabel: 'PlSpoiler content', skipTraversal: true);

  /// The cover and the Hide row, as nodes that cannot take the focus themselves
  /// and only answer whether something inside them has it.
  final FocusNode _coverFocus = FocusNode(
    debugLabel: 'PlSpoiler cover',
    canRequestFocus: false,
    skipTraversal: true,
  );
  final FocusNode _hideFocus = FocusNode(
    debugLabel: 'PlSpoiler hide',
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void didUpdateWidget(PlSpoiler oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A controlled spoiler flips here rather than in [_change], and so does one
    // driven by a caller's own `action`.
    if ((oldWidget.revealed ?? _uncontrolled) != _open) {
      _handOffFocus(opening: _open);
    }
  }

  @override
  void dispose() {
    _contentFocus.dispose();
    _coverFocus.dispose();
    _hideFocus.dispose();
    super.dispose();
  }

  void _change(bool next) {
    if (widget.revealed == null) {
      _handOffFocus(opening: next);
      setState(() => _uncontrolled = next);
    }

    widget.onRevealedChanged?.call(next);
  }

  /// Moves the focus off the side that is about to be taken out of reach.
  ///
  /// The button that was pressed is put under an [ExcludeFocus] by the very
  /// build that acts on the press, and a node that stops being focusable hands
  /// the focus back to its scope — to whatever held it before, or to nothing —
  /// so the next Tab starts somewhere the reader never was. It goes where the
  /// reader was taken instead: into the content on the way in, and back to the
  /// control that uncovers it on the way out.
  ///
  /// After the frame, because neither of those can take the focus until that
  /// build has let go of them. And only when the focus was on the side that is
  /// going: a spoiler flipped from elsewhere on the screen leaves it alone.
  void _handOffFocus({required bool opening}) {
    final bool held = opening
        ? _coverFocus.hasFocus
        : _hideFocus.hasFocus || _contentFocus.hasFocus;

    if (!held) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }

      if (opening) {
        _contentFocus.requestFocus();
      } else {
        _coverFocus.traversalDescendants.firstOrNull?.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final radius = BorderRadius.circular(tokens.radii[_size]!);
    final insetX = sheetPaddingX[_density]![_size]!;
    final insetY = sheetPaddingY[_density]![_size]!;

    Widget content = widget.child ?? const SizedBox.shrink();

    if (widget.padded) {
      content = Padding(
        padding: EdgeInsets.symmetric(horizontal: insetX, vertical: insetY),
        child: content,
      );
    }

    content = Focus(focusNode: _contentFocus, includeSemantics: false, child: content);

    // Every wrapper below is built in both states and only switched, so the
    // child sits at the same depth covered and uncovered. Wrapped only while it
    // was covered, the child was one level deeper before a reveal than after it,
    // and Flutter took that for a different child: whatever it held in its
    // `State` — a playing video, a scroll position, a half-typed answer — was
    // thrown away on reveal and built again from nothing.
    content = ClipRect(
      clipBehavior: !_open && widget.maxHeight != null ? Clip.hardEdge : Clip.none,
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          // The clamp is only ever on the covered state.
          constraints: BoxConstraints(
            maxHeight: _open ? double.infinity : (widget.maxHeight ?? double.infinity),
          ),
          child: content,
        ),
      ),
    );

    content = ImageFiltered(
      enabled: !_open,
      imageFilter: ui.ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
      child: content,
    );

    // Out of the focus order, off the semantics tree and out of reach of the
    // pointer — the three things `inert` does in the other package, said as the
    // three widgets that do them. A spoiler somebody can tab into is not a
    // spoiler.
    content = ExcludeSemantics(
      excluding: !_open,
      child: ExcludeFocus(
        excluding: !_open,
        child: IgnorePointer(ignoring: !_open, child: content),
      ),
    );

    // The wash fills whatever the stack ends up being, and the cover's own text
    // and button are an *unpositioned* child so they count toward that size.
    // Together that is what keeps a one-line spoiler as tall as the button it is
    // asking somebody to press, rather than clipping it.
    final sheet = Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            content,
            if (widget.reversible)
              Focus(
                focusNode: _hideFocus,
                includeSemantics: false,
                child: _hideRow(insetX, insetY),
              ),
          ],
        ),
        // The wash is positioned, so it takes no part in sizing the stack; the
        // cover is what makes the sheet tall enough for its own button. Both are
        // built either way and merely hidden — a wash that came and went would
        // move the cover to a different slot in this list, and the cover would be
        // built again from nothing.
        Positioned.fill(
          child: Visibility(
            visible: !_open,
            child: ColoredBox(color: tokens.surface.withValues(alpha: tokens.surface.a * _scrim)),
          ),
        ),
        Focus(
          focusNode: _coverFocus,
          includeSemantics: false,
          child: _cover(tokens, insetX, insetY),
        ),
      ],
    );

    return PlassSurfaceBox(
      surface: sheetSurface(tokens, variant: widget.variant, elevation: widget.elevation),
      borderRadius: radius,
      duration: tokens.motionDurationSlow,
      child: ClipRRect(borderRadius: radius, child: sheet),
    );
  }

  /// The way back out, drawn whether or not it can be seen.
  ///
  /// It used to be built only once the spoiler was open, which grew the sheet by
  /// the height of a button on the way in and shrank it back on the way out —
  /// the page moving twice around the control somebody is pressing. The row is
  /// in the column from the start now and merely held invisible, so its space is
  /// paid for once; the cover is painted over it, so what is reserved reads as
  /// part of the covered sheet rather than as a gap under the blur.
  ///
  /// [Visibility] with `maintainSize` keeps the space and takes the row off the
  /// pointer and out of the semantics, and [ExcludeFocus] takes it out of the
  /// traversal — between them the three things `inert` does in the other
  /// package, which is the same trio the covered content is wrapped in.
  Widget _hideRow(double insetX, double insetY) {
    final Widget row = Padding(
      // The row takes the sheet's padding and then gives the top back: padded
      // content already ends with a full gap, and two of them stacked is a hole
      // between the text and the way back out.
      padding: EdgeInsetsDirectional.only(start: insetX, end: insetX, bottom: insetY),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: PlButton(
          variant: PlassVariant.ghost,
          size: _size,
          color: _color,
          density: _density,
          onPressed: () => _change(false),
          child: Text(widget.hideLabel ?? PlassTheme.labelsOf(context).hide),
        ),
      ),
    );

    return ExcludeFocus(
      excluding: !_open,
      child: Visibility(
        visible: _open,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: row,
      ),
    );
  }

  /// The notice and the button that lifts the cover.
  ///
  /// The wash is drawn separately, behind this, because the two answer different
  /// questions: the wash has to fill the sheet however tall the content made it,
  /// and this has to be able to *make* the sheet taller when the content is
  /// shorter than a button.
  ///
  /// Which is exactly why it is built once and then hidden rather than dropped
  /// from the stack on the way in. A cover is a line of explanation and a
  /// button, so it is routinely taller than the paragraph it covers; taken out
  /// of the tree it stops holding the stack open, the sheet collapses to the
  /// content and everything under it jumps up the page — then back down again
  /// when it is covered a second time. [Visibility] with `maintainSize` keeps
  /// the space, and with [ExcludeFocus] takes the row off the pointer, out of
  /// the traversal and off the semantics tree: the same trio the covered content
  /// and the Hide row are wrapped in.
  Widget _cover(PlassTokens tokens, double insetX, double insetY) {
    final Widget cover = Padding(
      padding: EdgeInsets.symmetric(horizontal: insetX, vertical: insetY),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: _coverGap,
        children: <Widget>[
          if (widget.description != null)
            DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg, fontSize: metaText[_size]!),
              textAlign: TextAlign.center,
              child: widget.description!,
            ),
          widget.action ??
              PlButton(
                size: _size,
                color: _color,
                density: _density,
                onPressed: () => _change(true),
                child: Text(widget.label ?? PlassTheme.labelsOf(context).reveal),
              ),
        ],
      ),
    );

    return ExcludeFocus(
      excluding: _open,
      child: Visibility(
        visible: !_open,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: cover,
      ),
    );
  }
}

/// The default line on the cover: the label pack's `spoilerWarning`, read where
/// the cover is drawn, so a translated theme reaches it.
class _Warning extends StatelessWidget {
  const _Warning();

  @override
  Widget build(BuildContext context) => Text(PlassTheme.labelsOf(context).spoilerWarning);
}
