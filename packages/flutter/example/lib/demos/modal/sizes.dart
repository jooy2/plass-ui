import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ModalSizes extends StatefulWidget {
  const ModalSizes({super.key});

  @override
  State<ModalSizes> createState() => _ModalSizesState();
}

class _ModalSizesState extends State<ModalSizes> {
  PlassSize? _size;

  @override
  Widget build(BuildContext context) {
    // A preview is as tall as its content, and a sheet takes away whatever it is
    // inside. This is the page for it to take.
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final size in PlassSize.values)
                PlButton(
                  variant: PlassVariant.glass,
                  onPressed: () => setState(() => _size = size),
                  child: Text(size.name),
                ),
            ],
          ),
          PlModal(
            open: _size != null,
            size: _size ?? PlassSize.md,
            onOpenChanged: (bool next) => setState(() => _size = null),
            title: Text('size: ${_size?.name}'),
            description: const Text('The width and the type scale move together.'),
            actions: <Widget>[
              PlButton(
                size: PlassSize.sm,
                onPressed: () => setState(() => _size = null),
                child: const Text('Close'),
              ),
            ],
            child: const Text(
              'How long a line of text is comfortable inside the sheet is the question this '
              'ladder answers, which is why its steps are further apart than the control heights.',
            ),
          ),
        ],
      ),
    );
  }
}
