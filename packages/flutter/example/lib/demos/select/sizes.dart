import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlSelectOption<String>> _zones = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'utc', label: Text('UTC')),
  PlSelectOption<String>(value: 'kst', label: Text('KST')),
];

const List<PlassSize> _steps = <PlassSize>[PlassSize.sm, PlassSize.md, PlassSize.lg];

class SelectSizes extends StatefulWidget {
  const SelectSizes({super.key});

  @override
  State<SelectSizes> createState() => _SelectSizesState();
}

class _SelectSizesState extends State<SelectSizes> {
  final Map<PlassSize, String?> _values = <PlassSize, String?>{
    for (final size in _steps) size: 'utc',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final size in _steps)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: <Widget>[
                PlSelect<String>(
                  size: size,
                  options: _zones,
                  value: _values[size],
                  onChanged: (String? next) => setState(() => _values[size] = next),
                ),
                PlTextField(size: size, placeholder: 'Same shell, same height'),
              ],
            ),
        ],
      ),
    );
  }
}
