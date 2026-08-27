import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SpoilerClamped extends StatelessWidget {
  const SpoilerClamped({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: PlSpoiler(
        maxHeight: 120,
        blur: 6,
        reversible: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            for (var index = 1; index <= 6; index += 1)
              Text(
                'Paragraph $index of the ending, which is longer than a cover has any '
                'reason to be.',
              ),
          ],
        ),
      ),
    );
  }
}
