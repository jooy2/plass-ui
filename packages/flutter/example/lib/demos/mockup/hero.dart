import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MockupHero extends StatelessWidget {
  const MockupHero({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return PlMockup(
      device: PlMockupDevice.mobile,
      width: 260,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            Text(
              'Today',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: tokens.fg),
            ),
            Text(
              'Three things left. The screen is a real viewport at 390 by 844, so this '
              'column wraps where it would wrap on a phone.',
              style: TextStyle(fontSize: 14, color: tokens.mutedFg),
            ),
            const Spacer(),
            PlButton(onPressed: () {}, child: const Text('Start')),
          ],
        ),
      ),
    );
  }
}
