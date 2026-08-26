import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class DividerColors extends StatelessWidget {
  const DividerColors({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          const PlDivider(child: Text('neutral')),
          for (final color in <PlassColor>[
            PlassColor.primary,
            PlassColor.success,
            PlassColor.warning,
            PlassColor.danger,
          ])
            PlDivider(color: color, child: Text(color.name)),
        ],
      ),
    );
  }
}
