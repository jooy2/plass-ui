import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TimelineOrientation extends StatelessWidget {
  const TimelineOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      child: PlTimeline(
        orientation: PlassResponsive<PlassOrientation>(PlassOrientation.horizontal),
        active: 1,
        items: <PlTimelineItem>[
          PlTimelineItem(title: Text('Account'), bullet: Text('1')),
          PlTimelineItem(title: Text('Payment'), bullet: Text('2')),
          PlTimelineItem(title: Text('Review'), bullet: Text('3')),
          PlTimelineItem(title: Text('Done'), bullet: Text('4')),
        ],
      ),
    );
  }
}
