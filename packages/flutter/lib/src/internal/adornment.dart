/// What a field draws its `startIcon` and `endIcon` in.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// A field's adornment: [child] in a box one line of the field's type tall.
///
/// The React field's adornment is a `h-[1lh]` box inside a shell whose type
/// classes set the size and the line of everything in it and whose muted ink is
/// the colour of everything in it. This is that box in Dart, written once so
/// that every field draws the same one.
///
/// - One line tall and centred, so the adornment sits on the field's first line
///   rather than in the middle of the whole box, which is the only way it stays
///   put when a text field grows to five rows. A picture taller than a line
///   does not make the field taller.
/// - Muted, the words as well as the glyph, and whether or not the field holds
///   the focus: the family reaches the edge, the ring and the caret, and stops.
/// - A word in it is set in the value's type and line, so a currency sign or a
///   unit is the size of the value beside it at every `size`.
class PlassFieldAdornment extends StatelessWidget {
  /// Creates the adornment of a field of [size].
  const PlassFieldAdornment({required this.size, required this.child, super.key});

  /// The field's size, which decides the line, the type and the glyph.
  final PlassSize size;

  /// The caller's `startIcon` or `endIcon`, or a glyph the field draws there.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final muted = PlassTheme.of(context).mutedFg;
    final scale = controlTextLeading[size]!;

    return SizedBox(
      height: scale.line,
      child: Center(
        child: IconTheme.merge(
          data: IconThemeData(color: muted, size: scale.size * iconScale),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: muted,
              fontSize: scale.size,
              height: scale.height,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
