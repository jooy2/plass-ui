import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class OtpFieldCharset extends StatelessWidget {
  const OtpFieldCharset({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        PlOtpField(length: 4, label: Text('numeric')),
        PlOtpField(length: 4, charset: PlOtpCharset.alphanumeric, label: Text('alphanumeric')),
        PlOtpField(
          length: 4,
          charset: PlOtpCharset.any,
          groupSize: 2,
          separator: '·',
          label: Text('any'),
        ),
      ],
    );
  }
}
