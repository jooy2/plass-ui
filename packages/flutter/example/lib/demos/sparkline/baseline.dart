import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final List<PlassChartDatum> _latency = <double>[
  180,
  210,
  240,
  195,
  320,
  280,
  260,
  340,
  300,
  250,
].map(PlassChartDatum.new).toList();

class SparklineBaseline extends StatelessWidget {
  const SparklineBaseline({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Row(
      children: <Widget>[
        SizedBox(
          width: 64,
          child: Text('p95 ms', style: TextStyle(fontSize: 14, color: tokens.mutedFg)),
        ),
        Expanded(
          child: PlSparkline(
            data: _latency,
            shape: PlSparklineShape.area,
            baseline: 250,
            endDot: true,
            semanticLabel: 'p95 latency',
          ),
        ),
      ],
    );
  }
}
