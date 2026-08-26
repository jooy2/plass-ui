import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class SegmentedButtonFullWidth extends StatefulWidget {
  const SegmentedButtonFullWidth({super.key});

  @override
  State<SegmentedButtonFullWidth> createState() => _SegmentedButtonFullWidthState();
}

class _SegmentedButtonFullWidthState extends State<SegmentedButtonFullWidth> {
  String _delivery = 'standard';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 448,
      child: PlSegmentedButton<String>(
        fullWidth: true,
        semanticLabel: 'Delivery',
        value: _delivery,
        onChanged: (String next) => setState(() => _delivery = next),
        segments: const <PlSegment<String>>[
          PlSegment<String>(value: 'standard', label: Text('Standard')),
          PlSegment<String>(value: 'express', label: Text('Express')),
          PlSegment<String>(value: 'pickup', label: Text('Pick up')),
        ],
      ),
    );
  }
}
