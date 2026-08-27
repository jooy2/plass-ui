import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressLinearHero extends StatelessWidget {
  const ProgressLinearHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: const <Widget>[
          PlProgressLinear(label: Text('Uploading'), value: 62, showValue: true),
          PlProgressLinear(label: Text('Rebuilding index')),
        ],
      ),
    );
  }
}
