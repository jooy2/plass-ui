import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassChartSeries> _latency = <PlassChartSeries>[
  PlassChartSeries(
    name: 'p95 latency',
    data: <PlassChartDatum>[
      PlassChartDatum(180),
      PlassChartDatum(210),
      PlassChartDatum(240),
      PlassChartDatum(205),
      PlassChartDatum(260),
      PlassChartDatum(320),
      PlassChartDatum(280),
      PlassChartDatum(230),
    ],
  ),
];

const List<PlassChartCategory> _days = <PlassChartCategory>[
  PlassChartCategory.text('Mon'),
  PlassChartCategory.text('Tue'),
  PlassChartCategory.text('Wed'),
  PlassChartCategory.text('Thu'),
  PlassChartCategory.text('Fri'),
  PlassChartCategory.text('Sat'),
  PlassChartCategory.text('Sun'),
  PlassChartCategory.text('Mon'),
];

class LineChartReference extends StatelessWidget {
  const LineChartReference({super.key});

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return PlLineChart(
      series: _latency,
      categories: _days,
      markers: PlChartMarkers.all,
      reference: <PlassChartReference>[
        const PlassChartReference(value: 250, label: 'Budget'),
        PlassChartReference(
          value: 300,
          label: 'Breach',
          color: tokens.family(PlassColor.danger).accent,
        ),
      ],
      yAxis: const PlChartAxis(label: 'ms'),
    );
  }
}
