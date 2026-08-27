import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PillSizes extends StatelessWidget {
  const PillSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final PlassSize size in PlassSize.values)
          PlPill(size: size, color: PlassColor.success, title: Text('size: ${size.name}')),
      ],
    );
  }
}
