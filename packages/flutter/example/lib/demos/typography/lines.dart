import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const String _text =
    'A thing that is pressed is tinted glass: a gradient that sweeps between two ends of its '
    'colour family, a drop shadow tinted with that family, and a bloom of light that follows '
    'the pointer across it.';

class TypographyLines extends StatelessWidget {
  const TypographyLines({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          PlTypography(_text, lines: 1),
          PlTypography(_text, lines: 2),
          PlTypography(_text),
        ],
      ),
    );
  }
}
