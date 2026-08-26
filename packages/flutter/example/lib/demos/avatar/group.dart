import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A stack is a layout, not a component — an overlap and a ring.
class AvatarGroup extends StatelessWidget {
  const AvatarGroup({super.key});

  static const List<String> _people = <String>[
    'Ada Lovelace',
    'Grace Hopper',
    'Alan Turing',
    'Jane Doe',
  ];

  /// A `md` avatar, and how far along each one starts.
  static const double _diameter = 40;
  static const double _step = 28;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final faces = <Widget>[
      for (final name in _people) PlAvatar(variant: PlassVariant.glass, name: name),
      const PlAvatar(color: PlassColor.secondary, initials: '+7'),
    ];

    return SizedBox(
      width: _step * (faces.length - 1) + _diameter,
      height: _diameter,
      child: Stack(
        children: <Widget>[
          for (var index = 0; index < faces.length; index += 1)
            PositionedDirectional(
              start: index * _step,
              child: DecoratedBox(
                // The ring is the page showing between two faces, which is what
                // keeps a stack readable when they are the same colour.
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.surface, width: 2),
                ),
                child: faces[index],
              ),
            ),
        ],
      ),
    );
  }
}
