import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressBoxIndeterminate extends StatelessWidget {
  const ProgressBoxIndeterminate({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        PlProgressBox(label: Text('Known'), value: 45, showValue: true),
        PlProgressBox(label: Text('Unknown')),
      ],
    );
  }
}
