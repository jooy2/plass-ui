import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const String _source = '''flutter pub add plass_ui

flutter run''';

class CodeBlockTerminal extends StatelessWidget {
  const CodeBlockTerminal({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlCodeBlock(code: _source, language: 'bash', prompt: r'$', showLanguage: false);
  }
}
