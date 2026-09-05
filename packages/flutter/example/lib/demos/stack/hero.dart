import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class StackHero extends StatelessWidget {
  const StackHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlStack(
      max: 4,
      total: 11,
      ring: BorderRadius.circular(999),
      overflow: (int hidden) => PlAvatar(size: PlassSize.lg, initials: '+$hidden'),
      children: const <Widget>[
        PlAvatar(
          size: PlassSize.lg,
          name: 'Nadia Rowan',
          image: NetworkImage('/samples/avatars/nadia-rowan.webp'),
        ),
        PlAvatar(
          size: PlassSize.lg,
          name: 'Theo Quinn',
          image: NetworkImage('/samples/avatars/theo-quinn.webp'),
        ),
        PlAvatar(
          size: PlassSize.lg,
          name: 'Victor Saye',
          image: NetworkImage('/samples/avatars/victor-saye.webp'),
        ),
        PlAvatar(
          size: PlassSize.lg,
          name: 'Noa Marin',
          image: NetworkImage('/samples/avatars/noa-marin.webp'),
        ),
        PlAvatar(size: PlassSize.lg, name: '홍길동'),
      ],
    );
  }
}
