import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlSegment<String>> _pair = <PlSegment<String>>[
  PlSegment<String>(value: 'a', label: Text('First')),
  PlSegment<String>(value: 'b', label: Text('Second')),
];

class SegmentedButtonSizes extends StatelessWidget {
  const SegmentedButtonSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final size in PlassSize.values)
          PlSegmentedButton<String>(
            size: size,
            semanticLabel: size.name,
            segments: _pair,
            value: 'a',
            onChanged: (String next) {},
          ),
      ],
    );
  }
}
