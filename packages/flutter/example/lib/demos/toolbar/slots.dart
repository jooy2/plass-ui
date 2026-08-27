import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToolbarSlots extends StatefulWidget {
  const ToolbarSlots({super.key});

  @override
  State<ToolbarSlots> createState() => _ToolbarSlotsState();
}

class _ToolbarSlotsState extends State<ToolbarSlots> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return PlToolbar(
      divider: true,
      start: const <Widget>[PlTypography('Invoices', level: PlTypographyLevel.h6)],
      end: <Widget>[PlButton(size: PlassSize.sm, onPressed: () {}, child: const Text('Export'))],
      child: PlSegmentedButton<String>(
        size: PlassSize.sm,
        semanticLabel: 'Filter',
        value: _filter,
        onChanged: (String next) => setState(() => _filter = next),
        segments: const <PlSegment<String>>[
          PlSegment<String>(value: 'all', label: Text('All')),
          PlSegment<String>(value: 'open', label: Text('Open')),
          PlSegment<String>(value: 'paid', label: Text('Paid')),
        ],
      ),
    );
  }
}
