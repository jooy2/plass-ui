import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A magnifier, which is the whole glyph a search field needs.
class _SearchGlyph extends StatelessWidget {
  const _SearchGlyph();

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);

    return CustomPaint(
      size: Size.square(theme.size ?? 16),
      painter: _SearchPainter(theme.color ?? const Color(0xFF000000)),
    );
  }
}

class _SearchPainter extends CustomPainter {
  const _SearchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas
      ..save()
      ..scale(size.shortestSide / 16)
      ..drawCircle(const Offset(7, 7), 4.5, paint)
      ..drawLine(const Offset(10.5, 10.5), const Offset(13.5, 13.5), paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_SearchPainter oldDelegate) => oldDelegate.color != color;
}

class TextFieldIcons extends StatefulWidget {
  const TextFieldIcons({super.key});

  @override
  State<TextFieldIcons> createState() => _TextFieldIconsState();
}

class _TextFieldIconsState extends State<TextFieldIcons> {
  final TextEditingController _domain = TextEditingController(text: 'acme');
  final TextEditingController _checking = TextEditingController(text: 'acme');

  @override
  void dispose() {
    _domain.dispose();
    _checking.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          const PlTextField(
            fullWidth: true,
            startIcon: _SearchGlyph(),
            placeholder: 'Search projects',
          ),
          PlTextField(
            fullWidth: true,
            controller: _domain,
            label: const Text('Domain'),
            endIcon: const Text('.plass.dev'),
          ),
          PlTextField(
            fullWidth: true,
            controller: _checking,
            label: const Text('Checking availability'),
            loading: true,
          ),
        ],
      ),
    );
  }
}
