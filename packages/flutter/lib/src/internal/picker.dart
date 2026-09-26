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
import 'package:plass_ui/src/internal/dismiss.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/notch.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/target.dart';
import 'package:plass_ui/src/internal/text.dart';
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
    this.labelPlacement,
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

  /// The name of what the control holds.
  final Widget? label;

  /// Where the [label] goes — above the trigger, or in its top edge.
  ///
  /// Resolved here rather than in each of the six pickers that draw this shell:
  /// they all hand their parameters straight through, and one resolution cannot
  /// disagree with itself the way six can.
  final PlassFieldLabelPlacement? labelPlacement;

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

  /// Empties the control, closes the popup if it is up, and keeps the focus on
  /// the control.
  ///
  /// The × leaves the tree with the value it cleared. Holding the focus as it
  /// goes, it would hand it to the scope round the picker, which gives it to
  /// whatever it focused before — the next field, for a reader who reached the
  /// × moving backwards — and take them off the field they had just emptied.
  /// The trigger's node counts a focused descendant as focus, and the × is the
  /// only one.
  void _clear() {
    final held = _focusNode.hasFocus && !_focusNode.hasPrimaryFocus;

    widget.onClear();

    // As a press anywhere else outside the popup closes it, and as the React ×
    // closes it, which is outside the popover's trigger.
    if (widget.open) {
      widget.onOpenChanged(false);
    }

    if (held) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final hasError = widget.error != null;
    final isInvalid = widget.invalid ?? hasError;
    final family = tokens.family(isInvalid ? PlassColor.danger : widget.color);

    final size = widget.size;
    final scale = controlTextLeading[size]!;
    final meta = metaText[size]!;
    final radius = BorderRadius.circular(tokens.radii[size]!);
    final placement =
        widget.labelPlacement ??
        PlassTheme.labelPlacementOf(context) ??
        PlassFieldLabelPlacement.top;
    // A notch with nothing in it is a gap in the edge for no reason, so the
    // placement only takes effect where there is a label to put there.
    final notched = placement == PlassFieldLabelPlacement.notch && widget.label != null;

    // One widget for both placements, so the label a reader taps and the label
    // a screen reader reads are the same widget wherever it is drawn — the
    // exclusion included, or the notch would name the trigger a second time.
    final Widget? labelNode = widget.label == null
        ? null
        : ExcludeSemantics(
            excluding: widget.semanticLabel == null && plassTextOf(widget.label) != null,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: widget.disabled ? tokens.mutedFg : tokens.fg,
                fontSize: meta,
                fontWeight: FontWeight.w600,
              ),
              child: widget.label!,
            ),
          );

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
        // The trigger's own focus. A focus node counts a focused descendant as
        // focus, and the × inside the trigger is a stop of its own that draws its
        // own ring.
        final bool focusVisible = state.focusVisible && Focus.of(context).hasPrimaryFocus;
        final surface = fieldSurface(
          tokens,
          family,
          variant: widget.variant,
          elevation: widget.elevation,
          hovered: state.hovered,
          focused: focusVisible || widget.open,
          readOnly: widget.readOnly,
          disabled: widget.disabled,
        );

        Widget shell = ConstrainedBox(
          constraints: BoxConstraints(minHeight: controlHeight[size]!),
          child: PlassSurfaceBox(
            // A notched trigger hands its edge over: the line round it has a
            // gap in it, and a gap is not something a border can have.
            surface: notched ? surface.withoutBorder() : surface,
            borderRadius: radius,
            // The interaction light. A trigger is a field, and a field
            // answering a pointer is as true a claim as a key answering one —
            // but it is a locked field's claim to make, so a disabled or a
            // read-only one carries none.
            pointer: state.pointer,
            glow: _usable ? tokens.fieldGlow(family) : null,
            glowVisible: state.hovered,
            flash: _usable ? tokens.fieldFlash(family) : null,
            flashVisible: state.pressed,
            reduceMotion: reduceMotion,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingX[widget.density]![size]!),
              child: Row(
                mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                spacing: gap[size]!,
                children: <Widget>[
                  // Muted, the words as well as the glyph, as a text field's
                  // adornment is and as the React field's is.
                  if (widget.startIcon != null)
                    IconTheme.merge(
                      data: IconThemeData(color: tokens.mutedFg, size: scale.size * iconScale),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: tokens.mutedFg),
                        child: widget.startIcon!,
                      ),
                    ),
                  if (widget.fullWidth)
                    Expanded(child: _value(tokens, scale))
                  else
                    Flexible(child: _value(tokens, scale)),
                  if (widget.clearable && !widget.empty && _usable)
                    // Drawn at the size of the text, and pressed from a 24px
                    // square through the scope round the trigger. A focus stop
                    // of its own after the trigger, so the value can be cleared
                    // from the keyboard too.
                    SizedBox(
                      height: scale.line,
                      child: Center(
                        child: PlassDismissButton(
                          label: widget.clearLabel,
                          onPressed: _clear,
                          size: scale.size * iconScale,
                          color: tokens.mutedFg,
                          ring: family.ring,
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

        if (notched) {
          // No ring here: an outline is a rectangle and the label is sitting on
          // the edge it would be drawn along, so the edge itself thickens.
          shell = PlassFieldNotch(
            size: size,
            density: widget.density,
            disabled: widget.disabled,
            edge: notchEdgePainter(
              tokens,
              family,
              variant: widget.variant,
              borderRadius: radius,
              hovered: state.hovered,
              focused: focusVisible || widget.open,
              readOnly: widget.readOnly,
              disabled: widget.disabled,
            ),
            label: labelNode!,
            child: shell,
          );
        } else {
          // Always there, with only the painter coming and going. A ring wrapped
          // round the shell when it is needed would move the shell to a new
          // parent as the focus steps on to the ×, and the × built again from
          // scratch would lose the focus it had just been given.
          shell = CustomPaint(
            foregroundPainter: focusVisible
                ? PlassFocusRingPainter(color: family.ring, borderRadius: radius)
                : null,
            child: shell,
          );
        }

        return Semantics(
          container: true,
          button: true,
          expanded: widget.open,
          readOnly: widget.readOnly,
          enabled: !widget.disabled,
          // The field's label names the trigger, and what is chosen is the value.
          label: widget.semanticLabel ?? plassTextOf(widget.label),
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
      // A press on the trigger reaches it rather than closing the popup on its
      // way down and going no further. The trigger closes the popup itself, and
      // the × inside it would otherwise never be pressed while the popup is up.
      anchorInside: true,
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
      child: PlassTargetScope(child: trigger),
    );

    final stack = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: stackGap[size]!,
      children: <Widget>[
        // Left out of the tree when its words already name the trigger, so the
        // label is not read once on its own and again as the trigger.
        if (labelNode != null && !notched) labelNode,
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
    // A `fullWidth` shell takes its width from its container, so it lays out no
    // samples: every one built there, and every picture in one, would be work
    // for nothing.
    final samples = widget.fullWidth ? const <Widget>[] : widget.samples;

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
            for (final Widget sample in samples)
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
