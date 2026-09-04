import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class _Plus extends StatelessWidget {
  const _Plus();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(dimension: 20, child: FittedBox(child: Text('+')));
  }
}

class FloatingActionButtonExtended extends StatelessWidget {
  const FloatingActionButtonExtended({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: <Widget>[
          PlFloatingActionButton(
            floating: false,
            icon: const _Plus(),
            label: 'New project',
            onPressed: () {},
          ),
          PlFloatingActionButton(
            floating: false,
            extended: true,
            icon: const _Plus(),
            label: 'New project',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
