/// A message that arrives on its own and leaves on its own.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/dismiss.dart';
import 'package:plass_ui/src/internal/ease.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/ink.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/target.dart';
import 'package:plass_ui/src/theme/theme.dart';
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

/// How loudly a toast asks to be announced.
///
/// Every toast is announced whichever this is. The two differ in the React build,
/// where they are a polite and an assertive live region; Flutter's live region
/// has one politeness, so here both are read when the reader pauses.
enum PlToastPriority {
  /// Waits for a pause. A save confirmation is not worth interrupting for.
  low,

  /// Interrupts where the platform can. An error is worth it.
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

  /// How loudly it asks to be announced. It is announced either way.
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
  PlToast _named(String name, {Duration? timeout}) {
    return PlToast(
      id: name,
      title: title,
      description: description,
      timeout: timeout ?? this.timeout,
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
/// WidgetsApp(
///   // …
///   builder: (BuildContext context, Widget? child) => PlToastProvider(child: child!),
/// )
/// ```
///
/// ```dart
/// PlToastProvider.of(context).show(
///   const PlToast(color: PlassColor.success, title: Text('Saved')),
/// );
/// ```
///
/// One of these, once, and it goes **inside** the application rather than
/// around it, because above a `WidgetsApp` or a `MaterialApp` there is no
/// `Directionality` yet. Everything about how a toast *looks* is decided here —
/// where the stack sits, how wide it is, which material it wears, how long it
/// lasts — so the call site stays the one thing it should be: what happened.
///
/// The stack is a layer over whatever the provider wraps, so it needs no
/// [Overlay] of its own: the provider is already above everything it has to
/// cover, and `builder` is therefore all it asks for.
class PlToastProvider extends StatefulWidget {
  /// Creates a provider.
  const PlToastProvider({
    required this.child,
    this.position = PlToastPosition.bottomEnd,
    this.timeout = _defaultTimeout,
    this.limit = _defaultLimit,
    this.width = _defaultWidth,
    this.closeLabel,
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
  final String? closeLabel;

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
  _Entry({required this.toast, required this.fade})
    : opacity = CurvedAnimation(parent: fade, curve: Curves.linear);

  PlToast toast;
  final AnimationController fade;

  /// The fade as it is drawn, on the theme's curve. A stand-in curve here: the
  /// stack's build hands it the theme's with the duration, and again whenever
  /// the theme changes.
  final CurvedAnimation opacity;

  Timer? timer;

  /// Fading out: off the clock, and not to be dismissed a second time.
  bool closing = false;

  void cancel() {
    timer?.cancel();
    timer = null;
  }

  /// Lets go of the fade, the curve before the controller it listens to.
  void dispose() {
    opacity.dispose();
    fade.dispose();
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

  /// The group the stack's toasts read the backdrop in, which is theirs alone,
  /// for the reason `PlassPortal` gives: the stack is painted over the app, and
  /// a key it shared with a sheet in the app, through a `BackdropGroup` round
  /// this provider, would hand a toast the backdrop as it was when that sheet
  /// was drawn.
  final BackdropKey _layer = BackdropKey();

  /// Whether the pointer is resting on the stack, which is a reader reading it.
  bool _hovered = false;

  /// Whether the keyboard focus is on something inside the stack, such as a
  /// toast's action, which is a reader about to use it.
  bool _focused = false;

  /// The fingers, pens and buttons pressed on the stack. A finger resting on a
  /// toast is the touch screen's hover.
  final Set<int> _pressed = <int>{};

  /// Whether the app is anywhere but in front of the reader: in the background,
  /// behind a system sheet, or in a browser tab or window that lost the focus.
  bool _away = false;

  late final AppLifecycleListener _lifecycle;

  /// Whether anything says the stack is being read, or cannot be.
  bool get _held => _hovered || _focused || _pressed.isNotEmpty || _away;

  @override
  void initState() {
    super.initState();

    final AppLifecycleState? state = WidgetsBinding.instance.lifecycleState;
    _away = state != null && state != AppLifecycleState.resumed;
    _lifecycle = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        _hold(away: state != AppLifecycleState.resumed);
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();

    for (final entry in _entries) {
      entry
        ..cancel()
        ..dispose();
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

    // The duration `build` gives every fade, set here as well because this
    // one starts before the next build: a fade that started over the theme's
    // duration keeps it, and under less movement the toast has to arrive at
    // once.
    final entry = _Entry(
      toast: toast._named(id),
      fade: AnimationController(
        vsync: this,
        duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
            ? Duration.zero
            : PlassTheme.of(context).motionDuration,
      ),
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
    // than the timeout would otherwise dismiss the message saying it is running,
    // and the answer would have nothing left to replace. Stored with no timeout
    // rather than with its clock stopped once, because the clocks are started
    // again whenever another toast arrives or the pointer leaves the stack.
    final id = show(
      loading._named(loading.id ?? 'plass-toast-${_sequence++}', timeout: Duration.zero),
    );

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
  /// started; a toast under the pointer, a finger or the keyboard focus *is*
  /// being read, so its life is paused, and so is every toast of an app the
  /// reader has left.
  void _rewind() {
    for (var index = 0; index < _entries.length; index += 1) {
      final entry = _entries[index];
      final timeout = entry.toast.timeout ?? widget.timeout;
      final visible = index < widget.limit;

      if (entry.closing || !visible || _held || timeout == Duration.zero) {
        entry.cancel();

        continue;
      }

      entry.timer ??= Timer(timeout, () => _dismiss(entry));
    }
  }

  void _dismiss(_Entry entry) {
    // A toast already on its way out is left to go. A second dismissal would
    // report the close again and reverse a fade that may already be disposed.
    if (entry.closing) {
      return;
    }

    entry
      ..closing = true
      ..cancel();
    entry.toast.onClose?.call();
    entry.fade.reverse().whenComplete(() {
      if (!mounted) {
        return;
      }

      setState(() => _entries.remove(entry));
      entry.dispose();

      // The last toast takes the stack out of the tree, and neither a mouse
      // region nor a focus node reports leaving on its way out. What held the
      // clocks goes with it, or the next toast would arrive already paused.
      if (_entries.isEmpty) {
        _hovered = false;
        _focused = false;
        _pressed.clear();
      }

      _rewind();
    });
  }

  /// Records one of the things that stop the clocks, and hands the clocks back
  /// when the last of them has gone.
  void _hold({bool? over, bool? focused, bool? away}) {
    final bool held = _held;

    _hovered = over ?? _hovered;
    _focused = focused ?? _focused;
    _away = away ?? _away;

    if (held != _held) {
      _rewind();
    }
  }

  void _press(PointerEvent event) {
    final bool held = _held;

    _pressed.add(event.pointer);

    if (held != _held) {
      _rewind();
    }
  }

  void _release(PointerEvent event) {
    final bool held = _held;

    _pressed.remove(event.pointer);

    if (held != _held) {
      _rewind();
    }
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
    final tokens = PlassTheme.of(context);
    final fade = reduceMotion ? Duration.zero : tokens.motionDuration;

    for (final entry in _entries) {
      entry.fade.duration = fade;
      easeBothWays(entry.opacity, tokens.motionEase);
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
              // Clear of the system's bars, the notch and a soft keyboard, so a
              // top stack is not under the status bar and a bottom one is not
              // under the home indicator.
              child: BackdropGroup(
                backdropKey: _layer,
                child: Padding(
                  padding:
                      const EdgeInsets.all(_stackInset) +
                      MediaQuery.paddingOf(context) +
                      EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
                  child: Align(
                    alignment: _alignment,
                    child: MouseRegion(
                      opaque: false,
                      onEnter: (_) => _hold(over: true),
                      onExit: (_) => _hold(over: false),
                      child: Listener(
                        onPointerDown: _press,
                        onPointerUp: _release,
                        onPointerCancel: _release,
                        child: Focus(
                          canRequestFocus: false,
                          skipTraversal: true,
                          includeSemantics: false,
                          onFocusChange: (bool focused) => _hold(focused: focused),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: _across,
                            spacing: _stackGap,
                            children: <Widget>[
                              // Newest nearest the edge the stack is pinned to, so a
                              // message that has just arrived is never the one that
                              // moved. The list is oldest-first, so a top stack reads
                              // it backwards and a bottom one does not.
                              //
                              // Keyed here, on the column's own child, rather than
                              // further in: the column matches unkeyed children by
                              // position, so a leaving toast's place would go to the
                              // one after it, which would then be built again.
                              for (final entry in _atTop ? visible.reversed : visible)
                                ConstrainedBox(
                                  key: ValueKey<String>(entry.toast.id!),
                                  constraints: BoxConstraints(maxWidth: widget.width),
                                  child: FadeTransition(
                                    opacity: entry.opacity,
                                    child: _Toast(
                                      toast: entry.toast,
                                      variant: entry.toast.variant ?? widget.variant,
                                      color: entry.toast.color ?? _color,
                                      size: _size,
                                      density: _density,
                                      closeLabel:
                                          widget.closeLabel ?? PlassTheme.labelsOf(context).close,
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

    // On `solid` the glyph, the title and the action ride on the toast's own
    // ink, as they do in the React build, where they inherit the toast's
    // `color`: they name no colour of their own and ease with the message when
    // `update` changes the colour. On the other two the accent is their own and
    // changes at once, as the React build's does.
    final accent = solid ? null : family.accent;

    // Muted only under a title: a one-line toast *is* the message, and a
    // message written in the quiet ink is a message that looks like a footnote.
    final detail = toast.title != null && !solid ? tokens.mutedFg : null;

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

    // A glyph a caller hands the toast takes the same colour and size as the
    // severity's own mark, as it does in the React build.
    final glyph = toast.icon != null || toast.showIcon
        ? Builder(
            builder: (BuildContext context) => IconTheme.merge(
              data: IconThemeData(
                color: accent ?? DefaultTextStyle.of(context).style.color,
                size: body.size * iconScale,
              ),
              child: toast.icon ?? PlassGlyph(severityGlyph(color)),
            ),
          )
        : null;

    /// A box one line high, so an adornment sits on the *first* line of a
    /// three-line message rather than in the middle of the whole box.
    Widget line(Widget slot) => SizedBox(
      height: body.line,
      child: Center(child: slot),
    );

    // Every toast is a live region, whatever its priority. A toast appears
    // somewhere the reader is not, so without one a "Saved" arrives and leaves
    // unheard. Flutter's live region has no second, assertive level to give a
    // `high` toast — the framework's own documentation calls it polite, and the
    // web engine announces it politely — and the `alert` and `status` roles that
    // would carry the difference are refused on a node that is a live region.
    return Semantics(
      container: true,
      liveRegion: true,
      child: PlassTargetScope(
        child: PlassSurfaceBox(
          surface: surface,
          borderRadius: BorderRadius.circular(tokens.radii[size]!),
          // The message, the × and, on `solid`, the glyph, the title and the
          // action ease to a new ink with the fill, as the React build's
          // `color` does under the house transition. A glyph a caller puts in
          // the title, the message or the action takes the colour of the
          // words around it, and 1.2× their type size, as an `<svg>` drawn in
          // `currentColor` at `1.2em` does in the React toast.
          child: PlassInk(
            color: surface.ink,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sheetPaddingX[density]![size]!,
                vertical: sheetPaddingY[density]![size]!,
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(
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
                              child: IconTheme.merge(
                                data: IconThemeData(
                                  color: accent,
                                  size: sheetTitle[size]!.size * iconScale,
                                ),
                                child: toast.title!,
                              ),
                            ),
                          if (toast.description != null)
                            DefaultTextStyle.merge(
                              style: TextStyle(color: detail),
                              child: IconTheme.merge(
                                data: IconThemeData(color: detail, size: body.size * iconScale),
                                child: toast.description!,
                              ),
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
                                child: IconTheme.merge(
                                  data: IconThemeData(
                                    color: accent,
                                    size: metaText[size]! * iconScale,
                                  ),
                                  child: toast.actionLabel!,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    line(
                      Builder(
                        builder: (BuildContext context) => PlassDismissButton(
                          label: closeLabel,
                          onPressed: onClose,
                          size: body.size * _closeScale,
                          color: DefaultTextStyle.of(context).style.color,
                          ring: solid ? family.onSolid : family.ring,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
