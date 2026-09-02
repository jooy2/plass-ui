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
        PlAvatar(size: PlassSize.lg, name: 'Ada Lovelace'),
        PlAvatar(size: PlassSize.lg, name: 'Grace Hopper'),
        PlAvatar(size: PlassSize.lg, name: 'Katherine Johnson'),
        PlAvatar(size: PlassSize.lg, name: '홍길동'),
        PlAvatar(size: PlassSize.lg, name: 'Alan Turing'),
      ],
    );
  }
}
