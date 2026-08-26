import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NumberFieldFormat extends StatefulWidget {
  const NumberFieldFormat({super.key});

  @override
  State<NumberFieldFormat> createState() => _NumberFieldFormatState();
}

class _NumberFieldFormatState extends State<NumberFieldFormat> {
  double? _value = 0.185;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          PlNumberField(
            fullWidth: true,
            label: const Text('Commission'),
            step: 0.005,
            smallStep: 0.001,
            value: _value,
            // The two halves of one idea: one writes the percentage, the other
            // reads it back into the fraction the value actually is.
            format: (double value) => '${(value * 100).toStringAsFixed(2)}%',
            parse: (String text) {
              final digits = text.replaceAll(RegExp(r'[^0-9.\-]'), '');
              final percent = double.tryParse(digits);

              return percent == null ? null : percent / 100;
            },
            onChanged: (double? next) => setState(() => _value = next),
          ),
          PlTypography(
            'The field shows a percentage; the value is $_value.',
            level: PlTypographyLevel.caption,
          ),
        ],
      ),
    );
  }
}
