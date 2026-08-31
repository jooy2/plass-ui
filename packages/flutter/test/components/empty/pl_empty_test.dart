import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 400));
  await tester.pumpAndSettle();
}

void main() {
  group('PlEmpty', () {
    group('the four parts', () {
      testWidgets('draws the title, the description and the actions', (WidgetTester tester) async {
        await _pump(
          tester,
          PlEmpty(
            title: const Text('No projects yet'),
            description: const Text('Start one and it will show up here.'),
            actions: <Widget>[PlButton(onPressed: () {}, child: const Text('New project'))],
          ),
        );

        expect(find.text('No projects yet'), findsOneWidget);
        expect(find.text('Start one and it will show up here.'), findsOneWidget);
        expect(find.text('New project'), findsOneWidget);
      });

      testWidgets('draws its own child between the description and the actions', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          const PlEmpty(title: Text('No projects yet'), child: Text('Anything else')),
        );

        expect(find.text('Anything else'), findsOneWidget);
      });

      testWidgets('leaves out what it was not given', (WidgetTester tester) async {
        await _pump(tester, const PlEmpty(title: Text('No projects yet')));

        expect(find.byType(Wrap), findsNothing);
      });
    });

    group('the glyph', () {
      testWidgets('is hidden from a screen reader', (WidgetTester tester) async {
        await _pump(tester, const PlEmpty(icon: Text('📭'), title: Text('No mail')));

        // The title says what the glyph says, and a reader should not be told
        // twice.
        expect(find.byType(ExcludeSemantics), findsOneWidget);
      });

      testWidgets('is not drawn when there is none', (WidgetTester tester) async {
        await _pump(tester, const PlEmpty(title: Text('No mail')));

        expect(find.byType(ExcludeSemantics), findsNothing);
      });
    });

    group('the surface', () {
      testWidgets('draws none', (WidgetTester tester) async {
        await _pump(tester, const PlEmpty(title: Text('No projects yet')));

        // An empty state is always inside something, and a sheet inside a sheet
        // is two sheets.
        expect(find.byType(DecoratedBox), findsNothing);
      });
    });
  });
}
