import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

PlassChartDatum _at(double x, double y) =>
    PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.number(x), y: y));

final List<PlassChartSeries> _stores = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Owned',
    data: <PlassChartDatum>[
      _at(12, 41),
      _at(19, 55),
      _at(25, 52),
      _at(31, 74),
      _at(38, 81),
      _at(44, 78),
      _at(52, 96),
    ],
  ),
  PlassChartSeries(
    name: 'Franchise',
    data: <PlassChartDatum>[
      _at(15, 28),
      _at(22, 34),
      _at(29, 31),
      _at(36, 47),
      _at(47, 51),
      _at(55, 62),
    ],
  ),
];

class ScatterChartHero extends StatelessWidget {
  const ScatterChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlScatterChart(
      series: _stores,
      semanticLabel: 'Revenue against floor area',
      xAxis: const PlChartAxis(label: 'Floor area (m²)'),
      yAxis: const PlChartAxis(label: 'Revenue (£k)'),
    );
  }
}
