import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlSegment<String>> _modes = <PlSegment<String>>[
  PlSegment<String>(value: 'on', label: Text('On')),
  PlSegment<String>(value: 'auto', label: Text('Auto')),
  PlSegment<String>(value: 'off', label: Text('Off')),
];

class SegmentedButtonColors extends StatelessWidget {
  const SegmentedButtonColors({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final color in <PlassColor>[
          PlassColor.primary,
          PlassColor.success,
          PlassColor.warning,
          PlassColor.danger,
        ])
          PlSegmentedButton<String>(
            variant: PlassVariant.solid,
            color: color,
            size: PlassSize.sm,
            semanticLabel: color.name,
            segments: _modes,
            value: 'on',
            onChanged: (String next) {},
          ),
      ],
    );
  }
}
