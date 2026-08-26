import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlSelectOption<String>> _plans = <PlSelectOption<String>>[
  PlSelectOption<String>(value: 'starter', label: Text('Starter')),
  PlSelectOption<String>(value: 'team', label: Text('Team')),
  PlSelectOption<String>(value: 'enterprise', label: Text('Enterprise')),
];

class SelectVariants extends StatefulWidget {
  const SelectVariants({super.key});

  @override
  State<SelectVariants> createState() => _SelectVariantsState();
}

class _SelectVariantsState extends State<SelectVariants> {
  final Map<PlassVariant, String?> _values = <PlassVariant, String?>{
    for (final variant in PlassVariant.values) variant: 'team',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          for (final variant in PlassVariant.values)
            PlSelect<String>(
              variant: variant,
              options: _plans,
              value: _values[variant],
              onChanged: (String? next) => setState(() => _values[variant] = next),
            ),
        ],
      ),
    );
  }
}
