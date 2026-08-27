import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressCircularSizes extends StatelessWidget {
  const ProgressCircularSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final PlassSize size in PlassSize.values)
          PlProgressCircular(size: size, value: 65, label: Text(size.name)),
      ],
    );
  }
}
