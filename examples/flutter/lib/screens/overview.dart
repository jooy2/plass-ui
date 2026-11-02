import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:plass_showcase/app/page.dart';
import 'package:plass_showcase/data/sample.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

List<PlassChartDatum> _readings(List<double> values) => values.map(PlassChartDatum.new).toList();

const List<PlassChartCategory> _days = <PlassChartCategory>[
  PlassChartCategory.text('Mon'),
  PlassChartCategory.text('Tue'),
  PlassChartCategory.text('Wed'),
  PlassChartCategory.text('Thu'),
  PlassChartCategory.text('Fri'),
  PlassChartCategory.text('Sat'),
  PlassChartCategory.text('Sun'),
];

const List<PlassChartCategory> _regions = <PlassChartCategory>[
  PlassChartCategory.text('Europe'),
  PlassChartCategory.text('Asia'),
  PlassChartCategory.text('Americas'),
  PlassChartCategory.text('Africa'),
];

const List<PlassChartCategory> _sources = <PlassChartCategory>[
  PlassChartCategory.text('Search'),
  PlassChartCategory.text('Direct'),
  PlassChartCategory.text('Social'),
  PlassChartCategory.text('Referral'),
];

const List<PlassChartDatum> _shares = <PlassChartDatum>[
  PlassChartDatum(46),
  PlassChartDatum(29),
  PlassChartDatum(16),
  PlassChartDatum(9),
];

/// A dashboard: figures, charts and what has happened lately.
class OverviewScreen extends StatefulWidget {
  /// Creates the screen.
  const OverviewScreen({required this.bottomInset, super.key});

  /// Room held under the content for the bottom bar.
  final double bottomInset;

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  String _period = 'week';

  @override
  Widget build(BuildContext context) {
    final monthly = _period == 'month';

    return ScreenScroll(
      title: 'Overview',
      subtitle: 'Good morning, here is your week.',
      bottomInset: widget.bottomInset,
      action: PlBadge(
        count: 3,
        label: '3 unread notifications',
        child: PlIconButton(
          label: 'Notifications',
          variant: PlassVariant.glass,
          color: PlassColor.secondary,
          icon: const BellGlyph(),
          onPressed: () => PlToastProvider.of(context).show(
            const PlToast(
              color: PlassColor.info,
              title: Text('Three new messages'),
              description: Text('Open the inbox to read them.'),
            ),
          ),
        ),
      ),
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final columns = constraints.maxWidth >= 640 ? 4 : 2;
            // Android lays the first frame out at no width at all.
            final width = math.max(0.0, (constraints.maxWidth - 12 * (columns - 1)) / columns);

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final (String label, String value, double change, PlStatDirection better)
                    in const <(String, String, double, PlStatDirection)>[
                      ('Revenue', '£48,120', 12.4, PlStatDirection.up),
                      ('Sign-ups', '1,204', 8.1, PlStatDirection.up),
                      ('Churn', '4.2%', 2.6, PlStatDirection.down),
                      ('Tickets', '38', -5, PlStatDirection.down),
                    ])
                  SizedBox(
                    width: width,
                    child: PlCard(
                      child: PlStat(
                        label: Text(label),
                        value: Text(value),
                        change: change,
                        improvesWhen: better,
                        description: const Text('vs last week'),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        PlCard(
          title: const Text('Traffic'),
          headerAction: PlSegmentedButton<String>(
            size: PlassSize.sm,
            semanticLabel: 'Period',
            value: _period,
            onChanged: (String next) => setState(() => _period = next),
            segments: const <PlSegment<String>>[
              PlSegment<String>(value: 'week', label: Text('Week')),
              PlSegment<String>(value: 'month', label: Text('Month')),
            ],
          ),
          child: PlAreaChart(
            categories: _days,
            curve: PlChartCurve.smooth,
            series: <PlassChartSeries>[
              PlassChartSeries(
                name: 'Direct',
                data: _readings(
                  monthly
                      ? <double>[900, 1200, 1100, 1500, 1800, 1400, 1300]
                      : <double>[320, 410, 380, 520, 610, 460, 430],
                ),
              ),
              PlassChartSeries(
                name: 'Search',
                data: _readings(
                  monthly
                      ? <double>[700, 800, 950, 900, 1200, 1100, 1000]
                      : <double>[210, 260, 300, 280, 390, 350, 310],
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bars = PlCard(
              title: const Text('Revenue by region'),
              child: PlBarChart(
                categories: _regions,
                series: <PlassChartSeries>[
                  PlassChartSeries(name: 'This year', data: _readings(<double>[42, 58, 31, 47])),
                  PlassChartSeries(name: 'Last year', data: _readings(<double>[35, 44, 38, 41])),
                ],
              ),
            );
            const pie = PlCard(
              title: Text('Sources'),
              child: PlPieChart(data: _shares, categories: _sources, semanticLabel: 'Sources'),
            );

            if (constraints.maxWidth < 640) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: <Widget>[bars, pie],
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: <Widget>[
                  Expanded(child: bars),
                  const Expanded(child: pie),
                ],
              ),
            );
          },
        ),
        const PlCard(
          title: Text('Spring release'),
          subtitle: Text('Four of six milestones done'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              PlProgressLinear(label: Text('Testing'), value: 72, showValue: true),
              PlProgressLinear(
                label: Text('Rollout'),
                value: 35,
                showValue: true,
                color: PlassColor.info,
              ),
            ],
          ),
        ),
        PlCard(
          title: const Text('Recent activity'),
          child: PlTimeline(
            active: 2,
            items: <PlTimelineItem>[
              for (final Conversation one in conversations.take(4))
                PlTimelineItem(
                  title: Text(one.person.name),
                  meta: Text(one.time),
                  child: Text(one.subject),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
