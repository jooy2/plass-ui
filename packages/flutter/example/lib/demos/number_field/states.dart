import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NumberFieldStates extends StatefulWidget {
  const NumberFieldStates({super.key});

  @override
  State<NumberFieldStates> createState() => _NumberFieldStatesState();
}

class _NumberFieldStatesState extends State<NumberFieldStates> {
  double? _error = 99;
  double? _unit = 3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          const PlNumberField(fullWidth: true, label: Text('Read-only'), readOnly: true, value: 12),
          const PlNumberField(fullWidth: true, label: Text('Disabled'), disabled: true, value: 12),
          PlNumberField(
            fullWidth: true,
            label: const Text('With an error'),
            error: const Text('Twelve at most.'),
            value: _error,
            onChanged: (double? next) => setState(() => _error = next),
          ),
          PlNumberField(
            fullWidth: true,
            label: const Text('With a unit'),
            endIcon: const Text('kg'),
            value: _unit,
            onChanged: (double? next) => setState(() => _unit = next),
          ),
        ],
      ),
    );
  }
}
