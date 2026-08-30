import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FieldsetDisabled extends StatefulWidget {
  const FieldsetDisabled({super.key});

  @override
  State<FieldsetDisabled> createState() => _FieldsetDisabledState();
}

class _FieldsetDisabledState extends State<FieldsetDisabled> {
  bool _same = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          PlSwitch(
            value: _same,
            onChanged: (bool next) => setState(() => _same = next),
            label: const Text('Same as shipping address'),
          ),
          PlFieldset(
            legend: const Text('Billing address'),
            disabled: _same,
            children: const <Widget>[
              PlTextField(label: Text('Street'), fullWidth: true),
              PlCheckbox(value: false, label: Text('This is a business address')),
            ],
          ),
        ],
      ),
    );
  }
}
