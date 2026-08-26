/// A set of options where exactly one is chosen.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// One option in a [PlRadioGroup].
///
/// A description rather than a widget, and for a sharper reason than the one a
/// `PlBreadcrumbItem` has: the group owns the roving focus and the arrow keys,
/// so it has to know which option is chosen, which are available, and what comes
/// after each one. None of that can be asked of a `Widget`.
///
/// It carries no `size` and no `color` either, and could not: both belong to the
/// set, which is the only place they can be set once and mean the same thing for
/// every option in it.
@immutable
class PlRadioOption<T> {
  /// Creates an option.
  const PlRadioOption({required this.value, this.label, this.description, this.disabled = false});

  /// What choosing this option means.
  final T value;

  /// The text beside the dot. Pressing it chooses the option.
  final Widget? label;

  /// Helper text under the label.
  final Widget? description;

  /// Unavailable. Keeps its place in the set and cannot be reached by an arrow
  /// key.
  final bool disabled;
}

/// A set of options where exactly one is chosen.
///
/// ```dart
/// PlRadioGroup<String>(
///   value: plan,
///   onChanged: (String next) => setState(() => plan = next),
///   label: const Text('Plan'),
///   options: const <PlRadioOption<String>>[
///     PlRadioOption<String>(value: 'starter', label: Text('Starter')),
///     PlRadioOption<String>(value: 'team', label: Text('Team')),
///   ],
/// )
/// ```
///
/// The set takes **one** focus stop and the arrow keys move within it, which is
/// the whole reason a radio group is a widget at all rather than a column of
/// controls: a set of five options that costs five tab presses to walk past is a
/// set that has misunderstood what it is.
///
/// The dot is round, and it is one of the two things in the library allowed to
/// be — roundness is exactly what tells a reader "one of these" rather than "any
/// of these", and it is the one convention old enough that breaking it would
/// cost more than it bought.
class PlRadioGroup<T> extends StatefulWidget {
  /// Creates a group.
  const PlRadioGroup({
    required this.options,
    required this.value,
    this.onChanged,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.orientation = PlassOrientation.vertical,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.readOnly = false,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The options, in the order they are shown.
  final List<PlRadioOption<T>> options;

  /// Which option is chosen, or `null` for none.
  final T? value;

  /// Called with the option that was chosen.
  ///
  /// Leaving it `null` disables the group, as it does everywhere else in
  /// Flutter.
  final ValueChanged<T>? onChanged;

  /// The tick ladder's step, shared by every option.
  final PlassSize size;

  /// Semantic colour role, shared by every option.
  final PlassColor color;

  /// Which way the options stack.
  ///
  /// Vertical by default — a column of options is scannable at any length, and
  /// a row silently becomes unreadable the moment one label is longer than
  /// expected.
  final PlassOrientation orientation;

  /// The question the options answer.
  final Widget? label;

  /// Helper text under the label.
  final Widget? description;

  /// Error message below the options. Its presence also turns the group
  /// invalid.
  final Widget? error;

  /// Forces the invalid state without a message — for when an external form
  /// library owns the validity.
  final bool? invalid;

  /// Inert but not dimmed — the choice is still there to be read.
  final bool readOnly;

  /// Unavailable. The light goes out.
  final bool disabled;

  /// Drive the group's one focus stop from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  State<PlRadioGroup<T>> createState() => _PlRadioGroupState<T>();
}

class _PlRadioGroupState<T> extends State<PlRadioGroup<T>> {
  bool get _disabled => widget.disabled || widget.onChanged == null;

  bool get _interactive => !_disabled && !widget.readOnly;

  /// Which option the one focus stop currently rests on.
  ///
  /// The chosen one, or — with nothing chosen yet — the first that can be
  /// reached. Which is the roving tab index, in a sentence.
  int get _focused {
    final chosen = widget.options.indexWhere(
      (PlRadioOption<T> option) => option.value == widget.value,
    );

    if (chosen >= 0) {
      return chosen;
    }

    final first = widget.options.indexWhere((PlRadioOption<T> option) => !option.disabled);

    return first < 0 ? 0 : first;
  }

  /// The next option in [step]'s direction that can be chosen, wrapping.
  ///
  /// Wrapping is what an arrow key does in a radio group and what it does not do
  /// in a list: the set is a ring of alternatives with no beginning.
  void _move(int step) {
    if (!_interactive || widget.options.isEmpty) {
      return;
    }

    final count = widget.options.length;
    var index = _focused;

    for (var tried = 0; tried < count; tried += 1) {
      index = (index + step + count) % count;

      if (!widget.options[index].disabled) {
        widget.onChanged!(widget.options[index].value);

        return;
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.arrowRight:
        _move(1);

        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.arrowLeft:
        _move(-1);

        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final hasError = widget.error != null;
    final isInvalid = widget.invalid ?? hasError;
    // Invalid re-points the whole family at `danger`, so every dot, the ring and
    // the message all turn over together.
    final family = tokens.family(isInvalid ? PlassColor.danger : widget.color);
    final meta = metaText[widget.size]!;

    final options = <Widget>[
      for (var index = 0; index < widget.options.length; index += 1)
        _Radio<T>(
          option: widget.options[index],
          selected: widget.options[index].value == widget.value,
          size: widget.size,
          family: family,
          tokens: tokens,
          disabled: _disabled || widget.options[index].disabled,
          readOnly: widget.readOnly,
          onPressed: _interactive && !widget.options[index].disabled
              ? () => widget.onChanged!(widget.options[index].value)
              : null,
          // Exactly one option is a focus stop, and the arrows move it. Every
          // other one is reachable by pointer and invisible to the tab key.
          focusable: index == _focused,
          focusNode: index == _focused ? widget.focusNode : null,
          autofocus: index == _focused && widget.autofocus,
        ),
    ];

    return Focus(
      // The group itself takes no focus: the option that currently holds the
      // stop does. This listens on the way past, which is what a key event
      // travelling up the focus chain from that option runs into.
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: Semantics(
        container: true,
        enabled: _interactive,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: <Widget>[
            if (widget.label != null)
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: _disabled ? tokens.mutedFg : tokens.fg,
                  fontSize: meta,
                  fontWeight: FontWeight.w600,
                ),
                child: widget.label!,
              ),
            if (widget.description != null)
              DefaultTextStyle.merge(
                style: TextStyle(color: tokens.mutedFg, fontSize: meta),
                child: widget.description!,
              ),
            if (widget.orientation == PlassOrientation.horizontal)
              Wrap(spacing: 20, runSpacing: 8, children: options)
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: options,
              ),
            if (hasError)
              DefaultTextStyle.merge(
                style: TextStyle(color: family.accent, fontSize: meta),
                child: widget.error!,
              ),
          ],
        ),
      ),
    );
  }
}

/// One drawn option.
class _Radio<T> extends StatelessWidget {
  const _Radio({
    required this.option,
    required this.selected,
    required this.size,
    required this.family,
    required this.tokens,
    required this.disabled,
    required this.readOnly,
    required this.onPressed,
    required this.focusable,
    required this.focusNode,
    required this.autofocus,
  });

  final PlRadioOption<T> option;
  final bool selected;
  final PlassSize size;
  final PlassColorFamily family;
  final PlassTokens tokens;
  final bool disabled;
  final bool readOnly;
  final VoidCallback? onPressed;
  final bool focusable;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final row = tickRowText[size]!;
    final box = tickSize[size]!;
    final dot = tickDot[size]!;
    final interactive = onPressed != null;

    Widget mark(PlassInteraction state) {
      // No gloss line and no tinted lift, for the reason a checkbox's tick has
      // neither: a 1px white edge is light on a cut edge at 40px and a grey
      // smudge at 18px, and a `0 6px 16px` shadow under an 18px circle is
      // bigger than the circle. The glass stays; only the two decorations go.
      Widget circle = AnimatedContainer(
        duration: reduceMotion ? Duration.zero : PlassTokens.duration,
        curve: PlassTokens.ease,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? null : tokens.glass,
          gradient: selected ? family.fill : null,
          border: selected
              ? null
              : Border.all(
                  color: interactive && state.hovered ? family.line : tokens.border,
                  width: hairline,
                ),
        ),
        child: Center(
          child: SizedBox.square(
            dimension: selected ? dot : 0,
            child: selected
                ? DecoratedBox(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: family.onSolid),
                  )
                : null,
          ),
        ),
      );

      circle = SizedBox.square(dimension: box, child: circle);

      circle = plassStateFilter(
        child: circle,
        disabled: disabled,
        readOnly: readOnly,
        hovered: state.hovered && selected,
        reduceMotion: reduceMotion,
        lit: selected,
      );

      if (state.focusVisible) {
        circle = CustomPaint(
          foregroundPainter: PlassFocusRingPainter(
            color: family.ring,
            borderRadius: BorderRadius.circular(box),
          ),
          child: circle,
        );
      }

      return circle;
    }

    return MergeSemantics(
      child: Semantics(
        container: true,
        inMutuallyExclusiveGroup: true,
        checked: selected,
        enabled: interactive,
        onTap: onPressed,
        // The roving tab index, in one widget: every option answers the
        // pointer, and exactly one of them is in the tab order.
        child: ExcludeFocus(
          excluding: !focusable,
          child: PlassInteractive(
            onTap: onPressed,
            interactive: interactive,
            enabled: !disabled,
            focusNode: focusNode,
            autofocus: autofocus,
            cursor: disabled
                ? SystemMouseCursors.forbidden
                : readOnly
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            builder: (BuildContext context, PlassInteraction state) {
              return DefaultTextStyle.merge(
                style: TextStyle(
                  color: tokens.fg,
                  fontSize: row.size,
                  height: row.height,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: <Widget>[
                    SizedBox(
                      height: row.line,
                      child: Center(child: mark(state)),
                    ),
                    if (option.label != null || option.description != null)
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 2,
                          children: <Widget>[
                            if (option.label != null)
                              DefaultTextStyle.merge(
                                style: TextStyle(color: disabled ? tokens.mutedFg : tokens.fg),
                                child: option.label!,
                              ),
                            if (option.description != null)
                              DefaultTextStyle.merge(
                                style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                                child: option.description!,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
