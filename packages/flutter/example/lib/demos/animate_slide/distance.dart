import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AnimateSlideDistance extends StatelessWidget {
  const AnimateSlideDistance({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 320,
      child: ClipRect(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: <Widget>[
            PlAnimateSlide(
              from: PlassSide.left,
              duration: Duration(milliseconds: 1400),
              repeat: null,
              alternate: true,
              child: PlBox(
                size: PlassSize.sm,
                child: Text('no distance — its own width, so it starts out of frame'),
              ),
            ),
            PlAnimateSlide(
              from: PlassSide.left,
              distance: 16,
              duration: Duration(milliseconds: 1400),
              repeat: null,
              alternate: true,
              child: PlBox(
                size: PlassSize.sm,
                child: Text('16px — a nudge rather than an entrance'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
