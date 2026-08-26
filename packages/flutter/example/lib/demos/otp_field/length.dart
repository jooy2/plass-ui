import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class OtpFieldLength extends StatelessWidget {
  const OtpFieldLength({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        PlOtpField(length: 4, label: Text('Four digits')),
        PlOtpField(length: 8, groupSize: 4, label: Text('Eight, in two blocks')),
      ],
    );
  }
}
