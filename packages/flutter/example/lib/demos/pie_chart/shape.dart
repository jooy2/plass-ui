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

class PieChartShape extends StatelessWidget {
  const PieChartShape({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final PlPieShape shape in PlPieShape.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: PlPieChart(
                data: _spend,
                categories: _teams,
                shape: shape,
                height: 160,
                legend: const PlChartLegend(hidden: true),
                semanticLabel: 'Spend, ${shape.name}',
              ),
            ),
          ),
      ],
    );
  }
}
