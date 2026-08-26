import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AlertVariants extends StatelessWidget {
  const AlertVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final variant in PlassVariant.values)
            PlAlert(
              variant: variant,
              title: Text(variant.name),
              child: const Text('The same alert, three materials deep.'),
            ),
        ],
      ),
    );
  }
}
