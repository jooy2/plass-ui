/// An immediate on/off.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Track and thumb.
///
/// The thumb is inset 2px on every side, so its diameter is the track's height
/// minus 4 and its travel is the track's width minus the diameter and both
/// insets. That is the one number per step that has to be written out.
const Map<PlassSize, Size> _track = <PlassSize, Size>{
  PlassSize.xs: Size(24, 14),
  PlassSize.sm: Size(28, 16),
  PlassSize.md: Size(36, 20),
  PlassSize.lg: Size(44, 24),
  PlassSize.xl: Size(52, 28),
};

/// How far the thumb sits from every edge of the track.
const double _inset = 2;

/// The thumb is white in both themes — not the surface token, which is a near
/// navy in the dark and would leave the off state as a grey lozenge in a grey
/// slot.
const Color _thumb = Color(0xFFFFFFFF);

/// The shadow under it: the smallest on the ladder rather than a full step.
///
/// The thumb is the one part of a switch that genuinely is above the surface it
/// moves along, so it casts something — but a 14px disc under a 4px-blurred,
/// 14px-wide shadow is a knob, not a light.
const BoxShadow _thumbShadow = BoxShadow(
  color: Color(0x4014285A),
  offset: Offset(0, 1),
  blurRadius: 2,
);

/// An immediate on/off.
///
/// ```dart
/// PlSwitch(
///   value: notify,
///   onChanged: (bool next) => setState(() => notify = next),
///   label: const Text('Email me'),
/// )
/// ```
///
/// The difference from a [PlCheckbox] is not visual, it is temporal: a checkbox
/// is a value that gets submitted with a form, a switch takes effect the moment
/// it moves. If there is a Save button underneath, it should have been a
/// checkbox.
///
/// Off, the track is the **groove** — the one neutral ink in the library whose
/// job is to be seen from across a room. On, it is the family's gradient. There
/// is no well, no gloss and no edge: a groove that is a *tone* rather than a
/// recess needs no hairline to say where it ends, and an inset shadow under a
/// thumb carrying a drop shadow of its own is a moulded rocker in a bevelled
/// slot — the one picture this design language exists not to draw.
class PlSwitch extends StatelessWidget {
  /// Creates a switch.
  const PlSwitch({
    required this.value,
    this.onChanged,
    this.size,
    this.color,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.labelPlacement = PlassAlign.end,
    this.readOnly = false,
    this.disabled = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         labelPlacement != PlassAlign.center,
         'a switch label sits at the start or the end of the row, never in the middle',
       );

  /// Whether the switch is on.
  final bool value;

  /// Called with what the value should become.
  ///
  /// Leaving it `null` disables the switch, as it does everywhere else in
  /// Flutter.
  final ValueChanged<bool>? onChanged;

  /// The track's ladder — 24×14 to 52×28.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// The text beside the track. Pressing it flips the switch.
  final Widget? label;

  /// Helper text under the label.
  final Widget? description;

  /// Error message below. Its presence also turns the switch invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// Which side the label sits on.
  ///
  /// [PlassAlign.end] reads as a caption for the control; [PlassAlign.start] is
  /// for a settings list, where the labels form a column and every switch lines
  /// up on the trailing edge.
  final PlassAlign labelPlacement;

  /// Inert but not dimmed.
  final bool readOnly;

  /// Unavailable. The light goes out.
  final bool disabled;

  /// The name a screen reader announces, for a switch with no visible [label].
  final String? semanticLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  bool get _disabled => disabled || onChanged == null;

  bool get _interactive => !_disabled && !readOnly;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final tokens = PlassTheme.of(context);
    final hasError = error != null;
    final isInvalid = invalid ?? hasError;
    final family = tokens.family(isInvalid ? PlassColor.danger : color);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final row = tickRowText[size]!;
    final rail = _track[size]!;
    final diameter = rail.height - _inset * 2;
    final travel = rail.width - diameter - _inset * 2;

    Widget track(PlassInteraction state) {
      // A pill, and one of the two places in the library that is right.
      // Everywhere else the radius stops well short of 50%, because the flat run
      // along the top and bottom edge is what reads as a sheet with its corners
      // cut off. A switch is not a sheet — it is a track something runs along,
      // and a track with corners is a track the thumb would have to climb out
      // of.
      Widget rails = AnimatedContainer(
        duration: reduceMotion ? Duration.zero : PlassTokens.duration,
        curve: PlassTokens.ease,
        width: rail.width,
        height: rail.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rail.height),
          color: value ? null : tokens.track,
          gradient: value ? family.fill : null,
          boxShadow: value && _interactive ? <BoxShadow>[tokens.lift(family)] : null,
        ),
        child: Stack(
          children: <Widget>[
            AnimatedPositionedDirectional(
              duration: reduceMotion ? Duration.zero : PlassTokens.duration,
              curve: PlassTokens.ease,
              top: _inset,
              start: value ? _inset + travel : _inset,
              child: SizedBox.square(
                dimension: diameter,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _thumb,
                    boxShadow: <BoxShadow>[_thumbShadow],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      rails = plassStateFilter(
        child: rails,
        disabled: _disabled,
        readOnly: readOnly,
        hovered: state.hovered,
        reduceMotion: reduceMotion,
      );

      if (state.focusVisible) {
        rails = CustomPaint(
          foregroundPainter: PlassFocusRingPainter(
            color: family.ring,
            borderRadius: BorderRadius.circular(rail.height),
          ),
          child: rails,
        );
      }

      return rails;
    }

    Widget field = PlassInteractive(
      onTap: _interactive ? () => onChanged!(!value) : null,
      interactive: _interactive,
      enabled: !_disabled,
      focusNode: focusNode,
      autofocus: autofocus,
      cursor: _disabled
          ? SystemMouseCursors.forbidden
          : readOnly
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      builder: (BuildContext context, PlassInteraction state) {
        final text = label != null || description != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: <Widget>[
                  if (label != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(color: _disabled ? tokens.mutedFg : tokens.fg),
                      child: label!,
                    ),
                  if (description != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                      child: description!,
                    ),
                ],
              )
            : null;

        final slots = <Widget>[
          // A box the height of one line centres the track on the *first* line
          // of the label rather than on the whole block.
          SizedBox(
            height: row.line,
            child: Center(child: track(state)),
          ),
          // With the label on the leading side it has to take the slack, or the
          // switch sits against the text instead of against the edge of the row.
          if (text != null)
            labelPlacement == PlassAlign.start ? Expanded(child: text) : Flexible(child: text),
        ];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: labelPlacement == PlassAlign.start ? MainAxisSize.max : MainAxisSize.min,
          spacing: 10,
          children: labelPlacement == PlassAlign.start ? slots.reversed.toList() : slots,
        );
      },
    );

    field = DefaultTextStyle.merge(
      style: TextStyle(
        color: tokens.fg,
        fontSize: row.size,
        height: row.height,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      child: field,
    );

    if (hasError) {
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: <Widget>[
          field,
          DefaultTextStyle.merge(
            style: TextStyle(color: family.accent, fontSize: metaText[size]!),
            child: error!,
          ),
        ],
      );
    }

    return MergeSemantics(
      child: Semantics(
        container: true,
        toggled: value,
        enabled: _interactive,
        label: semanticLabel,
        onTap: _interactive ? () => onChanged!(!value) : null,
        child: field,
      ),
    );
  }
}
