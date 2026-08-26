import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class OtpFieldSizes extends StatefulWidget {
  const OtpFieldSizes({super.key});

  @override
  State<OtpFieldSizes> createState() => _OtpFieldSizesState();
}

class _OtpFieldSizesState extends State<OtpFieldSizes> {
  final Map<PlassSize, TextEditingController> _codes = <PlassSize, TextEditingController>{
    for (final PlassSize size in PlassSize.values) size: TextEditingController(text: '12'),
  };

  @override
  void dispose() {
    for (final TextEditingController controller in _codes.values) {
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
        for (final PlassSize size in PlassSize.values)
          PlOtpField(size: size, length: 4, controller: _codes[size], label: Text(size.name)),
      ],
    );
  }
}
