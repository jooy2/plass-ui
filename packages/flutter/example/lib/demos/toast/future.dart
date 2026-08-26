import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class ToastFuture extends StatelessWidget {
  const ToastFuture({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: PlToastProvider(
        child: Builder(
          builder: (BuildContext context) {
            final toasts = PlToastProvider.of(context);

            void run({required bool succeed}) {
              final work = Future<String>.delayed(
                const Duration(milliseconds: 1600),
                () => succeed ? 'v128' : throw StateError('health check'),
              );

              unawaited(
                toasts
                    .showFuture<String>(
                      work,
                      loading: const PlToast(title: Text('Deploying…'), showIcon: false),
                      success: (String version) =>
                          PlToast(color: PlassColor.success, title: Text('Deployed $version')),
                      failure: (Object error) => PlToast(
                        color: PlassColor.danger,
                        title: const Text('The deploy failed'),
                        description: Text('$error'),
                      ),
                    )
                    // The toast has already said what happened; this only keeps
                    // the failure from reaching the zone as unhandled.
                    .catchError((Object _) => ''),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                PlButton(
                  size: PlassSize.sm,
                  onPressed: () => run(succeed: true),
                  child: const Text('Deploy'),
                ),
                PlButton(
                  size: PlassSize.sm,
                  variant: PlassVariant.glass,
                  color: PlassColor.danger,
                  onPressed: () => run(succeed: false),
                  child: const Text('Deploy badly'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
