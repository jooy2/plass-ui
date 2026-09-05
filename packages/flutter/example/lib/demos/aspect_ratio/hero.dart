import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AspectRatioHero extends StatelessWidget {
  const AspectRatioHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 384,
      child: PlAspectRatio(
        ratio: 16 / 9,
        rounded: true,
        size: PlassSize.lg,
        fit: PlAspectFit.cover,
        child: Image(
          image: NetworkImage('/samples/photos/lakeside-observatory-blue-hour.webp'),
          fit: BoxFit.cover,
          semanticLabel: 'An observatory beside a lake at blue hour',
        ),
      ),
    );
  }
}
