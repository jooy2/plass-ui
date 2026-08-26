import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A filled disc, which is the whole glyph a status chip needs.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = theme.size ?? 16;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.color ?? const Color(0xFF000000),
        ),
        child: Center(child: SizedBox.square(dimension: size / 2)),
      ),
    );
  }
}

class ChipSlots extends StatelessWidget {
  const ChipSlots({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        PlChip(startIcon: _Dot(), color: PlassColor.success, child: Text('Deployed')),
        PlChip(
          startIcon: PlAvatar(size: PlassSize.xs, name: 'Ada Lovelace'),
          color: PlassColor.secondary,
          child: Text('Ada Lovelace'),
        ),
        PlChip(count: Text('12'), color: PlassColor.danger, child: Text('Errors')),
        PlChip(variant: PlassVariant.solid, count: Text('99+'), child: Text('Unread')),
      ],
    );
  }
}
