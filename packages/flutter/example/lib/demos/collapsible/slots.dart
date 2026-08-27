import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A bell, which is the whole glyph a notifications section needs.
class _BellGlyph extends StatelessWidget {
  const _BellGlyph();

  @override
  Widget build(BuildContext context) {
    final IconThemeData theme = IconTheme.of(context);

    return CustomPaint(
      size: Size.square(theme.size ?? 16),
      painter: _BellPainter(theme.color ?? const Color(0xFF000000)),
    );
  }
}

class _BellPainter extends CustomPainter {
  const _BellPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.shortestSide / 24;
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * unit
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    final Path dome = Path()
      ..moveTo(6 * unit, 9 * unit)
      ..arcToPoint(Offset(18 * unit, 9 * unit), radius: Radius.circular(6 * unit))
      ..lineTo(19.5 * unit, 14.5 * unit)
      ..lineTo(4.5 * unit, 14.5 * unit)
      ..close();

    final Path clapper = Path()
      ..moveTo(10 * unit, 18 * unit)
      ..arcToPoint(Offset(14 * unit, 18 * unit), radius: Radius.circular(2 * unit));

    canvas
      ..drawPath(dome, stroke)
      ..drawPath(clapper, stroke);
  }

  @override
  bool shouldRepaint(_BellPainter oldDelegate) => oldDelegate.color != color;
}

class CollapsibleSlots extends StatefulWidget {
  const CollapsibleSlots({super.key});

  @override
  State<CollapsibleSlots> createState() => _CollapsibleSlotsState();
}

class _CollapsibleSlotsState extends State<CollapsibleSlots> {
  bool _open = true;
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: PlCollapsible(
        open: _open,
        onOpenChanged: (bool next) => setState(() => _open = next),
        title: const Text('Notifications'),
        subtitle: const Text('Email and push'),
        startIcon: const _BellGlyph(),
        action: PlSwitch(
          size: PlassSize.sm,
          value: _on,
          onChanged: (bool next) => setState(() => _on = next),
          label: const Text('On'),
        ),
        child: const Text(
          'The switch is outside the trigger, because a header that both folds and holds a '
          'control has two things to press and one of them cannot be inside the other.',
        ),
      ),
    );
  }
}
