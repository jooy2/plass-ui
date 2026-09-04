import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// Where the child sits, as a horizontal offset.
double _at(WidgetTester tester) => tester.getTopLeft(find.text('Wrong')).dx;

/// A shake driven by a counter, the way a form drives one.
class _Subject extends StatefulWidget {
  const _Subject();

  @override
  State<_Subject> createState() => _SubjectState();
}

class _SubjectState extends State<_Subject> {
  int _attempts = 0;

  void refuse() => setState(() => _attempts += 1);

  @override
  Widget build(BuildContext context) {
    return PlAnimateShake(replay: _attempts, child: const Text('Wrong'));
  }
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(host(child, width: 240, height: 120));
  await tester.pump();
}

void main() {
  group('PlAnimateShake', () {
    testWidgets('draws its child', (WidgetTester tester) async {
      await _pump(tester, const PlAnimateShake(child: Text('Wrong')));

      expect(find.text('Wrong'), findsOneWidget);
    });

    testWidgets('holds still until it is told, unlike every other effect here', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const PlAnimateShake(child: Text('Wrong')));

      final double home = _at(tester);

      await tester.pump(const Duration(milliseconds: 200));

      expect(_at(tester), home);
    });

    testWidgets('does not shake on the first build', (WidgetTester tester) async {
      await _pump(tester, const PlAnimateShake(replay: 0, child: Text('Wrong')));

      final double home = _at(tester);

      await tester.pump(const Duration(milliseconds: 200));

      // A shake that played itself on mount would be answering an event that
      // has not happened.
      expect(_at(tester), home);
    });

    testWidgets('shakes when the value changes, and lands where it started', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const _Subject());

      final double home = _at(tester);

      tester.state<_SubjectState>(find.byType(_Subject)).refuse();
      // Twice: the run is started from a post-frame callback, so the frame that
      // rebuilt is not yet the frame that is animating.
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(_at(tester), isNot(home));

      await tester.pumpAndSettle();

      // The one effect a caller runs over content that is still being typed
      // into: a field left a few pixels off its label would be worse than the
      // error it was reporting.
      expect(_at(tester), closeTo(home, 0.5));
    });

    testWidgets('shakes again the second time, which a bool cannot say', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const _Subject());

      final double home = _at(tester);
      final _SubjectState subject = tester.state<_SubjectState>(find.byType(_Subject));

      subject.refuse();
      await tester.pump();
      await tester.pumpAndSettle();

      subject.refuse();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(_at(tester), isNot(home));

      await tester.pumpAndSettle();
    });

    testWidgets('still answers `play` for a caller who has one', (WidgetTester tester) async {
      await _pump(tester, const PlAnimateShake(child: Text('Wrong')));

      final double home = _at(tester);

      await tester.pumpWidget(
        host(const PlAnimateShake(play: true, child: Text('Wrong')), width: 240, height: 120),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(_at(tester), isNot(home));

      await tester.pumpAndSettle();
    });
  });
}
