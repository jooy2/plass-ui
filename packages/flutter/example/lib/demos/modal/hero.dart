import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ModalHero extends StatefulWidget {
  const ModalHero({super.key});

  @override
  State<ModalHero> createState() => _ModalHeroState();
}

class _ModalHeroState extends State<ModalHero> {
  bool _open = false;
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void close() => setState(() => _open = false);

    // A preview is as tall as its content, and a sheet takes away whatever it is
    // inside. This is the page for it to take.
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          PlButton(
            color: PlassColor.danger,
            onPressed: () => setState(() => _open = true),
            child: const Text('Delete project'),
          ),
          PlModal(
            open: _open,
            onOpenChanged: (bool next) => setState(() => _open = next),
            title: const Text('Delete “Aurora”?'),
            description: const Text('Everything in it goes with it. This cannot be undone.'),
            actions: <Widget>[
              PlButton(
                variant: PlassVariant.ghost,
                color: PlassColor.secondary,
                onPressed: close,
                child: const Text('Cancel'),
              ),
              PlButton(color: PlassColor.danger, onPressed: close, child: const Text('Delete')),
            ],
            child: PlTextField(
              fullWidth: true,
              controller: _name,
              label: const Text('Type the project name to confirm'),
              placeholder: 'Aurora',
            ),
          ),
        ],
      ),
    );
  }
}
