/// The colour a control's words and glyphs are drawn in, eased with its fill.
///
/// The React build's house transition eases `color` with the fill, the edge
/// and the shadow, so a label changes colour as its surface does. Flutter has
/// no inherited transition: a control that hands its label a new colour in a
/// `DefaultTextStyle` changes it in one frame, and over a fill that is still
/// easing the label takes its new colour on the old surface for the length of
/// the transition. A `solid` toggle going on wrote its white label over the
/// pale glass it was leaving.
///
/// None of this is exported from `plass_ui.dart` — it is the library talking to
/// itself.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';

/// Draws what [child] writes in [color], and eases to a new [color] over the
/// theme's [PlassTokens.motionDuration] on its [PlassTokens.motionEase], as a
/// `PlassSurfaceBox` eases its fill. At once when the platform asks for less
/// movement, as every surface changes.
///
/// The colour is handed down through [DefaultTextStyle] and, unless [icons] is
/// `false`, [IconTheme], and nothing else in either is touched: the size, the
/// weight and the line height are whatever the caller merges around or inside
/// this. A glyph or a spinner that takes its ink as a parameter reads it from
/// the [IconTheme] instead of being handed the colour, so it follows the eased
/// value rather than the target.
///
/// It is in the tree whatever the colour, so what it holds keeps its place when
/// the state changes, and only what reads the colour is built again on each
/// frame of the change. The animation is made the first time the colour
/// changes: a control that never changes state, or one in a long list at rest,
/// carries no controller for it.
class PlassInk extends StatefulWidget {
  /// Draws [child] in [color].
  const PlassInk({
    required this.color,
    required this.child,
    this.duration,
    this.icons = true,
    super.key,
  });

  /// The colour the words and glyphs settle on.
  final Color color;

  /// How long a change takes, or `null` for the theme's
  /// [PlassTokens.motionDuration]. Pass the same duration the surface under
  /// the words eases over, so the two arrive together.
  final Duration? duration;

  /// Whether glyphs take the colour too. `false` where only the words were
  /// ever drawn in it, so an icon a caller put beside them keeps the colour it
  /// had.
  final bool icons;

  /// What is drawn.
  final Widget child;

  @override
  State<PlassInk> createState() => _PlassInkState();
}

class _PlassInkState extends State<PlassInk> with SingleTickerProviderStateMixin {
  /// Made on the first change of colour, and kept from then on.
  AnimationController? _controller;

  /// From the colour shown when the change began to the one being eased to,
  /// or `null` while nothing is changing.
  ColorTween? _tween;

  /// The curve the change in progress runs on.
  Curve _curve = Curves.linear;

  /// The colour drawn now, given the colour [target] that is settled on when
  /// nothing is changing.
  Color _shown(Color target) {
    final ColorTween? tween = _tween;
    final AnimationController? controller = _controller;

    if (tween == null || controller == null) {
      return target;
    }

    return tween.transform(_curve.transform(controller.value))!;
  }

  @override
  void didUpdateWidget(PlassInk oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.color == oldWidget.color) {
      return;
    }

    // From wherever the colour is now, which is part of the way along an
    // earlier change if one is still running, as a CSS transition that is
    // interrupted starts again from the value on screen.
    final Color from = _shown(oldWidget.color);
    final PlassTokens tokens = PlassTheme.of(context);
    final bool still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final Duration duration = still ? Duration.zero : widget.duration ?? tokens.motionDuration;

    if (duration == Duration.zero || from == widget.color) {
      _controller?.stop();
      _tween = null;

      return;
    }

    _tween = ColorTween(begin: from, end: widget.color);
    _curve = tokens.motionEase;

    final AnimationController controller = _controller ??= AnimationController(vsync: this)
      ..addListener(_changed)
      ..addStatusListener(_settled);

    controller
      ..duration = duration
      ..forward(from: 0);
  }

  void _changed() {
    setState(() {});
  }

  void _settled(AnimationStatus status) {
    // At the end of the change the tween stands at the colour it was easing
    // to, exactly, so letting it go changes nothing on screen.
    if (status == AnimationStatus.completed) {
      _tween = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _shown(widget.color);

    // Both wrappers are in the tree whatever [PlassInk.icons] says, so the
    // shape above [child] is one shape; with no colour to give, the icon theme
    // merges nothing.
    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child: IconTheme.merge(
        data: IconThemeData(color: widget.icons ? color : null),
        child: widget.child,
      ),
    );
  }
}
