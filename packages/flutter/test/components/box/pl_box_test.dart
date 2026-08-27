import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A child that fills whatever content box it is given.
///
/// A box is as wide as it is offered and centres what it holds, so a narrow line
/// of text says nothing about the sheet's own inset — what has to be measured is
/// something that reaches the edges of the space the padding left behind.
const Widget _filler = SizedBox(
  key: ValueKey<String>('filler'),
  width: double.infinity,
  height: 40,
  child: Text('Grouped'),
);

/// The room the sheet kept around [_filler], as it was actually laid out.
EdgeInsets _inset(WidgetTester tester) {
  final Rect box = tester.getRect(find.byType(PlBox));
  final Rect child = tester.getRect(find.byKey(const ValueKey<String>('filler')));

  return EdgeInsets.fromLTRB(
    child.left - box.left,
    child.top - box.top,
    box.right - child.right,
    box.bottom - child.bottom,
  );
}

/// The decoration carrying the sheet's own fill and edge.
BoxDecoration _sheet(WidgetTester tester) {
  return decorationWhere(
    tester,
    find.byType(PlBox),
    (BoxDecoration decoration) => decoration.color != null || decoration.border != null,
  );
}

void main() {
  group('PlBox', () {
    group('the sheet', () {
      testWidgets('draws what it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBox(child: Text('Grouped')), width: 320));

        expect(find.text('Grouped'), findsOneWidget);
      });

      testWidgets('is a glass sheet with a hairline round it by default', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlBox(child: Text('Grouped')), width: 320));

        final tokens = PlassTokens.light();

        expect(_sheet(tester).color, tokens.glass);
        expect(_sheet(tester).border, isNotNull);
      });

      testWidgets('is the densest glass on solid, and no sheet at all on ghost', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const PlBox(variant: PlassVariant.solid, child: Text('Grouped')), width: 320),
        );

        expect(_sheet(tester).color, PlassTokens.light().glassPress);

        await tester.pumpWidget(
          host(const PlBox(variant: PlassVariant.ghost, child: Text('Grouped')), width: 320),
        );

        expect(
          decorationsOf(tester, find.byType(PlBox)),
          everyElement(
            predicate<BoxDecoration>((BoxDecoration d) => d.color == null && d.border == null),
          ),
        );
      });

      testWidgets('is never dyed, whatever colour it is given', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBox(color: PlassColor.danger, child: Text('Grouped')), width: 320),
        );

        // What a box holds arrives with its own colours; the family never
        // reaches the pane under them.
        expect(_sheet(tester).gradient, isNull);
        expect(_sheet(tester).color, PlassTokens.light().glass);
      });

      testWidgets('lies flat until it is asked to float', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBox(child: Text('Grouped')), width: 320));

        expect(
          decorationsOf(
            tester,
            find.byType(PlBox),
          ).every((BoxDecoration d) => d.boxShadow == null || d.boxShadow!.isEmpty),
          isTrue,
        );

        await tester.pumpWidget(
          host(const PlBox(elevation: 2, child: Text('Grouped')), width: 320),
        );

        expect(
          decorationsOf(
            tester,
            find.byType(PlBox),
          ).any((BoxDecoration d) => d.boxShadow != null && d.boxShadow!.isNotEmpty),
          isTrue,
        );
      });
    });

    group('size and padding', () {
      testWidgets('takes its radius and its padding off the size ladder', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const PlBox(size: PlassSize.lg, child: _filler), width: 320));

        // `size` on a box is the size of the *sheet* — its radius and its
        // padding — and never a height or a type scale.
        expect(
          _sheet(tester).borderRadius,
          BorderRadius.circular(PlassTokens.radius[PlassSize.lg]!),
        );
        expect(_inset(tester), const EdgeInsets.all(24));
      });

      testWidgets('packs tighter on compact', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlBox(density: PlassDensity.compact, child: _filler), width: 320),
        );

        expect(_inset(tester), const EdgeInsets.all(14));
      });

      testWidgets('goes full bleed when the padding is turned off', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlBox(padded: false, child: _filler), width: 320));

        expect(_inset(tester), EdgeInsets.zero);
      });
    });

    group('the type scale', () {
      testWidgets('leaves the text it holds alone', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(
            const DefaultTextStyle(
              style: TextStyle(fontSize: 21),
              child: PlBox(size: PlassSize.xs, child: Text('Grouped')),
            ),
            width: 320,
          ),
        );

        // A container that reset the type scale would render the same paragraph
        // at two sizes depending on what it was wrapped in.
        expect(styleOf(tester, 'Grouped').fontSize, 21);
      });
    });
  });
}
