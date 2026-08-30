import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToggleHero extends StatefulWidget {
  const ToggleHero({super.key});

  @override
  State<ToggleHero> createState() => _ToggleHeroState();
}

class _ToggleHeroState extends State<ToggleHero> {
  bool _bold = true;
  bool _italic = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            PlToggle(
              pressed: _bold,
              onPressedChanged: (bool next) => setState(() => _bold = next),
              child: const Text('Bold'),
            ),
            PlToggle(
              pressed: _italic,
              onPressedChanged: (bool next) => setState(() => _italic = next),
              child: const Text('Italic'),
            ),
          ],
        ),
        Text(
          'The toggle changes the state of the thing beside it.',
          style: TextStyle(
            fontWeight: _bold ? FontWeight.w700 : FontWeight.w400,
            fontStyle: _italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
