import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

PlassChartCategory _day(int n) => PlassChartCategory.date(DateTime(2026, 1, n));

final List<PlassTimelineSeries> _work = <PlassTimelineSeries>[
  PlassTimelineSeries(
    name: 'Migration',
    data: <PlassTimelinePoint>[
      PlassTimelinePoint(start: _day(-40), end: _day(24), label: 'Data migration'),
    ],
  ),
  PlassTimelineSeries(
    name: 'Rewrite',
    data: <PlassTimelinePoint>[
      PlassTimelinePoint(start: _day(5), end: _day(70), label: 'Service rewrite'),
    ],
  ),
];

class TimelineChartWindow extends StatelessWidget {
  const TimelineChartWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return PlTimelineChart(
      series: _work,
      min: _day(1),
      max: _day(31),
      height: 140,
      semanticLabel: 'This quarter',
    );
  }
}
