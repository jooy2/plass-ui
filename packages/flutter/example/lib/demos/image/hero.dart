import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ImageHero extends StatelessWidget {
  const ImageHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: Row(
        children: <Widget>[
          for (final String name in <String>['portrait-1.svg', 'portrait-2.svg']) ...<Widget>[
            Expanded(
              child: PlImage(
                image: NetworkImage('/$name'),
                semanticLabel: 'A portrait',
                ratio: 4 / 3,
                rounded: true,
                size: PlassSize.lg,
              ),
            ),
            if (name != 'portrait-2.svg') const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}
