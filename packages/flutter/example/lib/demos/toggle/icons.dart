import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A letter standing in for a glyph: the package ships no icon set, and a demo
/// that pulled one in would be showing somebody else's work.
class _Mark extends StatelessWidget {
  const _Mark(this.letter, {this.style});

  final String letter;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(letter, style: style);
  }
}

class ToggleIcons extends StatelessWidget {
  const ToggleIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlToggleGroup(
      multiple: true,
      variant: PlassVariant.ghost,
      defaultValue: <String>['bold'],
      children: <Widget>[
        PlToggle(
          value: 'bold',
          semanticLabel: 'Bold',
          startIcon: _Mark('B', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        PlToggle(
          value: 'italic',
          semanticLabel: 'Italic',
          startIcon: _Mark('I', style: TextStyle(fontStyle: FontStyle.italic)),
        ),
        PlToggle(
          value: 'underline',
          semanticLabel: 'Underline',
          startIcon: _Mark('U', style: TextStyle(decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}
