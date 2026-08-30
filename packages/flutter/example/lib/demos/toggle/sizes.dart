import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToggleSizes extends StatelessWidget {
  const ToggleSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final PlassSize size in PlassSize.values)
          PlToggle(size: size, defaultPressed: true, child: Text(size.name)),
      ],
    );
  }
}
