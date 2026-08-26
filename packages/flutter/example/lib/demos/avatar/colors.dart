import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AvatarColors extends StatelessWidget {
  const AvatarColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final color in PlassColor.values) PlAvatar(color: color, name: color.name),
      ],
    );
  }
}
