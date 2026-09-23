import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plass_ui/src/internal/text.dart';

/// A widget that only decides what it draws when it builds.
class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) => const Text('New');
}

void main() {
  group('plassTextWithin', () {
    test('reads a text as its words', () {
      expect(plassTextWithin(const Text('Guide')), 'Guide');
      expect(
        plassTextWithin(
          const Text.rich(
            TextSpan(
              text: 'Ship ',
              children: <InlineSpan>[TextSpan(text: 'faster')],
            ),
          ),
        ),
        'Ship faster',
      );
    });

    test('walks into what only holds other widgets, and joins what it finds', () {
      expect(
        plassTextWithin(
          const Padding(
            padding: EdgeInsets.zero,
            child: Row(children: <Widget>[Text('Ship '), SizedBox(width: 4), Text('faster')]),
          ),
        ),
        'Ship faster',
      );
      expect(
        plassTextWithin(const DefaultTextStyle(style: TextStyle(), child: Text('Docs'))),
        'Docs',
      );
    });

    test('reads nothing out of a widget that has not built yet, or out of a picture', () {
      // A picture of a thing is not its name, and what a widget draws is only
      // decided when it builds.
      expect(plassTextWithin(const _Badge()), '');
      expect(plassTextWithin(const Row(children: <Widget>[_Badge(), Text('Docs')])), 'Docs');
      expect(
        plassTextWithin(
          const Text.rich(
            TextSpan(
              children: <InlineSpan>[
                WidgetSpan(child: _Badge()),
                TextSpan(text: 'Docs'),
              ],
            ),
          ),
        ),
        'Docs',
      );
      expect(plassTextWithin(null), '');
    });
  });
}
