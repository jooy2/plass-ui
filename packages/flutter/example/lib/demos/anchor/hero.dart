import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnchorHero extends StatefulWidget {
  const AnchorHero({super.key});

  @override
  State<AnchorHero> createState() => _AnchorHeroState();
}

class _AnchorHeroState extends State<AnchorHero> {
  final ScrollController _scroll = ScrollController();
  final List<GlobalKey> _keys = <GlobalKey>[GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey()];

  static const List<String> _titles = <String>['Overview', 'Install', 'Options', 'Troubleshooting'];
  static const List<int> _depths = <int>[0, 0, 1, 0];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      height: 300,
      width: 520,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          SizedBox(
            width: 180,
            child: PlAnchor(
              controller: _scroll,
              label: const Text('On this page'),
              items: <PlAnchorItem>[
                for (int index = 0; index < _titles.length; index += 1)
                  PlAnchorItem(
                    target: _keys[index],
                    label: Text(_titles[index]),
                    depth: _depths[index],
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (int index = 0; index < _titles.length; index += 1) ...<Widget>[
                    Padding(
                      key: _keys[index],
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _titles[index],
                        style: TextStyle(
                          color: tokens.fg,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Text(
                        'Scroll the column on the right and the list beside it follows. '
                        'What is lit is the last heading you passed, not whichever one '
                        'happens to be on screen.',
                        style: TextStyle(color: tokens.mutedFg, fontSize: 14, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
