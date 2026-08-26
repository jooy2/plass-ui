import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HighlightMatching extends StatelessWidget {
  const HighlightMatching({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          const PlHighlight(
            'One database, and the data inside it.',
            query: <String>['data', 'database'],
          ),
          const PlHighlight('A cat that can concatenate.', query: 'cat', wholeWord: true),
          const PlHighlight(
            'Glass is not glass when the case matters.',
            query: 'glass',
            caseSensitive: true,
          ),
          PlHighlight(
            'The blur is 22px and the duration 150ms.',
            query: RegExp(r'\d+(\.\d+)?'),
            color: PlassColor.info,
          ),
        ],
      ),
    );
  }
}
