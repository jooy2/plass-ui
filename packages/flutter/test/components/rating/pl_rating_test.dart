import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';

import '../../support/host.dart';

/// A rating wired to a variable, which is how every caller uses it.
class _Harness extends StatefulWidget {
  const _Harness({
    this.value = 0,
    this.precision = 1,
    this.clearable = true,
    this.disabled = false,
    this.frozen = false,
  });

  final double value;
  final double precision;
  final bool clearable;
  final bool disabled;

  /// No `onChanged` at all — a rating that has been handed a number and no way
  /// to change it.
  final bool frozen;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late double _value = widget.value;

  double get value => _value;

  /// How many times the rating called `onChanged`, whether or not the score moved.
  int changes = 0;

  @override
  Widget build(BuildContext context) {
    return PlRating(
      value: _value,
      precision: widget.precision,
      clearable: widget.clearable,
      disabled: widget.disabled,
      autofocus: true,
      onChanged: widget.frozen
          ? null
          : (double next) => setState(() {
              changes++;
              _value = next;
            }),
    );
  }
}

/// A glyph with a `State` of its own: built again from scratch, it is a
/// different object.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

/// How much of each star is filled, star by star.
List<double> fills(WidgetTester tester) {
  return tester
      .widgetList<ClipRect>(find.byType(ClipRect))
      .map((ClipRect clip) => clip.clipper!.getClip(const Size(20, 20)).width / 20)
      .toList();
}

void main() {
  group('PlRating', () {
    group('the row', () {
      testWidgets('is five stars unless it is told otherwise', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlRating(value: 5)));

        expect(fills(tester).length, 5);
      });

      testWidgets('takes the count it was given', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlRating(value: 3, count: 3)));

        expect(fills(tester).length, 3);
      });

      testWidgets('is named as one control', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const PlRating(value: 0, label: 'How was it?')));

        expect(find.bySemanticsLabel('How was it?'), findsOneWidget);

        handle.dispose();
      });
    });

    group('the fraction', () {
      testWidgets('fills whole stars and leaves the rest empty', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlRating(value: 3)));

        // An empty star's filled glyph is cropped to nothing.
        expect(fills(tester), <double>[1, 1, 1, 0, 0]);
      });

      testWidgets('draws a fraction the reader could not have chosen', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlRating(value: 4.3)));

        final List<double> drawn = fills(tester);

        expect(drawn.take(4), <double>[1, 1, 1, 1]);
        expect(drawn[4], closeTo(0.3, 0.0001));
      });

      testWidgets('never fills past the end of the row', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlRating(value: 99, count: 3)));

        expect(fills(tester), <double>[1, 1, 1]);
      });

      testWidgets('draws nothing at all below zero', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlRating(value: -4, count: 2)));

        expect(fills(tester), <double>[0, 0]);
      });

      testWidgets('keeps a star’s glyph and its choices as its fill crosses zero', (
        WidgetTester tester,
      ) async {
        Widget rating(double value) {
          return host(PlRating(value: value, icon: const _Probe(), onChanged: (double _) {}));
        }

        // The first star's filled glyph, and its one choice.
        State glyph() => tester.state(find.byType(_Probe).first);
        State choice() => tester.state(find.byType(RawGestureDetector).first);

        await tester.pumpWidget(rating(1));
        final State heldGlyph = glyph();
        final State heldChoice = choice();

        for (final (String reason, Widget next) in <(String, Widget)>[
          ('emptied', rating(0)),
          ('filled again', rating(1)),
        ]) {
          await tester.pumpWidget(next);

          expect(glyph(), same(heldGlyph), reason: reason);
          expect(choice(), same(heldChoice), reason: reason);
        }
      });

      testWidgets('fills from the trailing edge under RTL', (WidgetTester tester) async {
        await tester.pumpWidget(
          host(const PlRating(value: 0.5, count: 1), textDirection: TextDirection.rtl),
        );

        final Rect clip = tester
            .widget<ClipRect>(find.byType(ClipRect))
            .clipper!
            .getClip(const Size(20, 20));

        expect(clip.left, 10);
        expect(clip.right, 20);
      });
    });

    group('choosing', () {
      testWidgets('reports the score that was tapped', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness()));

        await tester.tapAt(_partCentre(tester, star: 3, part: 0, parts: 1));

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 4);
      });

      testWidgets('offers a choice per fraction once it is asked to', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(precision: 0.5)));

        await tester.tapAt(_partCentre(tester, star: 1, part: 0, parts: 2));

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 1.5);
      });

      testWidgets('clears when the score already chosen is chosen again', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const _Harness(value: 3)));

        await tester.tapAt(_partCentre(tester, star: 2, part: 0, parts: 1));

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 0);
      });

      testWidgets('does not clear when it was told not to', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(value: 3, clearable: false)));

        await tester.tapAt(_partCentre(tester, star: 2, part: 0, parts: 1));

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 3);
      });

      testWidgets('stays where it is with no callback at all', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(value: 2, frozen: true)));

        await tester.tapAt(_partCentre(tester, star: 4, part: 0, parts: 1));

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 2);
      });
    });

    group('the keyboard', () {
      testWidgets('steps up and down by one precision step', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(value: 2, precision: 0.5)));
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 2.5);

        // A frame between: the rating is controlled, so it does not see the new
        // value until the caller has rebuilt it with one.
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 2);
      });

      testWidgets('never steps past either end', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(value: 0)));
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 0);
      });

      testWidgets('jumps to the ends', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(value: 2)));
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.end);

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 5);
      });

      testWidgets('stays on a full row, and says nothing, when a key would go past it', (
        WidgetTester tester,
      ) async {
        // Clearable, which is the default: End on a full row goes to where the
        // score already is rather than choosing it a second time.
        await tester.pumpWidget(host(const _Harness(value: 5)));
        await tester.pump();

        for (final LogicalKeyboardKey key in <LogicalKeyboardKey>[
          LogicalKeyboardKey.end,
          LogicalKeyboardKey.arrowRight,
          LogicalKeyboardKey.arrowUp,
        ]) {
          await tester.sendKeyEvent(key);
          await tester.pump();
        }

        final _HarnessState harness = tester.state<_HarnessState>(find.byType(_Harness));

        expect(harness.value, 5);
        expect(harness.changes, 0);
      });

      testWidgets('stays on an empty row, and says nothing, when a key would go past it', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const _Harness(value: 0)));
        await tester.pump();

        for (final LogicalKeyboardKey key in <LogicalKeyboardKey>[
          LogicalKeyboardKey.home,
          LogicalKeyboardKey.arrowLeft,
          LogicalKeyboardKey.arrowDown,
        ]) {
          await tester.sendKeyEvent(key);
          await tester.pump();
        }

        final _HarnessState harness = tester.state<_HarnessState>(find.byType(_Harness));

        expect(harness.value, 0);
        expect(harness.changes, 0);
      });

      testWidgets('follows the writing direction rather than the left key', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(host(const _Harness(value: 2), textDirection: TextDirection.rtl));
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 1);
      });
    });

    group('readOnly', () {
      testWidgets('has no choices at all', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlRating(value: 4, readOnly: true)));

        expect(find.byType(GestureDetector), findsNothing);
      });

      testWidgets('is passed by Tab, even where every control can be reached', (
        WidgetTester tester,
      ) async {
        final FocusNode before = FocusNode();
        final FocusNode rating = FocusNode();
        addTearDown(before.dispose);
        addTearDown(rating.dispose);

        // Directional navigation is where a disabled control is still a stop,
        // so a reader can find it. A read-only row has nothing to find.
        await tester.pumpWidget(
          host(
            MediaQuery(
              data: const MediaQueryData(navigationMode: NavigationMode.directional),
              child: afterFocusStop(
                before,
                PlRating(value: 4, readOnly: true, focusNode: rating, onChanged: (double _) {}),
              ),
            ),
          ),
        );
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(rating.hasFocus, isFalse);
      });

      testWidgets('is one image carrying the score as a sentence', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const PlRating(value: 4, readOnly: true)));

        expect(find.bySemanticsLabel('4 out of 5'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('says so when there is no score yet', (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(host(const PlRating(value: 0, readOnly: true)));

        expect(find.bySemanticsLabel('No rating'), findsOneWidget);

        handle.dispose();
      });

      testWidgets('still draws the fraction', (WidgetTester tester) async {
        await tester.pumpWidget(host(const PlRating(value: 2.5, readOnly: true)));

        final List<double> drawn = fills(tester);

        expect(drawn.take(2), <double>[1, 1]);
        expect(drawn[2], closeTo(0.5, 0.0001));
      });
    });

    group('disabled', () {
      testWidgets('takes the light out of the row', (WidgetTester tester) async {
        Iterable<int> alphas() {
          return tester.layers.whereType<OpacityLayer>().map((OpacityLayer layer) => layer.alpha!);
        }

        await tester.pumpWidget(host(const PlRating(value: 3, disabled: true)));

        expect(alphas(), <int>[Color.getAlphaFromOpacity(0.5)]);

        await tester.pumpWidget(host(const PlRating(value: 3)));

        // And an available row is not painted through an opacity of 1, which
        // would be one more layer for nothing.
        expect(alphas(), isEmpty);
      });

      testWidgets('does not answer a tap', (WidgetTester tester) async {
        await tester.pumpWidget(host(const _Harness(value: 1, disabled: true)));

        await tester.tapAt(_partCentre(tester, star: 4, part: 0, parts: 1));

        expect(tester.state<_HarnessState>(find.byType(_Harness)).value, 1);
      });
    });

    testWidgets('keeps what its stars are drawn with as it is made read-only and disabled', (
      WidgetTester tester,
    ) async {
      Widget rating({bool readOnly = false, bool disabled = false}) {
        return host(
          PlRating(
            value: 3,
            emptyIcon: const _Probe(),
            readOnly: readOnly,
            disabled: disabled,
            onChanged: (double next) {},
          ),
        );
      }

      await tester.pumpWidget(rating());
      final State<_Probe> held = tester.state(find.byType(_Probe).first);

      for (final (String reason, Widget next) in <(String, Widget)>[
        ('read-only', rating(readOnly: true)),
        ('writable again', rating()),
        ('disabled', rating(disabled: true)),
        ('enabled again', rating()),
      ]) {
        await tester.pumpWidget(next);
        await tester.pumpAndSettle();

        expect(tester.state(find.byType(_Probe).first), same(held), reason: reason);
      }
    });

    group('the label', () {
      test('says the score out of the count', () {
        expect(PlRating.defaultValueLabel(3, 5), '3 out of 5');
      });

      test('drops the decimal a whole star does not have', () {
        expect(PlRating.defaultValueLabel(4, 5), '4 out of 5');
        expect(PlRating.defaultValueLabel(4.5, 5), '4.5 out of 5');
      });

      test('names the empty score rather than calling it zero', () {
        expect(PlRating.defaultValueLabel(0, 5), 'No rating');
      });
    });
  });
}

/// The middle of one hit region, in global coordinates.
///
/// Measured off the row rather than found in the tree: every star is
/// `iconSize` across with `gap` between, both at `md`, and a finder would be
/// counting boxes the layout is free to rearrange.
Offset _partCentre(
  WidgetTester tester, {
  required int star,
  required int part,
  required int parts,
}) {
  const double box = 20;
  const double spacing = 8;

  final Rect row = tester.getRect(find.byType(PlRating));
  final double left = row.left + star * (box + spacing);
  final double width = box / parts;

  return Offset(left + width * (part + 0.5), row.center.dy);
}
