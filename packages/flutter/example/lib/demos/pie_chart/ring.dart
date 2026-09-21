import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassChartDatum> _spend = <PlassChartDatum>[
  PlassChartDatum(46),
  PlassChartDatum(31),
  PlassChartDatum(23),
];

const List<PlassChartCategory> _teams = <PlassChartCategory>[
  PlassChartCategory.text('Engineering'),
  PlassChartCategory.text('Marketing'),
  PlassChartCategory.text('Support'),
];

/// The hole and the gap, at three settings each.
const List<({double innerRadius, double padAngle, String caption})> _rings =
    <({double innerRadius, double padAngle, String caption})>[
      (innerRadius: 0, padAngle: 0, caption: 'A filled disc, closed up'),
      (innerRadius: 0.5, padAngle: 0, caption: 'Half open, closed up'),
      (innerRadius: 0.8, padAngle: 6, caption: 'A thin band, in segments'),
    ];

class PieChartRing extends StatelessWidget {
  const PieChartRing({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final ring in _rings)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: PlPieChart(
                data: _spend,
                categories: _teams,
                innerRadius: ring.innerRadius,
                padAngle: ring.padAngle,
                height: 160,
                legend: const PlChartLegend(hidden: true),
                semanticLabel: ring.caption,
              ),
            ),
          ),
      ],
    );
  }
}
