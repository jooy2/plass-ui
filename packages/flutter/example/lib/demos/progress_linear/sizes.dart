import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressLinearSizes extends StatelessWidget {
  const ProgressLinearSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: <Widget>[
          for (final PlassSize size in PlassSize.values)
            PlProgressLinear(size: size, label: Text(size.name), value: 60),
        ],
      ),
    );
  }
}
