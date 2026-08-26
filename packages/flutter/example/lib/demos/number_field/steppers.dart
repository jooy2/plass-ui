import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NumberFieldSteppers extends StatefulWidget {
  const NumberFieldSteppers({super.key});

  @override
  State<NumberFieldSteppers> createState() => _NumberFieldSteppersState();
}

class _NumberFieldSteppersState extends State<NumberFieldSteppers> {
  final Map<PlNumberFieldSteppers, double?> _values = <PlNumberFieldSteppers, double?>{
    for (final steppers in PlNumberFieldSteppers.values) steppers: 2,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final steppers in PlNumberFieldSteppers.values)
            PlNumberField(
              fullWidth: true,
              steppers: steppers,
              label: Text(steppers.name),
              value: _values[steppers],
              onChanged: (double? next) => setState(() => _values[steppers] = next),
            ),
        ],
      ),
    );
  }
}
