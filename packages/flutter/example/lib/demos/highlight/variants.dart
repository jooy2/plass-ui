import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HighlightVariants extends StatelessWidget {
  const HighlightVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          for (final variant in PlassVariant.values)
            PlHighlight(
              'A key of tinted glass resting on a clear sheet.',
              query: 'tinted glass',
              variant: variant,
            ),
        ],
      ),
    );
  }
}
