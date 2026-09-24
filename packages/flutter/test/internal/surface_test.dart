/// That the filters a surface wears for its state leave what it holds alone.
///
/// A hover and a press change how bright a lit surface is, and nothing else
/// about it. A filter that came and went with them would change the shape of
/// the tree above the content, and Flutter builds a changed shape from scratch,
/// so what is checked here is the content's own state, kept across both.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/src/internal/surface.dart';

import '../support/host.dart';

/// Content with a `State` of its own: rebuilt from scratch, it is a different
/// object, where a field would have lost what was typed into it.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Text('Content');
}

void main() {
  group('plassStateFilter', () {
    Widget lit({bool hovered = false, bool pressed = false}) {
      return host(plassStateFilter(hovered: hovered, pressed: pressed, child: const _Probe()));
    }

    testWidgets('keeps what a lit surface holds across a hover and a press', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(lit());
      final State<_Probe> resting = tester.state(find.byType(_Probe));

      for (final Widget next in <Widget>[
        lit(hovered: true),
        lit(hovered: true, pressed: true),
        lit(hovered: true),
        lit(),
      ]) {
        await tester.pumpWidget(next);
        await tester.pumpAndSettle();

        expect(tester.state(find.byType(_Probe)), same(resting));
      }
    });

    testWidgets('is the identity at rest', (WidgetTester tester) async {
      await tester.pumpWidget(lit(hovered: true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(lit());
      await tester.pumpAndSettle();

      final ColorFiltered filter = tester.widget(
        find.ancestor(of: find.byType(_Probe), matching: find.byType(ColorFiltered)),
      );

      expect(
        filter.colorFilter,
        const ColorFilter.matrix(<double>[
          1, 0, 0, 0, 0, //
          0, 1, 0, 0, 0, //
          0, 0, 1, 0, 0, //
          0, 0, 0, 1, 0, //
        ]),
      );
    });
  });
}
