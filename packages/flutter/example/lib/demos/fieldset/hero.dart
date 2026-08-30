import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class FieldsetHero extends StatelessWidget {
  const FieldsetHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 340,
      child: PlFieldset(
        legend: Text('Billing address'),
        description: Text('Where the invoice goes.'),
        children: <Widget>[
          PlTextField(label: Text('Street'), fullWidth: true),
          PlTextField(label: Text('City'), fullWidth: true),
          PlTextField(label: Text('Postcode'), fullWidth: true),
        ],
      ),
    );
  }
}
