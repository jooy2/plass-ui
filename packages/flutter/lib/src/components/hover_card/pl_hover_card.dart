/// A preview of what is behind a link, shown when the pointer rests on it.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/anchored.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/wedge.dart';
import 'package:plass_ui/src/theme/defaults.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How wide the card is allowed to get, per [PlassSize].
///
/// One rung wider than a `PlPopover`'s at every step. A popover is a detail
/// beside a control; a hover card is a preview of a whole thing, and a preview
/// squeezed to the width of a hint is a preview nobody reads.
const Map<PlassSize, double> _maxWidth = <PlassSize, double>{
  PlassSize.xs: 256,
  PlassSize.sm: 288,
  PlassSize.md: 384,
  PlassSize.lg: 448,
  PlassSize.xl: 512,
};

/// The wedge, at roughly a third of the sheet's corner radius per step.
const Map<PlassSize, double> _arrowSize = <PlassSize, double>{
  PlassSize.xs: 8,
  PlassSize.sm: 9,
  PlassSize.md: 10,
  PlassSize.lg: 11,
  PlassSize.xl: 12,
};

/// A preview of what is behind a link, shown when the pointer rests on it.
///
/// ```dart
/// PlHoverCard(
///   title: const Text('Ada Lovelace'),
///   description: const Text('Mathematician'),
///   child: const Text('Wrote the first algorithm intended for a machine.'),
///   trigger: PlTextLink(onPressed: open, child: const Text('Ada Lovelace')),
/// )
/// ```
///
/// The three floating surfaces are told apart by **what opens them and what you
/// can do once they are open**, not by how they look. A [PlTooltip] names the
/// thing under the pointer: one phrase, and nothing in it can be reached. A
/// hover card previews what is behind it — it opens on its own, the pointer can
/// move onto it, and it holds a title, a picture, a figure. A [PlPopover] was
/// asked for, stays until it is dismissed, and can be typed into.
///
/// **Nothing may live only in here.** A card that opens on hover does not open
/// for a finger, so a link, a button or a fact that exists nowhere else on the
/// screen is one that half the readers never get. Everything in it is a preview
/// of something already reachable, which is what makes it safe to have at all.
///
/// The delays are the component. [delay] is long so the card does not fire at
/// every link a pointer crosses on the way somewhere else, and [closeDelay] is
/// not zero because the gap between the trigger and the card has no pointer in
/// it — a card that closed the moment the pointer left could never be reached.
///
/// Needs an [Overlay] above it, which `WidgetsApp` with a navigator and
/// `MaterialApp` both provide.
class PlHoverCard extends StatefulWidget {
  /// Creates a hover card.
  const PlHoverCard({
    required this.trigger,
    this.title,
    this.description,
    this.child,
    this.side = PlassSide.bottom,
    this.align = PlassAlign.center,
    this.offset = 8,
    this.delay = const Duration(milliseconds: 600),
    this.closeDelay = const Duration(milliseconds: 300),
    this.arrow = false,
    this.open,
    this.onOpenChanged,
    this.disabled = false,
    this.width,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// What the card previews. Usually a link.
  final Widget trigger;

  /// The heading.
  final Widget? title;

  /// A line under it.
  final Widget? description;

  /// The body.
  final Widget? child;

  /// Which edge of the trigger it appears on. It flips to the opposite side when
  /// there is no room.
  final PlassSide side;

  /// Where it sits along that edge.
  final PlassAlign align;

  /// How far it stands off the trigger, in logical pixels.
  final double offset;

  /// How long the pointer has to rest before it opens.
  final Duration delay;

  /// How long it waits after the pointer leaves.
  final Duration closeDelay;

  /// Draws the little wedge pointing at the trigger.
  final bool arrow;

  /// Drives the card from outside.
  ///
  /// `null` — the default — leaves it to the pointer and the keyboard, which is
  /// the arrangement a [PlTooltip] makes for the same reason: nobody has an
  /// opinion about whether a pointer is resting on a link. [onOpenChanged]
  /// still reports either way.
  final bool? open;

  /// Called whenever the card opens or closes, however it was asked.
  final ValueChanged<bool>? onOpenChanged;

  /// Stops the card opening at all, without disabling the trigger.
  final bool disabled;

  /// A hard cap on the card's width, overriding the one [size] implies.
  final double? width;

  /// Type scale, radius and padding of the sheet.
  final PlassSize? size;

  /// The family the focus ring and any accent inside take.
  final PlassColor? color;

  /// How tightly the sheet packs its content.
  final PlassDensity? density;

  @override
  State<PlHoverCard> createState() => _PlHoverCardState();
}

class _PlHoverCardState extends State<PlHoverCard> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  bool _open = false;
  PlassSide _side = PlassSide.bottom;
  Timer? _timer;

  /// Whether the pointer is on the trigger, and whether it is on the card. Two
  /// flags rather than one because the gap between them has neither, and a card
  /// that closed on leaving the trigger could never be reached.
  bool _onTrigger = false;
  bool _onCard = false;

  @override
  void initState() {
    super.initState();
    _side = widget.side;
    _open = widget.open ?? false;
  }

  @override
  void didUpdateWidget(PlHoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.open != null && widget.open != _open) {
      _open = widget.open!;
    }

    if (widget.disabled && _open) {
      _open = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _set(bool next) {
    _timer?.cancel();
    _timer = null;

    if (_open == next) {
      return;
    }

    if (widget.open == null) {
      setState(() => _open = next);
    }

    widget.onOpenChanged?.call(next);
  }

  void _schedule(bool next) {
    if (widget.disabled) {
      return;
    }

    _timer?.cancel();

    final wait = next ? widget.delay : widget.closeDelay;

    if (wait == Duration.zero) {
      _set(next);

      return;
    }

    _timer = Timer(wait, () {
      // Read again on the way out: the pointer may have crossed the gap into
      // the card while the timer was running.
      if (!next && (_onTrigger || _onCard)) {
        return;
      }

      _set(next);
    });
  }

  void _pointer({bool? trigger, bool? card}) {
    _onTrigger = trigger ?? _onTrigger;
    _onCard = card ?? _onCard;

    _schedule(_onTrigger || _onCard);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final size = _size;
    final density = _density;
    final radius = BorderRadius.circular(PlassTokens.radius[size]!);
    final body = sheetBody[size]!;

    Widget popup = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.width ?? _maxWidth[size]!),
      child: PlassSurfaceBox(
        surface: PlassSurface(
          fill: tokens.glassPress,
          border: Border.all(color: tokens.glassLine, width: hairline),
          ink: tokens.fg,
          blur: true,
          insets: <PlassInsetShadow>[tokens.glossGlass],
          shadows: tokens.elevation(plassElevationMax),
        ),
        borderRadius: radius,
        duration: PlassTokens.durationSlow,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: tokens.fg,
            fontSize: body.size,
            height: body.height,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sheetPaddingX[density]![size]!,
              vertical: sheetPaddingY[density]![size]!,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: sheetSectionGap[size]!,
              children: <Widget>[
                if (widget.title != null || widget.description != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: sheetHeaderGap[size]!,
                    children: <Widget>[
                      if (widget.title != null)
                        DefaultTextStyle.merge(
                          style: TextStyle(
                            color: tokens.fg,
                            fontSize: sheetTitle[size]!.size,
                            height: sheetTitle[size]!.height,
                            fontWeight: FontWeight.w600,
                            leadingDistribution: TextLeadingDistribution.even,
                          ),
                          child: Semantics(header: true, child: widget.title!),
                        ),
                      if (widget.description != null)
                        DefaultTextStyle.merge(
                          style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                          child: widget.description!,
                        ),
                    ],
                  ),
                if (widget.child != null) widget.child!,
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.arrow) {
      popup = PlassWedged(
        side: _side,
        size: _arrowSize[size]!,
        fill: tokens.glassPress,
        line: tokens.glassLine,
        child: popup,
      );
    }

    // The card is hoverable, which is the whole difference from a tooltip: the
    // pointer can cross into it and what is inside can be pressed.
    popup = MouseRegion(
      onEnter: (_) => _pointer(card: true),
      onExit: (_) => _pointer(card: false),
      child: popup,
    );

    Widget trigger = MouseRegion(
      onEnter: (_) => _pointer(trigger: true),
      onExit: (_) => _pointer(trigger: false),
      child: widget.trigger,
    );

    // The keyboard's way in. A reader who tabs onto the link gets the same
    // preview a pointer would, which is the half a hover-only card loses.
    trigger = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (bool has) => _pointer(trigger: has),
      child: trigger,
    );

    return PlassAnchoredPortal(
      open: _open && !widget.disabled,
      side: widget.side,
      align: widget.align,
      offset: widget.offset,
      onSideResolved: (PlassSide side) {
        if (mounted && side != _side) {
          setState(() => _side = side);
        }
      },
      popup: PlassTheme.merge(
        defaults: PlassDefaults(color: _color),
        child: popup,
      ),
      child: trigger,
    );
  }
}
