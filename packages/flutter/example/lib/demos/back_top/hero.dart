import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class BackTopHero extends StatefulWidget {
  const BackTopHero({super.key});

  @override
  State<BackTopHero> createState() => _BackTopHeroState();
}

class _BackTopHeroState extends State<BackTopHero> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 380,
      height: 260,
      // Where it goes is the caller's: there is no `position: fixed` here, so a
      // `Stack` with a `Positioned` is how a Flutter screen pins anything to a
      // corner.
      child: PlCard(
        child: Stack(
          children: <Widget>[
            ListView(
              controller: _controller,
              children: <Widget>[
                for (int index = 0; index < 40; index += 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Line ${index + 1}',
                      style: TextStyle(color: tokens.mutedFg, fontSize: 13),
                    ),
                  ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: PlBackTop(controller: _controller, visibilityHeight: 200, size: PlassSize.sm),
            ),
          ],
        ),
      ),
    );
  }
}
