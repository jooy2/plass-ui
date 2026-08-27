/// The shell the pickers wear: a field-shaped trigger with a popup hanging off
/// it.
///
/// Here rather than in one of the components for the reason the calendar is:
/// several components need it, and none of them should have to import another.
/// What it draws is deliberately not new — the trigger is `fieldSurface`, the
/// same box a [PlTextField] and a [PlSelect]'s trigger are drawn on, to the
/// pixel. A form where the date field is a different height, radius or material
/// from the text field beside it is a form that looks assembled rather than
/// designed.
///
/// The one thing the pickers do *not* offer is typing a date into the trigger.
/// Parsing a date out of free text is locale-dependent in a way that cannot be
/// done honestly without a date library, and a field that understands `27/7/26`
/// in one place and not the next is worse than one that never claimed to. So the
/// trigger is a button, exactly as a select's is, and the calendar is where the
/// answer comes from.
///
/// None of it is exported from `plass_ui.dart`.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/anchored.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far the popup stands off the trigger.
const double pickerStandoff = 6;

/// The popup's own padding, one track tighter than a control's.
const Map<PlassSize, double> popupPadding = <PlassSize, double>{
  PlassSize.xs: 6,
  PlassSize.sm: 8,
  PlassSize.md: 10,
  PlassSize.lg: 12,
  PlassSize.xl: 14,
};

/// The sheet a picker's panel is drawn on.
///
/// Like every floating surface in the library it carries a shadow by default, at
/// the top of the ladder, because it is genuinely off the screen rather than
/// merely on top of it. The glass at its most opaque: it has a page under it
/// rather than a sheet, and a 62%-translucent pane over arbitrary body copy is a
/// pane you read the body copy through.
PlassSurface pickerPopupSurface(PlassTokens tokens) {
  return PlassSurface(
    fill: tokens.glassPress,
    border: Border.all(color: tokens.glassLine, width: hairline),
    ink: tokens.fg,
    blur: true,
    insets: <PlassInsetShadow>[tokens.glossGlass],
    shadows: tokens.elevation(plassElevationMax),
  );
}

/// A trigger, a label, the two lines of text under it, and a popup.
///
/// Everything about it that is visible is a decision already made elsewhere: the
/// field surface, the read-only and disabled treatments, the label's type scale
/// and the way `invalid` re-points the whole colour family at `danger` so the
/// edge, the ring and the message turn over together.
class PlassPickerShell extends StatefulWidget {
  /// Creates a picker shell.
  const PlassPickerShell({
    required this.display,
    required this.semanticValue,
    required this.empty,
    required this.open,
    required this.onOpenChanged,
    required this.onClear,
    required this.clearLabel,
    required this.popup,
    this.samples = const <Widget>[],
    this.clearable = false,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.startIcon,
    this.fullWidth = false,
    this.readOnly = false,
    this.disabled = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// What the trigger reads. A placeholder when [empty].
  final Widget display;

  /// The same thing in words, or `null` when there is nothing chosen.
  ///
  /// The display is a widget and a screen reader wants a string, so the picker
  /// hands both over. It goes on the node as its **value** rather than being
  /// folded into the label, which is what a select already does: the label names
  /// the field and the value says what is in it.
  final String? semanticValue;

  /// Every string the display could hold, so the trigger stops changing width
  /// with its value.
  ///
  /// Laid out and not painted: a field that shrank when a shorter date was
  /// chosen would move out from under the finger that chose it.
  final List<Widget> samples;

  /// Nothing has been chosen yet, so the display is muted.
  final bool empty;

  /// Whether the popup is up.
  final bool open;

  /// Called when it should open or close.
  final ValueChanged<bool> onOpenChanged;

  /// Offers the × that empties the control.
  final bool clearable;

  /// Called when that × is pressed.
  final VoidCallback onClear;

  /// The name a screen reader gives it.
  final String clearLabel;

  /// The panel that floats off the trigger.
  final Widget popup;

  /// What the trigger's well is cut into.
  final PlassVariant variant;

  /// Height and type scale.
  final PlassSize size;

  /// Semantic colour role.
  final PlassColor color;

  /// Horizontal padding. Never the height.
  final PlassDensity density;

  /// Drop shadow depth of the **trigger**. The popup has its own, at the top of
  /// the ladder.
  final PlassElevation elevation;

  /// Label above the trigger.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Error message below it. Its presence also turns the control invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// The glyph before the value — a calendar or a clock.
  final Widget? startIcon;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The value is shown but cannot be changed, and the popup does not open.
  final bool readOnly;

  /// Unavailable.
  final bool disabled;

  /// The name a screen reader gives the trigger.
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlassPickerShell> createState() => _PlassPickerShellState();
}

class _PlassPickerShellState extends State<PlassPickerShell> {
  FocusNode? _owned;

  @override
  void dispose() {
    _owned?.dispose();
    super.dispose();
  }

  FocusNode get _focusNode =>
      widget.focusNode ?? (_owned ??= FocusNode(debugLabel: 'PlassPickerShell'));

  /// A read-only picker does not open. What it holds is something to read, and a
  /// calendar whose every cell was inert would be a menu of nothing.
  bool get _usable => !widget.disabled && !widget.readOnly;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final hasError = widget.error != null;
    final isInvalid = widget.invalid ?? hasError;
    final family = tokens.family(isInvalid ? PlassColor.danger : widget.color);

    final size = widget.size;
    final scale = controlTextLeading[size]!;
    final meta = metaText[size]!;
    final radius = BorderRadius.circular(PlassTokens.radius[size]!);

    final trigger = PlassInteractive(
      onTap: () => widget.onOpenChanged(!widget.open),
      enabled: !widget.disabled,
      interactive: _usable,
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : _usable
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      shortcuts: PlassInteractive.enterOnly,
      builder: (BuildContext context, PlassInteraction state) {
        final surface = fieldSurface(
          tokens,
          family,
          variant: widget.variant,
          elevation: widget.elevation,
          hovered: state.hovered,
          focused: state.focusVisible || widget.open,
          readOnly: widget.readOnly,
          disabled: widget.disabled,
        );

        Widget shell = ConstrainedBox(
          constraints: BoxConstraints(minHeight: controlHeight[size]!),
          child: PlassSurfaceBox(
            surface: surface,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingX[widget.density]![size]!),
              child: Row(
                mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                spacing: gap[size]!,
                children: <Widget>[
                  if (widget.startIcon != null)
                    IconTheme.merge(
                      data: IconThemeData(color: tokens.mutedFg, size: scale.size * iconScale),
                      child: widget.startIcon!,
                    ),
                  if (widget.fullWidth)
                    Expanded(child: _value(tokens, scale))
                  else
                    Flexible(child: _value(tokens, scale)),
                  if (widget.clearable && !widget.empty && _usable)
                    Semantics(
                      button: true,
                      label: widget.clearLabel,
                      onTap: widget.onClear,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        excludeFromSemantics: true,
                        onTap: widget.onClear,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: SizedBox(
                            height: scale.line,
                            child: Center(
                              child: PlassGlyph(
                                PlassGlyphShape.close,
                                size: scale.size * iconScale,
                                color: tokens.mutedFg,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );

        shell = plassStateFilter(
          child: shell,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          lit: false,
        );

        if (state.focusVisible) {
          shell = CustomPaint(
            foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
            child: shell,
          );
        }

        return Semantics(
          container: true,
          button: true,
          expanded: widget.open,
          readOnly: widget.readOnly,
          enabled: !widget.disabled,
          label: widget.semanticLabel,
          value: widget.semanticValue,
          onTap: _usable ? () => widget.onOpenChanged(!widget.open) : null,
          child: shell,
        );
      },
    );

    final field = PlassAnchoredPortal(
      open: widget.open,
      side: PlassSide.bottom,
      align: PlassAlign.start,
      offset: pickerStandoff,
      onDismiss: () => widget.onOpenChanged(false),
      popup: PlassSurfaceBox(
        surface: pickerPopupSurface(tokens),
        borderRadius: radius,
        // The panel is as wide as the widest thing in it — which is the
        // calendar — rather than as wide as the screen. A portal hands its popup
        // loose constraints, and a column that stretches inside those is a
        // footer whose buttons end up at the far edge of the world.
        child: IntrinsicWidth(
          child: Padding(padding: EdgeInsets.all(popupPadding[size]!), child: widget.popup),
        ),
      ),
      child: trigger,
    );

    final stack = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: stackGap[size]!,
      children: <Widget>[
        if (widget.label != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: widget.disabled ? tokens.mutedFg : tokens.fg,
              fontSize: meta,
              fontWeight: FontWeight.w600,
            ),
            child: widget.label!,
          ),
        field,
        if (widget.description != null)
          DefaultTextStyle.merge(
            style: TextStyle(color: tokens.mutedFg, fontSize: meta),
            child: widget.description!,
          ),
        if (hasError)
          DefaultTextStyle.merge(
            style: TextStyle(color: family.accent, fontSize: meta),
            child: widget.error!,
          ),
      ],
    );

    return widget.fullWidth ? stack : IntrinsicWidth(child: stack);
  }

  /// The value, over every value it could have been.
  ///
  /// The whole stack is excluded from semantics: the samples are there to be
  /// measured and never read, and the display itself is already on the node
  /// above as its value.
  Widget _value(PlassTokens tokens, PlassTextScale scale) {
    return ExcludeSemantics(
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: widget.empty ? tokens.mutedFg : tokens.fg,
          fontSize: scale.size,
          height: scale.height,
          leadingDistribution: TextLeadingDistribution.even,
        ),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: <Widget>[
            for (final Widget sample in widget.samples)
              Visibility(
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: sample,
              ),
            widget.display,
          ],
        ),
      ),
    );
  }
}

/// The row of shortcuts under a picker's panel.
///
/// A hairline above it rather than a gap, because the actions act on the panel
/// and a gap would read as a second popup stacked under the first.
class PlassPickerFooter extends StatelessWidget {
  /// Creates a footer.
  const PlassPickerFooter({required this.size, required this.children, super.key});

  /// The size the picker is on.
  final PlassSize size;

  /// The actions, which are ordinary buttons.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: tokens.divider, width: hairline),
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, spacing: gap[size]!, children: children),
    );
  }
}

/// The vertical hairline between a calendar and the clock beside it.
class PlassPickerDivider extends StatelessWidget {
  /// Creates the hairline.
  const PlassPickerDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: hairline, color: PlassTheme.of(context).divider);
  }
}
