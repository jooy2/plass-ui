import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/line_chart/data.dart';

final List<PlassChartSeries> _rate = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Base rate',
    data: <double>[
      0.5,
      0.5,
      1.25,
      1.25,
      2,
      3,
      3,
      4.25,
      5,
      5,
      4.75,
      4.5,
    ].map(PlassChartDatum.new).toList(),
  ),
];

class LineChartCurve extends StatefulWidget {
  const LineChartCurve({super.key});

  @override
  State<LineChartCurve> createState() => _LineChartCurveState();
}

class _LineChartCurveState extends State<LineChartCurve> {
  PlChartCurve _curve = PlChartCurve.step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlSegmentedButton<PlChartCurve>(
          value: _curve,
          onChanged: (PlChartCurve next) => setState(() => _curve = next),
          segments: const <PlSegment<PlChartCurve>>[
            PlSegment<PlChartCurve>(value: PlChartCurve.linear, label: Text('linear')),
            PlSegment<PlChartCurve>(value: PlChartCurve.smooth, label: Text('smooth')),
            PlSegment<PlChartCurve>(value: PlChartCurve.step, label: Text('step')),
          ],
        ),
        const SizedBox(height: 16),
        PlLineChart(
          series: _rate,
          categories: months,
          curve: _curve,
          format: (double value) => '$value%',
        ),
      ],
    );
  }
}
