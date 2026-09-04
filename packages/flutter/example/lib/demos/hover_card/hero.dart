import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class HoverCardHero extends StatelessWidget {
  const HoverCardHero({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 360,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: tokens.fg, fontSize: 15, height: 1.6),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            const Text('The notes were written by '),
            PlHoverCard(
              title: const Text('Ada Lovelace'),
              description: const Text('Mathematician, 1815–1852'),
              trigger: PlTextLink(onPressed: () {}, child: const Text('Ada Lovelace')),
              child: const Text(
                'Wrote the first algorithm intended to be carried out by a machine, in a set '
                'of notes longer than the paper they annotated.',
              ),
            ),
            const Text(', and are longer than the paper.'),
          ],
        ),
      ),
    );
  }
}
