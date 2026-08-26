import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToastPositions extends StatefulWidget {
  const ToastPositions({super.key});

  @override
  State<ToastPositions> createState() => _ToastPositionsState();
}

class _ToastPositionsState extends State<ToastPositions> {
  PlToastPosition _position = PlToastPosition.bottomEnd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: PlToastProvider(
        // Keyed on the position so the stack is rebuilt where it was moved to
        // rather than sliding across the screen.
        key: ValueKey<PlToastPosition>(_position),
        position: _position,
        timeout: const Duration(milliseconds: 2500),
        child: Builder(
          builder: (BuildContext context) {
            final toasts = PlToastProvider.of(context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final position in PlToastPosition.values)
                      PlButton(
                        size: PlassSize.xs,
                        variant: position == _position ? PlassVariant.solid : PlassVariant.glass,
                        color: PlassColor.secondary,
                        onPressed: () => setState(() => _position = position),
                        child: Text(position.name),
                      ),
                  ],
                ),
                PlButton(
                  size: PlassSize.sm,
                  onPressed: () => toasts.show(PlToast(title: Text(_position.name))),
                  child: const Text('Raise it'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
