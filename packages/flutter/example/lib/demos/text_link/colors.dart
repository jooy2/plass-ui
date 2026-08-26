import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TextLinkColors extends StatelessWidget {
  const TextLinkColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlTextLink(onPressed: () {}, child: const Text('inherited')),
        for (final color in <PlassColor>[
          PlassColor.primary,
          PlassColor.success,
          PlassColor.warning,
          PlassColor.danger,
          PlassColor.info,
        ])
          PlTextLink(onPressed: () {}, color: color, child: Text(color.name)),
      ],
    );
  }
}
