import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressBoxHero extends StatelessWidget {
  const ProgressBoxHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        PlProgressBox(label: Text('Step 3 of 5'), value: 3, max: 5, count: 5, showValue: true),
        PlProgressBox(label: Text('Compiling')),
      ],
    );
  }
}
