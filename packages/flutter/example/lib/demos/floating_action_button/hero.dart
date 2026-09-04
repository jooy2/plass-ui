import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class _Plus extends StatelessWidget {
  const _Plus();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(dimension: 20, child: FittedBox(child: Text('+')));
  }
}

class FloatingActionButtonHero extends StatelessWidget {
  const FloatingActionButtonHero({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return SizedBox(
      width: 360,
      height: 220,
      child: PlCard(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'The one action this screen is about, in the corner it is always '
                'in. Everything else on the screen goes on working.',
                style: TextStyle(color: tokens.mutedFg, fontSize: 14, height: 1.6),
              ),
            ),
            PlFloatingActionButton(icon: const _Plus(), label: 'New project', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
