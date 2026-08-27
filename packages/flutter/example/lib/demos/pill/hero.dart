import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// A filled dot, which is the whole glyph a recording indicator needs.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    final IconThemeData theme = IconTheme.of(context);

    return SizedBox(
      width: theme.size ?? 16,
      height: theme.size ?? 16,
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.color ?? const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}

/// A filled square: stop.
class _Stop extends StatelessWidget {
  const _Stop();

  @override
  Widget build(BuildContext context) {
    final IconThemeData theme = IconTheme.of(context);

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: theme.color ?? const Color(0xFFFFFFFF),
      ),
    );
  }
}

class PillHero extends StatelessWidget {
  const PillHero({super.key});

  @override
  Widget build(BuildContext context) {
    return PlPill(
      color: PlassColor.danger,
      title: const Text('Recording'),
      description: const Text('00:41'),
      startIcon: const _Dot(),
      endIcon: PlIconButton(
        size: PlassSize.xs,
        variant: PlassVariant.ghost,
        icon: const _Stop(),
        label: 'Stop',
        onPressed: () {},
      ),
    );
  }
}
