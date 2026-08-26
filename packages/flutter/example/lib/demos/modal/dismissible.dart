import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ModalDismissible extends StatefulWidget {
  const ModalDismissible({super.key});

  @override
  State<ModalDismissible> createState() => _ModalDismissibleState();
}

class _ModalDismissibleState extends State<ModalDismissible> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    // A preview is as tall as its content, and a sheet takes away whatever it is
    // inside. This is the page for it to take.
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          PlButton(
            variant: PlassVariant.glass,
            onPressed: () => setState(() => _open = true),
            child: const Text('Finish setup'),
          ),
          PlModal(
            open: _open,
            size: PlassSize.sm,
            dismissible: false,
            showClose: false,
            onOpenChanged: (bool next) => setState(() => _open = next),
            title: const Text('One more thing'),
            description: const Text(
              'Escape and a press outside are both off, so the actions are the only way out.',
            ),
            actions: <Widget>[
              PlButton(
                onPressed: () => setState(() => _open = false),
                child: const Text('I understand'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
