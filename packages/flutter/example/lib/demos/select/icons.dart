import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlSelectOption<String>> _locales = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'en', label: Text('English')),
  PlSelectOption<String>(value: 'ko', label: Text('한국어')),
  PlSelectOption<String>(value: 'pt-BR', label: Text('Português (Brasil)')),
];

class SelectIcons extends StatefulWidget {
  const SelectIcons({super.key});

  @override
  State<SelectIcons> createState() => _SelectIconsState();
}

class _SelectIconsState extends State<SelectIcons> {
  String? _locale = 'en';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Align(
        alignment: Alignment.topLeft,
        child: PlSelect<String>(
          label: const Text('Language'),
          startIcon: const Text('🌐'),
          options: _locales,
          value: _locale,
          onChanged: (String? next) => setState(() => _locale = next),
        ),
      ),
    );
  }
}
