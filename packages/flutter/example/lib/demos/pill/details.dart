import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class PillDetails extends StatefulWidget {
  const PillDetails({super.key});

  @override
  State<PillDetails> createState() => _PillDetailsState();
}

class _PillDetailsState extends State<PillDetails> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          PlPill(
            color: PlassColor.info,
            title: const Text('Two updates'),
            description: Text(_expanded ? 'Tap to fold away' : 'Tap to see them'),
            expanded: _expanded,
            onPressed: () => setState(() => _expanded = !_expanded),
            details: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                Text('· Billing moved to the new provider.'),
                Text('· Two members are waiting to be approved.'),
              ],
            ),
          ),
          PlButton(
            variant: PlassVariant.ghost,
            size: PlassSize.sm,
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'Collapse' : 'Expand'),
          ),
        ],
      ),
    );
  }
}
