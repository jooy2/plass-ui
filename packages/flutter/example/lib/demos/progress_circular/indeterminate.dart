import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressCircularIndeterminate extends StatelessWidget {
  const ProgressCircularIndeterminate({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: <Widget>[
        PlProgressCircular(label: Text('Known'), value: 45, showValue: true),
        PlProgressCircular(label: Text('Unknown')),
      ],
    );
  }
}
