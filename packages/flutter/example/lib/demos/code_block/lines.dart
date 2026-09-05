import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const String _source = '''PlassSurface surfaceSlots(PlassColor color, int elevation) {
  return PlassSurface(
    ink: family.accent,
    fill: family.soft,
    shadows: tokens.elevation(elevation),
  );
}''';

class CodeBlockLines extends StatelessWidget {
  const CodeBlockLines({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlCodeBlock(
      code: _source,
      language: 'dart',
      title: Text('internal/styles.dart'),
      lineNumbers: true,
      startLine: 551,
      highlightLines: '553-555',
    );
  }
}
