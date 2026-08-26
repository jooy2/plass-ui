import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BlockquoteAttribution extends StatelessWidget {
  const BlockquoteAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          PlBlockquote(child: Text('Nobody is credited, so there is no attribution row.')),
          PlBlockquote(author: Text('Ada Lovelace'), child: Text('A person said it.')),
          PlBlockquote(
            source: Text('Notes on the Analytical Engine'),
            child: Text('A work it came from.'),
          ),
          PlBlockquote(
            author: Text('Ada Lovelace'),
            source: Text('Notes on the Analytical Engine'),
            child: Text('Both.'),
          ),
        ],
      ),
    );
  }
}
