import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui/src/internal/icons.dart';

import '../../support/host.dart';

/// A glyph a caller hands the alert, recording the colour and the size it is
/// drawn at.
class _Glyph extends StatelessWidget {
  const _Glyph(this.name);

  final String name;

  static final Map<String, Color?> seen = <String, Color?>{};

  static final Map<String, double?> sizes = <String, double?>{};

  @override
  Widget build(BuildContext context) {
    seen[name] = IconTheme.of(context).color;
    sizes[name] = IconTheme.of(context).size;

    return const SizedBox.square(dimension: 16);
  }
}

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

      testWidgets('draws a glyph a caller hands it in the colour of the words around it', (
        WidgetTester tester,
      ) async {
        final tokens = PlassTokens.light();
        final family = tokens.family(PlassColor.info);

        for (final PlassVariant variant in PlassVariant.values) {
          await tester.pumpWidget(
            host(
              PlAlert(
                key: ValueKey<PlassVariant>(variant),
                variant: variant,
                title: const Row(children: <Widget>[_Glyph('title'), Text('Title')]),
                action: const _Glyph('action'),
                child: const Row(children: <Widget>[_Glyph('message'), Text('Message')]),
              ),
              width: 400,
            ),
          );

          final bool solid = variant == PlassVariant.solid;

          // As an `<svg>` drawn in `currentColor` takes the React alert's: the
          // alert's own ink in the action, the accent in the title and the
          // muted ink in the detail under it, all of them the ink on `solid`.
          expect(_Glyph.seen['action'], solid ? family.onSolid : tokens.fg, reason: variant.name);
          expect(
            _Glyph.seen['title'],
            solid ? family.onSolid : family.accent,
            reason: variant.name,
          );
          expect(
            _Glyph.seen['message'],
            solid ? family.onSolid : tokens.mutedFg,
            reason: variant.name,
          );
        }
      });
    });

    group('size', () {
      testWidgets('draws a glyph a caller hands it at 1.2 times the words around it', (
        WidgetTester tester,
      ) async {
        for (final PlassSize size in PlassSize.values) {
          await tester.pumpWidget(
            host(
              PlAlert(
                key: ValueKey<PlassSize>(size),
                size: size,
                icon: const _Glyph('icon'),
                title: const Row(children: <Widget>[_Glyph('title'), Text('Title')]),
                action: const _Glyph('action'),
                child: const Row(children: <Widget>[_Glyph('message'), Text('Message')]),
              ),
              width: 400,
            ),
          );

          final double title = styleOf(tester, 'Title').fontSize!;
          final double message = styleOf(tester, 'Message').fontSize!;

          // As an `<svg>` at `1.2em` is in the React alert: the glyph at the
          // start and the one in the action against the message's type, and
          // the one in the title against the title's.
          expect(_Glyph.sizes['icon'], closeTo(message * 1.2, 0.001), reason: size.name);
          expect(_Glyph.sizes['title'], closeTo(title * 1.2, 0.001), reason: size.name);
          expect(_Glyph.sizes['message'], closeTo(message * 1.2, 0.001), reason: size.name);
          expect(_Glyph.sizes['action'], closeTo(message * 1.2, 0.001), reason: size.name);
        }
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
      testWidgets('announces every alert, whatever its severity', (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        // An `info` or `success` alert is news too: a "Saved" that is not a
        // live region appears in silence.
        for (final PlassColor color in PlassColor.values) {
          await tester.pumpWidget(
            host(PlAlert(color: color, child: const Text('Note')), width: 400),
          );

          expect(
            semanticsOf(tester, find.byType(PlAlert)),
            isSemantics(isLiveRegion: true),
            reason: '$color',
          );
        }

        // With no severity named the alert is informational, and still announced.
        await tester.pumpWidget(host(const PlAlert(child: Text('Note')), width: 400));

        expect(semanticsOf(tester, find.byType(PlAlert)), isSemantics(isLiveRegion: true));

        handle.dispose();
      });
    });
  });
}
