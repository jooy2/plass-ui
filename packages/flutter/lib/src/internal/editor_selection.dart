/// A selection on a touch screen: the handles and the menu of a text field.
///
/// `TextField` gets these from Material or Cupertino, and this package imports
/// neither, so a field here is built on an `EditableText`, which draws neither
/// by itself. Without them a word taken with a long press can be neither
/// adjusted nor copied, and nothing can be pasted into a field.
///
/// None of this is exported from `plass_ui.dart` — it is the library talking to
/// itself.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// Whether a selection here is adjusted with a finger, on handles.
bool get plassTouchEditing =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.fuchsia;

/// Keeps the handles of a field under a selection a finger made.
///
/// A selection set by the code, by the keyboard or by a tap has none: they would
/// come up over a field that was only given the focus, and go on animating.
mixin PlassEditorHandles<T extends StatefulWidget> on State<T> {
  bool _handles = false;

  /// Whether the editor shows its handles now.
  bool get editorHandles => _handles;

  /// Told about every change of the selection.
  void noteEditorSelection(TextSelection selection, SelectionChangedCause? cause) {
    final bool next =
        plassTouchEditing &&
        cause != null &&
        cause != SelectionChangedCause.keyboard &&
        !selection.isCollapsed;

    if (next != _handles) {
      setState(() => _handles = next);
    }
  }
}

/// How far a handle's knob reaches past the line it marks.
const double _knobReach = 9;

/// The radius of a handle's knob.
const double _knobRadius = 5;

/// The width of the box a handle is drawn in, which is what a finger has to
/// land on.
const double _handleWidth = 24;

/// The handles for a field in [context], or `null` with no [Overlay] above it.
///
/// An editor with controls asks for an [Overlay] to put them in, and a field
/// needs none to be typed into, so one with nowhere to put them goes without.
TextSelectionControls? plassSelectionControls(BuildContext context, Color color) {
  return Overlay.maybeOf(context) == null ? null : PlassSelectionControls(color);
}

/// The handles of a selection, in the [color] the caret is.
///
/// A stem as tall as the line with a knob at its far end: over the start of the
/// selection and under its end. A caret has no handle of its own, since a tap
/// puts it where it is wanted.
class PlassSelectionControls extends TextSelectionControls with TextSelectionHandleControls {
  /// Creates the handles.
  PlassSelectionControls(this.color);

  /// What they are drawn in.
  final Color color;

  // By the colour, because an editor handed different controls builds its
  // selection overlay again, and these are made afresh on every build.
  @override
  bool operator ==(Object other) => other is PlassSelectionControls && other.color == color;

  @override
  int get hashCode => color.hashCode;

  @override
  Size getHandleSize(double textLineHeight) {
    return Size(_handleWidth, textLineHeight + _knobReach);
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return switch (type) {
      TextSelectionHandleType.left => Offset(_handleWidth / 2, textLineHeight + _knobReach),
      _ => Offset(_handleWidth / 2, textLineHeight),
    };
  }

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    if (type == TextSelectionHandleType.collapsed) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: getHandleSize(textLineHeight),
      painter: _HandlePainter(color: color, knobFirst: type == TextSelectionHandleType.left),
    );
  }
}

class _HandlePainter extends CustomPainter {
  const _HandlePainter({required this.color, required this.knobFirst});

  final Color color;

  /// Whether the knob is at the top, as it is on the start of a selection.
  final bool knobFirst;

  @override
  void paint(Canvas canvas, Size size) {
    final double x = size.width / 2;
    final paint = Paint()..color = color;

    canvas
      ..drawRect(Rect.fromLTWH(x - 1, 0, 2, size.height), paint)
      ..drawCircle(
        Offset(x, knobFirst ? _knobRadius : size.height - _knobRadius),
        _knobRadius,
        paint,
      );
  }

  @override
  bool shouldRepaint(_HandlePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.knobFirst != knobFirst;
  }
}

/// The words on a menu's buttons, in the language of the app.
String _labelOf(ContextMenuButtonItem item, WidgetsLocalizations words) {
  return item.label ??
      switch (item.type) {
        ContextMenuButtonType.cut => words.cutButtonLabel,
        ContextMenuButtonType.copy => words.copyButtonLabel,
        ContextMenuButtonType.paste => words.pasteButtonLabel,
        ContextMenuButtonType.selectAll => words.selectAllButtonLabel,
        ContextMenuButtonType.lookUp => words.lookUpButtonLabel,
        ContextMenuButtonType.searchWeb => words.searchWebButtonLabel,
        ContextMenuButtonType.share => words.shareButtonLabel,
        _ => '',
      };
}

/// The builder of the menu for a field in [context], or `null` with no [Overlay]
/// above it, for the same reason as [plassSelectionControls].
EditableTextContextMenuBuilder? plassEditorMenuBuilder(BuildContext context) {
  return Overlay.maybeOf(context) == null ? null : _editorMenu;
}

/// The menu of a selection: Cut, Copy, Paste and the rest.
///
/// iOS draws its own wherever the field holds a connection to the keyboard, and
/// that is the menu a reader there expects, with the system's own words. On any
/// other platform it is a sheet of glass over the selection.
Widget _editorMenu(BuildContext context, EditableTextState state) {
  if (SystemContextMenu.isSupportedByField(state)) {
    return SystemContextMenu.editableText(editableTextState: state);
  }

  return _EditorMenu(state: state);
}

class _EditorMenu extends StatelessWidget {
  const _EditorMenu({required this.state});

  final EditableTextState state;

  @override
  Widget build(BuildContext context) {
    final BuildContext field = state.context;
    final tokens = PlassTheme.of(field);
    final WidgetsLocalizations words =
        Localizations.of<WidgetsLocalizations>(field, WidgetsLocalizations) ??
        const DefaultWidgetsLocalizations();
    final TextSelectionToolbarAnchors anchors = state.contextMenuAnchors;
    final EdgeInsets safe = MediaQuery.paddingOf(field);
    const double margin = 8;
    final Offset inset = Offset(margin, safe.top + margin);

    final List<ContextMenuButtonItem> items = state.contextMenuButtonItems
        .where((ContextMenuButtonItem item) => _labelOf(item, words).isNotEmpty)
        .toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Lifted into the root overlay, above whatever theme and direction the
    // field had, so both are handed on from the field.
    return Directionality(
      textDirection: Directionality.of(field),
      child: PlassTheme.tokens(
        tokens: tokens,
        child: Padding(
          padding: EdgeInsets.fromLTRB(margin, safe.top + margin, margin, margin),
          child: CustomSingleChildLayout(
            delegate: TextSelectionToolbarLayoutDelegate(
              anchorAbove: anchors.primaryAnchor - inset,
              anchorBelow: (anchors.secondaryAnchor ?? anchors.primaryAnchor) - inset,
            ),
            child: PlassSurfaceBox(
              surface: PlassSurface(
                ink: tokens.fg,
                fill: tokens.glassPress,
                blur: true,
                shadows: tokens.elevation(3),
              ),
              borderRadius: BorderRadius.circular(tokens.radii[PlassSize.md]!),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (final ContextMenuButtonItem item in items)
                        PlButton(
                          size: PlassSize.sm,
                          variant: PlassVariant.ghost,
                          color: PlassColor.secondary,
                          onPressed: item.onPressed,
                          child: Text(_labelOf(item, words)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
