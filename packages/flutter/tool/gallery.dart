/// Every component in the package, constructed once.
///
/// The heaviest scenario `tool/size.dart` measures, and the one that answers
/// "what does the whole library cost?". It is deliberately minimal: each
/// component appears once with the arguments its constructor demands and
/// nothing more, so what the build measures is the library rather than the
/// screens somebody built out of it. The example app under `example/` is the
/// opposite — every component *and* several hundred demos — and measuring that
/// one describes the demos.
///
/// It lives here as real Dart rather than as a string inside `size.dart` so the
/// analyser checks it: a component whose constructor gains a required parameter
/// breaks `flutter analyze` here, which is the only thing that keeps this file
/// from quietly falling behind the package it is supposed to cover.
///
/// `size.dart` copies this file into a throwaway app and builds it. It is an
/// entry point, not a library, so it is never imported.
library;

import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

const Widget _c = Text('x');
const List<Widget> _cs = <Widget>[Text('x')];
const List<PlassChartDatum> _d = <PlassChartDatum>[PlassChartDatum(1)];
const List<PlassChartSeries> _s = <PlassChartSeries>[PlassChartSeries(data: _d)];
void _f() {}

List<Widget> everything() => <Widget>[
  PlAccordion<int>(
    items: const <PlAccordionItem<int>>[PlAccordionItem<int>(value: 1, title: _c)],
    value: const <int>{1},
  ),
  const PlAlert(child: _c),
  PlAnchor(
    items: <PlAnchorItem>[PlAnchorItem(target: GlobalKey(), label: _c)],
  ),
  const PlAnimateAppear(children: _cs),
  const PlAnimateBlink(child: _c),
  const PlAnimateCounter(value: 1),
  const PlAnimateFade(child: _c),
  const PlAnimateFloat(child: _c),
  const PlAnimateGrow(child: _c),
  const PlAnimateHeadline(children: _cs),
  const PlAnimateLighting(child: _c),
  const PlAnimateMarquee(children: _cs),
  const PlAnimateReveal(child: _c),
  const PlAnimateRotate(child: _c),
  const PlAnimateScramble(text: 'x'),
  const PlAnimateShake(child: _c),
  const PlAnimateSlide(child: _c),
  const PlAnimateSplit(text: 'x'),
  const PlAnimateTyping('x'),
  const PlAnimateZoom(child: _c),
  const PlAppLogo(child: _c),
  const PlAreaChart(series: _s),
  const PlAspectRatio(child: _c),
  const PlAvatar(),
  const PlBackTop(),
  const PlBadge(child: _c),
  const PlBarChart(series: _s),
  const PlBlockquote(child: _c),
  PlBottomNavigation<int>(items: const <PlBottomNavigationItem<int>>[], value: 1),
  const PlBox(child: _c),
  const PlBreadcrumb(items: <PlBreadcrumbItem>[PlBreadcrumbItem(label: _c)]),
  PlButton(onPressed: _f, child: _c),
  const PlButtonGroup(children: _cs),
  const PlCalendar(value: null),
  const PlCard(child: _c),
  const PlCarousel(value: 0, children: _cs),
  const PlChatBubble(child: _c),
  const PlCheckbox(value: false),
  const PlChip(child: _c),
  const PlCodeBlock(code: 'x'),
  const PlCollapsible(open: false, child: _c),
  const PlColorPicker(value: '#000000'),
  PlCombobox<int>(options: const <PlComboboxOption<int>>[], value: null),
  const PlCommandPalette(items: <PlCommandItem>[], open: false),
  const PlConfirmProvider(child: _c),
  const PlContainer(child: _c),
  const PlDataList(children: _cs),
  PlDataTable<int>(columns: const <PlDataTableColumn<int>>[], rows: const <int>[]),
  const PlDatePicker(value: null),
  const PlDateRangePicker(value: PlDateRange.empty),
  const PlDateTimePicker(value: null),
  const PlDivider(),
  const PlDrawer(open: false),
  const PlEmpty(),
  const PlFieldset(children: _cs),
  const PlFilePicker(value: <PlFile>[]),
  PlFloatingActionButton(icon: _c, label: 'x', onPressed: _f),
  PlFloatingBottomNavigation<int>(items: const <PlFloatingBottomNavigationItem<int>>[], value: 1),
  const PlFooter(),
  const PlForm(children: _cs),
  const PlGallery(items: <PlGalleryItem>[]),
  const PlGaugeChart(value: 1),
  const PlGrid(items: <PlGridItem>[PlGridItem(child: _c)]),
  const PlHeader(),
  const PlHeatmapChart(series: _s),
  const PlHighlight('x', query: 'x'),
  const PlHotKeys(),
  const PlKbd(child: _c),
  const PlHoverCard(trigger: _c, child: _c),
  const PlHowToSteps(steps: <PlHowToStep>[]),
  const PlIcon(icon: _c),
  PlIconButton(icon: _c, label: 'x', onPressed: _f),
  const PlImage(image: AssetImage('x')),
  const PlLineChart(series: _s),
  const PlList(children: _cs),
  const PlListItem(child: _c),
  PlMenu(
    items: const <PlMenuEntry>[],
    trigger: (BuildContext context, VoidCallback open, bool isOpen) => _c,
  ),
  const PlMenubar(menus: <PlMenubarMenu>[]),
  const PlMeter(value: 1),
  const PlMockup(device: PlMockupDevice.mobile),
  const PlModal(open: false),
  const PlNavigationMenu(items: <PlNavigationMenuItem>[]),
  const PlNumberField(value: 1),
  const PlOtpField(),
  const PlOverlay(open: false),
  const PlPageLayout(child: _c),
  const PlPagination(count: 1, page: 1),
  const PlPanes(panes: <PlPane>[PlPane(child: _c)]),
  const PlPieChart(data: _d),
  const PlPill(child: _c),
  const PlPopconfirm(open: false, trigger: _c),
  const PlPopover(open: false, trigger: _c),
  const PlProgressBox(),
  const PlProgressCircular(),
  const PlProgressLinear(),
  PlRadioGroup<int>(options: const <PlRadioOption<int>>[PlRadioOption<int>(value: 1)], value: 1),
  const PlRating(value: 1),
  const PlScatterChart(series: _s),
  const PlScrollArea(child: _c),
  const PlScrollZone(children: _cs),
  PlSegmentedButton<int>(
    segments: const <PlSegment<int>>[PlSegment<int>(value: 1, label: _c)],
    value: 1,
  ),
  PlSelect<int>(options: const <PlSelectOption<int>>[], value: null),
  const PlShow(child: _c),
  const PlSidebar(child: _c),
  const PlSkeleton(),
  const PlSlider(values: <double>[1]),
  const PlSparkline(data: _d),
  const PlSpoiler(child: _c),
  const PlStack(children: _cs),
  const PlStat(),
  const PlStepper(steps: <PlStep>[], active: 0),
  const PlSwitch(value: false),
  PlTable<int>(columns: const <PlTableColumn<int>>[], rows: const <int>[]),
  PlTabs<int>(tabs: const <PlTab<int>>[PlTab<int>(value: 1, label: _c)], value: 1),
  const PlTextField(),
  const PlTextLink(child: _c),
  const PlTimePicker(value: null),
  const PlTimeline(items: <PlTimelineItem>[]),
  const PlTimelineChart(
    series: <PlassTimelineSeries>[PlassTimelineSeries(data: <PlassTimelinePoint>[])],
  ),
  const PlToastProvider(child: _c),
  const PlToggle(),
  const PlToolbar(child: _c),
  const PlTooltipProvider(child: _c),
  const PlTour(steps: <PlTourStep>[]),
  const PlTransfer(items: <PlTransferItem>[]),
  const PlTree(items: <PlTreeNode>[]),
  const PlTreeSelect(items: <PlTreeSelectNode>[]),
  const PlTypography('x'),
  const PlWindowPane(),
];

void main() => runApp(
  WidgetsApp(
    color: const Color(0xFF000000),
    debugShowCheckedModeBanner: false,
    home: ListView(children: everything()),
  ),
);
