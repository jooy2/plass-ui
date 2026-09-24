/// That a calendar cell keeps what it holds as it is marked today and blocked.
///
/// Both change how a cell looks: today takes a dot under the number, and a
/// blocked cell goes faint. Neither may change the shape of the tree above what
/// the cell holds, because Flutter builds a changed shape from scratch, so what
/// is checked here is the content's own `State`, kept across both.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/calendar.dart';
import 'package:plass_ui/src/internal/scales.dart';

import '../support/host.dart';

/// A slot with a `State` of its own: built again from scratch, it is a different
/// object.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Text('27');
}

Widget _cell({bool current = false, bool disabled = false}) {
  return host(
    PlassCalendarCell(
      label: 'Monday, July 27, 2026',
      size: PlassSize.md,
      color: PlassColor.primary,
      current: current,
      disabled: disabled,
      onPressed: () {},
      child: const _Probe(),
    ),
  );
}

/// Today's mark: the one circle in a cell.
final Finder _dot = find.byWidgetPredicate(
  (Widget widget) =>
      widget is DecoratedBox &&
      widget.decoration is BoxDecoration &&
      (widget.decoration as BoxDecoration).shape == BoxShape.circle,
);

void main() {
  group('PlassCalendarCell', () {
    testWidgets('keeps what it holds as it is marked today and blocked', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_cell());
      final State<_Probe> held = tester.state(find.byType(_Probe));

      for (final (String reason, Widget next) in <(String, Widget)>[
        ('today', _cell(current: true)),
        ('not today', _cell()),
        ('blocked', _cell(disabled: true)),
        ('open again', _cell()),
      ]) {
        await tester.pumpWidget(next);
        await tester.pumpAndSettle();

        expect(tester.state(find.byType(_Probe)), same(held), reason: reason);
      }
    });

    testWidgets('marks today with a dot, and no other day', (WidgetTester tester) async {
      await tester.pumpWidget(_cell(current: true));

      expect(_dot, findsOneWidget);

      await tester.pumpWidget(_cell());

      expect(_dot, findsNothing);
    });

    testWidgets('dims a blocked cell, with no layer on one that can be taken', (
      WidgetTester tester,
    ) async {
      Iterable<int> alphas() {
        return tester.layers.whereType<OpacityLayer>().map((OpacityLayer layer) => layer.alpha!);
      }

      await tester.pumpWidget(_cell(disabled: true));

      expect(alphas(), <int>[Color.getAlphaFromOpacity(disabledOpacity)]);

      await tester.pumpWidget(_cell());
      await tester.pumpAndSettle();

      // An opacity of 1 is nothing to apply, and a layer applying it would be
      // one more on each of forty-two cells for nothing.
      expect(alphas(), isEmpty);
    });
  });
}
