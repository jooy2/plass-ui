import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AvatarVariants extends StatelessWidget {
  const AvatarVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final variant in PlassVariant.values)
          PlAvatar(size: PlassSize.lg, variant: variant, name: 'Jane Doe'),
      ],
    );
  }
}
