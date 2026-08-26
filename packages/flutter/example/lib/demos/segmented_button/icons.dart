import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// Four squares, and three rules with a bullet — the two layout glyphs.
class _LayoutGlyph extends StatelessWidget {
  const _LayoutGlyph({required this.grid});

  final bool grid;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);

    return CustomPaint(
      size: Size.square(theme.size ?? 16),
      painter: _LayoutPainter(grid: grid, color: theme.color ?? const Color(0xFF000000)),
    );
  }
}

class _LayoutPainter extends CustomPainter {
  const _LayoutPainter({required this.grid, required this.color});

  final bool grid;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas
      ..save()
      ..scale(size.shortestSide / 16);

    if (grid) {
      for (final origin in const <Offset>[
        Offset(2.5, 2.5),
        Offset(9, 2.5),
        Offset(2.5, 9),
        Offset(9, 9),
      ]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(origin.dx, origin.dy, 4.5, 4.5),
            const Radius.circular(1),
          ),
          paint,
        );
      }
    } else {
      for (final y in const <double>[4, 8, 12]) {
        canvas
          ..drawLine(Offset(5, y), Offset(14, y), paint)
          ..drawLine(Offset(2.5, y), Offset(2.6, y), paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LayoutPainter oldDelegate) {
    return oldDelegate.grid != grid || oldDelegate.color != color;
  }
}

class SegmentedButtonIcons extends StatefulWidget {
  const SegmentedButtonIcons({super.key});

  @override
  State<SegmentedButtonIcons> createState() => _SegmentedButtonIconsState();
}

class _SegmentedButtonIconsState extends State<SegmentedButtonIcons> {
  String _layout = 'grid';

  @override
  Widget build(BuildContext context) {
    return PlSegmentedButton<String>(
      semanticLabel: 'Layout',
      value: _layout,
      onChanged: (String next) => setState(() => _layout = next),
      segments: const <PlSegment<String>>[
        PlSegment<String>(value: 'grid', startIcon: _LayoutGlyph(grid: true), label: Text('Grid')),
        PlSegment<String>(
          value: 'list',
          startIcon: _LayoutGlyph(grid: false),
          label: Text('List'),
          endIcon: Text('12'),
        ),
      ],
    );
  }
}
