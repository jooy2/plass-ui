import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

PlassChartCategory _day(int n) => PlassChartCategory.date(DateTime(2026, 1, n));

final List<PlassTimelineSeries> _plan = <PlassTimelineSeries>[
  PlassTimelineSeries(
    name: 'Research',
    data: <PlassTimelinePoint>[
      PlassTimelinePoint(start: _day(2), end: _day(12), label: 'Interviews'),
    ],
  ),
  PlassTimelineSeries(
    name: 'Design',
    data: <PlassTimelinePoint>[
      PlassTimelinePoint(start: _day(9), end: _day(20), label: 'Wireframes'),
      PlassTimelinePoint(start: _day(22), end: _day(34), label: 'Visuals'),
    ],
  ),
  PlassTimelineSeries(
    name: 'Build',
    data: <PlassTimelinePoint>[
      PlassTimelinePoint(start: _day(18), end: _day(52), label: 'Implementation'),
    ],
  ),
  PlassTimelineSeries(
    name: 'Launch',
    data: <PlassTimelinePoint>[
      PlassTimelinePoint(start: _day(50), end: _day(58), label: 'Rollout'),
    ],
  ),
];

class TimelineChartHero extends StatelessWidget {
  const TimelineChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlTimelineChart(series: _plan, height: 220, semanticLabel: 'Project plan');
  }
}
