import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassChartDatum> _plans = <PlassChartDatum>[
  PlassChartDatum(1840),
  PlassChartDatum(620),
  PlassChartDatum(210),
];

const List<PlassChartCategory> _tiers = <PlassChartCategory>[
  PlassChartCategory.text('Starter'),
  PlassChartCategory.text('Team'),
  PlassChartCategory.text('Enterprise'),
];

class PieChartCenter extends StatelessWidget {
  const PieChartCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return PlPieChart(
      data: _plans,
      categories: _tiers,
      shape: PlPieShape.donut,
      semanticLabel: 'Accounts by plan',
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '2,670',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: tokens.fg),
          ),
          Text('accounts', style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
        ],
      ),
    );
  }
}
