// That a control keeps what it holds as its focus ring comes and goes.
//
// A ring is a `CustomPaint` round the control, and it has to be in the tree
// whether there is a ring to draw or not. Put in only while the control is
// focused, it moves what the control holds a level down the tree as the focus
// arrives and again as it leaves, and Flutter builds a moved widget again from
// scratch: a stateful slot starts over, an animation starts again from its end,
// and a picture is looked up again. What is checked here is that the element of
// what the control holds is the same object before, during and after the focus,
// and that the ring really is drawn round it while the focus is there.
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/surface.dart';

import '../support/host.dart';

/// A slot with a `State` of its own: built again from scratch, it is a different
/// object.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Text('Probe');
}

/// A control, and what in it has to survive the ring.
class _Case {
  const _Case(this.build, {this.held, this.height, this.settle, this.reach});

  final Widget Function() build;

  /// What has to survive, or `null` for the [_Probe] the control was given.
  final Finder Function()? held;

  /// How tall a box the control is laid out in, for one that fills the
  /// height it is given.
  final double? height;

  /// Anything the control needs done before the keyboard reaches it, such as
  /// a picture decoding.
  final Future<void> Function(WidgetTester tester)? settle;

  /// How the keyboard gets to the part with the ring, for a control whose
  /// first stop draws a ring round the whole of it instead, or `null` to Tab.
  final Future<void> Function(WidgetTester tester)? reach;

  Finder get finder => held == null ? find.byType(_Probe) : held!();
}

/// A painter with a ring to draw.
final Finder _ring = find.byWidgetPredicate(
  (Widget widget) => widget is CustomPaint && widget.foregroundPainter is PlassFocusRingPainter,
);

/// The first widget of [type] inside the control [control] names.
Finder Function() _inside(bool Function(Widget widget) control, Type type) {
  return () =>
      find.descendant(of: find.byWidgetPredicate(control), matching: find.byType(type)).first;
}

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

/// Lets a picture decode, which happens off the fake clock, and waits for the
/// frame that draws it.
Future<void> _decode(WidgetTester tester) async {
  for (int tries = 0; tries < 50; tries += 1) {
    await tester.pump();

    final bool waiting = tester
        .widgetList<RawImage>(find.byType(RawImage))
        .any((RawImage raw) => raw.image == null);

    if (!waiting && find.byType(RawImage).evaluate().isNotEmpty) {
      break;
    }

    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
  }
}

const List<PlassChartSeries> _series = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Revenue',
    data: <PlassChartDatum>[PlassChartDatum(12), PlassChartDatum(19), PlassChartDatum(15)],
  ),
  PlassChartSeries(
    name: 'Cost',
    data: <PlassChartDatum>[PlassChartDatum(8), PlassChartDatum(11), PlassChartDatum(9)],
  ),
];

const List<PlassChartCategory> _months = <PlassChartCategory>[
  PlassChartCategory.text('Jan'),
  PlassChartCategory.text('Feb'),
  PlassChartCategory.text('Mar'),
];

final Map<String, _Case> _cases = <String, _Case>{
  'PlAccordion': _Case(
    () => PlAccordion<String>(
      items: const <PlAccordionItem<String>>[
        PlAccordionItem<String>(value: 'a', title: _Probe(), child: Text('Body')),
      ],
      value: const <String>{},
      onChanged: (Set<String> next) {},
    ),
  ),
  'PlAlert': _Case(
    () => PlAlert(onClose: () {}, child: const Text('Saved.')),
    held: _inside((Widget widget) => widget is PlAlert, AnimatedOpacity),
  ),
  'PlBottomNavigation': _Case(
    () => PlBottomNavigation<String>(
      items: const <PlBottomNavigationItem<String>>[
        PlBottomNavigationItem<String>(value: 'home', label: 'Home', icon: _Probe()),
        PlBottomNavigationItem<String>(value: 'search', label: 'Search', icon: Text('S')),
      ],
      value: 'home',
      onChanged: (String next) {},
    ),
  ),
  'PlBreadcrumb': _Case(
    () => PlBreadcrumb(
      items: <PlBreadcrumbItem>[
        PlBreadcrumbItem(label: const _Probe(), onPressed: () {}),
        const PlBreadcrumbItem(label: Text('Billing'), current: true),
      ],
    ),
  ),
  'folded PlBreadcrumb': _Case(
    () => PlBreadcrumb(
      maxItems: 2,
      items: <PlBreadcrumbItem>[
        PlBreadcrumbItem(label: const Text('Home'), onPressed: () {}),
        PlBreadcrumbItem(label: const Text('Settings'), onPressed: () {}),
        PlBreadcrumbItem(label: const Text('Team'), onPressed: () {}),
        const PlBreadcrumbItem(label: Text('Billing'), current: true),
      ],
    ),
    held: () => find
        .ancestor(
          of: find.byWidgetPredicate(
            (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.ellipsis,
          ),
          matching: find.byType(AnimatedContainer),
        )
        .first,
  ),
  'PlCalendar': _Case(
    () => PlCalendar(value: DateTime(2026, 7, 27), onChanged: (DateTime? next) {}),
    held: () => find.ancestor(of: find.text('27'), matching: find.byType(AnimatedContainer)).first,
  ),
  'PlChatBubble': _Case(
    () => PlChatBubble(
      preview: PlChatBubbleLinkPreview(onPressed: () {}, title: const _Probe()),
      child: const Text('Have a look'),
    ),
  ),
  'PlCheckbox': _Case(
    () => PlCheckbox(value: false, onChanged: (bool next) {}),
    held: _inside((Widget widget) => widget is PlCheckbox, AnimatedContainer),
  ),
  'PlCodeBlock': _Case(
    () => const PlCodeBlock(code: 'final int answer = 42;'),
    held: _inside((Widget widget) => widget is PlCodeBlock, PlassGlyph),
  ),
  'PlCollapsible': _Case(
    () => PlCollapsible(
      open: false,
      onOpenChanged: (bool next) {},
      title: const _Probe(),
      child: const Text('Body'),
    ),
  ),
  'PlColorPicker rail': _Case(
    () => PlColorPicker(inline: true, value: '#ff0000', onValueChanged: (String next) {}),
    held: _inside((Widget widget) => widget is PlColorPicker, FocusableActionDetector),
  ),
  'PlColorPicker swatch': _Case(
    () => PlColorPicker(
      inline: true,
      value: '#ff0000',
      swatches: const <String>['#22c55e'],
      onValueChanged: (String next) {},
    ),
    held: () => find
        .descendant(
          of: find.bySemanticsLabel(RegExp('22c55e', caseSensitive: false)),
          matching: find.byType(Container),
        )
        .first,
  ),
  'PlDataTable': _Case(
    () => PlDataTable<String>(
      columns: <PlDataTableColumn<String>>[
        PlDataTableColumn<String>(
          key: 'city',
          header: const _Probe(),
          sortable: true,
          value: (String row) => row,
          cell: (String row, int _) => Text(row),
        ),
      ],
      rows: const <String>['Seoul', 'Lisbon'],
      rowKey: (String row, int _) => row,
    ),
    held: () => find.byType(_Probe).first,
  ),
  'PlFilePicker': _Case(
    () => PlFilePicker(
      value: const <PlFile>[],
      title: const _Probe(),
      onBrowse: () async => const <PlFile>[],
      onFilesChanged: (List<PlFile> files) {},
    ),
  ),
  'PlFloatingBottomNavigation': _Case(
    () => PlFloatingBottomNavigation<String>(
      items: const <PlFloatingBottomNavigationItem<String>>[
        PlFloatingBottomNavigationItem<String>(value: 'home', label: 'Home', icon: _Probe()),
        PlFloatingBottomNavigationItem<String>(value: 'search', label: 'Search', icon: Text('S')),
      ],
      value: 'home',
      onChanged: (String next) {},
    ),
  ),
  'PlImage': _Case(
    () => PlImage(
      image: MemoryImage(_onePixelPng),
      semanticLabel: 'A portrait',
      width: 80,
      ratio: 1,
      preview: true,
    ),
    held: () => find.byType(RawImage),
    settle: _decode,
  ),
  'PlLineChart legend': _Case(
    () => PlLineChart(series: _series, categories: _months),
    held: () => find.text('Revenue'),
    height: 400,
  ),
  'folded PlLineChart legend': _Case(
    () => PlLineChart(
      series: _series,
      categories: _months,
      legend: const PlChartLegend(maxEntries: 1),
    ),
    held: () => find.text('1 more'),
    height: 400,
  ),
  'PlList': _Case(
    () => PlList(
      children: <Widget>[PlListItem(onPressed: () {}, child: const _Probe())],
    ),
  ),
  'PlMenubar': _Case(
    () => PlMenubar(
      menus: <PlMenubarMenu>[
        PlMenubarMenu(
          label: 'File',
          startIcon: const _Probe(),
          items: <PlMenuEntry>[PlMenuItem(label: 'New', onPressed: () {})],
        ),
      ],
    ),
  ),
  'PlNavigationMenu': _Case(
    () => PlNavigationMenu(
      items: <PlNavigationMenuItem>[
        PlNavigationMenuItem(label: 'Home', startIcon: const _Probe(), onPressed: () {}),
      ],
    ),
  ),
  'PlNavigationMenu link': _Case(
    () => PlNavigationMenu(
      initialValue: 'Product',
      items: <PlNavigationMenuItem>[
        PlNavigationMenuItem(
          label: 'Product',
          links: <PlNavigationMenuLink>[
            PlNavigationMenuLink(title: 'Docs', startIcon: const _Probe(), onPressed: () {}),
          ],
        ),
      ],
    ),
    height: 400,
  ),
  // The stepper, and not the field: the field's own ring is round the
  // steppers too, and it is always in the tree.
  'PlNumberField': _Case(
    () => const PlNumberField(value: 42),
    held: _inside((Widget widget) => widget is PlNumberField, PlassGlyph),
    reach: (WidgetTester tester) async {
      final Finder glyph = _inside((Widget widget) => widget is PlNumberField, PlassGlyph)();

      Focus.of(tester.element(glyph)).requestFocus();
      await tester.pumpAndSettle();
    },
  ),
  'PlOtpField': _Case(
    () => const PlOtpField(length: 4),
    held: _inside((Widget widget) => widget is PlOtpField, PlassSurfaceBox),
  ),
  'PlPanes': _Case(
    () => const PlPanes(
      panes: <PlPane>[
        PlPane(child: SizedBox.expand()),
        PlPane(child: SizedBox.expand()),
      ],
    ),
    held: _inside((Widget widget) => widget is PlPanes, AnimatedContainer),
    height: 200,
  ),
  'PlRadioGroup': _Case(
    () => PlRadioGroup<String>(
      value: null,
      onChanged: (String? next) {},
      options: const <PlRadioOption<String>>[
        PlRadioOption<String>(value: 'kr', label: Text('Seoul')),
        PlRadioOption<String>(value: 'pt', label: Text('Lisbon')),
      ],
    ),
    held: _inside((Widget widget) => widget is PlRadioGroup, AnimatedContainer),
  ),
  'PlRating': _Case(
    () => PlRating(value: 3, icon: const _Probe(), onChanged: (double next) {}),
    held: () => find.byType(_Probe).first,
  ),
  'PlSegmentedButton': _Case(
    () => PlSegmentedButton<String>(
      segments: const <PlSegment<String>>[
        PlSegment<String>(value: 'day', label: _Probe()),
        PlSegment<String>(value: 'week', label: Text('Week')),
      ],
      value: 'day',
      onChanged: (String? next) {},
    ),
  ),
  'PlSelect': _Case(
    () => PlSelect<String>(
      options: const <PlSelectOption<String>>[
        PlSelectOption<String>(value: 'kr-11', label: Text('Seoul')),
      ],
      value: null,
      startIcon: const _Probe(),
      onChanged: (String? value) {},
    ),
  ),
  'PlSidebar': _Case(
    () => const Align(
      alignment: Alignment.centerLeft,
      child: PlSidebar(resizable: true, width: 220, child: Text('Links')),
    ),
    held: () =>
        find.descendant(of: find.byType(PlSidebar), matching: find.byType(AnimatedContainer)).last,
    height: 300,
  ),
  'PlSlider': _Case(
    () => PlSlider(values: const <double>[40], onChanged: (List<double> next) {}),
    held: _inside((Widget widget) => widget is PlSlider, AnimatedContainer),
  ),
  'PlSwitch': _Case(
    () => PlSwitch(value: false, onChanged: (bool next) {}),
    held: _inside((Widget widget) => widget is PlSwitch, AnimatedContainer),
  ),
  'PlTabs': _Case(
    () => PlTabs<String>(
      tabs: const <PlTab<String>>[
        PlTab<String>(value: 'a', label: _Probe()),
        PlTab<String>(value: 'b', label: Text('B')),
      ],
      value: 'a',
      onChanged: (String next) {},
    ),
  ),
  'PlTextLink': _Case(() => PlTextLink(onPressed: () {}, child: const _Probe())),
  'PlToggle': _Case(() => PlToggle(onPressedChanged: (bool next) {}, child: const _Probe())),
  'PlTree': _Case(
    () => PlTree(
      items: const <PlTreeNode>[PlTreeNode(id: 'a', label: _Probe())],
      onSelectedChanged: (Set<String> next) {},
    ),
  ),
  'PlWindowPane button': _Case(
    () => PlWindowPane(
      title: const Text('Notes'),
      controls: const <PlWindowControl>{PlWindowControl.close},
      onOpenChanged: (bool next) {},
    ),
    held: () =>
        find.descendant(of: find.bySemanticsLabel('Close'), matching: find.byType(Container)).first,
  ),
  'PlWindowPane handle': _Case(
    () => const PlWindowPane(
      title: Text('Notes'),
      controls: <PlWindowControl>{},
      resizable: true,
      width: 300,
      height: 200,
    ),
    held: () => find
        .descendant(of: find.bySemanticsLabel(RegExp('[Rr]esize')), matching: find.byType(SizedBox))
        .last,
    height: 300,
  ),
};

void main() {
  setUp(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  });

  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  group('what a control holds', () {
    _cases.forEach((String name, _Case control) {
      testWidgets('survives the focus ring of a $name coming and going', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        addTearDown(before.dispose);

        await tester.pumpWidget(
          host(
            afterFocusStop(
              before,
              SizedBox(width: 480, height: control.height, child: control.build()),
            ),
            width: 480,
            overlay: true,
          ),
        );
        await control.settle?.call(tester);
        await tester.pumpAndSettle();

        final Element held = tester.element(control.finder);

        before.requestFocus();
        await tester.pump();

        // Tab on until a ring is drawn round what the control holds. The first
        // stop in a control is not always the one with that ring. A table's
        // scrolling box can draw one round its heading's as well, so this asks
        // for one or more.
        Finder round() => find.ancestor(of: control.finder, matching: _ring);

        await control.reach?.call(tester);

        for (int stops = 0; stops < 12 && round().evaluate().isEmpty; stops += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
        }

        expect(round(), findsWidgets, reason: 'the ring is drawn round it');
        expect(tester.element(control.finder), same(held), reason: 'as the focus arrives');

        before.requestFocus();
        await tester.pumpAndSettle();

        expect(_ring, findsNothing, reason: 'the ring has gone');
        expect(tester.element(control.finder), same(held), reason: 'as the focus leaves');
      });
    });
  });

  testWidgets('the key of a floating bottom navigation keeps its place as it is quieted', (
    WidgetTester tester,
  ) async {
    Widget build({required bool disabled}) {
      return host(
        PlFloatingBottomNavigation<String>(
          items: <PlFloatingBottomNavigationItem<String>>[
            PlFloatingBottomNavigationItem<String>(
              value: 'home',
              label: 'Home',
              icon: const Text('H'),
              disabled: disabled,
            ),
            const PlFloatingBottomNavigationItem<String>(
              value: 'search',
              label: 'Search',
              icon: Text('S'),
            ),
          ],
          value: 'home',
          onChanged: (String next) {},
        ),
        width: 400,
      );
    }

    // The key is the one circle painted with the family's gradient.
    final Finder key = find.byWidgetPredicate(
      (Widget widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
          (widget.decoration as BoxDecoration).gradient != null,
    );

    await tester.pumpWidget(build(disabled: false));
    await tester.pumpAndSettle();

    final Element held = tester.element(key);

    await tester.pumpWidget(build(disabled: true));
    await tester.pumpAndSettle();

    expect(tester.element(key), same(held), reason: 'quieted');

    await tester.pumpWidget(build(disabled: false));
    await tester.pumpAndSettle();

    expect(tester.element(key), same(held), reason: 'lit again');
  });
}
