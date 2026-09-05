import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

List<PlassChartDatum> _readings(List<double> values) => values.map(PlassChartDatum.new).toList();

final List<PlassChartSeries> _plans = <PlassChartSeries>[
  PlassChartSeries(name: 'Free', data: _readings(<double>[420, 460, 480, 510])),
  PlassChartSeries(name: 'Pro', data: _readings(<double>[180, 220, 260, 310])),
  PlassChartSeries(name: 'Team', data: _readings(<double>[40, 55, 72, 96])),
];

const List<PlassChartCategory> _quarters = <PlassChartCategory>[
  PlassChartCategory.text('Q1'),
  PlassChartCategory.text('Q2'),
  PlassChartCategory.text('Q3'),
  PlassChartCategory.text('Q4'),
];

class BarChartStacked extends StatefulWidget {
  const BarChartStacked({super.key});

  @override
  State<BarChartStacked> createState() => _BarChartStackedState();
}

class _BarChartStackedState extends State<BarChartStacked> {
  PlBarStacking _stacking = PlBarStacking.stacked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlSegmentedButton<PlBarStacking>(
          value: _stacking,
          onChanged: (PlBarStacking next) => setState(() => _stacking = next),
          segments: const <PlSegment<PlBarStacking>>[
            PlSegment<PlBarStacking>(value: PlBarStacking.grouped, label: Text('grouped')),
            PlSegment<PlBarStacking>(value: PlBarStacking.stacked, label: Text('stacked')),
            PlSegment<PlBarStacking>(value: PlBarStacking.full, label: Text('full')),
          ],
        ),
        const SizedBox(height: 16),
        PlBarChart(series: _plans, categories: _quarters, stacking: _stacking),
      ],
    );
  }
}
