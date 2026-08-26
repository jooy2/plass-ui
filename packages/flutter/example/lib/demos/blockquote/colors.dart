import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BlockquoteColors extends StatelessWidget {
  const BlockquoteColors({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          for (final color in <PlassColor>[
            PlassColor.primary,
            PlassColor.success,
            PlassColor.warning,
            PlassColor.danger,
          ])
            PlBlockquote(
              color: color,
              showIcon: false,
              child: const Text('The family reaches the rule and stops there.'),
            ),
        ],
      ),
    );
  }
}
