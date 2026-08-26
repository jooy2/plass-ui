import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TimelineSizes extends StatelessWidget {
  const TimelineSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 512,
      child: Wrap(
        spacing: 32,
        runSpacing: 32,
        children: <Widget>[
          for (final size in PlassSize.values)
            SizedBox(
              width: 200,
              child: PlTimeline(
                size: size,
                density: PlassDensity.compact,
                active: 1,
                items: <PlTimelineItem>[
                  PlTimelineItem(title: Text(size.name), bullet: const Text('1')),
                  const PlTimelineItem(title: Text('Next'), bullet: Text('2')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
