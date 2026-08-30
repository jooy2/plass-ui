import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FooterVariants extends StatelessWidget {
  const FooterVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Column(
        spacing: 16,
        children: <Widget>[
          for (final PlassVariant variant in PlassVariant.values)
            PlFooter(
              size: PlassSize.sm,
              variant: variant,
              child: Text('The sheet is ${variant.name}.'),
            ),
        ],
      ),
    );
  }
}
