import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ConfirmAlert extends StatelessWidget {
  const ConfirmAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return PlConfirmProvider(
      child: Builder(
        builder: (BuildContext context) {
          return PlButton(
            variant: PlassVariant.glass,
            onPressed: () async {
              await PlConfirmProvider.of(context).alert(
                const PlConfirmOptions(
                  title: Text('Your session expired.'),
                  description: Text('Sign in again to carry on where you left off.'),
                ),
              );
            },
            child: const Text('Show an alert'),
          );
        },
      ),
    );
  }
}
