import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

void main() {
  group('PlTypography', () {
    group('rendering', () {
      testWidgets('renders its text', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTypography('The quick brown fox')));

        expect(find.text('The quick brown fox'), findsOneWidget);
      });

      testWidgets('renders spans through the rich constructor', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTypography.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: 'Half '),
                  TextSpan(text: 'and half'),
                ],
              ),
            ),
          ),
        );

        expect(find.textContaining('and half', findRichText: true), findsOneWidget);
      });
    });

    group('level', () {
      testWidgets('defaults to body, at 13px on a 22px line', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTypography('Body')));

        final style = styleOf(tester, 'Body');

        expect(style.fontSize, 13);
        expect(style.height, 22 / 13);
        expect(style.fontWeight, FontWeight.w400);
      });

      testWidgets('sets the scale and the weight together', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTypography('Title', level: PlTypographyLevel.h1)));

        final style = styleOf(tester, 'Title');

        expect(style.fontSize, 30);
        expect(style.height, 36 / 30);
        expect(style.fontWeight, FontWeight.w600);
      });

      testWidgets('tightens the tracking as the type grows', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTypography('Title', level: PlTypographyLevel.h1)));

        expect(styleOf(tester, 'Title').letterSpacing, -0.02 * 30);
      });

      testWidgets('opens the tracking out on an overline', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTypography('Section', level: PlTypographyLevel.overline)),
        );

        expect(styleOf(tester, 'SECTION').letterSpacing, 0.08 * 11);
      });

      testWidgets('upper-cases an overline', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTypography('Section', level: PlTypographyLevel.overline)),
        );

        expect(find.text('SECTION'), findsOneWidget);
        expect(find.text('Section'), findsNothing);
      });

      testWidgets('announces a heading as one', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlTypography('Title', level: PlTypographyLevel.h2)));

        expect(
          tester.getSemantics(find.text('Title')),
          matchesSemantics(label: 'Title', isHeader: true),
        );

        handle.dispose();
      });

      testWidgets('does not announce body copy as a heading', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlTypography('Body')));

        expect(tester.getSemantics(find.text('Body')), matchesSemantics(label: 'Body'));

        handle.dispose();
      });
    });

    group('colour', () {
      testWidgets('takes the page foreground with no colour asked for', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlTypography('Body')));

        expect(styleOf(tester, 'Body').color, PlassTokens.light().fg);
      });

      testWidgets('mutes the two quiet levels', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTypography('Note', level: PlTypographyLevel.caption)));

        expect(styleOf(tester, 'Note').color, PlassTokens.light().mutedFg);
      });

      testWidgets('wears a family accent when one is asked for', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTypography('Failed', color: PlassColor.danger)));

        expect(
          styleOf(tester, 'Failed').color,
          PlassTokens.light().family(PlassColor.danger).accent,
        );
      });

      testWidgets('follows the platform brightness', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTypography('Body'), brightness: Brightness.dark));

        expect(styleOf(tester, 'Body').color, PlassTokens.dark().fg);
      });
    });

    group('weight', () {
      testWidgets('overrides the weight the level would pick', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTypography(
              'Title',
              level: PlTypographyLevel.h1,
              weight: PlTypographyWeight.regular,
            ),
          ),
        );

        expect(styleOf(tester, 'Title').fontWeight, FontWeight.w400);
      });
    });

    group('lines', () {
      testWidgets('clamps and ellipsises', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlTypography('One two three four five six seven eight nine ten', lines: 2),
            width: 80,
          ),
        );

        final text = tester.widget<Text>(find.byType(Text));

        expect(text.maxLines, 2);
        expect(text.overflow, TextOverflow.ellipsis);
      });

      testWidgets('wraps as far as it needs to when no clamp is asked for', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlTypography('One two three'), width: 60));

        expect(tester.widget<Text>(find.byType(Text)).maxLines, isNull);
      });
    });

    group('gutter', () {
      testWidgets('leaves no room under itself by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlTypography('Body')));

        expect(find.byType(Padding), findsNothing);
      });

      testWidgets('leaves the level its own room when asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlTypography('Title', level: PlTypographyLevel.h1, gutter: true)),
        );

        expect(
          tester.widget<Padding>(find.byType(Padding)).padding,
          const EdgeInsets.only(bottom: 16),
        );
      });
    });
  });
}
