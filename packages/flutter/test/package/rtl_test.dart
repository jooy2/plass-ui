// That the library still runs the other way.
//
// A test of a *contract* rather than of a widget, which is why it is here
// rather than under `test/components/`: RTL is not a feature any one component
// has, it is a rule every one of them follows — **`start`/`end`, never
// `left`/`right`** — and the way that rule breaks is one component at a time,
// quietly, in a named argument nobody looked at twice.
//
// So there are two halves. The first drives a real
// `Directionality(textDirection: TextDirection.rtl)` tree, which is the only
// way to check the places that read the direction in Dart rather than leaving
// it to a `*Directional` widget. The second reads every component's source and
// fails on a physical constructor that is not on the list below — that is the
// half that catches the *next* component, and it is the reason a widget test
// would not have done.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../support/host.dart';

/// Both directions, so every case below is written once and asked twice.
const List<TextDirection> both = <TextDirection>[TextDirection.ltr, TextDirection.rtl];

void main() {
  group('a tree that runs the other way', () {
    testWidgets("PlSlider counts along the reader's line, not the screen's", (
      WidgetTester tester,
    ) async {
      Future<double> arrow(TextDirection direction) async {
        double seen = 50;

        await tester.pumpWidget(
          host(
            PlSlider(
              values: const <double>[50],
              autofocus: true,
              onChanged: (List<double> next) => seen = next.first,
            ),
            width: 300,
            textDirection: direction,
          ),
        );
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        return seen;
      }

      expect(await arrow(TextDirection.ltr), greaterThan(50));

      // The same key, the opposite result. A slider that counted the same way
      // in both would be counting away from the arrow half the time.
      expect(await arrow(TextDirection.rtl), lessThan(50));
    });

    testWidgets('PlSlider puts its minimum at the reading start', (WidgetTester tester) async {
      Future<double> tapNearTheLeftEdge(TextDirection direction) async {
        double seen = 50;

        await tester.pumpWidget(
          host(
            PlSlider(
              values: const <double>[50],
              onChanged: (List<double> next) => seen = next.first,
            ),
            width: 300,
            textDirection: direction,
          ),
        );
        await tester.pumpAndSettle();

        final Rect box = tester.getRect(find.byType(PlSlider));

        await tester.tapAt(Offset(box.left + 10, box.center.dy));
        await tester.pump();

        return seen;
      }

      expect(await tapNearTheLeftEdge(TextDirection.ltr), lessThan(20));

      // The same press, and it lands near the *maximum*: under RTL the run
      // begins at the right edge, so the left one is the far end of it.
      expect(await tapNearTheLeftEdge(TextDirection.rtl), greaterThan(80));
    });

    testWidgets('PlSwitch parks its thumb at the reading start', (WidgetTester tester) async {
      Future<double> thumb(TextDirection direction, {required bool value}) async {
        await tester.pumpWidget(
          host(
            PlSwitch(value: value, onChanged: (bool _) {}),
            textDirection: direction,
          ),
        );
        await tester.pumpAndSettle();

        final Finder disc = find.byWidgetPredicate(
          (Widget widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        );

        return tester.getCenter(disc.first).dx;
      }

      final double offLtr = await thumb(TextDirection.ltr, value: false);
      final double onLtr = await thumb(TextDirection.ltr, value: true);
      final double offRtl = await thumb(TextDirection.rtl, value: false);
      final double onRtl = await thumb(TextDirection.rtl, value: true);

      expect(onLtr, greaterThan(offLtr), reason: 'LTR: on is to the right');
      expect(onRtl, lessThan(offRtl), reason: 'RTL: on is to the left');
    });

    testWidgets('PlPanes moves its boundary the way the pointer went', (WidgetTester tester) async {
      Future<double> dragRight(TextDirection direction) async {
        await tester.pumpWidget(
          host(
            PlPanes(
              // Keyed by the direction, or the second pump reuses the first's
              // state and starts from wherever the first drag left it.
              key: ValueKey<TextDirection>(direction),
              panes: <PlPane>[
                const PlPane(child: SizedBox.expand(key: ValueKey<String>('a'))),
                const PlPane(child: SizedBox.expand()),
              ],
            ),
            width: 408,
            height: 200,
            textDirection: direction,
          ),
        );
        await tester.pumpAndSettle();

        await tester.drag(find.byType(GestureDetector).first, const Offset(50, 0));
        await tester.pump();

        return tester.getSize(find.byKey(const ValueKey<String>('a'))).width;
      }

      // The first pane is the one at the reading start, so a pointer that went
      // physically right grew it in one direction and shrank it in the other.
      expect(await dragRight(TextDirection.ltr), greaterThan(200));
      expect(await dragRight(TextDirection.rtl), lessThan(200));
    });

    testWidgets('PlChatBubble tightens the corner that faces the sender', (
      WidgetTester tester,
    ) async {
      Future<BorderRadius> corners(TextDirection direction) async {
        await tester.pumpWidget(
          host(
            const PlChatBubble(side: PlChatBubbleSide.end, child: Text('On my way')),
            width: 300,
            textDirection: direction,
          ),
        );
        await tester.pumpAndSettle();

        return decorationWhere(
              tester,
              find.byType(PlChatBubble),
              (BoxDecoration decoration) => decoration.borderRadius is BorderRadius,
            ).borderRadius!
            as BorderRadius;
      }

      final BorderRadius ltr = await corners(TextDirection.ltr);
      final BorderRadius rtl = await corners(TextDirection.rtl);

      expect(ltr.topRight.x, lessThan(ltr.topLeft.x), reason: 'LTR: `end` is on the right');
      expect(rtl.topLeft.x, lessThan(rtl.topRight.x), reason: 'RTL: `end` is on the left');
    });

    testWidgets('PlPill keeps its padding on the side the icon is on', (WidgetTester tester) async {
      Future<double> inset(TextDirection direction) async {
        await tester.pumpWidget(
          host(
            const PlPill(startIcon: Icon(IconData(0x1F600)), child: Text('Draft')),
            textDirection: direction,
          ),
        );
        await tester.pumpAndSettle();

        final Rect pill = tester.getRect(find.byType(PlPill));
        final Rect icon = tester.getRect(find.byType(Icon));

        // How far the icon is from the *reading* start edge.
        return direction == TextDirection.ltr ? icon.left - pill.left : pill.right - icon.right;
      }

      expect(await inset(TextDirection.rtl), closeTo(await inset(TextDirection.ltr), 0.5));
    });

    testWidgets('PlTree points its closed twisty the way the rows run', (
      WidgetTester tester,
    ) async {
      Future<double> turns(TextDirection direction) async {
        await tester.pumpWidget(
          host(
            const PlTree(
              items: <PlTreeNode>[
                PlTreeNode(
                  id: 'src',
                  label: Text('src'),
                  children: <PlTreeNode>[PlTreeNode(id: 'index', label: Text('index.ts'))],
                ),
              ],
              expanded: <String>{},
            ),
            width: 320,
            textDirection: direction,
          ),
        );
        await tester.pumpAndSettle();

        return tester.widget<AnimatedRotation>(find.byType(AnimatedRotation).first).turns;
      }

      // A quarter turn either way, and opposite ways: a twisty that pointed at
      // the screen's right in both directions would be pointing back up the
      // rows in one of them.
      expect(await turns(TextDirection.ltr), -0.25);
      expect(await turns(TextDirection.rtl), 0.25);
    });

    testWidgets('PlAnimateMarquee travels towards the reading start', (WidgetTester tester) async {
      Future<double> shift(TextDirection direction) async {
        await tester.pumpWidget(
          host(
            const PlAnimateMarquee(
              duration: Duration(seconds: 8),
              children: <Widget>[Text('Now boarding')],
            ),
            width: 200,
            height: 40,
            textDirection: direction,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));

        final Iterable<double> shifts = tester
            .widgetList<Transform>(find.byType(Transform))
            .map((Transform transform) => transform.transform.getTranslation().x)
            .where((double x) => x != 0);

        expect(shifts, isNotEmpty, reason: 'the strip never moved');

        return shifts.first;
      }

      expect(await shift(TextDirection.ltr), lessThan(0), reason: 'LTR: the strip slides left');
      expect(await shift(TextDirection.rtl), greaterThan(0), reason: 'RTL: the strip slides right');
    });

    testWidgets('every kind of surface lays out in both directions', (WidgetTester tester) async {
      // Nothing subtle: a widget that refuses a direction outright throws
      // during layout, and one loop here is cheaper than finding out from a
      // consumer with an Arabic locale.
      final Map<String, Widget> screen = <String, Widget>{
        'PlCard': PlCard(
          title: const Text('Seats'),
          headerAction: const PlPill(child: Text('12')),
          child: const Text('Ten left.'),
        ),
        'PlList': PlList(
          children: <Widget>[
            PlListItem(
              description: const Text('Owner'),
              action: PlSwitch(value: true, onChanged: (bool _) {}),
              child: const Text('Ada'),
            ),
          ],
        ),
        'PlChatBubble': const PlChatBubble(side: PlChatBubbleSide.end, child: Text('On my way')),
        'PlSlider': PlSlider(values: const <double>[40], onChanged: (List<double> _) {}),
        'PlStepper': const PlStepper(
          active: 1,
          steps: <PlStep>[
            PlStep(label: Text('Cart')),
            PlStep(label: Text('Pay')),
          ],
        ),
        'PlTimeline': const PlTimeline(
          items: <PlTimelineItem>[PlTimelineItem(title: Text('Shipped'))],
        ),
        'PlBreadcrumb': const PlBreadcrumb(
          items: <PlBreadcrumbItem>[
            PlBreadcrumbItem(label: Text('Home')),
            PlBreadcrumbItem(label: Text('Seats')),
          ],
        ),
        'PlProgressLinear': const PlProgressLinear(value: 62),
      };

      for (final MapEntry<String, Widget> entry in screen.entries) {
        for (final TextDirection direction in both) {
          await tester.pumpWidget(host(entry.value, width: 360, textDirection: direction));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull, reason: '${entry.key} in $direction');
        }
      }
    });
  });

  /* -------------------------------------------------------------------------
   * The half that catches the next component
   * ---------------------------------------------------------------------- */

  group('every component lays out logically', () {
    final List<File> sources = Directory('lib/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList(growable: false);

    /// Comments out. Half of this repository's prose is about left and right.
    String code(String source) {
      return source
          .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
          .replaceAll(RegExp(r'^\s*///?.*$', multiLine: true), '');
    }

    /// The named arguments and constants that name a side of the *screen*.
    ///
    /// Two families are deliberately absent. `top:` and `bottom:` have no
    /// directional twin worth having — a tooltip above a button is above it in
    /// every writing direction — and the symmetric spellings
    /// (`EdgeInsets.symmetric(horizontal:)`, `Positioned.fill`) name both sides
    /// at once, so there is nothing for a direction to swap.
    /// A `.` in front is what tells a named argument from an enum: `left:` is a
    /// side of the screen being asked for, and `PlassSide.left:` is a `case`
    /// label on a type whose whole job is to name one.
    final RegExp physical = RegExp(
      r'(?:^|[^\w.])(?:left|right|topLeft|topRight|bottomLeft|bottomRight)\s*:'
      r'|\bAlignment\.(?:center|top|bottom)(?:Left|Right)\b',
      multiLine: true,
    );

    /// The files that reach for a physical side on purpose, and what each one
    /// buys by it.
    ///
    /// Short, and every entry is a place where the *thing being measured* is
    /// physical too — pairing a directional widget with a distance from the
    /// left edge is what would actually break the direction.
    const Map<String, String> deliberate = <String, String>{
      'lib/src/internal/button_group.dart':
          'the shared corners are resolved against the ambient TextDirection by hand, because the '
          'same value has to reach a ClipRRect, a BoxDecoration and two painters',
      'lib/src/internal/calendar.dart':
          'a range opens and closes on corners resolved against the ambient TextDirection by '
          'hand, because the same radius reaches a BoxDecoration and the focus-ring painter',
      'lib/src/internal/focus_ring.dart':
          'the painter floors an already-resolved BorderRadius, corner by corner',
      'lib/src/components/tabs/pl_tabs.dart':
          'the moving indicator is placed from a measured offset, which is a distance from the '
          'left edge in both directions',
      'lib/src/components/segmented_button/pl_segmented_button.dart':
          'the gradient tile is placed from a measured offset, as above',
      'lib/src/components/floating_bottom_navigation/pl_floating_bottom_navigation.dart':
          'the disc is placed from a measured offset, as above',
      'lib/src/components/drawer/pl_drawer.dart':
          "a drawer's side is physical — PlassSide is — so the edge it flies in from is too",
      'lib/src/components/tooltip/pl_tooltip.dart':
          "the arrow is placed against the popup's own physical PlassSide, as above",
      'lib/src/components/chat_bubble/pl_chat_bubble.dart':
          'the tail corner is resolved against the ambient TextDirection by hand, because the '
          'same radius reaches a ClipRRect and a PlassSurface',
      'lib/src/components/skeleton/pl_skeleton.dart':
          'the sweep is a highlight crossing a surface rather than a value on a line, and a light '
          'that changed direction with the locale would read as a different material',
      'lib/src/components/color_picker/pl_color_picker.dart':
          'a hue rail is a colour space rather than a reading axis: 0° sits where 0° sits in every '
          'picker in every locale, and a mirrored one would be unrecognisable',
      'lib/src/components/mockup/pl_mockup.dart':
          'a camera is where the hardware put it: a phone turned sideways has its lens against one '
          'physical edge whichever way the reader reads, and the React build places it the same '
          'way, so mirroring only this one would make the two disagree',
      'lib/src/internal/mockup.dart':
          'the cut-out is drawn against a physical edge for the reason above; nothing else in the '
          'device is placed by side at all',
      'lib/src/internal/chart.dart':
          "a bar's rounded end follows the direction its *value* grows in, which is a direction "
          'on the canvas the frame paints; see the entry below',
      'lib/src/components/heatmap_chart/pl_heatmap_chart.dart':
          'a heatmap is painted in canvas coordinates like every other chart, and its readout is '
          'placed against where the pointer physically is; the grid runs left to right in both '
          'builds, so mirroring only this one would make the two disagree',
      'lib/src/internal/chart_frame.dart':
          'a plot is painted in canvas coordinates and its tooltip is placed against where the '
          'pointer physically is; the axis itself runs left to right in every locale, which is '
          'what every chart a reader has ever seen does with time',
    };

    test('lib/src is not empty (the scan below would pass vacuously)', () {
      expect(sources.length, greaterThan(40));
    });

    for (final File file in sources) {
      final String path = file.path.replaceAll(r'\', '/');

      if (deliberate.containsKey(path)) {
        continue;
      }

      test('$path names no side of the screen', () {
        expect(
          physical.allMatches(code(file.readAsStringSync())).map((Match m) => m[0]).toList(),
          isEmpty,
          reason:
              'Plass lays out with start/end. Use EdgeInsetsDirectional, PositionedDirectional, '
              'AlignmentDirectional or BorderRadiusDirectional — or add $path to the deliberate '
              'list with a reason.',
        );
      });
    }

    for (final MapEntry<String, String> entry in deliberate.entries) {
      test('${entry.key} is physical on purpose', () {
        final File file = File(entry.key);

        expect(
          file.existsSync(),
          isTrue,
          reason: '${entry.key} is listed and is not a source file',
        );

        // And it still is: an entry that has been cleaned up should leave the
        // list rather than sitting here excusing nothing.
        expect(
          physical.hasMatch(code(file.readAsStringSync())),
          isTrue,
          reason: '${entry.key} no longer needs its exemption — ${entry.value}',
        );
      });
    }
  });
}
