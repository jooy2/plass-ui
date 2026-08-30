import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FieldsetSizes extends StatelessWidget {
  const FieldsetSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        for (final PlassSize size in <PlassSize>[PlassSize.sm, PlassSize.md, PlassSize.lg])
          SizedBox(
            width: 200,
            child: PlFieldset(
              size: size,
              legend: Text(size.name),
              description: const Text('A group at this step'),
              children: <Widget>[
                PlTextField(size: size, label: const Text('One'), fullWidth: true),
                PlTextField(size: size, label: const Text('Two'), fullWidth: true),
              ],
            ),
          ),
      ],
    );
  }
}
