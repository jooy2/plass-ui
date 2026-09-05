import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class AvatarFallback extends StatelessWidget {
  const AvatarFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 24,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _Case(
          label: 'picture',
          child: PlAvatar(
            name: 'Nadia Rowan',
            image: NetworkImage('/samples/avatars/nadia-rowan.webp'),
          ),
        ),
        _Case(
          label: 'initials',
          // A provider that will never produce pixels, which is the case an
          // avatar has to survive rather than the one it hopes for.
          child: PlAvatar(name: 'Nadia Rowan', image: NetworkImage('https://example.invalid/x')),
        ),
        _Case(
          label: 'initials, written',
          child: PlAvatar(name: 'Nadia Rowan', initials: 'NR!'),
        ),
        _Case(
          label: 'child',
          child: PlAvatar(name: 'Cat', child: Text('🐈')),
        ),
        _Case(label: 'silhouette', child: PlAvatar()),
      ],
    );
  }
}

class _Case extends StatelessWidget {
  const _Case({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        child,
        PlTypography(label, level: PlTypographyLevel.caption),
      ],
    );
  }
}
