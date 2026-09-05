import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

final Map<String, List<PlassChartDatum>> _rows = <String, List<PlassChartDatum>>{
  'Europe': <double>[82, 88, 91, 87, 94, 99].map(PlassChartDatum.new).toList(),
  'Asia': <double>[11, 14, 12, 17, 15, 21].map(PlassChartDatum.new).toList(),
};

class SparklineScale extends StatelessWidget {
  const SparklineScale({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[const _Group(shared: false), const _Group(shared: true)],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.shared});

  final bool shared;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        Text(
          shared ? 'Both from 0 to 100' : 'Each to its own range',
          style: TextStyle(fontSize: 12, color: tokens.mutedFg),
        ),
        for (final MapEntry<String, List<PlassChartDatum>> row in _rows.entries)
          Row(
            children: <Widget>[
              SizedBox(
                width: 64,
                child: Text(row.key, style: TextStyle(fontSize: 14, color: tokens.mutedFg)),
              ),
              Expanded(
                child: PlSparkline(
                  data: row.value,
                  min: shared ? 0 : null,
                  max: shared ? 100 : null,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
