import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BlockquoteVariants extends StatelessWidget {
  const BlockquoteVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          for (final variant in PlassVariant.values)
            PlBlockquote(
              variant: variant,
              author: Text(variant.name),
              child: const Text('The same quote, three materials deep.'),
            ),
        ],
      ),
    );
  }
}
