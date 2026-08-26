import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A key, which is the whole glyph a credentials section needs.
class _KeyGlyph extends StatelessWidget {
  const _KeyGlyph();

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);

    return CustomPaint(
      size: Size.square(theme.size ?? 16),
      painter: _KeyPainter(theme.color ?? const Color(0xFF000000)),
    );
  }
}

class _KeyPainter extends CustomPainter {
  const _KeyPainter(this.color);

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
      ..scale(size.shortestSide / 16)
      ..drawCircle(const Offset(5.5, 5.5), 3, paint)
      ..drawLine(const Offset(7.8, 7.8), const Offset(13, 13), paint)
      ..drawLine(const Offset(11, 13), const Offset(12.5, 11.5), paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_KeyPainter oldDelegate) => oldDelegate.color != color;
}

class AccordionSlots extends StatefulWidget {
  const AccordionSlots({super.key});

  @override
  State<AccordionSlots> createState() => _AccordionSlotsState();
}

class _AccordionSlotsState extends State<AccordionSlots> {
  Set<String> _open = <String>{'keys'};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: PlAccordion<String>(
        value: _open,
        onChanged: (Set<String> next) => setState(() => _open = next),
        items: <PlAccordionItem<String>>[
          PlAccordionItem<String>(
            value: 'keys',
            title: const Text('API keys'),
            subtitle: const Text('Two active'),
            startIcon: const _KeyGlyph(),
            action: PlButton(
              size: PlassSize.xs,
              variant: PlassVariant.ghost,
              onPressed: () {},
              child: const Text('New key'),
            ),
            child: const Text(
              'Keys are shown once, when they are created. Rotate one rather than sharing it.',
            ),
          ),
          const PlAccordionItem<String>(
            value: 'webhooks',
            title: Text('Webhooks'),
            subtitle: Text('None yet'),
            child: Text('Point a URL at an event and we will POST to it.'),
          ),
        ],
      ),
    );
  }
}
