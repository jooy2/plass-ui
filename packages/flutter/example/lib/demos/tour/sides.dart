import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TourSides extends StatefulWidget {
  const TourSides({super.key});

  @override
  State<TourSides> createState() => _TourSidesState();
}

class _TourSidesState extends State<TourSides> {
  final GlobalKey _middle = GlobalKey();
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: PlCard(
        size: PlassSize.sm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            PlButton(
              key: _middle,
              size: PlassSize.sm,
              variant: PlassVariant.ghost,
              onPressed: () {},
              child: const Text('The target'),
            ),
            PlButton(
              size: PlassSize.sm,
              onPressed: () => setState(() => _running = true),
              child: const Text('Walk round it'),
            ),
            PlTour(
              open: _running,
              onOpenChanged: (bool next) => setState(() => _running = next),
              scrollIntoView: false,
              steps: <PlTourStep>[
                PlTourStep(target: _middle, title: const Text('Below')),
                PlTourStep(target: _middle, title: const Text('Above'), side: PlassSide.top),
                PlTourStep(
                  target: _middle,
                  title: const Text('Beside it'),
                  side: PlassSide.right,
                  align: PlassAlign.start,
                ),
                // No target: the card goes to the middle and nothing is cut out.
                const PlTourStep(title: Text('And nowhere in particular')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
