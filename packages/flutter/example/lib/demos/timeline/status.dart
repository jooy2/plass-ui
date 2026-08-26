import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TimelineStatus extends StatelessWidget {
  const TimelineStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 448,
      child: PlTimeline(
        active: 3,
        items: <PlTimelineItem>[
          PlTimelineItem(title: Text('Cloned'), bullet: Text('1')),
          PlTimelineItem(title: Text('Installed'), bullet: Text('2')),
          PlTimelineItem(
            title: Text('Tested'),
            bullet: Text('✕'),
            status: PlTimelineStatus.upcoming,
            color: PlassColor.danger,
            child: Text('Two tests are red, so this step never finished.'),
          ),
          PlTimelineItem(title: Text('Deployed'), bullet: Text('4')),
        ],
      ),
    );
  }
}
