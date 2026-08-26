import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NumberFieldVariants extends StatefulWidget {
  const NumberFieldVariants({super.key});

  @override
  State<NumberFieldVariants> createState() => _NumberFieldVariantsState();
}

class _NumberFieldVariantsState extends State<NumberFieldVariants> {
  final Map<PlassVariant, double?> _values = <PlassVariant, double?>{
    for (final variant in PlassVariant.values) variant: 8,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final variant in PlassVariant.values)
            PlNumberField(
              fullWidth: true,
              variant: variant,
              label: Text(variant.name),
              value: _values[variant],
              onChanged: (double? next) => setState(() => _values[variant] = next),
            ),
        ],
      ),
    );
  }
}
