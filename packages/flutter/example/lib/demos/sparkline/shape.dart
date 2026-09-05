import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final List<PlassChartDatum> _readings = <double>[
  12,
  19,
  15,
  22,
  18,
  26,
  24,
  31,
].map(PlassChartDatum.new).toList();

class SparklineShape extends StatelessWidget {
  const SparklineShape({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final PlSparklineShape shape in PlSparklineShape.values)
          Row(
            children: <Widget>[
              SizedBox(
                width: 56,
                child: Text(shape.name, style: TextStyle(fontSize: 14, color: tokens.mutedFg)),
              ),
              Expanded(
                child: PlSparkline(data: _readings, shape: shape),
              ),
            ],
          ),
      ],
    );
  }
}
