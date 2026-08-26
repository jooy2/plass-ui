import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToastHero extends StatelessWidget {
  const ToastHero({super.key});

  @override
  Widget build(BuildContext context) {
    // A stack needs a page to sit at the edge of, and this is the page.
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: PlToastProvider(
        child: Builder(
          builder: (BuildContext context) {
            final toasts = PlToastProvider.of(context);

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                PlButton(
                  size: PlassSize.sm,
                  onPressed: () => toasts.show(
                    const PlToast(
                      color: PlassColor.success,
                      title: Text('Saved'),
                      description: Text('Your changes are live.'),
                    ),
                  ),
                  child: const Text('Save'),
                ),
                PlButton(
                  size: PlassSize.sm,
                  variant: PlassVariant.glass,
                  color: PlassColor.danger,
                  onPressed: () => toasts.show(
                    PlToast(
                      color: PlassColor.danger,
                      title: const Text('Deleted “Aurora”'),
                      timeout: Duration.zero,
                      actionLabel: const Text('Undo'),
                      onAction: () => toasts.show(
                        const PlToast(color: PlassColor.info, title: Text('Restored')),
                      ),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
