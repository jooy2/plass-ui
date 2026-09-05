import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

PlassChartCategory _hour(int h) => PlassChartCategory.date(DateTime(2026, 1, 5, h));

final List<PlassTimelineSeries> _rooms = <PlassTimelineSeries>[
  PlassTimelineSeries(
    name: 'Studio A',
    data: <PlassTimelinePoint>[
      PlassTimelinePoint(start: _hour(9), end: _hour(12), label: 'Standup'),
      PlassTimelinePoint(start: _hour(10), end: _hour(14), label: 'Workshop'),
      PlassTimelinePoint(start: _hour(15), end: _hour(18), label: 'Review'),
    ],
  ),
  PlassTimelineSeries(
    name: 'Studio B',
    data: <PlassTimelinePoint>[
      PlassTimelinePoint(start: _hour(11), end: _hour(17), label: 'Recording'),
    ],
  ),
];

class TimelineChartLanes extends StatelessWidget {
  const TimelineChartLanes({super.key});

  @override
  Widget build(BuildContext context) {
    return PlTimelineChart(series: _rooms, height: 180, semanticLabel: 'Room bookings');
  }
}
