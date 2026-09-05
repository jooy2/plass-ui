import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

PlassChartDatum _at(double x, double y) =>
    PlassChartDatum.point(PlassChartPoint(x: PlassChartCategory.number(x), y: y));

final List<PlassChartSeries> _runs = <PlassChartSeries>[
  for (int n = 1; n <= 5; n += 1)
    PlassChartSeries(
      name: 'Run $n',
      data: <PlassChartDatum>[
        _at(n * 4, 20 + n * 6),
        _at(n * 4 + 9, 34 + n * 4),
        _at(n * 4 + 17, 26 + n * 7),
      ],
    ),
];

class ScatterChartShape extends StatelessWidget {
  const ScatterChartShape({super.key});

  @override
  Widget build(BuildContext context) {
    return PlScatterChart(series: _runs, semanticLabel: 'Five runs', shape: PlScatterShape.varied);
  }
}
