/// The way back up, once there is a way back up to want.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/icon_button/pl_icon_button.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The way back up, once there is a way back up to want.
///
/// It is **hidden until it is useful** and that is the whole design: a button
/// pinned to the corner of every screen from the first frame is one more thing
/// covering the content, and on a screen short enough not to scroll it is a
/// control that does nothing. It appears when the reader is a screen or so down,
/// which is the point at which scrolling back stops being something they would
/// just do.
///
/// The scroll is animated, and **not** when the platform has asked for less
/// movement — a screen that flies past a reader who turned animations off is the
/// exact case that setting exists for. It jumps instead, which arrives in the
/// same place.
///
/// **Where it goes is yours.** There is no `floating` here and no equivalent of
/// the web's `position: fixed`: put it in a [Stack] over the scrollable, in a
/// [Positioned] or an [Align], which is how a Flutter screen pins anything to a
/// corner.
///
/// ```dart
/// Stack(
///   children: <Widget>[
///     ListView(controller: controller, children: rows),
///     Positioned(
///       right: 24,
///       bottom: 24,
///       child: PlBackTop(controller: controller),
///     ),
///   ],
/// )
/// ```
class PlBackTop extends StatefulWidget {
  /// Creates a back-to-top button.
  const PlBackTop({
    this.controller,
    this.visibilityHeight = 400,
    this.label = 'Back to top',
    this.icon,
    this.onPressed,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.elevation = 2,
    super.key,
  });

  /// What is scrolled, and what is watched.
  ///
  /// Left out, it is the [PrimaryScrollController] — which is what a `ListView`
  /// with no controller of its own is attached to, and is therefore the Flutter
  /// equivalent of "the window".
  final ScrollController? controller;

  /// How far down the reader has to be before it appears, in logical pixels.
  ///
  /// 400 is roughly one screen on a phone, which is the point at which "go back
  /// to the top" stops being a thing they could just do by scrolling.
  final double visibilityHeight;

  /// What it does, in words, and the name a screen reader gives it.
  final String label;

  /// The glyph. An upward chevron by default.
  final Widget? icon;

  /// Runs instead of the scroll, rather than before it.
  ///
  /// For the screen whose "up" is somewhere other than offset zero — a chat log,
  /// a list that starts in the middle.
  final VoidCallback? onPressed;

  /// What the surface is made of.
  final PlassVariant variant;

  /// The size of the disc.
  final PlassSize size;

  /// Semantic colour role.
  final PlassColor color;

  /// Drop shadow depth.
  final int elevation;

  @override
  State<PlBackTop> createState() => _PlBackTopState();
}

class _PlBackTopState extends State<PlBackTop> {
  ScrollController? _attached;
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach(widget.controller ?? PrimaryScrollController.maybeOf(context));
  }

  @override
  void didUpdateWidget(PlBackTop oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _attach(widget.controller ?? PrimaryScrollController.maybeOf(context));
    }
  }

  @override
  void dispose() {
    _attached?.removeListener(_read);
    super.dispose();
  }

  void _attach(ScrollController? next) {
    if (identical(next, _attached)) {
      return;
    }

    _attached?.removeListener(_read);
    _attached = next;
    _attached?.addListener(_read);

    // Read once on attaching as well as on every scroll: a screen restored
    // halfway down has already done its scrolling before this listener existed.
    _read();
  }

  void _read() {
    if (!mounted) {
      return;
    }

    final position = _attached?.hasClients ?? false ? _attached!.offset : 0.0;
    final next = position > widget.visibilityHeight;

    if (next != _shown) {
      setState(() => _shown = next);
    }
  }

  void _toTop() {
    if (widget.onPressed != null) {
      widget.onPressed!();

      return;
    }

    if (!(_attached?.hasClients ?? false)) {
      return;
    }

    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (still) {
      _attached!.jumpTo(0);

      return;
    }

    _attached!.animateTo(0, duration: const Duration(milliseconds: 400), curve: PlassTokens.ease);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return AnimatedOpacity(
      opacity: _shown ? 1 : 0,
      duration: reduceMotion ? Duration.zero : PlassTokens.duration,
      curve: PlassTokens.ease,
      // Hidden from the pointer *and* from the semantics tree while it is not
      // useful, rather than merely faded: a control a reader can reach and
      // cannot see is worse than one that is not there.
      child: IgnorePointer(
        ignoring: !_shown,
        child: ExcludeSemantics(
          excluding: !_shown,
          child: ExcludeFocus(
            excluding: !_shown,
            child: PlIconButton(
              icon: widget.icon ?? const PlassGlyph(PlassGlyphShape.chevron, quarterTurns: 2),
              label: widget.label,
              onPressed: _toTop,
              variant: widget.variant,
              size: widget.size,
              color: widget.color,
              elevation: widget.elevation,
            ),
          ),
        ),
      ),
    );
  }
}
