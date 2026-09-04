import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TourHero extends StatefulWidget {
  const TourHero({super.key});

  @override
  State<TourHero> createState() => _TourHeroState();
}

class _TourHeroState extends State<TourHero> {
  final GlobalKey _filter = GlobalKey();
  final GlobalKey _save = GlobalKey();
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlCard(
        size: PlassSize.sm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
              children: <Widget>[
                Expanded(
                  child: PlTextField(
                    key: _filter,
                    size: PlassSize.sm,
                    label: const Text('Search'),
                    placeholder: 'Anything at all',
                    fullWidth: true,
                  ),
                ),
                PlButton(
                  key: _save,
                  size: PlassSize.sm,
                  onPressed: () {},
                  child: const Text('Save'),
                ),
              ],
            ),
            PlButton(
              size: PlassSize.sm,
              variant: PlassVariant.ghost,
              onPressed: () => setState(() => _running = true),
              child: const Text('Show me around'),
            ),
            PlTour(
              open: _running,
              onOpenChanged: (bool next) => setState(() => _running = next),
              // Nothing scrolls inside a documentation page, and a smooth
              // scroll would move the page around whoever is reading it.
              scrollIntoView: false,
              steps: <PlTourStep>[
                PlTourStep(
                  target: _filter,
                  title: const Text('Narrow the list'),
                  content: const Text('Type anything here and the list below follows along.'),
                ),
                PlTourStep(
                  target: _save,
                  title: const Text('Keep what you found'),
                  content: const Text('A saved search comes back next time you open this.'),
                  side: PlassSide.top,
                  align: PlassAlign.end,
                ),
                const PlTourStep(
                  title: Text('That is all of it'),
                  content: Text('Everything else works the way you expect.'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
