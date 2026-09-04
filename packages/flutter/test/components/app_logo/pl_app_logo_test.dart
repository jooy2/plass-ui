import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A mark that is wider than it is tall, which is what a wordmark is.
class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 96, height: 24);
  }
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  // No width on the host: a tight constraint from outside would answer the
  // question these tests are asking, which is what the logo sizes itself to.
  await tester.pumpWidget(host(child));
  await tester.pumpAndSettle();
}

void main() {
  group('PlAppLogo', () {
    group('the framing', () {
      testWidgets('draws the artwork as it was given', (WidgetTester tester) async {
        await _pump(tester, const PlAppLogo(child: _Mark()));

        // A height and no width: cropping a wordmark to a square is the failure
        // this widget is here to avoid.
        final Size laid = tester.getSize(find.byType(PlAppLogo));

        expect(laid.height, 32);
        expect(laid.width, greaterThan(laid.height));
      });

      testWidgets('puts it on a square tile when it was asked to', (WidgetTester tester) async {
        await _pump(tester, const PlAppLogo(shape: PlAppLogoShape.plate, child: _Mark()));

        expect(tester.getSize(find.byType(PlAppLogo)), const Size(32, 32));
      });

      testWidgets('insets the artwork inside a tile rather than filling it', (
        WidgetTester tester,
      ) async {
        await _pump(tester, const PlAppLogo(shape: PlAppLogoShape.plate, child: _Mark()));

        // 70% of 32.
        expect(tester.getSize(find.byType(FittedBox)).width, closeTo(22.4, 0.1));
      });

      testWidgets('rounds the tile all the way for a disc', (WidgetTester tester) async {
        await _pump(tester, const PlAppLogo(shape: PlAppLogoShape.circle, child: _Mark()));

        final BoxDecoration decoration = decorationWhere(
          tester,
          find.byType(PlAppLogo),
          (BoxDecoration box) => box.borderRadius != null,
        );

        expect((decoration.borderRadius! as BorderRadius).topLeft.x, _markSize);
      });

      testWidgets('takes the family on the tile', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlAppLogo(shape: PlAppLogoShape.plate, color: PlassColor.success, child: _Mark()),
        );

        final BoxDecoration decoration = decorationWhere(
          tester,
          find.byType(PlAppLogo),
          (BoxDecoration box) => box.gradient != null,
        );

        expect(
          (decoration.gradient! as LinearGradient).colors.first,
          PlassTheme.of(tester.element(find.byType(PlAppLogo))).family(PlassColor.success).solid,
        );
      });
    });

    group('the words', () {
      testWidgets('sets the name beside the mark', (WidgetTester tester) async {
        await _pump(
          tester,
          const PlAppLogo(name: Text('Acme'), description: Text('Staging'), child: _Mark()),
        );

        expect(find.text('Acme'), findsOneWidget);
        expect(find.text('Staging'), findsOneWidget);
      });

      testWidgets('draws none of that when it was given none', (WidgetTester tester) async {
        await _pump(tester, const PlAppLogo(child: _Mark()));

        expect(find.byType(Text), findsNothing);
      });
    });

    group('semantics', () {
      testWidgets('hides the mark once the name says it', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(
          tester,
          const PlAppLogo(semanticLabel: 'Acme', name: Text('Acme'), child: _Mark()),
        );

        // Once, not twice: the wordmark beside a picture of the wordmark is a
        // screen reader reading the product's name two times.
        expect(find.bySemanticsLabel('Acme'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('lets the mark speak when there is no name', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await _pump(tester, const PlAppLogo(semanticLabel: 'Acme', child: _Mark()));

        expect(find.bySemanticsLabel('Acme'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('becomes a button when it is given something to do', (WidgetTester tester) async {
        int pressed = 0;

        await _pump(tester, PlAppLogo(onPressed: () => pressed += 1, child: const _Mark()));

        await tester.tap(find.byType(PlAppLogo));

        expect(pressed, 1);
      });
    });
  });
}

/// The `md` mark height, which is also the radius a disc is cut to.
const double _markSize = 32;
