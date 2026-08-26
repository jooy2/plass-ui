import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ModalDividers extends StatefulWidget {
  const ModalDividers({super.key});

  @override
  State<ModalDividers> createState() => _ModalDividersState();
}

class _ModalDividersState extends State<ModalDividers> {
  bool _open = false;

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
            variant: PlassVariant.glass,
            onPressed: () => setState(() => _open = true),
            child: const Text('Read the terms'),
          ),
          PlModal(
            open: _open,
            dividers: true,
            onOpenChanged: (bool next) => setState(() => _open = next),
            title: const Text('Terms of service'),
            description: const Text('Last updated in March.'),
            actions: <Widget>[
              PlButton(
                variant: PlassVariant.ghost,
                color: PlassColor.secondary,
                onPressed: close,
                child: const Text('Decline'),
              ),
              PlButton(onPressed: close, child: const Text('Accept')),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: <Widget>[
                for (var clause = 1; clause <= 12; clause += 1)
                  Text(
                    'Clause $clause. The header and the actions stay put while only this part '
                    'scrolls, which is exactly when the hairlines start earning their place.',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
