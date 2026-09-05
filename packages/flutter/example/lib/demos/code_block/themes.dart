import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const String _source = '''final routes = <String, Handler>{};

/// Answers /health, and nothing else.
Response health(Request request) {
  return Response('ok', status: 200);
}''';

const List<String> _themes = <String>[
  'dark',
  'light',
  'auto',
  'mono',
  'one-dark',
  'dracula',
  'monokai',
  'nord',
  'night-owl',
  'gruvbox',
  'github',
  'solarized-light',
];

class CodeBlockThemes extends StatefulWidget {
  const CodeBlockThemes({super.key});

  @override
  State<CodeBlockThemes> createState() => _CodeBlockThemesState();
}

class _CodeBlockThemesState extends State<CodeBlockThemes> {
  String _theme = 'dracula';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlSelect<String>(
          label: const Text('Theme'),
          value: _theme,
          onChanged: (String? next) => setState(() => _theme = next ?? 'dark'),
          options: <PlSelectOption<String>>[
            for (final String name in _themes)
              PlSelectOption<String>(value: name, label: Text(name)),
          ],
        ),
        const SizedBox(height: 12),
        PlCodeBlock(code: _source, language: 'dart', theme: _theme),
      ],
    );
  }
}
