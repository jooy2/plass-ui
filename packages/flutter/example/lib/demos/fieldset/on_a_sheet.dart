import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FieldsetOnASheet extends StatefulWidget {
  const FieldsetOnASheet({super.key});

  @override
  State<FieldsetOnASheet> createState() => _FieldsetOnASheetState();
}

class _FieldsetOnASheetState extends State<FieldsetOnASheet> {
  String _speed = 'standard';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: PlCard(
        title: const Text('Delivery'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 24,
          children: <Widget>[
            const PlFieldset(
              size: PlassSize.sm,
              legend: Text('Where'),
              children: <Widget>[
                PlTextField(size: PlassSize.sm, label: Text('Street'), fullWidth: true),
              ],
            ),
            PlFieldset(
              size: PlassSize.sm,
              legend: const Text('How fast'),
              children: <Widget>[
                PlRadioGroup<String>(
                  size: PlassSize.sm,
                  value: _speed,
                  onChanged: (String? next) => setState(() => _speed = next ?? 'standard'),
                  options: const <PlRadioOption<String>>[
                    PlRadioOption<String>(value: 'standard', label: Text('Standard')),
                    PlRadioOption<String>(value: 'express', label: Text('Express')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
