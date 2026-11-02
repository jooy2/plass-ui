/// What a component does on a screen narrower than it was drawn for.
///
/// The width of a phone is where a row with no way out reports an overflow, and
/// the demos on the documentation site, a column about 700 wide, say nothing
/// about it. `examples/flutter/test/demos_test.dart` runs every demo at a phone's
/// width; this is the same question, asked of each component on its own.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

Future<void> _lay(WidgetTester tester, Widget child, {double width = 300}) async {
  await tester.pumpWidget(host(SingleChildScrollView(child: child), width: width, overlay: true));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  final Map<String, Widget Function()> components = <String, Widget Function()>{
    'tabs that share the width': () => PlTabs<int>(
      fullWidth: true,
      value: 0,
      tabs: const <PlTab<int>>[
        PlTab<int>(value: 0, label: Text('Open'), panel: Text('Three')),
        PlTab<int>(value: 1, label: Text('Paid'), panel: Text('Four')),
      ],
    ),
    'solid tabs that share the width': () => PlTabs<int>(
      fullWidth: true,
      variant: PlassVariant.solid,
      value: 0,
      tabs: const <PlTab<int>>[
        PlTab<int>(value: 0, label: Text('Open'), panel: Text('Three')),
        PlTab<int>(value: 1, label: Text('Paid'), panel: Text('Four')),
      ],
    ),
  };

  for (final MapEntry(key: name, value: build) in components.entries) {
    testWidgets('$name lays out', (WidgetTester tester) async {
      await _lay(tester, build());

      expect(tester.takeException(), isNull);
    });
  }


}
