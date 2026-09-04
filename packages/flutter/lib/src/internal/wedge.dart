/// The wedge a floating sheet points at its anchor with.
///
/// Written once because two surfaces draw it — a `PlPopover` and a
/// `PlHoverCard` — and a second copy of a triangle painter is a second place for
/// the hairline to stop lining up with the sheet's.
///
/// Not exported from `plass_ui.dart`.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/types.dart';

/// The popup with a wedge on the edge that faces the trigger.
///
/// Drawn pointing down once and turned to match — a rotation of a glyph, which
/// is the one allowance the no-transform rule makes. Only the two slanted sides
/// are stroked, so the wedge continues the sheet's hairline instead of drawing a
/// line across the edge it is growing out of.
class PlassWedged extends StatelessWidget {
  /// Wraps [child] with a wedge on the edge facing the anchor.
  const PlassWedged({
    required this.side,
    required this.size,
    required this.fill,
    required this.line,
    required this.child,
    super.key,
  });

  /// Which edge of the sheet faces the anchor.
  final PlassSide side;

  /// The wedge's width. Its height is half of that.
  final double size;

  /// The sheet's own fill, so the wedge is the same pane.
  final Color fill;

  /// The sheet's hairline, drawn on the two slanted sides only.
  final Color line;

  /// The sheet.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wedge = CustomPaint(
      size: Size(size, size / 2),
      painter: _WedgePainter(fill: fill, line: line),
    );

    // A quarter turn per side, so one drawing serves all four.
    final turned = switch (side) {
      PlassSide.top => wedge,
      PlassSide.bottom => RotatedBox(quarterTurns: 2, child: wedge),
      PlassSide.left => RotatedBox(quarterTurns: 3, child: wedge),
      PlassSide.right => RotatedBox(quarterTurns: 1, child: wedge),
    };

    // The wedge sits a hairline *inside* the sheet's edge, so the two overlap
    // and the sheet's own line runs into the wedge's rather than crossing it.
    return switch (side) {
      PlassSide.top => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          child,
          Transform.translate(offset: const Offset(0, -1), child: turned),
        ],
      ),
      PlassSide.bottom => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Transform.translate(offset: const Offset(0, 1), child: turned),
          child,
        ],
      ),
      PlassSide.left => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          child,
          Transform.translate(offset: const Offset(-1, 0), child: turned),
        ],
      ),
      PlassSide.right => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Transform.translate(offset: const Offset(1, 0), child: turned),
          child,
        ],
      ),
    };
  }
}

class _WedgePainter extends CustomPainter {
  const _WedgePainter({required this.fill, required this.line});

  final Color fill;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final triangle = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(triangle, Paint()..color = fill);

    // Only the two slanted sides.
    final edges = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(
      edges,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = hairline
        ..color = line,
    );
  }

  @override
  bool shouldRepaint(_WedgePainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.line != line;
}
