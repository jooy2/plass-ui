import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class WindowPaneHero extends StatefulWidget {
  const WindowPaneHero({super.key});

  @override
  State<WindowPaneHero> createState() => _WindowPaneHeroState();
}

class _WindowPaneHeroState extends State<WindowPaneHero> {
  Offset _at = Offset.zero;
  bool _open = true;
  bool _minimized = false;
  bool _maximized = false;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    if (!_open) {
      return PlButton(
        onPressed: () => setState(() => _open = true),
        child: const Text('Open the window'),
      );
    }

    return PlWindowPane(
      title: const Text('Notes'),
      draggable: true,
      width: 420,
      height: 240,
      offset: _at,
      minimized: _minimized,
      maximized: _maximized,
      onOffsetChanged: (Offset value) => setState(() => _at = value),
      onOpenChanged: (bool value) => setState(() => _open = value),
      onMinimizedChanged: (bool value) => setState(() => _minimized = value),
      onMaximizedChanged: (bool value) => setState(() => _maximized = value),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            Text(
              'Drag the bar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: tokens.fg),
            ),
            Text(
              'The three buttons are real buttons with real names, and minimize rolls '
              'the window up to its bar because a page has nowhere to send it.',
              style: TextStyle(fontSize: 14, color: tokens.mutedFg),
            ),
          ],
        ),
      ),
    );
  }
}
