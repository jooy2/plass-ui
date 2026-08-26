import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TimelineConnectors extends StatelessWidget {
  const TimelineConnectors({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 448,
      child: PlTimeline(
        density: PlassDensity.compact,
        active: 4,
        items: <PlTimelineItem>[
          PlTimelineItem(title: Text('solid')),
          PlTimelineItem(title: Text('dashed'), connector: PlTimelineConnector.dashed),
          PlTimelineItem(title: Text('dotted'), connector: PlTimelineConnector.dotted),
          PlTimelineItem(title: Text('none'), connector: PlTimelineConnector.none),
          PlTimelineItem(title: Text('The last line is never drawn')),
        ],
      ),
    );
  }
}
