import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class TourMask extends StatefulWidget {
  const TourMask({super.key});

  @override
  State<TourMask> createState() => _TourMaskState();
}

class _TourMaskState extends State<TourMask> {
  final GlobalKey _target = GlobalKey();
  bool _running = false;
  bool _mask = true;

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
            PlSwitch(
              size: PlassSize.sm,
              value: _mask,
              onChanged: (bool next) => setState(() => _mask = next),
              label: const Text('Dim the screen'),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: PlButton(
                key: _target,
                size: PlassSize.sm,
                variant: PlassVariant.ghost,
                onPressed: () {},
                child: const Text('The thing being pointed at'),
              ),
            ),
            PlButton(
              size: PlassSize.sm,
              onPressed: () => setState(() => _running = true),
              child: const Text('Start'),
            ),
            PlTour(
              open: _running,
              onOpenChanged: (bool next) => setState(() => _running = next),
              mask: _mask,
              scrollIntoView: false,
              steps: <PlTourStep>[
                PlTourStep(
                  target: _target,
                  title: const Text('Try pressing it'),
                  content: const Text(
                    'The light is a hole in the dimming, so what is inside it still answers.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
