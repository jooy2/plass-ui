import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget child, {bool settle = true}) async {
  await tester.pumpWidget(host(child, width: 300));

  // `settle: false` for the loading tests: a `PlSkeleton` shimmers forever, and
  // `pumpAndSettle` waits for an animation that never ends.
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// The colour the change was laid out in.
Color _changeInk(WidgetTester tester, String text) {
  return tester.renderObject<RenderParagraph>(find.text(text)).text.style!.color!;
}

void main() {
  group('PlStat', () {
    group('the figure', () {
      testWidgets('draws the label, the value and the description', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlStat(
            label: Text('Revenue'),
            value: Text('£48,120'),
            description: Text('vs last month'),
          ),
        );

        expect(find.text('Revenue'), findsOneWidget);
        expect(find.text('£48,120'), findsOneWidget);
        expect(find.text('vs last month'), findsOneWidget);
      });

      testWidgets('takes a widget for the value, already formatted', (WidgetTester tester) async {
        await _pump(tester, const PlStat(value: Text('₩48,120')));

        // How a figure is written is the screen's decision.
        expect(find.text('₩48,120'), findsOneWidget);
      });
    });

    group('the change', () {
      testWidgets('writes a rise with a sign', (WidgetTester tester) async {
        await _pump(tester, const PlStat(value: Text('£48,120'), change: 12.4));

        expect(find.text('+12.4%'), findsOneWidget);
      });

      testWidgets('writes a fall with its own', (WidgetTester tester) async {
        await _pump(tester, const PlStat(value: Text('£48,120'), change: -3.1));

        expect(find.text('-3.1%'), findsOneWidget);
      });

      testWidgets('drops a trailing zero', (WidgetTester tester) async {
        await _pump(tester, const PlStat(value: Text('£48,120'), change: 8));

        expect(find.text('+8%'), findsOneWidget);
      });

      testWidgets('is good news when it went the way it should', (WidgetTester tester) async {
        await _pump(tester, const PlStat(value: Text('£48,120'), change: 12.4));

        final PlassTokens tokens = PlassTokens.of(Brightness.light);

        expect(_changeInk(tester, '+12.4%'), equals(tokens.family(PlassColor.success).accent));
      });

      testWidgets('reads the meaning rather than the sign', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlStat(value: Text('4.2%'), change: 12.4, improvesWhen: PlStatDirection.down),
        );

        final PlassTokens tokens = PlassTokens.of(Brightness.light);

        // Churn going up is not good news, and a green arrow on it is a
        // dashboard lying to somebody.
        expect(_changeInk(tester, '+12.4%'), equals(tokens.family(PlassColor.danger).accent));
      });

      testWidgets('is neither when nothing moved', (WidgetTester tester) async {
        await _pump(tester, const PlStat(value: Text('£48,120'), change: 0));

        final PlassTokens tokens = PlassTokens.of(Brightness.light);

        expect(_changeInk(tester, '0%'), equals(tokens.mutedFg));
        expect(find.text('▲'), findsNothing);
      });

      testWidgets('draws an arrow for a movement', (WidgetTester tester) async {
        await _pump(tester, const PlStat(value: Text('£48,120'), change: 12.4));

        expect(find.text('▲'), findsOneWidget);
      });

      testWidgets('takes its own words instead of a percentage', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlStat(value: Text('1,204'), change: 8, changeLabel: Text('+1,204 this week')),
        );

        expect(find.text('+1,204 this week'), findsOneWidget);
        expect(find.text('+8%'), findsNothing);
      });

      testWidgets('draws none when there is none', (WidgetTester tester) async {
        await _pump(tester, const PlStat(value: Text('£48,120')));

        expect(find.text('▲'), findsNothing);
      });
    });

    group('loading', () {
      testWidgets('draws a skeleton where the figure will be', (WidgetTester tester) async {
        await _pump(tester, const PlStat(value: Text('£48,120'), loading: true), settle: false);

        expect(find.byType(PlSkeleton), findsOneWidget);
        expect(find.text('£48,120'), findsNothing);
      });

      testWidgets('holds the change back with it', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlStat(value: Text('£48,120'), change: 12.4, loading: true),
          settle: false,
        );

        // A movement beside a figure nobody has yet is a movement of nothing.
        expect(find.text('+12.4%'), findsNothing);
      });
    });

    group('the surface', () {
      testWidgets('draws none', (WidgetTester tester) async {
        await _pump(tester, const PlStat(value: Text('£48,120')));

        expect(find.byType(DecoratedBox), findsNothing);
      });
    });
  });
}
