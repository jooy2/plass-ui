/// A canvas that keeps the paints a painter filled its paths with.
///
/// `flutter_test`'s own `paints` matcher asserts a *sequence of named calls*,
/// which is the wrong shape for "nothing on this plot is faded": that is a
/// question about every paint at once, and about an alpha whose colour comes
/// out of the theme rather than out of the test. Recording the calls and
/// reading the alphas back answers it without naming a palette colour.
///
/// Only [drawPath] is recorded. Everything else a painter asks for — the grid
/// lines, the clips, the text — is accepted and dropped, which is what
/// [noSuchMethod] is doing here.
library;

import 'dart:ui';

class RecordingCanvas implements Canvas {
  /// Every paint a path was filled or stroked with, in the order it was drawn.
  final List<Paint> paints = <Paint>[];

  /// Only the fills, which is what a mark's colour and its alpha are on.
  List<Paint> get fills =>
      paints.where((Paint paint) => paint.style == PaintingStyle.fill).toList();

  @override
  void drawPath(Path path, Paint paint) => paints.add(paint);

  @override
  void noSuchMethod(Invocation invocation) {}
}
