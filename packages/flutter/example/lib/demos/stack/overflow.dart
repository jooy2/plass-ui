import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<String> _reviewers = <String>[
  'Ada Lovelace',
  'Grace Hopper',
  'Katherine Johnson',
  'Alan Turing',
];

class StackOverflow extends StatelessWidget {
  const StackOverflow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final int? max in <int?>[null, 3, 2])
          PlStack(
            max: max,
            total: 9,
            ring: BorderRadius.circular(999),
            overflow: (int hidden) => PlAvatar(initials: '+$hidden'),
            children: <Widget>[for (final String name in _reviewers) PlAvatar(name: name)],
          ),
      ],
    );
  }
}
