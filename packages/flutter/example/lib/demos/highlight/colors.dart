import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HighlightColors extends StatelessWidget {
  const HighlightColors({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          for (final color in <PlassColor>[
            PlassColor.warning,
            PlassColor.primary,
            PlassColor.success,
            PlassColor.danger,
            PlassColor.info,
          ])
            PlHighlight('The family is ${color.name} here.', query: color.name, color: color),
        ],
      ),
    );
  }
}
