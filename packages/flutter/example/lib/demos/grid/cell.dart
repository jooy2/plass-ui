import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// Something to see the layout with — a grid cell draws nothing at all.
class Cell extends StatelessWidget {
  const Cell(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.glassPress,
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.sm]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}
