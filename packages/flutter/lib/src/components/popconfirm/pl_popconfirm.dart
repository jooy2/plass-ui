/// A question asked where it was raised.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/button/pl_button.dart';
import 'package:plass_ui/src/components/popover/pl_popover.dart';
import 'package:plass_ui/src/types.dart';

/// A question asked where it was raised, rather than in the middle of the
/// screen.
///
/// The difference from [PlConfirmProvider] is not the words, it is **how much it
/// interrupts**. A modal takes the screen away and is right for the question
/// that deserves that — deleting an account, discarding an hour of work. This is
/// right for the row's own delete button: the question appears against the thing
/// it is about, the rest of the list stays readable, and a reader who changes
/// their mind presses outside and is exactly where they were.
///
/// The rule of thumb is what happens if they answer by accident. If the answer
/// is "they can undo it", this is the one.
///
/// [color] defaults to `danger` here and to `primary` on a [PlButton], and that
/// is not an inconsistency: nobody reaches for a popconfirm to ask whether to
/// save.
///
/// ```dart
/// PlPopconfirm(
///   open: asking,
///   onOpenChanged: (bool next) => setState(() => asking = next),
///   title: const Text('Delete this row?'),
///   confirmLabel: const Text('Delete'),
///   onConfirm: () => remove(row),
///   trigger: PlButton(
///     color: PlassColor.danger,
///     onPressed: () => setState(() => asking = true),
///     child: const Text('Delete'),
///   ),
/// )
/// ```
class PlPopconfirm extends StatefulWidget {
  /// Creates a popconfirm.
  const PlPopconfirm({
    required this.open,
    required this.trigger,
    this.onOpenChanged,
    this.title,
    this.description,
    this.confirmLabel = const Text('Confirm'),
    this.cancelLabel = const Text('Cancel'),
    this.onConfirm,
    this.onCancel,
    this.color = PlassColor.danger,
    this.size = PlassSize.md,
    this.side = PlassSide.top,
    this.align = PlassAlign.center,
    this.width = 280,
    super.key,
  });

  /// Whether the popup is up. Controlled, like everything stateful here.
  final bool open;

  /// What it hangs off.
  final Widget trigger;

  /// Called with what the open state should become.
  final ValueChanged<bool>? onOpenChanged;

  /// The question, as the heading that names the popup.
  final Widget? title;

  /// A line under it. Say what happens.
  final Widget? description;

  /// The word on the button that answers yes.
  final Widget confirmLabel;

  /// The word on the button that answers no.
  final Widget cancelLabel;

  /// What confirming does.
  ///
  /// **A future is waited for**: the button shows its loading state until it
  /// settles, and the popup closes only if it completes, so a failed request
  /// leaves the question on screen instead of pretending.
  ///
  /// An error is caught and goes no further. Keeping the question up is the
  /// whole of what this widget owes a failure; what the failure *means* is the
  /// caller's, and `onConfirm` is where to report it from.
  final FutureOr<void> Function()? onConfirm;

  /// What cancelling does, beyond closing.
  final VoidCallback? onCancel;

  /// The family the confirming button takes.
  final PlassColor color;

  /// The size of the popup and its two buttons.
  final PlassSize size;

  /// Which edge of the trigger it opens against.
  final PlassSide side;

  /// Where it sits along that edge.
  final PlassAlign align;

  /// How wide the sheet may get.
  final double width;

  @override
  State<PlPopconfirm> createState() => _PlPopconfirmState();
}

class _PlPopconfirmState extends State<PlPopconfirm> {
  bool _running = false;

  Future<void> _confirm() async {
    final result = widget.onConfirm?.call();

    if (result is! Future<void>) {
      widget.onOpenChanged?.call(false);

      return;
    }

    setState(() => _running = true);

    try {
      await result;
      widget.onOpenChanged?.call(false);
    } catch (_) {
      // Caught and gone no further, on purpose. What this widget owes a failure
      // is the **question, still on screen** — closing it would be the widget
      // saying the thing happened. What the failure *means* is the caller's.
    } finally {
      // Whether it completed or threw. A button left spinning over a question
      // that failed is worse than the failure.
      if (mounted) {
        setState(() => _running = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlPopover(
      open: widget.open,
      trigger: widget.trigger,
      onOpenChanged: (bool next) {
        // A request in flight is not something a stray press should abandon
        // halfway.
        if (_running) {
          return;
        }

        if (!next) {
          widget.onCancel?.call();
        }

        widget.onOpenChanged?.call(next);
      },
      title: widget.title,
      description: widget.description,
      side: widget.side,
      align: widget.align,
      width: widget.width,
      color: widget.color,
      size: widget.size,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        // A `Wrap` rather than a `Row`: two buttons whose labels have been
        // translated into something longer than "Confirm" and "Cancel" are two
        // buttons that do not fit a 280px sheet, and a `Row` answers that by
        // painting a yellow-and-black overflow bar across the question.
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            PlButton(
              variant: PlassVariant.ghost,
              color: PlassColor.secondary,
              size: widget.size,
              density: PlassDensity.compact,
              disabled: _running,
              onPressed: () {
                widget.onCancel?.call();
                widget.onOpenChanged?.call(false);
              },
              child: widget.cancelLabel,
            ),
            PlButton(
              color: widget.color,
              size: widget.size,
              density: PlassDensity.compact,
              loading: _running,
              // The focus lands here rather than on Cancel, which is the other
              // way round from `PlConfirmProvider` — and deliberately. A
              // popconfirm is opened *by* the button it is asking about, so the
              // reader has already said what they want once.
              autofocus: true,
              onPressed: _confirm,
              child: widget.confirmLabel,
            ),
          ],
        ),
      ),
    );
  }
}
