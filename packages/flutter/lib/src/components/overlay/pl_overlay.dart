/// A sheet over the whole app that stops it being used.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/portal.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// The padding between the content and the edge of the screen.
const Map<PlassSize, double> _inset = <PlassSize, double>{
  PlassSize.xs: 12,
  PlassSize.sm: 16,
  PlassSize.md: 24,
  PlassSize.lg: 32,
  PlassSize.xl: 40,
};

/// How far the neutral dim blurs what is behind it.
///
/// A whisper rather than the house blur: the page is meant to still be legible,
/// and past about 16 a backdrop smears into flat colour and reads opaque no
/// matter how low its alpha goes.
const double _scrimBlur = 2;

/// How much of the [PlOverlayTone.glass] wash is scrim.
const double _glassScrim = 45;

/// How much of the page the overlay takes away.
enum PlOverlayTone {
  /// The neutral dim a [PlModal] puts behind itself. The page is still there and
  /// still readable; it has only stopped being reachable.
  scrim,

  /// The house material at full strength, turned on the whole page. A lighter
  /// dim over a real blur, so what is behind is present as shape and colour but
  /// not as words. For "this is being replaced".
  glass,

  /// The page surface, opaque. For a screen that is genuinely gone.
  solid,

  /// Nothing drawn at all. Still catches the pointer, which is the whole reason
  /// to reach for it.
  clear,
}

/// A sheet over the whole app that stops it being used.
///
/// ```dart
/// PlOverlay(
///   open: saving,
///   child: const PlassSpinner(),
/// )
/// ```
///
/// The difference from a [PlModal] is what is *not* here: no surface, no border,
/// no title, no actions. An overlay is the scrim on its own, with whatever the
/// caller puts on top of it — most often a spinner and a line saying what is
/// being waited for.
///
/// It is **not dismissible** by default, and that is the one parameter worth
/// reading twice. A modal asks a question and <kbd>Escape</kbd> is the universal
/// "no"; an overlay is not asking anything — it is saying *wait* — and a save
/// that can be dismissed by a stray press is a save the reader will think
/// finished.
///
/// There is no `variant`: the three materials answer "how much does this surface
/// assert itself against the page", and an overlay has taken the page. [tone] is
/// the question it actually has to answer. There is no `elevation` either — the
/// overlay *is* the plane everything else floats above, and a scrim with a drop
/// shadow is a scrim with an edge.
///
/// Needs an [Overlay] above it, which `WidgetsApp` with a navigator and
/// `MaterialApp` both provide.
class PlOverlay extends StatelessWidget {
  /// Creates an overlay.
  const PlOverlay({
    required this.open,
    this.onOpenChanged,
    this.child,
    this.tone = PlOverlayTone.scrim,
    this.dismissible = false,
    this.modal = true,
    this.align = PlassAlign.center,
    this.size,
    this.label,
    super.key,
  });

  /// Whether the overlay is up.
  final bool open;

  /// Called with `false` when the overlay asks to be closed.
  ///
  /// Only ever called when [dismissible] is on, because nothing else can ask.
  final ValueChanged<bool>? onOpenChanged;

  /// What sits on top of the scrim — a spinner, a line of text, a small card.
  final Widget? child;

  /// How much of the page is taken away.
  final PlOverlayTone tone;

  /// Whether a press outside the content or <kbd>Escape</kbd> closes it.
  ///
  /// Off by default, which is the other way round from [PlModal]. Turn it on for
  /// the overlay whose job is to catch a press outside something.
  final bool dismissible;

  /// Whether the page behind is taken away for the pointer as well as the
  /// keyboard.
  ///
  /// `false` leaves the page clickable and scrollable while focus is still held
  /// inside, which is what a [PlOverlayTone.clear] overlay usually wants.
  final bool modal;

  /// Where the content sits down the screen.
  final PlassAlign align;

  /// The padding between the content and the edge of the screen.
  final PlassSize? size;

  /// The name a screen reader gives the overlay. Never drawn.
  ///
  /// An overlay holding nothing readable — a bare spinner, a clear sheet — still
  /// has to say what it is, which is why this has a default rather than being
  /// left empty.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;

    final tokens = PlassTheme.of(context);

    return PlassPortal(
      open: open,
      modal: modal,
      label: label ?? PlassTheme.labelsOf(context).overlay,
      barrierColor: switch (tone) {
        PlOverlayTone.scrim => tokens.scrim,
        PlOverlayTone.glass => colorMix(tokens.scrim, _glassScrim),
        PlOverlayTone.solid => tokens.surface,
        PlOverlayTone.clear => null,
      },
      barrierBlur: switch (tone) {
        PlOverlayTone.scrim => _scrimBlur,
        PlOverlayTone.glass => tokens.blurSigma,
        PlOverlayTone.solid || PlOverlayTone.clear => 0,
      },
      onDismiss: dismissible ? () => onOpenChanged?.call(false) : null,
      child: Padding(
        padding: EdgeInsets.all(_inset[size]!),
        child: Align(
          alignment: switch (align) {
            PlassAlign.start => Alignment.topCenter,
            PlassAlign.center => Alignment.center,
            PlassAlign.end => Alignment.bottomCenter,
          },
          child: child == null
              ? const SizedBox.shrink()
              // A press on the content is not a press outside it, which is the
              // whole of what an outside press means.
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: tokens.fg),
                    textAlign: TextAlign.center,
                    child: child!,
                  ),
                ),
        ),
      ),
    );
  }
}
