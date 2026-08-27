import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A magnifier, drawn rather than imported: the package ships no icon set.
class _SearchGlyph extends StatelessWidget {
  const _SearchGlyph();

  @override
  Widget build(BuildContext context) {
    final IconThemeData theme = IconTheme.of(context);

    return SizedBox(
      width: theme.size ?? 16,
      height: theme.size ?? 16,
      child: CustomPaint(painter: _SearchPainter(color: theme.color ?? const Color(0xFF000000))),
    );
  }
}

class _SearchPainter extends CustomPainter {
  const _SearchPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.09;

    final double radius = size.width * 0.25;
    final Offset centre = Offset(size.width * 0.46, size.height * 0.46);

    canvas.drawCircle(centre, radius, stroke);
    canvas.drawLine(
      centre + Offset(radius * 0.72, radius * 0.72),
      Offset(size.width * 0.85, size.height * 0.85),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_SearchPainter oldDelegate) => oldDelegate.color != color;
}

class ToolbarHero extends StatelessWidget {
  const ToolbarHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlToolbar(
      start: const <Widget>[PlTypography('Reports', level: PlTypographyLevel.h6)],
      end: <Widget>[
        PlIconButton(
          variant: PlassVariant.ghost,
          color: PlassColor.secondary,
          icon: const _SearchGlyph(),
          label: 'Search',
          onPressed: () {},
        ),
        PlButton(onPressed: () {}, child: const Text('New')),
        const PlAvatar(size: PlassSize.sm, name: 'Ada Lovelace'),
      ],
    );
  }
}
