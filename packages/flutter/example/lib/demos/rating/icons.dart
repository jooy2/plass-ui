import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

class RatingIcons extends StatefulWidget {
  const RatingIcons({super.key});

  @override
  State<RatingIcons> createState() => _RatingIconsState();
}

class _RatingIconsState extends State<RatingIcons> {
  double _score = 3;

  @override
  Widget build(BuildContext context) {
    return PlRating(
      value: _score,
      color: PlassColor.danger,
      // The same drawing twice — the two are laid one over the other and the
      // top one is cropped, so a filled heart over an outlined star would show
      // as a rim that does not line up with what is inside it.
      icon: const HeartGlyph(),
      emptyIcon: const HeartGlyph(),
      onChanged: (double next) => setState(() => _score = next),
    );
  }
}
