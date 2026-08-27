import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressBoxCount extends StatelessWidget {
  const ProgressBoxCount({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        PlProgressBox(label: Text('Four plates, 30%'), value: 30, showValue: true),
        PlProgressBox(
          label: Text('Five steps, on the third'),
          value: 3,
          max: 5,
          count: 5,
          showValue: true,
        ),
        PlProgressBox(label: Text('Twelve plates'), value: 30, count: 12, showValue: true),
      ],
    );
  }
}
