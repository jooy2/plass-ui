import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassChartCategory> _hours = <PlassChartCategory>[
  PlassChartCategory.text('09'),
  PlassChartCategory.text('10'),
  PlassChartCategory.text('11'),
  PlassChartCategory.text('12'),
  PlassChartCategory.text('13'),
  PlassChartCategory.text('14'),
  PlassChartCategory.text('15'),
  PlassChartCategory.text('16'),
  PlassChartCategory.text('17'),
];

const List<PlassChartSeries> _uptime = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Requests',
    // The sensor was offline for two hours. That is a gap, not a collapse.
    data: <PlassChartDatum>[
      PlassChartDatum(820),
      PlassChartDatum(910),
      PlassChartDatum(880),
      PlassChartDatum(960),
      PlassChartDatum.gap(),
      PlassChartDatum.gap(),
      PlassChartDatum(1040),
      PlassChartDatum(990),
      PlassChartDatum(1120),
    ],
  ),
];

class LineChartGaps extends StatelessWidget {
  const LineChartGaps({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlLineChart(
      series: _uptime,
      categories: _hours,
      markers: PlChartMarkers.all,
      xAxis: PlChartAxis(label: 'Hour'),
    );
  }
}
