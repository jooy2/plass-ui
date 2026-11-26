import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import 'package:plass_ui_example/canvas.dart';
import 'package:plass_ui_example/room.dart';

/// How wide the frame is. Only its height follows the preview.
const double _width = 600;

/// The height the page gives a frame before the preview has asked for any.
const double _reserve = 240;

/// One preview, hosted the way the documentation page hosts it: the demo on the
/// canvas, in a frame the page makes as tall as the preview last asked for.
class _Preview {
  _Preview(this.tester);

  final WidgetTester tester;
  final GlobalKey _content = GlobalKey();
  final ValueNotifier<double> _lead = ValueNotifier<double>(0);
  late BuildContext _context;

  /// Puts [demo] in a frame of the height the page reserves.
  Future<void> pump(Widget demo) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(_width, _reserve);
    addTearDown(tester.view.reset);
    addTearDown(_lead.dispose);

    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF3F63F2),
        builder: (BuildContext context, Widget? child) {
          return PlassTheme(
            brightness: Brightness.light,
            child: Overlay.wrap(
              child: Builder(
                builder: (BuildContext context) {
                  _context = context;

                  return ValueListenableBuilder<double>(
                    valueListenable: _lead,
                    builder: (BuildContext context, double lead, Widget? child) {
                      return PlassCanvas(lead: lead, child: child!);
                    },
                    child: KeyedSubtree(key: _content, child: demo),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// The frame the preview settles in once the page has followed what it asked
  /// for, or `null` if it was still asking for another after eight rounds.
  Future<PreviewRoom?> settle() async {
    PreviewRoom room = PreviewRoom.none;

    for (int round = 0; round < 8; round += 1) {
      final PreviewRoom? next = measureRoom(
        context: _context,
        content: _content,
        lead: _lead.value,
        padding: PlassCanvas.padding,
      );

      if (next == null) {
        return null;
      }

      if (next.matches(room)) {
        return next;
      }

      room = next;
      _lead.value = next.lead;
      tester.view.physicalSize = Size(_width, next.height);
      await tester.pump();
    }

    return null;
  }
}

/// Where the text of the only field is.
Offset _text(WidgetTester tester) {
  return tester.getTopLeft(find.byType(EditableText)) + const Offset(12, 8);
}

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController(text: 'acme-inc'));
  tearDown(() => controller.dispose());

  testWidgets('keeps the frame of a field whose text is selected with a mouse', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    final _Preview preview = _Preview(tester);

    await preview.pump(PlTextField(controller: controller));

    final PreviewRoom? idle = await preview.settle();

    // A press puts a caret down, which is a selection as well. The frame used
    // to grow without end from here on.
    await tester.tapAt(_text(tester), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    expect(controller.selection.isCollapsed, isTrue);
    expect(await preview.settle(), _sameAs(idle));

    // Two take a word.
    await tester.tapAt(_text(tester), kind: PointerDeviceKind.mouse);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(_text(tester), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    expect(controller.selection.isCollapsed, isFalse);
    expect(await preview.settle(), _sameAs(idle));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('keeps the frame of a field whose text is selected with a finger', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    final _Preview preview = _Preview(tester);

    await preview.pump(PlTextField(controller: controller));

    final PreviewRoom? idle = await preview.settle();

    // On a touch screen the handles are drawn, and the menu comes up with them.
    await tester.longPressAt(_text(tester));
    await tester.pumpAndSettle();

    expect(controller.selection.isCollapsed, isFalse);
    expect(find.text('Copy'), findsOneWidget);
    expect(await preview.settle(), _sameAs(idle));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('still makes room for a popup over a field whose text is selected', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    final _Preview preview = _Preview(tester);

    await preview.pump(
      SizedBox(
        width: 320,
        child: PlCombobox<String>(
          value: null,
          onChanged: (String? value) {},
          fullWidth: true,
          options: const <PlComboboxOption<String>>[
            PlComboboxOption<String>(value: 'mina', label: 'Mina Park'),
            PlComboboxOption<String>(value: 'amara', label: 'Amara Okafor'),
            PlComboboxOption<String>(value: 'leo', label: 'Leo Rossi'),
          ],
        ),
      ),
    );

    final PreviewRoom? idle = await preview.settle();

    await tester.enterText(find.byType(EditableText), 'a');
    await tester.pumpAndSettle();

    expect(find.text('Amara Okafor'), findsOneWidget);

    final PreviewRoom? open = await preview.settle();

    expect(open, isNotNull);
    expect(open!.height, greaterThan(idle!.height));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    final TextSelection selection = tester
        .widget<EditableText>(find.byType(EditableText))
        .controller
        .selection;

    expect(selection.isCollapsed, isFalse);
    expect(find.text('Amara Okafor'), findsOneWidget);
    expect(await preview.settle(), _sameAs(open));
    debugDefaultTargetPlatformOverride = null;
  });
}

/// A frame that settled, and settled on the same room as [expected].
Matcher _sameAs(PreviewRoom? expected) {
  return isA<PreviewRoom>().having(
    (PreviewRoom room) => expected != null && room.matches(expected),
    'matches $expected',
    isTrue,
  );
}
