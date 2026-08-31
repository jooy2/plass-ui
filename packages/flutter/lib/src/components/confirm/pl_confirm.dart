/// One dialog, asked for from anywhere under it.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/components/modal/pl_modal.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// Which button holds the focus when the dialog opens.
enum PlConfirmFocus {
  /// The one that answers yes.
  confirm,

  /// The one that answers no. The default, and the reason is in
  /// [PlConfirmOptions.initialFocus].
  cancel,
}

/// What one question looks like.
@immutable
class PlConfirmOptions {
  /// Creates a question.
  const PlConfirmOptions({
    this.title,
    this.description,
    this.child,
    this.confirmLabel,
    this.cancelLabel,
    this.color,
    this.size,
    this.initialFocus = PlConfirmFocus.cancel,
    this.dismissible = true,
    this.width,
  });

  /// The question, as the heading that names the dialog.
  final Widget? title;

  /// A line under it. Say what happens.
  final Widget? description;

  /// Anything more that belongs in the body — a list of what is about to go.
  final Widget? child;

  /// The word on the button that answers yes.
  final Widget? confirmLabel;

  /// The word on the button that answers no. Not drawn by `alert`.
  final Widget? cancelLabel;

  /// The family the confirming button takes. `danger` for anything that removes
  /// something.
  final PlassColor? color;

  /// The size of this one question.
  final PlassSize? size;

  /// Which button holds the focus when the dialog opens.
  ///
  /// **Cancel by default**, and that is the decision worth stating: a confirm
  /// dialog exists to make somebody stop, and an Enter key that lands on the
  /// destructive action defeats the whole thing. Move it for a question whose
  /// yes is the harmless answer — "Save before closing?" — where making somebody
  /// reach for the pointer to agree is its own kind of rude.
  final PlConfirmFocus initialFocus;

  /// Whether a press outside and the × answer **no**.
  ///
  /// On, because a question that cannot be escaped is a trap. Turn it off for
  /// the one that has to be answered.
  final bool dismissible;

  /// How wide the sheet may get.
  final double? width;
}

/// Asks questions from anywhere under a [PlConfirmProvider].
abstract class PlConfirmController {
  /// Asks the question and completes with the answer.
  Future<bool> confirm(PlConfirmOptions options);

  /// Says something and completes when it has been acknowledged. One button.
  Future<void> alert(PlConfirmOptions options);
}

/// One dialog, asked for from anywhere under it.
///
/// The thing a caller has at the moment a question is warranted is a **callback**,
/// not a place in the tree — `onPressed: () async { if (await …confirm(…)) … }`
/// is the shape this exists to make possible. The alternative, and what every
/// application writes without it, is a piece of state per question plus a
/// `PlModal` kept in the tree beside every button that might need one, and the
/// branch after the answer torn in half across a callback.
///
/// It is [PlToastProvider]'s arrangement for the same reason and with the same
/// trade: one widget near the root, and a lookup everywhere else.
///
/// ```dart
/// PlConfirmProvider(child: MyApp())
/// ```
///
/// ```dart
/// if (await PlConfirmProvider.of(context).confirm(
///   const PlConfirmOptions(title: Text('Delete this project?'), color: PlassColor.danger),
/// )) {
///   await remove(project);
/// }
/// ```
///
/// **Questions asked while one is open are queued**, in the order they were
/// asked. The alternative is a future nobody ever completes, which is a hung
/// button rather than a visible bug.
class PlConfirmProvider extends StatefulWidget {
  /// Creates a provider.
  const PlConfirmProvider({
    required this.child,
    this.confirmLabel = const Text('Confirm'),
    this.cancelLabel = const Text('Cancel'),
    this.acknowledgeLabel = const Text('OK'),
    this.width,
    this.size,
    this.color,
    super.key,
  });

  /// The application.
  final Widget child;

  /// The default word on the button that answers yes.
  final Widget confirmLabel;

  /// The default word on the button that answers no.
  final Widget cancelLabel;

  /// The default word on an `alert`'s single button.
  final Widget acknowledgeLabel;

  /// How wide a sheet may get, unless a question says otherwise.
  final double? width;

  /// The default size of a question.
  final PlassSize? size;

  /// The default family the confirming button takes.
  final PlassColor? color;

  /// The controller for the nearest provider above [context].
  static PlConfirmController of(BuildContext context) {
    final controller = maybeOf(context);

    assert(controller != null, 'No PlConfirmProvider found above this context.');

    return controller!;
  }

  /// The same, without the assertion.
  static PlConfirmController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_PlConfirmScope>()?.controller;
  }

  @override
  State<PlConfirmProvider> createState() => _PlConfirmProviderState();
}

class _PlConfirmScope extends InheritedWidget {
  const _PlConfirmScope({required this.controller, required super.child});

  final PlConfirmController controller;

  @override
  bool updateShouldNotify(_PlConfirmScope oldWidget) => controller != oldWidget.controller;
}

/// One question waiting for its answer.
class _Request {
  _Request({required this.options, required this.alert}) : completer = Completer<bool>();

  final PlConfirmOptions options;
  final bool alert;
  final Completer<bool> completer;
}

class _PlConfirmProviderState extends State<PlConfirmProvider> implements PlConfirmController {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

  final List<_Request> _queue = <_Request>[];

  _Request? _live;
  bool _open = false;

  @override
  void dispose() {
    // Everything an unmounting provider is still holding. A future that is never
    // completed is a callback that never runs its `finally`, so a route change
    // would leave a button spinning for the rest of the session.
    _live?.completer.complete(false);

    for (final _Request request in _queue) {
      request.completer.complete(false);
    }

    _queue.clear();
    _live = null;

    super.dispose();
  }

  Future<bool> _ask(PlConfirmOptions options, {required bool alert}) {
    final request = _Request(options: options, alert: alert);

    if (_live != null) {
      _queue.add(request);

      return request.completer.future;
    }

    setState(() {
      _live = request;
      _open = true;
    });

    return request.completer.future;
  }

  void _settle(bool value) {
    final request = _live;

    if (request == null) {
      return;
    }

    request.completer.complete(value);

    if (_queue.isNotEmpty) {
      // The dialog stays open and its content changes. Closing and reopening in
      // one frame would play neither transition, and would take the focus out of
      // a dialog the reader is about to be asked something else in.
      setState(() => _live = _queue.removeAt(0));

      return;
    }

    // `_live` is kept until the sheet has finished animating out, so there is
    // something to draw while it does.
    setState(() {
      _live = null;
      _open = false;
    });
  }

  @override
  Future<bool> confirm(PlConfirmOptions options) => _ask(options, alert: false);

  @override
  Future<void> alert(PlConfirmOptions options) => _ask(options, alert: true);

  @override
  Widget build(BuildContext context) {
    final options = _live?.options;
    final isAlert = _live?.alert ?? false;
    final focusConfirm =
        isAlert || (options?.initialFocus ?? PlConfirmFocus.cancel) == PlConfirmFocus.confirm;
    final size = options?.size ?? _size;
    final color = options?.color ?? _color;

    return _PlConfirmScope(
      controller: this,
      child: Stack(
        children: <Widget>[
          widget.child,
          PlModal(
            open: _open,
            // The only path that reaches here is the × or a press outside — the
            // buttons below settle and close it themselves, and a controlled
            // `open` does not call this back for that.
            onOpenChanged: (bool next) {
              if (!next) {
                _settle(false);
              }
            },
            dismissible: options?.dismissible ?? true,
            showClose: false,
            size: size,
            color: color,
            width: options?.width ?? widget.width,
            title: options?.title,
            description: options?.description,
            actions: <Widget>[
              if (!isAlert)
                PlButton(
                  variant: PlassVariant.ghost,
                  color: PlassColor.secondary,
                  size: size,
                  autofocus: !focusConfirm,
                  onPressed: () => _settle(false),
                  child: options?.cancelLabel ?? widget.cancelLabel,
                ),
              PlButton(
                color: color,
                size: size,
                autofocus: focusConfirm,
                onPressed: () => _settle(true),
                child:
                    options?.confirmLabel ??
                    (isAlert ? widget.acknowledgeLabel : widget.confirmLabel),
              ),
            ],
            child: options?.child,
          ),
        ],
      ),
    );
  }
}
