import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BlockquoteSizes extends StatelessWidget {
  const BlockquoteSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          for (final size in PlassSize.values)
            PlBlockquote(
              size: size,
              showIcon: false,
              author: Text(size.name),
              child: const Text('A quote is set at a heading’s scale with a paragraph’s leading.'),
            ),
        ],
      ),
    );
  }
}
