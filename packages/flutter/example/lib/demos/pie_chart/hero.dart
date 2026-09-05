import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<PlassChartDatum> _traffic = <PlassChartDatum>[
  PlassChartDatum(42),
  PlassChartDatum(27),
  PlassChartDatum(18),
  PlassChartDatum(9),
  PlassChartDatum(4),
];

const List<PlassChartCategory> _sources = <PlassChartCategory>[
  PlassChartCategory.text('Search'),
  PlassChartCategory.text('Direct'),
  PlassChartCategory.text('Social'),
  PlassChartCategory.text('Referral'),
  PlassChartCategory.text('Email'),
];

class PieChartHero extends StatelessWidget {
  const PieChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlPieChart(data: _traffic, categories: _sources, semanticLabel: 'Traffic');
  }
}
