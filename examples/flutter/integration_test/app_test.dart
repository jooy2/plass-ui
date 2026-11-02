/// The flows in `flows.dart`, on a real device or simulator.
///
/// ```bash
/// flutter drive --driver test_driver/integration_test.dart \
///   --target integration_test/app_test.dart --keep-app-running -d <device>
/// ```
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'flows.dart';
import 'support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  defineFlows(shot: (WidgetTester tester, String name) => saveShot(tester, 'app-$name'));
}
