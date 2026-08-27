import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressCircularHero extends StatelessWidget {
  const ProgressCircularHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: <Widget>[
        PlProgressCircular(label: Text('Syncing'), value: 68, showValue: true),
        PlProgressCircular(label: Text('Reticulating splines')),
      ],
    );
  }
}
