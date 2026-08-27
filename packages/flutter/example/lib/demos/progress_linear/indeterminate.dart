import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressLinearIndeterminate extends StatelessWidget {
  const ProgressLinearIndeterminate({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: const <Widget>[
          PlProgressLinear(label: Text('Known'), value: 45, showValue: true),
          PlProgressLinear(label: Text('Unknown')),
        ],
      ),
    );
  }
}
