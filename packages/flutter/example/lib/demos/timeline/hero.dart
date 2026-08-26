import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TimelineHero extends StatelessWidget {
  const TimelineHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 448,
      child: PlTimeline(
        active: 2,
        items: <PlTimelineItem>[
          PlTimelineItem(
            title: Text('Ordered'),
            meta: Text('Mon 09:12'),
            bullet: Text('1'),
            child: Text('Payment cleared and the warehouse was notified.'),
          ),
          PlTimelineItem(
            title: Text('Packed'),
            meta: Text('Mon 14:40'),
            bullet: Text('2'),
            child: Text('Two boxes, 3.1kg.'),
          ),
          PlTimelineItem(
            title: Text('Shipped'),
            meta: Text('Tue 07:05'),
            bullet: Text('3'),
            child: Text('In transit with the carrier.'),
          ),
          PlTimelineItem(title: Text('Delivered'), meta: Text('Expected Wed'), bullet: Text('4')),
        ],
      ),
    );
  }
}
