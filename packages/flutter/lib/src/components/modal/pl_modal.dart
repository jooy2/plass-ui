/// A sheet that takes the page away until it is answered.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/dismiss.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/portal.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far the scrim behind a modal blurs the page.
///
/// The same whisper a `PlOverlay`'s neutral tone uses, and it has to be: a modal
/// opened over an overlay would otherwise show a seam.
const double _scrimBlur = 2;

/// The room a modal keeps between its sheet and the edge of the screen.
const double _screenInset = 16;

/// How wide the sheet is allowed to get, per [PlassSize].
///
/// [PlassSize] and the width are one axis here rather than two. A second
/// five-value scale spelled `maxWidth` would be a second spelling of an idea the
/// library already has a word for, and the case it exists for — small type on a
/// wide sheet — is what [PlModal.width] is.
///
/// The steps are wider apart than the control ladder because they answer a
/// different question: not how big is this thing, but how long a line of text is
/// comfortable inside it.
const Map<PlassSize, double> _maxWidth = <PlassSize, double>{
  PlassSize.xs: 320,
  PlassSize.sm: 384,
  PlassSize.md: 512,
  PlassSize.lg: 672,
  PlassSize.xl: 896,
};

/// How large the × is drawn against the title beside it.
const double _closeScale = 1.6;

/// The gap between the header and the × in the corner.
const double _closeGap = 12;

/// The gap between two buttons in the actions row.
const double _actionsGap = 8;

/// A sheet that takes the page away until it is answered.
///
/// ```dart
/// PlModal(
///   open: confirming,
///   onOpenChanged: (bool next) => setState(() => confirming = next),
///   title: const Text('Delete this project?'),
///   description: const Text('Everything in it goes with it.'),
///   actions: <Widget>[
///     PlButton(variant: PlassVariant.ghost, onPressed: close, child: const Text('Cancel')),
///     PlButton(color: PlassColor.danger, onPressed: destroy, child: const Text('Delete')),
///   ],
///   child: const Text('This cannot be undone.'),
/// )
/// ```
///
/// The sections are parameters rather than sub-widgets, exactly as they are on a
/// `PlCard`: the arrangement of a modal is fixed — heading, description, body,
/// actions — and what a caller wants to decide is what goes in each slot.
///
/// The sheet is the glass at its most opaque, because what is behind it is
/// arbitrary: a modal floats over whatever the page happens to be, and a
/// 62%-translucent pane over a photograph is a pane you read the photograph
/// through. It is also one of the two surfaces in the library that is *supposed*
/// to float, so it carries a shadow one step past the ladder every other
/// component can ask for.
///
/// There is no `variant` and no `elevation`. The three materials answer "how
/// much does this surface assert itself against the page around it", and a modal
/// has already taken the page; a modal that could be told to sit flat on it
/// would be a modal that could be told to stop being one.
///
/// Only the body scrolls. The header and the actions stay put, which is why
/// [dividers] matters more here than on a card.
///
/// Needs an [Overlay] above it, which `WidgetsApp` with a navigator and
/// `MaterialApp` both provide.
class PlModal extends StatelessWidget {
  /// Creates a modal.
  const PlModal({
    required this.open,
    this.onOpenChanged,
    this.title,
    this.description,
    this.actions,
    this.child,
    this.dividers = false,
    this.showClose = true,
    this.closeLabel = 'Close',
    this.width,
    this.fullWidth = true,
    this.fullScreen = false,
    this.modal = true,
    this.dismissible = true,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    super.key,
  });

  /// Whether the modal is open.
  final bool open;

  /// Called with what the open state should become.
  ///
  /// This is the only way a modal closes itself: it is **controlled**, like
  /// every other stateful thing in the package, so the × and a press outside
  /// both report rather than act.
  final ValueChanged<bool>? onOpenChanged;

  /// The heading, and the modal's name.
  final Widget? title;

  /// A line under the title.
  final Widget? description;

  /// The bottom row.
  ///
  /// Laid out end-aligned and wrapping, so a pair of buttons needs no row of its
  /// own.
  final List<Widget>? actions;

  /// The body — the only part that scrolls.
  final Widget? child;

  /// Scores the sheet between the header, the body and the actions instead of
  /// separating them with space.
  ///
  /// Worth turning on the moment the body scrolls: the lines are what say the
  /// header stayed put.
  final bool dividers;

  /// Shows the × in the corner.
  ///
  /// On by default, unlike most of the switches in the library. A modal takes
  /// the page away until it is answered, and the visible way out should not have
  /// to be remembered.
  final bool showClose;

  /// The name a screen reader gives the ×. Never drawn.
  final String closeLabel;

  /// A hard cap on the sheet's width, overriding the one [size] implies.
  ///
  /// For the modal whose content decides its width — a wide table, a narrow
  /// confirmation — rather than for tuning the scale, which is [size].
  final double? width;

  /// The sheet takes the full width its [size] allows.
  ///
  /// On by default, which is the other way round from every other component.
  /// Elsewhere `fullWidth` means "fill the container"; a modal's container is the
  /// screen, and a modal that shrank to fit two words would be a tooltip.
  final bool fullWidth;

  /// Fills the screen edge to edge. For a small screen, or an editor.
  final bool fullScreen;

  /// Whether the page behind is taken away for the pointer as well as the
  /// keyboard.
  final bool modal;

  /// Whether <kbd>Escape</kbd> or a press outside closes the modal.
  ///
  /// Turn it off for the one that has to be answered — and then give it actions
  /// that answer it, because there will be no other way out.
  final bool dismissible;

  /// Type scale, radius, padding, and how wide the sheet is allowed to get.
  final PlassSize size;

  /// Semantic colour role. It reaches the focus rings inside and nothing else:
  /// what a modal holds arrives with its own colours.
  final PlassColor color;

  /// How tightly the sections pack.
  final PlassDensity density;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    void close() => onOpenChanged?.call(false);

    return PlassPortal(
      open: open,
      modal: modal,
      barrierColor: tokens.scrim,
      barrierBlur: _scrimBlur,
      onDismiss: dismissible ? close : null,
      child: Padding(
        padding: EdgeInsets.all(fullScreen ? 0 : _screenInset),
        child: Align(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: fullScreen ? double.infinity : width ?? _maxWidth[size]!,
            ),
            child: GestureDetector(
              // A press on the sheet is not a press outside it.
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: _sheet(context, tokens, close),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheet(BuildContext context, PlassTokens tokens, VoidCallback close) {
    final family = tokens.family(color);
    final insetX = sheetPaddingX[density]![size]!;
    final insetY = sheetPaddingY[density]![size]!;
    final body = sheetBody[size]!;
    final hasHeader = title != null || description != null;
    final hasActions = actions != null && actions!.isNotEmpty;

    final surface = PlassSurface(
      fill: tokens.glassPress,
      border: Border.all(color: tokens.glassLine, width: hairline),
      ink: tokens.fg,
      blur: true,
      insets: <PlassInsetShadow>[tokens.glossGlass],
      // One past the ladder any other component can ask for. A modal is
      // *supposed* to float, and the top of the ladder is where it floats from.
      shadows: tokens.elevation(plassElevationMax + 1),
    );

    // Paired with whether the section is the one allowed to give way when the
    // sheet runs out of screen. `Flexible` has to be a direct child of the
    // column, so which section is flexible has to be known out here.
    final sections = <({Widget child, bool flexible})>[
      if (hasHeader || showClose)
        (
          flexible: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: _closeGap,
            children: <Widget>[
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
                        // The heading is what names the modal, so it is announced
                        // as one rather than read as the first line of the body.
                        child: Semantics(header: true, child: title!),
                      ),
                    if (description != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                        child: description!,
                      ),
                  ],
                ),
              ),
              if (showClose)
                PlassDismissButton(
                  label: closeLabel,
                  onPressed: close,
                  size: sheetTitle[size]!.size * _closeScale,
                  color: tokens.mutedFg,
                  ring: family.ring,
                ),
            ],
          ),
        ),
      if (child != null)
        // The one part that scrolls, and the only one allowed to give way when
        // the sheet runs out of screen: a header that scrolled away would take
        // the modal's name with it.
        (flexible: true, child: SingleChildScrollView(child: child)),
      if (hasActions)
        (
          flexible: false,
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: _actionsGap,
            runSpacing: _actionsGap,
            children: actions!,
          ),
        ),
    ];

    Widget sheet = DefaultTextStyle.merge(
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
          children: <Widget>[
            for (var index = 0; index < sections.length; index += 1)
              // Scored, the rules have to reach both edges, so the sheet gives
              // up its vertical padding and every section takes it on instead.
              switch (sections[index]) {
                (:final bool flexible, :final Widget child) => () {
                  final band = _Section(
                    ruled: dividers && index > 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: insetX,
                      vertical: dividers ? insetY : 0,
                    ),
                    rule: tokens.divider,
                    child: child,
                  );

                  return flexible ? Flexible(child: band) : band;
                }(),
              },
          ],
        ),
      ),
    );

    sheet = PlassSurfaceBox(
      surface: surface,
      borderRadius: BorderRadius.circular(fullScreen ? 0 : PlassTokens.radius[size]!),
      child: sheet,
    );

    return fullScreen || fullWidth
        ? SizedBox(
            width: double.infinity,
            height: fullScreen ? double.infinity : null,
            child: sheet,
          )
        : sheet;
  }
}

/// One band of the sheet, with the rule above it when the sheet is scored.
///
/// A `Flexible` section has to stay flexible, and wrapping it in a `DecoratedBox`
/// inside the column would hand the scroll view an unbounded height — so the
/// decoration goes *around* the padding and the flex stays where the column can
/// see it.
class _Section extends StatelessWidget {
  const _Section({
    required this.ruled,
    required this.padding,
    required this.rule,
    required this.child,
  });

  final bool ruled;
  final EdgeInsets padding;
  final Color rule;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: ruled
            ? Border(
                top: BorderSide(color: rule, width: hairline),
              )
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
