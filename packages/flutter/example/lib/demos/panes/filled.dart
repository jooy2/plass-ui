import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// Something to see a pane with — a pane draws no surface of its own.
class Filled extends StatelessWidget {
  const Filled(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final PlassTokens tokens = PlassTheme.of(context);

    return ColoredBox(
      color: tokens.glassPress,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: tokens.mutedFg),
          ),
        ),
      ),
    );
  }
}
