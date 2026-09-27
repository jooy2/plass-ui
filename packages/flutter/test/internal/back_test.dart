import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/anchored.dart';
import 'package:plass_ui/src/internal/portal.dart';

import '../support/host.dart';

/// An app with a navigator over a page that says `Home`, which is the tree a
/// system back is answered in.
Widget _app(GlobalKey<NavigatorState> navigator, {Widget home = const Text('Home')}) {
  return WidgetsApp(
    navigatorKey: navigator,
    color: const Color(0xFF000000),
    pageRouteBuilder: _page,
    home: home,
  );
}

/// A route that shows what [builder] builds as a page of its own.
PageRoute<T> _page<T>(RouteSettings settings, WidgetBuilder builder) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (BuildContext context, Animation<double> _, Animation<double> _) {
      return builder(context);
    },
  );
}

/// Pushes a page that says `Second` over [holding], and waits for it to arrive.
Future<void> _push(
  WidgetTester tester,
  GlobalKey<NavigatorState> navigator,
  Widget holding, {
  String name = 'Second',
}) async {
  unawaited(
    navigator.currentState!.push(
      _page<void>(
        RouteSettings(name: name),
        (BuildContext context) =>
            Column(mainAxisSize: MainAxisSize.min, children: <Widget>[Text(name), holding]),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The system back, sent the way the engine sends it: Android's back button
/// and TalkBack's back as the activity's, VoiceOver's escape scrub as the view
/// controller's. It is the message the SDK's own tests send.
Future<void> _back(WidgetTester tester) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    const JSONMessageCodec().encodeMessage(<String, Object?>{'method': 'popRoute'}),
    (ByteData? _) {},
  );
  await tester.pumpAndSettle();
}

/// A modal whose `open` is [open], which writes what it is asked to become into
/// [asked] and then becomes it, as a caller's `setState` would.
Widget _modal(
  ValueNotifier<bool> open,
  List<bool> asked, {
  String title = 'Settings',
  bool dismissible = true,
  bool modal = true,
  Widget? child,
}) {
  return ValueListenableBuilder<bool>(
    valueListenable: open,
    builder: (BuildContext context, bool value, Widget? _) {
      return PlModal(
        open: value,
        dismissible: dismissible,
        modal: modal,
        onOpenChanged: (bool next) {
          asked.add(next);
          open.value = next;
        },
        title: Text(title),
        child: child,
      );
    },
  );
}

/// A popover whose `open` is [open], wired as [_modal] is.
Widget _popover(ValueNotifier<bool> open, List<bool> asked, {bool dismissible = true}) {
  return ValueListenableBuilder<bool>(
    valueListenable: open,
    builder: (BuildContext context, bool value, Widget? _) {
      return PlPopover(
        open: value,
        dismissible: dismissible,
        onOpenChanged: (bool next) {
          asked.add(next);
          open.value = next;
        },
        title: const Text('Explain'),
        trigger: const Text('Why?'),
      );
    },
  );
}

/// Every method the app sent the platform, by name, from here on.
List<String> _platformCalls(WidgetTester tester) {
  final List<String> calls = <String>[];

  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
    MethodCall call,
  ) async {
    calls.add(
      call.method == 'SystemNavigator.setFrameworkHandlesBack'
          ? '${call.method}(${call.arguments})'
          : call.method,
    );

    return null;
  });
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );

  return calls;
}

void main() {
  late GlobalKey<NavigatorState> navigator;

  setUp(() => navigator = GlobalKey<NavigatorState>());

  group('the system back', () {
    testWidgets('closes an open modal and leaves the page under it', (WidgetTester tester) async {
      final ValueNotifier<bool> open = ValueNotifier<bool>(true);
      final List<bool> asked = <bool>[];
      addTearDown(open.dispose);

      await tester.pumpWidget(_app(navigator));
      await _push(tester, navigator, _modal(open, asked));

      expect(find.text('Settings'), findsOneWidget);

      await _back(tester);

      expect(asked, <bool>[false], reason: 'the modal is asked to close');
      expect(find.text('Settings'), findsNothing);
      expect(find.text('Second'), findsOneWidget, reason: 'the page stays');

      await _back(tester);

      expect(find.text('Second'), findsNothing, reason: 'with the modal gone, the page goes');
      expect(find.text('Home'), findsOneWidget);
      expect(asked, <bool>[false]);
    });

    testWidgets('is refused by a modal layer that cannot be dismissed', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<bool> open = ValueNotifier<bool>(true);
      final List<bool> asked = <bool>[];
      addTearDown(open.dispose);

      await tester.pumpWidget(_app(navigator));
      await _push(
        tester,
        navigator,
        ValueListenableBuilder<bool>(
          valueListenable: open,
          builder: (BuildContext context, bool value, Widget? _) {
            return PlOverlay(
              open: value,
              onOpenChanged: asked.add,
              child: const Text('Saving your work'),
            );
          },
        ),
      );

      await _back(tester);

      expect(find.text('Saving your work'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget, reason: 'the page under it is not reached');
      expect(asked, isEmpty);

      open.value = false;
      await tester.pumpAndSettle();
      await _back(tester);

      expect(find.text('Second'), findsNothing, reason: 'closed, the page is popped again');
    });

    testWidgets('closes stacked modals one at a time', (WidgetTester tester) async {
      final ValueNotifier<bool> outer = ValueNotifier<bool>(true);
      final ValueNotifier<bool> inner = ValueNotifier<bool>(true);
      final List<bool> outerAsked = <bool>[];
      final List<bool> innerAsked = <bool>[];
      addTearDown(outer.dispose);
      addTearDown(inner.dispose);

      await tester.pumpWidget(_app(navigator));
      await _push(
        tester,
        navigator,
        _modal(outer, outerAsked, child: _modal(inner, innerAsked, title: 'Confirm')),
      );

      expect(find.text('Confirm'), findsOneWidget);

      await _back(tester);

      expect(innerAsked, <bool>[false], reason: 'the modal on top closes');
      expect(outerAsked, isEmpty, reason: 'and the one under it stays');
      expect(find.text('Settings'), findsOneWidget);

      await _back(tester);

      expect(outerAsked, <bool>[false]);
      expect(find.text('Second'), findsOneWidget);

      await _back(tester);

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('closes a popover and leaves the modal it was opened in up', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<bool> modal = ValueNotifier<bool>(true);
      final ValueNotifier<bool> popover = ValueNotifier<bool>(true);
      final List<bool> modalAsked = <bool>[];
      final List<bool> popoverAsked = <bool>[];
      addTearDown(modal.dispose);
      addTearDown(popover.dispose);

      await tester.pumpWidget(_app(navigator));
      await _push(
        tester,
        navigator,
        _modal(modal, modalAsked, child: _popover(popover, popoverAsked)),
      );

      expect(find.text('Explain'), findsOneWidget);

      await _back(tester);

      expect(popoverAsked, <bool>[false]);
      expect(modalAsked, isEmpty);
      expect(find.text('Explain'), findsNothing);
      expect(find.text('Settings'), findsOneWidget);

      await _back(tester);

      expect(modalAsked, <bool>[false]);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('passes a popup that is not a barrier', (WidgetTester tester) async {
      final List<String> escaped = <String>[];

      await tester.pumpWidget(_app(navigator));
      await _push(
        tester,
        navigator,
        PlassAnchoredPortal(
          open: true,
          // A tooltip's wiring: Escape closes it, a press outside does not.
          onEscape: () => escaped.add('tooltip'),
          popup: const Text('Copy'),
          child: const Text('Trigger'),
        ),
      );

      expect(find.text('Copy'), findsOneWidget);

      await _back(tester);

      expect(escaped, isEmpty);
      expect(find.text('Second'), findsNothing, reason: 'the page is popped');
    });

    testWidgets('passes a popover that cannot be dismissed', (WidgetTester tester) async {
      final ValueNotifier<bool> open = ValueNotifier<bool>(true);
      final List<bool> asked = <bool>[];
      addTearDown(open.dispose);

      await tester.pumpWidget(_app(navigator));
      await _push(tester, navigator, _popover(open, asked, dismissible: false));

      await _back(tester);

      expect(asked, isEmpty);
      expect(find.text('Second'), findsNothing, reason: 'the page it leaves in use is popped');
    });

    testWidgets('closes a layer that leaves the page in use only when it can be dismissed', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<bool> open = ValueNotifier<bool>(true);
      final List<bool> asked = <bool>[];
      addTearDown(open.dispose);

      await tester.pumpWidget(_app(navigator));
      await _push(tester, navigator, _modal(open, asked, modal: false));

      await _back(tester);

      expect(asked, <bool>[false], reason: 'a dismissible layer closes');
      expect(find.text('Second'), findsOneWidget);

      await _back(tester);
      open.value = true;
      await _push(tester, navigator, _modal(open, asked, modal: false, dismissible: false));

      await _back(tester);

      expect(asked, <bool>[false], reason: 'one that cannot be dismissed is not asked');
      expect(find.text('Second'), findsNothing, reason: 'and the back goes on to the page');
    });

    testWidgets('is not answered by a layer on a page another page covers', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<bool> under = ValueNotifier<bool>(false);
      final ValueNotifier<bool> over = ValueNotifier<bool>(true);
      final List<bool> underAsked = <bool>[];
      final List<bool> overAsked = <bool>[];
      addTearDown(under.dispose);
      addTearDown(over.dispose);

      await tester.pumpWidget(_app(navigator));
      await _push(tester, navigator, _modal(under, underAsked, title: 'Under'));
      await _push(tester, navigator, _modal(over, overAsked, title: 'Over'), name: 'Third');

      // Opened after the layer on the page on top, on the page it covers.
      under.value = true;
      await tester.pumpAndSettle();

      await _back(tester);

      expect(overAsked, <bool>[false], reason: 'the layer on the page on top closes');
      expect(underAsked, isEmpty);
      expect(find.text('Third'), findsOneWidget);

      await _back(tester);

      expect(find.text('Third'), findsNothing, reason: 'the page on top is popped');
      expect(underAsked, isEmpty);

      await _back(tester);

      expect(underAsked, <bool>[false], reason: 'uncovered, its layer is on top');
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('does not leave the app from the first page while a layer is open', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<bool> open = ValueNotifier<bool>(true);
      final List<bool> asked = <bool>[];
      addTearDown(open.dispose);

      final List<String> calls = _platformCalls(tester);
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StringCodec().encodeMessage(AppLifecycleState.resumed.toString()),
        (ByteData? _) {},
      );

      await tester.pumpWidget(_app(navigator, home: _modal(open, asked)));
      await tester.pumpAndSettle();

      // Android's predictive back is told the app answers the back itself, so
      // the back reaches the app rather than closing it.
      expect(calls.last, 'SystemNavigator.setFrameworkHandlesBack(true)');

      await _back(tester);

      expect(asked, <bool>[false]);
      expect(calls, isNot(contains('SystemNavigator.pop')));
      expect(calls.last, 'SystemNavigator.setFrameworkHandlesBack(false)');

      await _back(tester);

      expect(calls.last, 'SystemNavigator.pop', reason: 'closed, the back leaves the app');
    });

    testWidgets('is nothing to a layer with no navigator above it', (WidgetTester tester) async {
      final List<String> calls = _platformCalls(tester);

      await tester.pumpWidget(
        host(PlassPortal(open: true, onDismiss: () {}, child: const Text('Layer')), overlay: true),
      );
      await tester.pumpAndSettle();

      await _back(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Layer'), findsOneWidget);
      expect(calls, contains('SystemNavigator.pop'), reason: 'there was nothing to pop');
    });
  });
}
