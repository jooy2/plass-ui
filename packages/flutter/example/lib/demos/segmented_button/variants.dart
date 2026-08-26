import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlSegment<String>> _views = <PlSegment<String>>[
  PlSegment<String>(value: 'grid', label: Text('Grid')),
  PlSegment<String>(value: 'list', label: Text('List')),
  PlSegment<String>(value: 'table', label: Text('Table')),
];

class SegmentedButtonVariants extends StatelessWidget {
  const SegmentedButtonVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final variant in PlassVariant.values)
          PlSegmentedButton<String>(
            variant: variant,
            semanticLabel: variant.name,
            segments: _views,
            value: 'grid',
            onChanged: (String next) {},
          ),
      ],
    );
  }
}
