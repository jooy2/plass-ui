import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class OtpFieldStates extends StatefulWidget {
  const OtpFieldStates({super.key});

  @override
  State<OtpFieldStates> createState() => _OtpFieldStatesState();
}

class _OtpFieldStatesState extends State<OtpFieldStates> {
  final List<TextEditingController> _codes = <TextEditingController>[
    TextEditingController(text: '1234'),
    TextEditingController(text: '1234'),
    TextEditingController(text: '12'),
    TextEditingController(text: '1234'),
  ];

  @override
  void dispose() {
    for (final TextEditingController controller in _codes) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        PlOtpField(length: 4, mask: true, controller: _codes[0], label: const Text('Masked')),
        PlOtpField(
          length: 4,
          readOnly: true,
          controller: _codes[1],
          label: const Text('Read only'),
        ),
        PlOtpField(length: 4, disabled: true, controller: _codes[2], label: const Text('Disabled')),
        PlOtpField(
          length: 4,
          controller: _codes[3],
          label: const Text('Wrong code'),
          error: const Text('That code has expired.'),
        ),
      ],
    );
  }
}
