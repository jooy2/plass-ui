import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class OtpFieldVariants extends StatefulWidget {
  const OtpFieldVariants({super.key});

  @override
  State<OtpFieldVariants> createState() => _OtpFieldVariantsState();
}

class _OtpFieldVariantsState extends State<OtpFieldVariants> {
  final Map<PlassVariant, TextEditingController> _codes = <PlassVariant, TextEditingController>{
    for (final PlassVariant variant in PlassVariant.values)
      variant: TextEditingController(text: '12'),
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
        for (final PlassVariant variant in PlassVariant.values)
          PlOtpField(
            variant: variant,
            length: 4,
            controller: _codes[variant],
            label: Text(variant.name),
          ),
      ],
    );
  }
}
