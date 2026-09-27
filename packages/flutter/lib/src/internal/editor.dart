/// What a tap and a screen reader's focus do to a field built on an
/// [EditableText].
///
/// The editor answers neither on its own: its focus is kept off the semantics
/// tree, and a field's press on its shell excludes itself from it. So the
/// field's own node carries the two, answered as a Material `TextField` answers
/// them. The focus is the one that matters most: a screen reader on the web
/// moves the browser's focus onto the field's `<input>`, and that arrives as
/// nothing but a focus action.
///
/// The tap is also what a press on the field does. The editor asks for the
/// keyboard only when a press on its text moves the caret, and hears nothing of
/// a press round the text, or of any press on a field whose editor takes none.
/// [PlassEditorPress] hears a press on the text, and the field's shell a press
/// round it.
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// A tap on a field, from a screen reader or from a press on the field: a caret
/// at the end of the text if it has no selection yet, and the keyboard, which
/// brings the focus with it.
///
/// A field that holds the focus with its keyboard put away gets the keyboard
/// back, which a focus request alone would not do, and a caret already placed
/// stays where it is. A read-only field takes the focus and opens no keyboard.
void plassTapEditor(GlobalKey<EditableTextState> editor) {
  final EditableTextState? state = editor.currentState;

  if (state == null) {
    return;
  }

  final TextEditingController controller = state.widget.controller;

  if (!controller.selection.isValid) {
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
  }

  state.requestKeyboard();
}

/// A screen reader moving the focus onto a field: the field takes it, or,
/// holding it already, gets back the keyboard the platform had put away, as it
/// does when the web closes its editing session under a focused field.
///
/// [focus] is how the field takes the focus, for a field that puts its caret
/// somewhere of its own as it does; a plain focus request otherwise.
void plassFocusEditor(GlobalKey<EditableTextState> editor, {VoidCallback? focus}) {
  final EditableTextState? state = editor.currentState;

  if (state == null) {
    return;
  }

  final FocusNode node = state.widget.focusNode;

  if (!node.hasFocus) {
    (focus ?? node.requestFocus)();
  } else if (!state.widget.readOnly) {
    state.requestKeyboard();
  }
}

/// Hears a press on an editor's text, which the editor answers with the
/// keyboard only when the press moves the caret, and calls [onPress] for it
/// once the editor has answered it.
///
/// It takes no part in deciding what the press was, so the editor still puts
/// the caret where the press landed and a long press still takes a word, and
/// the shell round the text, whose press loses to the editor's, never hears the
/// same press. A press counts when it is made with the primary button and ends
/// within [kTouchSlop] of where it went down, however long it was held; a drag
/// across the text does not.
class PlassEditorPress extends StatefulWidget {
  /// Creates a listener for a press on the text of the editor in [child].
  const PlassEditorPress({super.key, required this.onPress, required this.child});

  /// What a tap on the text does, usually [plassTapEditor], or `null` for
  /// nothing, as on a disabled field.
  final VoidCallback? onPress;

  /// The editor, and whatever is drawn in its place, such as a placeholder.
  final Widget child;

  @override
  State<PlassEditorPress> createState() => _PlassEditorPressState();
}

class _PlassEditorPressState extends State<PlassEditorPress> {
  /// Where the press went down, for as long as it can still be a tap.
  Offset? _pressedAt;

  void _down(PointerDownEvent event) {
    _pressedAt = event.buttons == kPrimaryButton ? event.position : null;
  }

  void _move(PointerMoveEvent event) {
    final Offset? at = _pressedAt;

    if (at != null && (event.position - at).distance > kTouchSlop) {
      _pressedAt = null;
    }
  }

  void _up(PointerUpEvent event) {
    if (_pressedAt == null) {
      return;
    }

    _pressedAt = null;

    // After the editor has answered the press, which it does as the arena is
    // swept once this event has reached every listener. Asked first, on a
    // field without the focus, the caret [plassTapEditor] puts at the end would
    // be one the press then finds already in place, and the editor answers a
    // press that changed nothing on such a field by building a selection
    // overlay.
    scheduleMicrotask(() {
      if (mounted) {
        widget.onPress?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool live = widget.onPress != null;

    return Listener(
      onPointerDown: live ? _down : null,
      onPointerMove: live ? _move : null,
      onPointerUp: live ? _up : null,
      onPointerCancel: (PointerCancelEvent event) => _pressedAt = null,
      child: widget.child,
    );
  }
}
