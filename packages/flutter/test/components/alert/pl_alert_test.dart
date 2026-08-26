import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/icons.dart';

import '../../support/host.dart';

void main() {
  group('PlAlert', () {
    group('shapes', () {
      testWidgets('is one line with a glyph by default', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAlert(child: Text('Saved.')), width: 400));

        expect(find.text('Saved.'), findsOneWidget);
        expect(find.byType(PlassGlyph), findsOneWidget);
      });

      testWidgets('is a headline with detail under it when titled', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlAlert(title: Text('Deploy failed'), child: Text('Registry unreachable.')),
            width: 400,
          ),
        );

        expect(styleOf(tester, 'Deploy failed').fontWeight, FontWeight.w600);
        expect(styleOf(tester, 'Registry unreachable.').color, PlassTokens.light().mutedFg);
      });

      testWidgets('keeps the message as reading text when it is the whole alert', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlAlert(child: Text('Saved.')), width: 400));

        expect(styleOf(tester, 'Saved.').color, PlassTokens.light().fg);
      });

      testWidgets('drops the glyph when asked', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAlert(showIcon: false, child: Text('Saved.')), width: 400),
        );

        expect(find.byType(PlassGlyph), findsNothing);
      });
    });

    group('colour', () {
      testWidgets('is informational with no severity named', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlAlert(child: Text('Note')), width: 400));

        final tokens = PlassTokens.light();
        final sheet = decorationWhere(
          tester,
          find.byType(PlAlert),
          (BoxDecoration decoration) => decoration.border != null,
        );

        expect((sheet.border! as Border).top.color, tokens.family(PlassColor.info).line);
      });

      testWidgets('a solid alert is the gradient with its own ink', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const PlAlert(
              variant: PlassVariant.solid,
              color: PlassColor.danger,
              child: Text('Failed'),
            ),
            width: 400,
          ),
        );

        final family = PlassTokens.light().family(PlassColor.danger);
        final sheet = decorationWhere(
          tester,
          find.byType(PlAlert),
          (BoxDecoration decoration) => decoration.gradient != null,
        );

        expect((sheet.gradient! as LinearGradient).colors.first, family.solid);
        expect(styleOf(tester, 'Failed').color, family.onSolid);
      });

      testWidgets('a ghost alert is the tint and no edge', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlAlert(variant: PlassVariant.ghost, child: Text('Note')), width: 400),
        );

        final sheet = decorationWhere(
          tester,
          find.byType(PlAlert),
          (BoxDecoration decoration) => decoration.color != null,
        );

        expect(sheet.color, PlassTokens.light().family(PlassColor.info).soft);
        expect(sheet.border, isNull);
      });
    });

    group('dismissing', () {
      testWidgets('has no button until one is asked for', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(const PlAlert(child: Text('Note')), width: 400));

        expect(find.bySemanticsLabel('Dismiss'), findsNothing);
        handle.dispose();
      });

      testWidgets('fires when the button is pressed', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        var closed = 0;
        await tester.pumpWidget(
          host(PlAlert(onClose: () => closed += 1, child: const Text('Note')), width: 400),
        );

        await tester.tap(find.bySemanticsLabel('Dismiss'));
        expect(closed, 1);
        handle.dispose();
      });
    });

    group('accessibility', () {
      testWidgets('interrupts for a severity worth interrupting for', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlAlert(color: PlassColor.danger, child: Text('Failed')), width: 400),
        );

        expect(semanticsOf(tester, find.byType(PlAlert)), isSemantics(isLiveRegion: true));

        handle.dispose();
      });

      testWidgets('waits for a pause when it is only news', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const PlAlert(color: PlassColor.success, child: Text('Saved')), width: 400),
        );

        expect(semanticsOf(tester, find.byType(PlAlert)), isSemantics(isLiveRegion: false));

        handle.dispose();
      });
    });
  });
}
