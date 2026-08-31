/// A message that arrives on its own and leaves on its own.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/dismiss.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The room the stack keeps from the edge of the screen.
const double _stackInset = 16;

/// The gap between two toasts.
const double _stackGap = 8;

/// How wide a toast is allowed to get.
const double _defaultWidth = 380;

/// How long a toast lasts before it takes itself away.
const Duration _defaultTimeout = Duration(seconds: 5);

/// How many are on screen at once.
const int _defaultLimit = 3;

/// How large the × is drawn against the line it sits on.
const double _closeScale = 1.15;

/// Where the stack sits.
///
/// Written as one word rather than as a side and an alignment, because the two
/// are not independent: a toast stack is always pinned to the top or the bottom,
/// never to a side, and offering `left` as a *side* would invite a stack down
/// the middle of the screen that nothing in the layout survives.
enum PlToastPosition {
  /// Pinned to the top, at the leading edge.
  topStart,

  /// Pinned to the top, in the middle.
  topCenter,

  /// Pinned to the top, at the trailing edge.
  topEnd,

  /// Pinned to the bottom, at the leading edge.
  bottomStart,

  /// Pinned to the bottom, in the middle.
  bottomCenter,

  /// Pinned to the bottom, at the trailing edge.
  bottomEnd,
}

/// How loudly a toast is announced.
enum PlToastPriority {
  /// Waits for a pause. A save confirmation is not worth interrupting for.
  low,

  /// Interrupts. An error is.
  high,
}

/// One message.
///
/// A description rather than a widget, and for a sharper reason than usual: the
/// thing a caller has at the moment a toast is warranted is a callback, not a
/// place in the tree. A widget with an `open` flag would be a piece of state per
/// message, kept mounted forever, which is the shape this exists to avoid.
@immutable
class PlToast {
  /// Creates a message.
  const PlToast({
    this.id,
    this.title,
    this.description,
    this.timeout,
    this.priority = PlToastPriority.low,
    this.actionLabel,
    this.onAction,
    this.onClose,
    this.color,
    this.variant,
    this.icon,
    this.showIcon = true,
  });

  /// Names the toast.
  ///
  /// Showing a message with an id already on screen **updates that toast in
  /// place** and restarts its clock, which is what "uploading… / uploaded"
  /// wants: one toast that changed its mind, not two stacked on each other.
  final String? id;

  /// The headline.
  final Widget? title;

  /// The detail under it. A toast with only this is a one-line toast.
  final Widget? description;

  /// How long before it takes itself away.
  ///
  /// [Duration.zero] keeps it up until it is closed — which is the right answer
  /// for anything the reader has to act on, because a toast that leaves before
  /// it is read said nothing. Left out, the provider's own timeout is used.
  final Duration? timeout;

  /// How loudly it is announced.
  final PlToastPriority priority;

  /// The label of the action button. Passing it is what makes the button appear.
  final Widget? actionLabel;

  /// Called when that button is pressed.
  final VoidCallback? onAction;

  /// Called when the toast closes, however it closed.
  final VoidCallback? onClose;

  /// Semantic colour role. The provider's if it is left out.
  final PlassColor? color;

  /// What the toast is made of. The provider's if it is left out.
  final PlassVariant? variant;

  /// The glyph before the message. The severity's own mark if it is left out.
  final Widget? icon;

  /// Draws a glyph at all.
  final bool showIcon;

  /// The same message with [id] filled in, which is what the stack stores.
  PlToast _named(String name) {
    return PlToast(
      id: name,
      title: title,
      description: description,
      timeout: timeout,
      priority: priority,
      actionLabel: actionLabel,
      onAction: onAction,
      onClose: onClose,
      color: color,
      variant: variant,
      icon: icon,
      showIcon: showIcon,
    );
  }
}

/// Raises toasts from anywhere under a [PlToastProvider].
abstract class PlToastController {
  /// Raises a toast and hands back its id.
  String show(PlToast toast);

  /// Changes a toast already on screen, and restarts its clock.
  void update(String id, PlToast toast);

  /// Closes one toast, or every toast when called with nothing.
  void close([String? id]);

  /// One toast that follows a future: the loading message while it runs, then
  /// the success or the failure.
  ///
  /// The loading state is held open — a slow request cannot dismiss its own
  /// toast — and the same toast becomes the answer, so a reader who watched it
  /// start sees it finish rather than seeing a second one appear beside it.
  Future<T> showFuture<T>(
    Future<T> future, {
    required PlToast loading,
    required PlToast Function(T value) success,
    required PlToast Function(Object error) failure,
  });
}

/// Puts the toast stack on the screen and lets anything under it raise a
/// message.
///
/// ```dart
/// PlToastProvider(child: MyApp())
/// ```
///
/// ```dart
/// PlToastProvider.of(context).show(
///   const PlToast(color: PlassColor.success, title: Text('Saved')),
/// );
/// ```
///
/// Wrap the application once. Everything about how a toast *looks* is decided
/// here — where the stack sits, how wide it is, which material it wears, how
/// long it lasts — so the call site stays the one thing it should be: what
/// happened.
///
/// The stack is a layer over whatever the provider wraps, so it needs no
/// [Overlay]: the provider is already above everything it has to cover.
class PlToastProvider extends StatefulWidget {
  /// Creates a provider.
  const PlToastProvider({
    required this.child,
    this.position = PlToastPosition.bottomEnd,
    this.timeout = _defaultTimeout,
    this.limit = _defaultLimit,
    this.width = _defaultWidth,
    this.closeLabel = 'Close',
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    super.key,
  });

  /// The application.
  final Widget child;

  /// Where the stack sits.
  final PlToastPosition position;

  /// How long a toast lasts by default. [Duration.zero] keeps every toast up
  /// until it is closed.
  final Duration timeout;

  /// How many are shown at once. The rest are kept and shown as the stack
  /// drains rather than being thrown away.
  final int limit;

  /// How wide a toast is allowed to get.
  final double width;

  /// The name a screen reader gives every toast's ×. Never drawn.
  final String closeLabel;

  /// What a toast is made of, unless it says otherwise.
  final PlassVariant variant;

  /// Type scale, radius and padding.
  final PlassSize? size;

  /// The default colour family. A single toast overrides it.
  final PlassColor? color;

  /// How tightly a toast packs.
  final PlassDensity? density;

  /// The controller for the nearest provider above [context].
  static PlToastController of(BuildContext context) {
    final controller = maybeOf(context);

    assert(controller != null, 'No PlToastProvider found above this context.');

    return controller!;
  }

  /// The same, without the assertion.
  static PlToastController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_PlToastScope>()?.controller;
  }

  @override
  State<PlToastProvider> createState() => _PlToastProviderState();
}

class _PlToastScope extends InheritedWidget {
  const _PlToastScope({required this.controller, required super.child});

  final PlToastController controller;

  @override
  bool updateShouldNotify(_PlToastScope oldWidget) => controller != oldWidget.controller;
}

/// One toast on the stack, and the two things it owns: its fade and its clock.
class _Entry {
  _Entry({required this.toast, required this.fade});

  PlToast toast;
  final AnimationController fade;
  Timer? timer;

  void cancel() {
    timer?.cancel();
    timer = null;
  }
}

class _PlToastProviderState extends State<PlToastProvider>
    with TickerProviderStateMixin
    implements PlToastController {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  final List<_Entry> _entries = <_Entry>[];
  int _sequence = 0;

  /// Whether the pointer is resting on the stack, which is a reader reading it.
  bool _hovered = false;

  @override
  void dispose() {
    for (final entry in _entries) {
      entry
        ..cancel()
        ..fade.dispose();
    }

    _entries.clear();
    super.dispose();
  }

  @override
  String show(PlToast toast) {
    final id = toast.id ?? 'plass-toast-${_sequence++}';
    final existing = _find(id);

    if (existing != null) {
      _replace(existing, toast._named(id));

      return id;
    }

    final entry = _Entry(
      toast: toast._named(id),
      fade: AnimationController(vsync: this, duration: PlassTokens.duration),
    );

    setState(() => _entries.add(entry));
    entry.fade.forward();
    _rewind();

    return id;
  }

  @override
  void update(String id, PlToast toast) {
    final entry = _find(id);

    if (entry != null) {
      _replace(entry, toast._named(id));
    }
  }

  @override
  void close([String? id]) {
    for (final entry in <_Entry>[..._entries]) {
      if (id == null || entry.toast.id == id) {
        _dismiss(entry);
      }
    }
  }

  @override
  Future<T> showFuture<T>(
    Future<T> future, {
    required PlToast loading,
    required PlToast Function(T value) success,
    required PlToast Function(Object error) failure,
  }) async {
    // The loading toast is held open whatever it asked for: a request slower
    // than the timeout would otherwise dismiss the message saying it is running.
    final id = show(loading._named(loading.id ?? 'plass-toast-${_sequence++}'));
    final entry = _find(id);

    entry?.cancel();

    try {
      final value = await future;

      update(id, success(value));

      return value;
    } catch (error) {
      update(id, failure(error));
      rethrow;
    }
  }

  _Entry? _find(String id) {
    for (final entry in _entries) {
      if (entry.toast.id == id) {
        return entry;
      }
    }

    return null;
  }

  void _replace(_Entry entry, PlToast toast) {
    setState(() => entry.toast = toast);
    entry.cancel();
    _rewind();
  }

  /// Gives every toast that is actually on screen a clock, and takes it from the
  /// ones that are not.
  ///
  /// A toast waiting behind the limit is not being read, so its life has not
  /// started; a toast under the pointer *is* being read, so its life is paused.
  void _rewind() {
    for (var index = 0; index < _entries.length; index += 1) {
      final entry = _entries[index];
      final timeout = entry.toast.timeout ?? widget.timeout;
      final visible = index < widget.limit;

      if (!visible || _hovered || timeout == Duration.zero) {
        entry.cancel();

        continue;
      }

      entry.timer ??= Timer(timeout, () => _dismiss(entry));
    }
  }

  void _dismiss(_Entry entry) {
    entry.cancel();
    entry.toast.onClose?.call();
    entry.fade.reverse().whenComplete(() {
      if (!mounted) {
        return;
      }

      setState(() => _entries.remove(entry));
      entry.fade.dispose();
      _rewind();
    });
  }

  void _hover({required bool over}) {
    if (_hovered == over) {
      return;
    }

    _hovered = over;
    _rewind();
  }

  bool get _atTop =>
      widget.position == PlToastPosition.topStart ||
      widget.position == PlToastPosition.topCenter ||
      widget.position == PlToastPosition.topEnd;

  CrossAxisAlignment get _across {
    return switch (widget.position) {
      PlToastPosition.topStart || PlToastPosition.bottomStart => CrossAxisAlignment.start,
      PlToastPosition.topCenter || PlToastPosition.bottomCenter => CrossAxisAlignment.center,
      PlToastPosition.topEnd || PlToastPosition.bottomEnd => CrossAxisAlignment.end,
    };
  }

  AlignmentGeometry get _alignment {
    return switch (widget.position) {
      PlToastPosition.topStart => AlignmentDirectional.topStart,
      PlToastPosition.topCenter => AlignmentDirectional.topCenter,
      PlToastPosition.topEnd => AlignmentDirectional.topEnd,
      PlToastPosition.bottomStart => AlignmentDirectional.bottomStart,
      PlToastPosition.bottomCenter => AlignmentDirectional.bottomCenter,
      PlToastPosition.bottomEnd => AlignmentDirectional.bottomEnd,
    };
  }

  @override
  Widget build(BuildContext context) {
    final visible = _entries.take(widget.limit).toList();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    for (final entry in _entries) {
      entry.fade.duration = reduceMotion ? Duration.zero : PlassTokens.duration;
    }

    return _PlToastScope(
      controller: this,
      child: Stack(
        children: <Widget>[
          widget.child,
          if (visible.isNotEmpty)
            // The strip is not a wall the rest of the app is behind. Nothing
            // here is told to ignore the pointer, and nothing has to be: an
            // `Align` hit-tests its child and not the room around it, so the
            // page under the empty part of the strip is reached normally.
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(_stackInset),
                child: Align(
                  alignment: _alignment,
                  child: MouseRegion(
                    opaque: false,
                    onEnter: (_) => _hover(over: true),
                    onExit: (_) => _hover(over: false),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: _across,
                      spacing: _stackGap,
                      children: <Widget>[
                        // Newest nearest the edge the stack is pinned to, so a
                        // message that has just arrived is never the one that
                        // moved.
                        // Newest nearest the edge the stack is pinned to, so a
                        // message that has just arrived is never the one that
                        // moved. The list is oldest-first, so a top stack reads
                        // it backwards and a bottom one does not.
                        for (final entry in _atTop ? visible.reversed : visible)
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: widget.width),
                            child: FadeTransition(
                              opacity: entry.fade,
                              child: _Toast(
                                key: ValueKey<String>(entry.toast.id!),
                                toast: entry.toast,
                                variant: entry.toast.variant ?? widget.variant,
                                color: entry.toast.color ?? _color,
                                size: _size,
                                density: _density,
                                closeLabel: widget.closeLabel,
                                onClose: () => _dismiss(entry),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One toast's surface.
class _Toast extends StatelessWidget {
  const _Toast({
    required this.toast,
    required this.variant,
    required this.color,
    required this.size,
    required this.density,
    required this.closeLabel,
    required this.onClose,
    super.key,
  });

  final PlToast toast;
  final PlassVariant variant;
  final PlassColor color;
  final PlassSize size;
  final PlassDensity density;
  final String closeLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final solid = variant == PlassVariant.solid;
    final body = sheetBody[size]!;
    final ink = solid ? family.onSolid : tokens.fg;
    final accent = solid ? family.onSolid : family.accent;

    // A toast floats over the page, so — with the select's list, the modal's
    // sheet and the tooltip's plate — it carries a shadow. The two undyed
    // materials are the glass at its most opaque, for the reason the modal's
    // sheet is: what is behind a toast is arbitrary, and a 62%-translucent pane
    // over a photograph is a pane you read the photograph through.
    final surface = switch (variant) {
      PlassVariant.solid => PlassSurface(
        gradient: family.fill,
        ink: family.onSolid,
        shadows: <BoxShadow>[...tokens.elevation(plassElevationMax), tokens.lift(family)],
      ),
      PlassVariant.glass => PlassSurface(
        fill: tokens.glassPress,
        border: Border.all(color: family.line, width: hairline),
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: tokens.elevation(plassElevationMax),
      ),
      PlassVariant.ghost => PlassSurface(
        fill: tokens.glassPress,
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: tokens.elevation(plassElevationMax),
      ),
    };

    final glyph =
        toast.icon ??
        (toast.showIcon
            ? PlassGlyph(severityGlyph(color), size: body.size * iconScale, color: accent)
            : null);

    /// A box one line high, so an adornment sits on the *first* line of a
    /// three-line message rather than in the middle of the whole box.
    Widget line(Widget slot) => SizedBox(
      height: body.line,
      child: Center(child: slot),
    );

    return Semantics(
      container: true,
      liveRegion: toast.priority == PlToastPriority.high,
      child: PlassSurfaceBox(
        surface: surface,
        borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sheetPaddingX[density]![size]!,
            vertical: sheetPaddingY[density]![size]!,
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: ink,
              fontSize: body.size,
              height: body.height,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: sheetSectionGap[size]!,
              children: <Widget>[
                if (glyph != null) line(glyph),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: sheetHeaderGap[size]!,
                    children: <Widget>[
                      if (toast.title != null)
                        DefaultTextStyle.merge(
                          style: TextStyle(
                            color: accent,
                            fontSize: sheetTitle[size]!.size,
                            height: sheetTitle[size]!.height,
                            fontWeight: FontWeight.w600,
                          ),
                          child: toast.title!,
                        ),
                      if (toast.description != null)
                        DefaultTextStyle.merge(
                          // Muted only under a title: a one-line toast *is* the
                          // message, and a message written in the quiet ink is a
                          // message that looks like a footnote.
                          style: TextStyle(
                            color: toast.title != null && !solid ? tokens.mutedFg : ink,
                          ),
                          child: toast.description!,
                        ),
                    ],
                  ),
                ),
                if (toast.actionLabel != null)
                  line(
                    PlassInteractive(
                      onTap: () {
                        toast.onAction?.call();
                        onClose();
                      },
                      builder: (BuildContext context, PlassInteraction state) {
                        return Semantics(
                          container: true,
                          button: true,
                          child: DefaultTextStyle.merge(
                            style: TextStyle(
                              color: accent,
                              fontSize: metaText[size]!,
                              fontWeight: FontWeight.w500,
                              decoration: state.hovered ? TextDecoration.underline : null,
                            ),
                            child: toast.actionLabel!,
                          ),
                        );
                      },
                    ),
                  ),
                line(
                  PlassDismissButton(
                    label: closeLabel,
                    onPressed: onClose,
                    size: body.size * _closeScale,
                    color: ink,
                    ring: solid ? family.onSolid : family.ring,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
