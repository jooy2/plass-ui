/// Every demo the documentation shows, on the screens the app runs on.
///
/// The demos were written for a column about 700 wide on the documentation
/// site, and nothing else lays them out at the width of a phone.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui_example/demos/registry.dart';

import 'support/demo_host.dart';

const Map<String, Size> _screens = <String, Size>{
  'small phone': Size(360, 640),
  'phone': Size(402, 874),
  'tablet': Size(834, 1194),
};

void main() {
  setUpAll(loadFonts);

  for (final MapEntry(key: label, value: size) in _screens.entries) {
    group(label, () {
      for (final MapEntry(key: name, value: build) in demos.entries) {
        testWidgets(name, (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          final errors = await collectErrors(() async {
            await tester.pumpWidget(screen(Builder(builder: build), size: size));
            await tester.pump(const Duration(milliseconds: 400));
            await tester.pump(const Duration(milliseconds: 400));
            await tester.pumpWidget(const SizedBox());
            await tester.pump(const Duration(seconds: 10));
          });

          expect(errors, isEmpty);
        });
      }
    });
  }
}
