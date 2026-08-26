import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NumberFieldHero extends StatefulWidget {
  const NumberFieldHero({super.key});

  @override
  State<NumberFieldHero> createState() => _NumberFieldHeroState();
}

class _NumberFieldHeroState extends State<NumberFieldHero> {
  double? _quantity = 2;
  double? _budget = 1240;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          PlNumberField(
            fullWidth: true,
            label: const Text('Quantity'),
            description: const Text('Up to twelve per order.'),
            min: 1,
            max: 12,
            value: _quantity,
            onChanged: (double? next) => setState(() => _quantity = next),
          ),
          PlNumberField(
            fullWidth: true,
            label: const Text('Budget'),
            step: 10,
            value: _budget,
            format: (double value) => '\$${value.toStringAsFixed(2)}',
            onChanged: (double? next) => setState(() => _budget = next),
          ),
        ],
      ),
    );
  }
}
