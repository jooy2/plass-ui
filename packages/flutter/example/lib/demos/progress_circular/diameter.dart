import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressCircularDiameter extends StatelessWidget {
  const ProgressCircularDiameter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 32,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlProgressCircular(diameter: 64, label: Text('Preparing')),
        PlProgressCircular(diameter: 96, size: PlassSize.lg, value: 72, showValue: true),
      ],
    );
  }
}
