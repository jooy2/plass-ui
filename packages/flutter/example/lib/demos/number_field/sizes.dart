import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class NumberFieldSizes extends StatefulWidget {
  const NumberFieldSizes({super.key});

  @override
  State<NumberFieldSizes> createState() => _NumberFieldSizesState();
}

class _NumberFieldSizesState extends State<NumberFieldSizes> {
  final Map<PlassSize, double?> _values = <PlassSize, double?>{
    for (final size in PlassSize.values) size: 12,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final size in PlassSize.values)
            PlNumberField(
              fullWidth: true,
              size: size,
              label: Text(size.name),
              value: _values[size],
              onChanged: (double? next) => setState(() => _values[size] = next),
            ),
        ],
      ),
    );
  }
}
