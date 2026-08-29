import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateHeadlineRise extends StatelessWidget {
  const AnimateHeadlineRise({super.key});

  static const List<String> _names = <String>['Northwind', 'Contoso', 'Fabrikam'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 40,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: <Widget>[
        PlAnimateHeadline(
          interval: const Duration(milliseconds: 1600),
          children: <Widget>[for (final String name in _names) PlChip(child: Text(name))],
        ),
        PlAnimateHeadline(
          rise: 8,
          interval: const Duration(milliseconds: 1600),
          children: <Widget>[for (final String name in _names) PlChip(child: Text(name))],
        ),
      ],
    );
  }
}
