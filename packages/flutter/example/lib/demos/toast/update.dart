import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToastUpdate extends StatelessWidget {
  const ToastUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: PlToastProvider(
        child: Builder(
          builder: (BuildContext context) {
            final toasts = PlToastProvider.of(context);

            void start() {
              toasts.show(
                const PlToast(
                  id: 'upload',
                  title: Text('Uploading…'),
                  showIcon: false,
                  timeout: Duration.zero,
                ),
              );

              // The same id, so the message changes its mind rather than being
              // joined by a second one.
              Timer(const Duration(milliseconds: 1600), () {
                toasts.update(
                  'upload',
                  const PlToast(color: PlassColor.success, title: Text('Uploaded')),
                );
              });
            }

            return PlButton(
              size: PlassSize.sm,
              onPressed: start,
              child: const Text('Upload a file'),
            );
          },
        ),
      ),
    );
  }
}
