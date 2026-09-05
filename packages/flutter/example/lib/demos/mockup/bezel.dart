import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class MockupBezel extends StatelessWidget {
  const MockupBezel({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        for (final PlMockupBezel bezel in PlMockupBezel.values)
          PlMockup(device: PlMockupDevice.mobile, bezel: bezel, width: 100),
      ],
    );
  }
}
