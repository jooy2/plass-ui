/// Reading a widget as the words it draws.
library;

import 'package:flutter/widgets.dart';

/// The words [widget] draws when it is a [Text], for a semantics node that
/// needs its name as a string.
///
/// `null` for any other widget and for a blank [Text]: only a caller's own
/// `semanticLabel` can name a field whose label is a row of widgets.
String? plassTextOf(Widget? widget) {
  if (widget is! Text) {
    return null;
  }

  final String? text = widget.data ?? widget.textSpan?.toPlainText();

  return text == null || text.trim().isEmpty ? null : text;
}
