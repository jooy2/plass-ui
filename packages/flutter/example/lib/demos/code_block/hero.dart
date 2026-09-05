import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const String _source = '''import 'package:plass_ui/plass_ui.dart';

class Save extends StatelessWidget {
  const Save({required this.busy, super.key});

  final bool busy;

  @override
  Widget build(BuildContext context) {
    return PlButton(
      color: PlassColor.primary,
      loading: busy,
      child: const Text('Save changes'),
    );
  }
}''';

class CodeBlockHero extends StatelessWidget {
  const CodeBlockHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlCodeBlock(code: _source, language: 'dart', title: Text('lib/save.dart'));
  }
}
