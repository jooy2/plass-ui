import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A house, which is the whole glyph a first step needs.
class _HomeGlyph extends StatelessWidget {
  const _HomeGlyph();

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);

    return CustomPaint(
      size: Size.square(theme.size ?? 16),
      painter: _HomePainter(theme.color ?? const Color(0xFF000000)),
    );
  }
}

class _HomePainter extends CustomPainter {
  const _HomePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(2.5, 7)
      ..lineTo(8, 2.5)
      ..lineTo(13.5, 7)
      ..lineTo(13.5, 13.5)
      ..lineTo(2.5, 13.5)
      ..close();

    canvas
      ..save()
      ..scale(size.shortestSide / 16)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_HomePainter oldDelegate) => oldDelegate.color != color;
}

class BreadcrumbHero extends StatelessWidget {
  const BreadcrumbHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlBreadcrumb(
      items: <PlBreadcrumbItem>[
        PlBreadcrumbItem(
          label: const Text('Home'),
          startIcon: const _HomeGlyph(),
          onPressed: () {},
        ),
        PlBreadcrumbItem(label: const Text('Settings'), onPressed: () {}),
        PlBreadcrumbItem(label: const Text('Workspace'), onPressed: () {}),
        const PlBreadcrumbItem(label: Text('Billing')),
      ],
    );
  }
}
