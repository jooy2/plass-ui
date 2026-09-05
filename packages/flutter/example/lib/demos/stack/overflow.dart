import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const List<(String, String)> _reviewers = <(String, String)>[
  ('Nadia Rowan', '/samples/avatars/nadia-rowan.webp'),
  ('Theo Quinn', '/samples/avatars/theo-quinn.webp'),
  ('Victor Saye', '/samples/avatars/victor-saye.webp'),
  ('Anya Sol', '/samples/avatars/anya-sol.webp'),
  ('Helen Voss', '/samples/avatars/helen-voss.webp'),
  ('Noa Marin', '/samples/avatars/noa-marin.webp'),
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
            children: <Widget>[
              for (final (String name, String src) in _reviewers)
                PlAvatar(name: name, image: NetworkImage(src)),
            ],
          ),
      ],
    );
  }
}
