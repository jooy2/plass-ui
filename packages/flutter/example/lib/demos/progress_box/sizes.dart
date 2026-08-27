import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ProgressBoxSizes extends StatelessWidget {
  const ProgressBoxSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: <Widget>[
        for (final PlassSize size in PlassSize.values)
          PlProgressBox(size: size, label: Text(size.name), value: 60),
      ],
    );
  }
}
