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
library;

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
