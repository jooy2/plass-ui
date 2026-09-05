import 'package:plass_ui/plass_ui.dart';

/// Twelve months, so a stride on the category axis has something to do.
const List<PlassChartCategory> months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
  PlassChartCategory.text('Apr'),
  PlassChartCategory.text('May'),
  PlassChartCategory.text('Jun'),
  PlassChartCategory.text('Jul'),
  PlassChartCategory.text('Aug'),
  PlassChartCategory.text('Sep'),
  PlassChartCategory.text('Oct'),
  PlassChartCategory.text('Nov'),
  PlassChartCategory.text('Dec'),
];

List<PlassChartDatum> _readings(List<double> values) => values.map(PlassChartDatum.new).toList();

final List<PlassChartSeries> revenue = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Europe',
    data: _readings(<double>[42, 45, 51, 49, 58, 63, 61, 68, 72, 70, 78, 84]),
  ),
  PlassChartSeries(
    name: 'Asia',
    data: _readings(<double>[28, 31, 30, 36, 39, 42, 48, 47, 53, 58, 61, 66]),
  ),
  PlassChartSeries(
    name: 'Americas',
    data: _readings(<double>[19, 22, 24, 23, 27, 26, 31, 34, 33, 38, 41, 44]),
  ),
];
