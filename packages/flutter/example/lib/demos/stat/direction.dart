import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class StatDirection extends StatelessWidget {
  const StatDirection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Expanded(
            child: PlCard(
              child: PlStat(
                label: Text('Revenue'),
                value: Text('£48,120'),
                change: 12.4,
                description: Text('up is good'),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: PlCard(
              child: PlStat(
                label: Text('p95 latency'),
                value: Text('182ms'),
                change: 12.4,
                improvesWhen: PlStatDirection.down,
                description: Text('the same number, down is good'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
