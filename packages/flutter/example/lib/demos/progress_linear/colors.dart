import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressLinearColors extends StatelessWidget {
  const ProgressLinearColors({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          for (final PlassColor color in PlassColor.values)
            PlProgressLinear(color: color, label: Text(color.name), value: 70),
        ],
      ),
    );
  }
}
