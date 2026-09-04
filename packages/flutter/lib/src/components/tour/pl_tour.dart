/// A guided walk over a screen that already exists.
library;

import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/internal/dismiss.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/tour.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How wide the card is allowed to get — a [PlPopover]'s own ladder.
const Map<PlassSize, double> _maxWidth = <PlassSize, double>{
  PlassSize.xs: 224,
  PlassSize.sm: 256,
  PlassSize.md: 320,
  PlassSize.lg: 384,
  PlassSize.xl: 512,
};

/// The buttons on the card, one rung under the card's own scale.
const Map<PlassSize, PlassSize> _buttonSize = <PlassSize, PlassSize>{
  PlassSize.xs: PlassSize.xs,
  PlassSize.sm: PlassSize.xs,
  PlassSize.md: PlassSize.sm,
  PlassSize.lg: PlassSize.sm,
  PlassSize.xl: PlassSize.md,
};

/// The cut-out's corner radius, matching the radius ladder.
const Map<PlassSize, double> _holeRadius = <PlassSize, double>{
  PlassSize.xs: 6,
  PlassSize.sm: 8,
  PlassSize.md: 10,
  PlassSize.lg: 12,
  PlassSize.xl: 14,
};

/// How far the card stands off the light.
const double _gap = 10;

/// How close to the edge of the screen the card is allowed to get.
const double _margin = 12;

/// How far the scrim blurs what is behind it.
const double _blur = 2;

/// The × relative to the card's title, and the gap beside it.
const double _closeScale = 1.6;
const double _closeGap = 12;

/// One stop on the tour.
@immutable
class PlTourStep {
  /// Creates a stop.
  const PlTourStep({
    this.target,
    this.title,
    this.content,
    this.side = PlassSide.bottom,
    this.align = PlassAlign.center,
    this.padding = 6,
    this.radius,
  });

  /// What this step is about, as a [GlobalKey] on the widget itself.
  ///
  /// A key rather than a selector, which is what the React build also offers
  /// but as one form among three: over there a target can belong to something
  /// the page does not render, and a string is the only way to name it. Here
  /// every widget on the screen was written by somebody who can put a key on
  /// it, and a key is checked by the compiler.
  ///
  /// Left out, the step is centred over the screen with nothing cut out of the
  /// dimming — which is what a welcome step and a closing step are.
  final GlobalKey? target;

  /// The step's heading.
  final Widget? title;

  /// What it says.
  final Widget? content;

  /// Which edge of the target the card is asked for.
  final PlassSide side;

  /// Where it sits along that edge.
  final PlassAlign align;

  /// How far the cut-out is grown past the target, in logical pixels.
  ///
  /// A control with a focus ring wants a few, so the ring is inside the light
  /// rather than cut in half by its edge; a whole panel wants none.
  final double padding;

  /// The cut-out's corner radius. Defaults to the size's own.
  final double? radius;
}

/// A guided walk over a screen that already exists — the three things a new
/// reader has to be shown once, pointed at where they actually are.
///
/// It is [PlHowToSteps] turned inside out. That widget puts the instructions
/// *in* the screen and the reader follows them; this one leaves the screen as
/// it is and stands over it. So a step says what it is about rather than
/// describing it: what a tour points at is already on screen, and a second copy
/// inside the card is a second copy to keep in step.
///
/// ```dart
/// PlTour(
///   open: _running,
///   onOpenChanged: (bool next) => setState(() => _running = next),
///   steps: <PlTourStep>[
///     PlTourStep(target: _filterKey, title: const Text('Narrow the list')),
///     PlTourStep(target: _exportKey, title: const Text('Take it with you')),
///   ],
/// )
/// ```
///
/// **The dimming takes the pointer and the light does not.** The scrim is one
/// layer clipped to the whole screen with the target cut out of it, and a
/// [ClipPath] clips hit testing as well as painting — so the control being
/// pointed at can be used and nothing else can. That is the difference between
/// a tour and a dialog with a picture of a control in it, and it falls out of
/// the geometry rather than being a second mechanism that has to agree with it.
///
/// It is **not** built on `PlassPortal`, which every other layer in this
/// package is, and the reason is the same one: that helper holds focus inside
/// itself, which is right for a modal and wrong here. A tour whose reader
/// cannot reach the control it is pointing at has pointed at a picture.
///
/// The widget draws nothing where it is written, so it can go anywhere under an
/// [Overlay] — `WidgetsApp` with a navigator and `MaterialApp` both provide one.
class PlTour extends StatefulWidget {
  /// Creates a tour.
  const PlTour({
    required this.steps,
    this.open = false,
    this.onOpenChanged,
    this.step,
    this.initialStep = 0,
    this.onStepChanged,
    this.onFinish,
    this.controller,
    this.mask = true,
    this.skippable = true,
    this.dismissible = true,
    this.scrollIntoView = true,
    this.previousLabel,
    this.nextLabel,
    this.doneLabel,
    this.skipLabel,
    this.closeLabel,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// The stops, in order.
  final List<PlTourStep> steps;

  /// Whether the tour is running.
  final bool open;

  /// Called with what [open] should become — a press on Skip, on the ×, on Done,
  /// or <kbd>Escape</kbd>.
  final ValueChanged<bool>? onOpenChanged;

  /// Which stop, counted from `0`. Pass it with [onStepChanged] to control one.
  final int? step;

  /// Which one it starts on, when the tour keeps that itself.
  final int initialStep;

  /// Called with the stop a Next or Previous press asks for.
  final ValueChanged<int>? onStepChanged;

  /// Called when the last step's button is pressed, before the tour closes.
  final VoidCallback? onFinish;

  /// The scroll the targets live in, so the light follows them.
  ///
  /// The same parameter [PlAnchor] takes and for the same reason: the tour is
  /// lifted into the [Overlay] and cannot see a scroll notification from there,
  /// so the one thing it cannot work out for itself is handed to it. Without
  /// it, the light is measured when the step changes and when the window
  /// changes size, which is enough for a screen that does not scroll.
  final ScrollController? controller;

  /// Dims the screen and cuts the target out of the dimming.
  final bool mask;

  /// Draws the Skip button beside the counter.
  final bool skippable;

  /// Whether <kbd>Escape</kbd> and the × end the tour.
  final bool dismissible;

  /// Scrolls each target into view as the tour reaches it.
  final bool scrollIntoView;

  /// The Previous button. Defaults to the theme's word.
  final Widget? previousLabel;

  /// The Next button.
  final Widget? nextLabel;

  /// What Next becomes on the last step.
  final Widget? doneLabel;

  /// The Skip button.
  final Widget? skipLabel;

  /// The name a screen reader gives the ×.
  final String? closeLabel;

  /// Type scale and the card's width.
  final PlassSize? size;

  /// Semantic colour role: the buttons and the focus ring.
  final PlassColor? color;

  /// The card's padding. Never the type scale.
  final PlassDensity? density;

  @override
  State<PlTour> createState() => _PlTourState();
}

class _PlTourState extends State<PlTour> with WidgetsBindingObserver {
  final OverlayPortalController _portal = OverlayPortalController();

  int _step = 0;

  /// Where the light is, tagged with the step it was measured for.
  ///
  /// Tagged rather than bare, because the step changes a frame before the
  /// measurement catches up: an untagged rectangle would put the *last* step's
  /// hole around the next step's card for one frame, which is exactly the
  /// flicker a tour is supposed to be too calm for.
  Rect? _spot;
  int _spotAt = -1;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    WidgetsBinding.instance.addObserver(this);
    widget.controller?.addListener(_measure);

    if (widget.open) {
      _open();
    }
  }

  @override
  void didUpdateWidget(PlTour oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_measure);
      widget.controller?.addListener(_measure);
    }

    if (widget.open != oldWidget.open) {
      widget.open ? _open() : _portal.hide();
    }

    if (widget.open && widget.step != oldWidget.step) {
      _afterFrame(_reveal);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_measure);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _measure();
  }

  /// Runs [callback] once the frame that asked for it is over.
  ///
  /// Everything here is out of bounds during a build, and a build is nearly
  /// always where the change arrives from: a `setState` above it.
  void _afterFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => callback());
  }

  void _open() {
    _afterFrame(() {
      if (!mounted || !widget.open) {
        return;
      }

      _portal.show();
      _reveal();
    });
  }

  int get _index {
    final asked = widget.step ?? _step;

    return widget.steps.isEmpty ? 0 : asked.clamp(0, widget.steps.length - 1);
  }

  PlTourStep? get _current => widget.steps.isEmpty ? null : widget.steps[_index];

  /// Brings the step's target on screen, then reads where it landed.
  void _reveal() {
    final context = _current?.target?.currentContext;

    if (context != null && widget.scrollIntoView) {
      Scrollable.ensureVisible(context, alignment: 0.5, duration: PlassTokens.durationSlow);
      // After the scroll, not during it: a rectangle read mid-flight is a
      // rectangle the light would have to be dragged away from.
      Future<void>.delayed(PlassTokens.durationSlow, _measure);
    }

    _measure();
  }

  void _measure() {
    if (!mounted || !widget.open) {
      return;
    }

    final target = _current?.target;
    final box = target?.currentContext?.findRenderObject();

    if (box is! RenderBox || !box.hasSize) {
      if (_spot != null || _spotAt != _index) {
        setState(() {
          _spot = null;
          _spotAt = _index;
        });
      }

      return;
    }

    final next = inflate(box.localToGlobal(Offset.zero) & box.size, _current?.padding ?? 6);

    if (_spot != next || _spotAt != _index) {
      setState(() {
        _spot = next;
        _spotAt = _index;
      });
    }
  }

  void _setOpen({required bool next}) {
    widget.onOpenChanged?.call(next);

    // An uncontrolled tour has no `open` of its own to change — `open` is the
    // parameter, so a caller who gave one owns it. What this can still do is
    // take the layer down, so a Skip on a tour whose owner ignores the callback
    // is not a tour that cannot be left.
    if (!next) {
      _portal.hide();
    }
  }

  void _goTo(int next) {
    if (widget.step == null) {
      setState(() => _step = next);
    }

    widget.onStepChanged?.call(next);
    _afterFrame(_reveal);
  }

  void _finish() {
    widget.onFinish?.call();
    _setOpen(next: false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildLayer,
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildLayer(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final labels = PlassTheme.labelsOf(context);
    final size = widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final density = widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;
    final family = tokens.family(color);
    final step = _current!;
    final spot = _spotAt == _index ? _spot : null;
    final first = _index == 0;
    final last = _index == widget.steps.length - 1;

    Widget layer = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (widget.mask)
          ClipPath(
            clipper: _Spotlight(spot: spot, radius: step.radius ?? _holeRadius[size]!),
            // Opaque, so the dimmed screen is taken away for the pointer as
            // well as for the eye. The hole is not part of this box at all —
            // `ClipPath` clips hit testing with the painting — so what is being
            // pointed at goes on working.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
                child: ColoredBox(color: tokens.scrim, child: const SizedBox.expand()),
              ),
            ),
          ),
        CustomSingleChildLayout(
          delegate: _CardLayout(spot: spot, step: step, maxWidth: _maxWidth[size]!),
          child: _card(
            tokens: tokens,
            family: family,
            labels: labels,
            size: size,
            color: color,
            density: density,
            step: step,
            first: first,
            last: last,
          ),
        ),
      ],
    );

    layer = Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (DismissIntent _) {
              if (widget.dismissible) {
                _setOpen(next: false);
              }

              return null;
            },
          ),
        },
        child: layer,
      ),
    );

    // `explicitChildNodes` and no `scopesRoute`: the card is announced as its
    // own thing, and the screen under it is still there to be reached. A tour
    // that took the route would be a modal, and the reader could not get to the
    // control the tour is telling them about.
    return Semantics(container: true, explicitChildNodes: true, child: layer);
  }

  Widget _card({
    required PlassTokens tokens,
    required PlassColorFamily family,
    required PlassLabels labels,
    required PlassSize size,
    required PlassColor color,
    required PlassDensity density,
    required PlTourStep step,
    required bool first,
    required bool last,
  }) {
    final body = sheetBody[size]!;
    final buttons = _buttonSize[size]!;
    final hasHeader = step.title != null || step.content != null;

    return PlassSurfaceBox(
      // The same frosted panel a popover draws, at the same elevation.
      surface: PlassSurface(
        fill: tokens.glassPress,
        border: Border.all(color: tokens.glassLine, width: hairline),
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: tokens.elevation(plassElevationMax),
      ),
      borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: sheetSectionGap[size]!,
            children: <Widget>[
              if (hasHeader)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: _closeGap,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: sheetHeaderGap[size]!,
                        children: <Widget>[
                          if (step.title != null)
                            DefaultTextStyle.merge(
                              style: TextStyle(
                                color: tokens.fg,
                                fontSize: sheetTitle[size]!.size,
                                height: sheetTitle[size]!.height,
                                fontWeight: FontWeight.w600,
                                leadingDistribution: TextLeadingDistribution.even,
                              ),
                              child: Semantics(header: true, child: step.title!),
                            ),
                          if (step.content != null)
                            DefaultTextStyle.merge(
                              style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                              child: step.content!,
                            ),
                        ],
                      ),
                    ),
                    if (widget.dismissible)
                      PlassDismissButton(
                        label: widget.closeLabel ?? labels.close,
                        onPressed: () => _setOpen(next: false),
                        size: sheetTitle[size]!.size * _closeScale,
                        color: tokens.mutedFg,
                        ring: family.ring,
                      ),
                  ],
                ),
              Row(
                spacing: gap[size]!,
                children: <Widget>[
                  // Two numbers rather than a sentence. "3 of 7" is a string
                  // that has to be translated and a word order that differs by
                  // language; the count itself does not.
                  Text(
                    '${_index + 1} / ${widget.steps.length}',
                    style: TextStyle(
                      color: tokens.mutedFg,
                      fontSize: metaText[size]!,
                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                  // A `Wrap` rather than the rest of the row, because three
                  // buttons in a translation whose words are longer than
                  // English's are three buttons wider than the card. They go to
                  // a second line instead of off the edge — a card is as tall
                  // as what is written on it, which is the whole reason it is
                  // laid out rather than given a height.
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: gap[size]!,
                      runSpacing: gap[size]! / 2,
                      children: <Widget>[
                        if (widget.skippable && !last)
                          PlButton(
                            size: buttons,
                            variant: PlassVariant.ghost,
                            color: PlassColor.secondary,
                            onPressed: () => _setOpen(next: false),
                            child: widget.skipLabel ?? Text(labels.skip),
                          ),
                        if (!first)
                          PlButton(
                            size: buttons,
                            variant: PlassVariant.ghost,
                            color: color,
                            onPressed: () => _goTo(_index - 1),
                            child: widget.previousLabel ?? Text(labels.previous),
                          ),
                        PlButton(
                          size: buttons,
                          color: color,
                          onPressed: () => last ? _finish() : _goTo(_index + 1),
                          child: last
                              ? widget.doneLabel ?? Text(labels.done)
                              : widget.nextLabel ?? Text(labels.next),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The screen with the light cut out of it.
class _Spotlight extends CustomClipper<Path> {
  const _Spotlight({required this.spot, required this.radius});

  final Rect? spot;
  final double radius;

  @override
  Path getClip(Size size) => spotlightPath(size, spot, radius);

  @override
  bool shouldReclip(_Spotlight oldClipper) =>
      oldClipper.spot != spot || oldClipper.radius != radius;
}

/// Puts the card beside the light, or in the middle of the screen when there is
/// no light to be beside.
class _CardLayout extends SingleChildLayoutDelegate {
  const _CardLayout({required this.spot, required this.step, required this.maxWidth});

  final Rect? spot;
  final PlTourStep step;
  final double maxWidth;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // Loosened, because the card is as tall as what is written on it, and
    // capped so that a card never runs off the edge it is trying to point from.
    return BoxConstraints.loose(constraints.biggest).copyWith(
      maxWidth: maxWidth.clamp(0.0, (constraints.maxWidth - _margin * 2).clamp(0.0, maxWidth)),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    if (spot == null) {
      return Offset((size.width - childSize.width) / 2, (size.height - childSize.height) / 2);
    }

    return cardOffset(
      view: size,
      spot: spot!,
      card: childSize,
      side: step.side,
      align: step.align,
      gap: _gap,
      margin: _margin,
    );
  }

  @override
  bool shouldRelayout(_CardLayout oldDelegate) =>
      oldDelegate.spot != spot ||
      oldDelegate.step.side != step.side ||
      oldDelegate.step.align != step.align ||
      oldDelegate.maxWidth != maxWidth;
}
