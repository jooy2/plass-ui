import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

List<PlassChartDatum> _series(List<double> values) => values.map(PlassChartDatum.new).toList();

final List<PlassChartDatum> _signups = _series(<double>[
  12,
  19,
  15,
  22,
  18,
  26,
  24,
  31,
  28,
  37,
  35,
  44,
]);

final List<PlassChartDatum> _churn = _series(<double>[9, 8, 11, 7, 6, 8, 5, 6, 4, 5, 3, 4]);

class SparklineHero extends StatelessWidget {
  const SparklineHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        _Row(name: 'Signups', data: _signups, total: '44'),
        _Row(name: 'Churn', data: _churn, total: '4', color: PlassColor.danger),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.name, required this.data, required this.total, this.color});

  final String name;
  final List<PlassChartDatum> data;
  final String total;
  final PlassColor? color;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Row(
      children: <Widget>[
        SizedBox(
          width: 92,
          child: Text(name, style: TextStyle(fontSize: 14, color: tokens.mutedFg)),
        ),
        Expanded(
          child: PlSparkline(data: data, color: color, endDot: true, semanticLabel: name),
        ),
        SizedBox(
          width: 44,
          child: Text(
            total,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tokens.fg),
          ),
        ),
      ],
    );
  }
}
