// That a Plass control changes at once when the platform asks for less
// movement.
//
// The React build ends every transition under `prefers-reduced-motion`: the
// house transition, and each one a component writes for itself. Here the same
// signal is `MediaQueryData.disableAnimations`, and there is no stylesheet to
// end the easing for every control at once, so each implicit animation has to
// ask for itself. A surface, a wash, a chevron or a fade that forgets eases over
// `motionDuration` whatever the reader asked for.
//
// Two halves, as the RTL test has. The first changes a state on each control
// under reduced motion, a hover, a press, a choice, an opening or a variant, and
// fails if anything under it is still moving two frames later; the same change
// with animations on has to move something, or the case would prove nothing.
// The second reads every source file for an implicit animation handed a fixed
// duration, which is the mistake that lets the next component ease whatever
// the platform asks.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/window.dart';

import '../support/host.dart';

/// How a state is changed: set up with `false`, changed with `true`. `null`
/// changes it by building the control again with `on`.
typedef _Change = Future<void> Function(WidgetTester tester, bool on);

/// One control, and how to change the state that moves something on it.
class _Case {
  const _Case(this.build, {this.change});

  /// The control, with the state on or off.
  final Widget Function(bool on) build;

  final _Change? change;
}

/// A mouse, put in the corner and then moved onto what [target] finds.
_Change _hover(Finder Function() target) {
  late TestGesture mouse;

  return (WidgetTester tester, bool on) async {
    if (!on) {
      mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await tester.pump();

      return;
    }

    await mouse.moveTo(tester.getCenter(target()));
    await tester.pump();
  };
}

/// A tap on what [target] finds.
_Change _tap(Finder Function() target) {
  return (WidgetTester tester, bool on) async {
    if (on) {
      await tester.tap(target());
      await tester.pump();
    }
  };
}

/// The focus, handed to the control.
///
/// Two frames: the focus moves in the first, and the control hears of it after
/// that frame has been built, so it draws its new state in the second.
_Change _focus(FocusNode node) {
  return (WidgetTester tester, bool on) async {
    if (on) {
      node.requestFocus();
      await tester.pump();
      await tester.pump();
    }
  };
}

/// Opens something with a tap, then moves a mouse from the corner onto what
/// [target] finds inside it.
_Change _openThenHover(Finder Function() opener, Finder Function() target) {
  late TestGesture mouse;

  return (WidgetTester tester, bool on) async {
    if (!on) {
      await tester.tap(opener());
      await tester.pump();
      await tester.pump(_rest);
      mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await tester.pump();

      return;
    }

    await mouse.moveTo(tester.getCenter(target()));
    await tester.pump();
  };
}

Finder _glyph(PlassGlyphShape shape) {
  return find.byWidgetPredicate((Widget widget) => widget is PlassGlyph && widget.shape == shape);
}

/// A window's caption button, drawing its mark.
Finder _caption(PlWindowControl control) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint &&
        widget.painter is PlWindowGlyphPainter &&
        (widget.painter! as PlWindowGlyphPainter).control == control,
  );
}

/// A 1×1 PNG, for a gallery tile that needs a picture.
final Uint8List _onePixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

Widget _gallery(PlGalleryHover hover, {PlGalleryCaption caption = PlGalleryCaption.none}) {
  return PlGallery(
    items: <PlGalleryItem>[
      PlGalleryItem(image: MemoryImage(_onePixel), semanticLabel: 'A harbour', title: 'Harbour'),
    ],
    columns: const PlassResponsive<int>(1),
    hover: hover,
    caption: caption,
    onItemSelected: (PlGalleryItem _, int _) {},
  );
}

/// A toast provider with a button under it that raises one, which stays up
/// until it is closed.
Widget _toaster() {
  return SizedBox(
    height: 400,
    child: PlToastProvider(
      timeout: Duration.zero,
      child: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => PlToastProvider.of(context).show(const PlToast(title: Text('Saved'))),
            child: const SizedBox(width: 200, height: 60, child: Text('Raise')),
          );
        },
      ),
    ),
  );
}

/// Two series with names a legend entry can be found by.
const List<PlassChartSeries> _twoSeries = <PlassChartSeries>[
  PlassChartSeries(
    name: 'Revenue',
    data: <PlassChartDatum>[PlassChartDatum(12), PlassChartDatum(19), PlassChartDatum(15)],
  ),
  PlassChartSeries(
    name: 'Cost',
    data: <PlassChartDatum>[PlassChartDatum(8), PlassChartDatum(11), PlassChartDatum(9)],
  ),
];

/// A chart's plot, whose middle is over a column or a span.
Finder _plot() {
  return find
      .byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter != null && widget.size.height > 40,
      )
      .first;
}

final GlobalKey _section = GlobalKey();
final PlAnchorItem _heading = PlAnchorItem(target: _section, label: const Text('Label'));
final FocusNode _otpFocus = FocusNode();
final FocusNode _textFocus = FocusNode();

const List<PlSelectOption<int>> _selectOptions = <PlSelectOption<int>>[
  PlSelectOption<int>(value: 0, label: Text('Other')),
  PlSelectOption<int>(value: 1, label: Text('Label')),
];

const List<PlComboboxOption<int>> _comboboxOptions = <PlComboboxOption<int>>[
  PlComboboxOption<int>(value: 0, label: 'Other'),
  PlComboboxOption<int>(value: 1, label: 'Label'),
];

/// The sheets whose surface follows their variant, each built on one.
final Map<String, Widget Function(PlassVariant variant)> _sheets =
    <String, Widget Function(PlassVariant variant)>{
      'PlAlert': (PlassVariant variant) => PlAlert(variant: variant, child: const Text('Body')),
      'PlAppLogo': (PlassVariant variant) => PlAppLogo(
        variant: variant,
        shape: PlAppLogoShape.plate,
        semanticLabel: 'Plass',
        child: const SizedBox.square(dimension: 16),
      ),
      'PlAvatar': (PlassVariant variant) => PlAvatar(variant: variant, initials: 'PL'),
      'PlBadge': (PlassVariant variant) => PlBadge(variant: variant, content: const Text('New')),
      'PlBlockquote': (PlassVariant variant) =>
          PlBlockquote(variant: variant, child: const Text('Body')),
      'PlBox': (PlassVariant variant) => PlBox(variant: variant, child: const Text('Body')),
      'PlChatBubble': (PlassVariant variant) =>
          PlChatBubble(variant: variant, child: const Text('Body')),
      'PlFooter': (PlassVariant variant) => PlFooter(variant: variant, child: const Text('Body')),
      'PlHeader': (PlassVariant variant) => PlHeader(variant: variant, child: const Text('Body')),
      'PlHotKeys': (PlassVariant variant) => PlHotKeys(variant: variant, keys: 'Mod+K'),
      'PlToolbar': (PlassVariant variant) => PlToolbar(variant: variant, child: const Text('Body')),
      'PlSpoiler': (PlassVariant variant) => PlSpoiler(variant: variant, child: const Text('Body')),
      'PlSidebar': (PlassVariant variant) => SizedBox(
        height: 200,
        child: PlSidebar(variant: variant, width: 200, child: const Text('Links')),
      ),
      'PlList': (PlassVariant variant) => PlList(
        variant: variant,
        children: const <Widget>[PlListItem(child: Text('Row'))],
      ),
      'PlAccordion': (PlassVariant variant) => PlAccordion<int>(
        variant: variant,
        value: const <int>{},
        onChanged: (Set<int> _) {},
        items: const <PlAccordionItem<int>>[
          PlAccordionItem<int>(value: 1, title: Text('Title'), child: Text('Body')),
        ],
      ),
      'PlCollapsible': (PlassVariant variant) => PlCollapsible(
        variant: variant,
        open: false,
        onOpenChanged: (bool _) {},
        title: const Text('Title'),
        child: const Text('Body'),
      ),
      'PlCarousel': (PlassVariant variant) => PlCarousel(
        variant: variant,
        value: 0,
        onChanged: (int _) {},
        children: const <Widget>[Text('One'), Text('Two')],
      ),
      'PlTable': (PlassVariant variant) => PlTable<String>(
        variant: variant,
        columns: <PlTableColumn<String>>[
          PlTableColumn<String>(header: const Text('Name'), cell: (String row, int _) => Text(row)),
        ],
        rows: const <String>['Seoul'],
      ),
      'PlTransfer': (PlassVariant variant) => PlTransfer(
        variant: variant,
        items: const <PlTransferItem>[PlTransferItem(value: 'a', label: 'Seoul')],
      ),
      'PlOtpField': (PlassVariant variant) => PlOtpField(variant: variant, length: 2),
      'PlSegmentedButton': (PlassVariant variant) => PlSegmentedButton<int>(
        variant: variant,
        value: 0,
        onChanged: (int _) {},
        segments: const <PlSegment<int>>[
          PlSegment<int>(value: 0, label: Text('One')),
          PlSegment<int>(value: 1, label: Text('Two')),
        ],
      ),
      'PlBottomNavigation': (PlassVariant variant) => PlBottomNavigation<int>(
        variant: variant,
        value: 0,
        onChanged: (int _) {},
        safeArea: false,
        items: const <PlBottomNavigationItem<int>>[
          PlBottomNavigationItem<int>(value: 0, label: 'One'),
          PlBottomNavigationItem<int>(value: 1, label: 'Two'),
        ],
      ),
      'PlFloatingBottomNavigation': (PlassVariant variant) => PlFloatingBottomNavigation<int>(
        variant: variant,
        value: 0,
        onChanged: (int _) {},
        safeArea: false,
        items: const <PlFloatingBottomNavigationItem<int>>[
          PlFloatingBottomNavigationItem<int>(value: 0, label: 'One'),
          PlFloatingBottomNavigationItem<int>(value: 1, label: 'Two'),
        ],
      ),
    };

final Map<String, _Case> _cases = <String, _Case>{
  // The places that eased whatever the platform asked.
  'PlCalendar, a day as it is chosen': _Case(
    (bool on) => PlCalendar(
      value: on ? DateTime(2026, 3, 18) : null,
      month: DateTime(2026, 3),
      onChanged: (DateTime? _) {},
    ),
  ),
  'PlStepper, a step under the pointer': _Case(
    (bool on) => PlStepper(
      active: 0,
      onActiveChanged: (int _) {},
      linear: false,
      steps: const <PlStep>[
        PlStep(label: Text('One')),
        PlStep(label: Text('Two')),
      ],
    ),
    change: _hover(() => find.text('Two')),
  ),
  'PlMenubar, a trigger under the pointer': _Case(
    (bool on) => PlMenubar(
      menus: <PlMenubarMenu>[
        PlMenubarMenu(
          label: 'File',
          items: <PlMenuEntry>[PlMenuItem(label: 'New', onPressed: () {})],
        ),
      ],
    ),
    change: _hover(() => find.text('File')),
  ),
  'PlFloatingBottomNavigation, a key under the pointer': _Case(
    (bool on) => PlFloatingBottomNavigation<int>(
      value: 0,
      onChanged: (int _) {},
      safeArea: false,
      items: const <PlFloatingBottomNavigationItem<int>>[
        PlFloatingBottomNavigationItem<int>(value: 0, label: 'One'),
        PlFloatingBottomNavigationItem<int>(
          value: 1,
          label: 'Two',
          icon: SizedBox.square(key: ValueKey<String>('two'), dimension: 16),
        ),
      ],
    ),
    change: _hover(() => find.byKey(const ValueKey<String>('two'))),
  ),
  'PlNavigationMenu, a link in its panel under the pointer': _Case(
    (bool on) => PlNavigationMenu(
      items: <PlNavigationMenuItem>[
        PlNavigationMenuItem(
          label: 'Products',
          links: <PlNavigationMenuLink>[PlNavigationMenuLink(title: 'Label', onPressed: () {})],
        ),
      ],
    ),
    change: _openThenHover(() => find.text('Products'), () => find.text('Label')),
  ),
  'PlCommandPalette, as it opens': _Case(
    (bool on) => PlCommandPalette(
      open: on,
      onOpenChanged: (bool _) {},
      items: const <PlCommandItem>[
        PlCommandItem(value: 'other', label: 'Other'),
        PlCommandItem(value: 'label', label: 'Label'),
      ],
    ),
  ),
  'PlAnchor, a heading as it becomes the active one': _Case(
    (bool on) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlAnchor(items: <PlAnchorItem>[_heading], active: on ? _heading : null),
        SizedBox(key: _section, height: 10),
      ],
    ),
  ),
  'PlBreadcrumb, a link under the pointer': _Case(
    (bool on) => PlBreadcrumb(
      items: <PlBreadcrumbItem>[
        PlBreadcrumbItem(label: const Text('Label'), onPressed: () {}),
        const PlBreadcrumbItem(label: Text('Here')),
      ],
    ),
    change: _hover(() => find.text('Label')),
  ),
  'PlBreadcrumb, its fold under the pointer': _Case(
    (bool on) => PlBreadcrumb(
      maxItems: 2,
      items: <PlBreadcrumbItem>[
        PlBreadcrumbItem(label: const Text('One'), onPressed: () {}),
        PlBreadcrumbItem(label: const Text('Two'), onPressed: () {}),
        PlBreadcrumbItem(label: const Text('Three'), onPressed: () {}),
        const PlBreadcrumbItem(label: Text('Here')),
      ],
    ),
    change: _hover(() => _glyph(PlassGlyphShape.ellipsis)),
  ),
  'PlList, a row under the pointer': _Case(
    (bool on) => PlList(
      children: <Widget>[PlListItem(onPressed: () {}, child: const Text('Label'))],
    ),
    change: _hover(() => find.text('Label')),
  ),
  'PlList, a row as it is chosen': _Case(
    (bool on) => PlList(
      children: <Widget>[PlListItem(selected: on, onPressed: () {}, child: const Text('Label'))],
    ),
  ),
  'PlTree, a node as it is chosen': _Case(
    (bool on) => PlTree(
      items: const <PlTreeNode>[PlTreeNode(id: 'a', label: Text('Label'))],
      selected: on ? const <String>{'a'} : const <String>{},
      onSelectedChanged: (Set<String> _) {},
    ),
  ),
  for (final PlGalleryHover hover in <PlGalleryHover>[
    PlGalleryHover.zoom,
    PlGalleryHover.dim,
    PlGalleryHover.lift,
  ])
    'PlGallery, a tile under the pointer, hover ${hover.name}': _Case(
      (bool on) => _gallery(hover),
      change: _hover(() => find.byType(PlGallery)),
    ),
  'PlGallery, a hover caption under the pointer': _Case(
    (bool on) => _gallery(PlGalleryHover.none, caption: PlGalleryCaption.hover),
    change: _hover(() => find.byType(PlGallery)),
  ),
  'PlSelect, its chevron as the list opens': _Case(
    (bool on) => PlSelect<int>(value: 0, onChanged: (int? _) {}, options: _selectOptions),
    change: _tap(() => _glyph(PlassGlyphShape.chevron)),
  ),
  'PlCombobox, its chevron as the list opens': _Case(
    (bool on) => PlCombobox<int>(value: 0, onChanged: (int? _) {}, options: _comboboxOptions),
    change: _tap(
      () => find.byWidgetPredicate(
        (Widget widget) => widget is Semantics && widget.properties.label == 'Open',
      ),
    ),
  ),
  'PlToast, as it arrives': _Case((bool on) => _toaster(), change: _tap(() => find.text('Raise'))),
  'PlOtpField, a slot as it takes the focus': _Case(
    (bool on) => PlOtpField(length: 2, focusNode: _otpFocus),
    change: _focus(_otpFocus),
  ),
  'PlOtpField, a slot under the pointer': _Case(
    (bool on) => const PlOtpField(length: 2),
    change: _hover(
      () => find
          .descendant(of: find.byType(PlOtpField), matching: find.byType(PlassSurfaceBox))
          .first,
    ),
  ),
  for (final MapEntry<String, Widget Function(PlassVariant variant)> sheet in _sheets.entries)
    '${sheet.key}, its variant': _Case(
      (bool on) => sheet.value(on ? PlassVariant.solid : PlassVariant.glass),
    ),

  // The places that already asked, kept honest.
  'PlButton, under the pointer': _Case(
    (bool on) => PlButton(onPressed: () {}, child: const Text('Label')),
    change: _hover(() => find.text('Label')),
  ),
  for (final PlassVariant variant in PlassVariant.values)
    '${variant.name} PlToggle, as it is pressed': _Case(
      (bool on) => PlToggle(variant: variant, pressed: on, child: const Text('Label')),
    ),
  'PlChip, as it is disabled': _Case(
    (bool on) => PlChip(variant: PlassVariant.glass, disabled: on, child: const Text('Label')),
  ),
  'PlSwitch, as it is turned on': _Case((bool on) => PlSwitch(value: on, onChanged: (bool _) {})),
  'PlCheckbox, as it is ticked': _Case((bool on) => PlCheckbox(value: on, onChanged: (bool? _) {})),
  'PlRadioGroup, as its choice moves': _Case(
    (bool on) => PlRadioGroup<int>(
      value: on ? 1 : 0,
      onChanged: (int? _) {},
      options: const <PlRadioOption<int>>[
        PlRadioOption<int>(value: 0, label: Text('One')),
        PlRadioOption<int>(value: 1, label: Text('Two')),
      ],
    ),
  ),
  'PlSlider, as its value moves': _Case(
    (bool on) => PlSlider(values: <double>[on ? 80 : 20], onChanged: (List<double> _) {}),
  ),
  'PlTabs, as the chosen tab moves': _Case(
    (bool on) => PlTabs<int>(
      value: on ? 1 : 0,
      onChanged: (int _) {},
      tabs: const <PlTab<int>>[
        PlTab<int>(value: 0, label: Text('One')),
        PlTab<int>(value: 1, label: Text('Two')),
      ],
    ),
  ),
  'PlSegmentedButton, as the chosen segment moves': _Case(
    (bool on) => PlSegmentedButton<int>(
      value: on ? 1 : 0,
      onChanged: (int _) {},
      segments: const <PlSegment<int>>[
        PlSegment<int>(value: 0, label: Text('One')),
        PlSegment<int>(value: 1, label: Text('Two')),
      ],
    ),
  ),
  'solid PlSegmentedButton, as the first choice of an empty set lands': _Case(
    (bool on) => PlSegmentedButton<int>(
      variant: PlassVariant.solid,
      value: on ? 1 : null,
      onChanged: (int _) {},
      segments: const <PlSegment<int>>[
        PlSegment<int>(value: 0, label: Text('One')),
        PlSegment<int>(value: 1, label: Text('Two')),
      ],
    ),
  ),
  'PlBottomNavigation, as the chosen item moves': _Case(
    (bool on) => PlBottomNavigation<int>(
      value: on ? 1 : 0,
      onChanged: (int _) {},
      safeArea: false,
      items: const <PlBottomNavigationItem<int>>[
        PlBottomNavigationItem<int>(value: 0, label: 'One'),
        PlBottomNavigationItem<int>(value: 1, label: 'Two'),
      ],
    ),
  ),
  'PlFloatingBottomNavigation, as the chosen key moves': _Case(
    (bool on) => PlFloatingBottomNavigation<int>(
      value: on ? 1 : 0,
      onChanged: (int _) {},
      safeArea: false,
      items: const <PlFloatingBottomNavigationItem<int>>[
        PlFloatingBottomNavigationItem<int>(value: 0, label: 'One'),
        PlFloatingBottomNavigationItem<int>(value: 1, label: 'Two'),
      ],
    ),
  ),
  'PlAccordion, as a section opens': _Case(
    (bool on) => PlAccordion<int>(
      value: on ? const <int>{1} : const <int>{},
      onChanged: (Set<int> _) {},
      items: const <PlAccordionItem<int>>[
        PlAccordionItem<int>(value: 1, title: Text('Title'), child: Text('Body')),
      ],
    ),
  ),
  'PlCollapsible, as it opens': _Case(
    (bool on) => PlCollapsible(
      open: on,
      onOpenChanged: (bool _) {},
      title: const Text('Title'),
      child: const Text('Body'),
    ),
  ),
  'PlCard, under the pointer': _Case(
    (bool on) => PlCard(interactive: true, onPressed: () {}, child: const Text('Label')),
    change: _hover(() => find.text('Label')),
  ),
  'PlTextField, as it takes the focus': _Case(
    (bool on) => PlTextField(focusNode: _textFocus),
    change: _focus(_textFocus),
  ),
  'PlNumberField, a stepper under the pointer': _Case(
    (bool on) => PlNumberField(value: 4, onChanged: (num? _) {}),
    change: _hover(() => _glyph(PlassGlyphShape.plus)),
  ),
  'PlCodeBlock, its copy button under the pointer': _Case(
    (bool on) => const PlCodeBlock(code: 'print(1);'),
    change: _hover(() => find.text('Copy')),
  ),
  'PlWindowPane, a caption button under the pointer': _Case(
    (bool on) => const PlWindowPane(os: PlWindowOs.windows11, title: Text('Notes')),
    change: _hover(() => _caption(PlWindowControl.close)),
  ),
  'PlCarousel, as the slide moves': _Case(
    (bool on) => PlCarousel(
      value: on ? 1 : 0,
      onChanged: (int _) {},
      children: const <Widget>[Text('One'), Text('Two')],
    ),
  ),
  'PlPill, as it opens': _Case(
    (bool on) => PlPill(expanded: on, title: const Text('Title'), details: const Text('Details')),
  ),
  'PlHighlight, its variant': _Case(
    (bool on) => PlHighlight(
      'A Label here',
      query: 'Label',
      variant: on ? PlassVariant.solid : PlassVariant.glass,
    ),
  ),
  'PlStepper, as the sequence reaches a step': _Case(
    (bool on) => PlStepper(
      active: on ? 1 : 0,
      onActiveChanged: (int _) {},
      linear: false,
      steps: const <PlStep>[
        PlStep(label: Text('One')),
        PlStep(label: Text('Two')),
      ],
    ),
  ),
  'PlProgressLinear, as its value moves': _Case((bool on) => PlProgressLinear(value: on ? 80 : 20)),
  'PlProgressCircular, as its value moves': _Case(
    (bool on) => PlProgressCircular(value: on ? 80 : 20),
  ),
  'PlPopover, as it opens': _Case(
    (bool on) => PlPopover(
      open: on,
      onOpenChanged: (bool _) {},
      trigger: const Text('Trigger'),
      child: const Text('Body'),
    ),
  ),
  'PlModal, as it opens': _Case(
    (bool on) => PlModal(open: on, onOpenChanged: (bool _) {}, title: const Text('Title')),
  ),
  'PlMenu, as it opens': _Case(
    (bool on) => PlMenu(
      trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
          GestureDetector(onTap: open, child: const Text('Trigger')),
      items: <PlMenuEntry>[PlMenuItem(label: 'New', onPressed: () {})],
    ),
    change: _tap(() => find.text('Trigger')),
  ),
  'PlLineChart, a series as another legend entry is pointed at': _Case(
    (bool on) => PlLineChart(series: _twoSeries),
    change: _hover(() => find.bySemanticsLabel('Cost')),
  ),
  'PlBarChart, a series as another legend entry is pointed at': _Case(
    (bool on) => PlBarChart(series: _twoSeries),
    change: _hover(() => find.bySemanticsLabel('Cost')),
  ),
  'PlBarChart, a column under the pointer': _Case(
    (bool on) => PlBarChart(series: _twoSeries),
    change: _hover(_plot),
  ),
  'PlScatterChart, a series as another legend entry is pointed at': _Case(
    (bool on) => PlScatterChart(series: _twoSeries),
    change: _hover(() => find.bySemanticsLabel('Cost')),
  ),
  'PlPieChart, the slices as a legend entry is pointed at': _Case(
    (bool on) => const PlPieChart(
      data: <PlassChartDatum>[PlassChartDatum(3), PlassChartDatum(2)],
      categories: <PlassChartCategory>[
        PlassChartCategory.text('Revenue'),
        PlassChartCategory.text('Cost'),
      ],
    ),
    change: _hover(() => find.bySemanticsLabel('Cost')),
  ),
  'PlTimelineChart, a span under the pointer': _Case(
    (bool on) => PlTimelineChart(
      series: <PlassTimelineSeries>[
        PlassTimelineSeries(
          name: 'Build',
          data: <PlassTimelinePoint>[
            PlassTimelinePoint(
              start: PlassChartCategory.date(DateTime(2026)),
              end: PlassChartCategory.date(DateTime(2026, 12, 31)),
            ),
          ],
        ),
      ],
    ),
    change: _hover(_plot),
  ),
  'PlHeatmapChart, a cell under the pointer': _Case(
    (bool on) => PlHeatmapChart(series: _twoSeries),
    change: _hover(_plot),
  ),
  'PlDataTable, its sort mark as the column is sorted': _Case(
    (bool on) => PlDataTable<String>(
      rows: const <String>['Seoul', 'Busan'],
      rowKey: (String row, int _) => row,
      columns: <PlDataTableColumn<String>>[
        PlDataTableColumn<String>(
          key: 'name',
          header: const Text('Name'),
          sortable: true,
          value: (String row) => row,
          cell: (String row, int _) => Text(row),
        ),
      ],
    ),
    // The pinned band's copy of the heading, which is the one on top once the
    // table has settled.
    change: _tap(() => find.text('Name').last),
  ),
};

/// One frame, at sixty a second.
const Duration _frame = Duration(milliseconds: 16);

/// Longer than any eased change in the library takes, the press flash's 700ms
/// included, and shorter than anything waits before it does something of its
/// own, such as a toast before it leaves.
const Duration _rest = Duration(seconds: 1);

void main() {
  group('a state change under reduced motion', () {
    // A caret blinks by animating its opacity for as long as its field has the
    // focus, a cycle at a time with a gap between, so it would be counted in
    // one of the two counts and not the other. It is the platform's, not a
    // change of state, and is held still here.
    setUp(() => EditableText.debugDeterministicCursor = true);
    tearDown(() => EditableText.debugDeterministicCursor = false);

    for (final MapEntry<String, _Case> entry in _cases.entries) {
      final _Case control = entry.value;

      Future<void> start(WidgetTester tester, {required bool reduced}) async {
        await tester.pumpWidget(
          host(control.build(false), width: 480, disableAnimations: reduced, overlay: true),
        );
        await tester.pump(_rest);
        await tester.pump(_rest);
        await control.change?.call(tester, false);
        await tester.pump(_rest);
        await tester.pump(_rest);
      }

      /// Changes the state, and counts what is moving two frames later, one
      /// for a light that goes out in a millisecond to start and one for it to
      /// finish, and what is still moving once every eased change has long
      /// finished: a caret that blinks moves for as long as it has the focus,
      /// and is in both counts.
      Future<({int early, int late})> turn(WidgetTester tester, {required bool reduced}) async {
        final _Change? change = control.change;

        if (change != null) {
          await change(tester, true);
        } else {
          await tester.pumpWidget(
            host(control.build(true), width: 480, disableAnimations: reduced, overlay: true),
          );
        }

        await tester.pump(_frame);
        await tester.pump(_frame);

        final int early = tester.binding.transientCallbackCount;

        // Twice: an animation started after a frame is over is timed from the
        // next one, so the first of these only starts its clock.
        await tester.pump(_rest);
        await tester.pump(_rest);

        return (early: early, late: tester.binding.transientCallbackCount);
      }

      testWidgets('${entry.key} moves something with animations on', (WidgetTester tester) async {
        await start(tester, reduced: false);

        final ({int early, int late}) moving = await turn(tester, reduced: false);

        // Without this the case below would pass on a change that moved
        // nothing at all.
        expect(moving.early, greaterThan(moving.late));
      });

      testWidgets('${entry.key} is still two frames later under reduced motion', (
        WidgetTester tester,
      ) async {
        await start(tester, reduced: true);

        final ({int early, int late}) moving = await turn(tester, reduced: true);

        expect(
          moving.early,
          moving.late,
          reason: 'something is still easing two frames after the change',
        );
      });
    }
  });

  /* -------------------------------------------------------------------------
   * The half that catches the next component
   * ---------------------------------------------------------------------- */

  group('every implicit animation asks the platform', () {
    final List<File> sources = Directory('lib/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList(growable: false);

    /// Comments out, so a sentence about an `AnimatedContainer` is not read as
    /// one.
    String code(String source) {
      return source
          .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
          .replaceAll(RegExp(r'^\s*///?.*$', multiLine: true), '');
    }

    /// Where a widget or a controller is handed the length of a change.
    final RegExp animation = RegExp(
      r'\b(?:Animated(?:Container|Opacity|Rotation|Scale|Slide|Positioned|PositionedDirectional|'
      r'Align|Padding|DefaultTextStyle|PhysicalModel|Size|Switcher|CrossFade|FractionallySizedBox)'
      r'|TweenAnimationBuilder(?:<[^>]*>)?|AnimationController)\(',
    );

    /// A length that is the same whatever the platform asks: a theme token or
    /// a constant, with no `Duration.zero` beside it.
    final RegExp fixed = RegExp(
      r'^(?:const\s+)?Duration\(|^(?:[\w.]*\s*\.\s*)?motionDuration(?:Slow)?$'
      r'|^PlassTheme\.of\(context\)\.motionDuration(?:Slow)?$|^PlassTokens\.\w+$',
    );

    /// The files that run an animation on a fixed length on purpose, and why.
    const Map<String, String> deliberate = <String, String>{
      'lib/src/internal/icons.dart':
          'the spinner turns once a second for as long as something loads, which is not a change '
          'of state, and it stops turning altogether when the platform turns animations off',
    };

    /// The `duration:` handed to the call that starts at [start] in [source].
    String? durationOf(String source, int start) {
      int depth = 0;
      int index = start;

      // To the parenthesis that closes the call.
      do {
        final String char = source[index];

        if (char == '(') {
          depth += 1;
        } else if (char == ')') {
          depth -= 1;
        }

        index += 1;
      } while (depth > 0 && index < source.length);

      final String call = source.substring(start, index);
      final Match? named = RegExp(r'\bduration:\s*').firstMatch(call);

      if (named == null) {
        return null;
      }

      // To the comma that ends the argument, at the argument's own depth.
      int level = 0;
      int end = named.end;

      while (end < call.length) {
        final String char = call[end];

        if (char == '(' || char == '[' || char == '{') {
          level += 1;
        } else if (char == ')' || char == ']' || char == '}') {
          if (level == 0) {
            break;
          }

          level -= 1;
        } else if (char == ',' && level == 0) {
          break;
        }

        end += 1;
      }

      return call.substring(named.end, end).trim();
    }

    test('lib/src is not empty (the scan below would pass vacuously)', () {
      expect(sources.length, greaterThan(40));
    });

    /// The fixed lengths in [source], one line each.
    List<String> fixedIn(String source) {
      return <String>[
        for (final Match match in animation.allMatches(source))
          if (durationOf(source, match.end - 1) case final String duration
              when fixed.hasMatch(duration))
            '${match[0]} duration: $duration',
      ];
    }

    for (final File file in sources) {
      final String path = file.path.replaceAll(r'\', '/');

      // The `PlAnimate` family runs on the caller's own duration, and answers
      // reduced motion by the rules on the animate page.
      if (deliberate.containsKey(path) ||
          path.contains('/components/animate_') ||
          path.endsWith('/internal/animate.dart')) {
        continue;
      }

      test('$path eases nothing on a fixed length', () {
        expect(
          fixedIn(code(file.readAsStringSync())),
          isEmpty,
          reason:
              'A change of state arrives at once when the platform asks for less movement. Take '
              'Duration.zero under MediaQuery.maybeDisableAnimationsOf(context) — or add $path '
              'to the deliberate list with a reason.',
        );
      });
    }

    for (final MapEntry<String, String> entry in deliberate.entries) {
      test('${entry.key} runs on a fixed length on purpose', () {
        final File file = File(entry.key);

        expect(
          file.existsSync(),
          isTrue,
          reason: '${entry.key} is listed and is not a source file',
        );
        expect(
          fixedIn(code(file.readAsStringSync())),
          isNotEmpty,
          reason: '${entry.key} no longer needs its exemption — ${entry.value}',
        );
      });
    }
  });
}
