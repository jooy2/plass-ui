/// That the ink a control's words and glyphs are drawn in eases as its fill
/// does, settles on exactly the colour it was given, and changes at once when
/// the platform asks for less movement.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/ink.dart';

import '../support/host.dart';

const Color _from = Color(0xFF102030);
const Color _to = Color(0xFFE0C0A0);

/// Counts how many times it is built, and reads nothing it could be told to
/// build again for.
class _Still extends StatelessWidget {
  const _Still();

  static int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds += 1;

    return const SizedBox.square(dimension: 4);
  }
}

/// Content with a `State` of its own: built again from scratch, it is a
/// different object.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const Text('Label');
}

/// Records the icon theme's colour it is built under.
class _Glyph extends StatelessWidget {
  const _Glyph();

  static Color? seen;

  @override
  Widget build(BuildContext context) {
    seen = IconTheme.of(context).color;

    return const SizedBox.square(dimension: 4);
  }
}

Widget _ink(
  Color color, {
  Duration? duration,
  bool icons = true,
  bool disableAnimations = false,
  Widget child = const Text('Label'),
}) {
  return host(
    PlassInk(
      color: color,
      duration: duration,
      icons: icons,
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[child, const _Glyph()]),
    ),
    disableAnimations: disableAnimations,
  );
}

Color _drawn(WidgetTester tester) => styleOf(tester, 'Label').color!;

void main() {
  final PlassTokens tokens = PlassTokens.light();

  Color along(double t) => Color.lerp(_from, _to, tokens.motionEase.transform(t))!;

  group('PlassInk', () {
    testWidgets('draws the words and the glyphs in its colour from the first frame', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_ink(_from));

      expect(_drawn(tester), _from);
      expect(_Glyph.seen, _from);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('eases to a new colour over the motion duration, on the motion curve', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_ink(_from));
      await tester.pumpWidget(_ink(_to));

      // Where the change starts: nothing has moved yet.
      expect(_drawn(tester), _from);

      await tester.pump(tokens.motionDuration ~/ 2);

      expect(_drawn(tester), along(0.5));
      expect(_Glyph.seen, along(0.5));

      await tester.pumpAndSettle();

      // Exactly the colour it was given, so a control at rest looks as it did.
      expect(_drawn(tester), _to);
      expect(_Glyph.seen, _to);
    });

    testWidgets('takes as long as it is told to, for a surface that eases slower', (
      WidgetTester tester,
    ) async {
      final Duration slow = tokens.motionDurationSlow;

      await tester.pumpWidget(_ink(_from, duration: slow));
      await tester.pumpWidget(_ink(_to, duration: slow));
      await tester.pump(slow ~/ 2);

      expect(_drawn(tester), along(0.5));

      await tester.pump(slow ~/ 2);

      expect(_drawn(tester), _to);
    });

    testWidgets('changes at once when the platform asks for less movement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_ink(_from, disableAnimations: true));
      await tester.pumpWidget(_ink(_to, disableAnimations: true));

      expect(_drawn(tester), _to);
      expect(_Glyph.seen, _to);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('turns back from where it is when the state changes back part of the way', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_ink(_from));
      await tester.pumpWidget(_ink(_to));
      await tester.pump(tokens.motionDuration ~/ 2);

      final Color halfway = _drawn(tester);

      // Back again, from the colour on screen rather than from the one it was
      // easing to, as a CSS transition that is interrupted runs.
      await tester.pumpWidget(_ink(_from));

      expect(_drawn(tester), halfway);

      await tester.pump(tokens.motionDuration ~/ 2);

      expect(_drawn(tester), Color.lerp(halfway, _from, tokens.motionEase.transform(0.5)));

      await tester.pumpAndSettle();

      expect(_drawn(tester), _from);
    });

    testWidgets('leaves the glyphs alone where only the words take it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_ink(_from, icons: false));

      final Color? ambient = _Glyph.seen;

      expect(ambient, isNot(_from));
      expect(_drawn(tester), _from);

      await tester.pumpWidget(_ink(_to, icons: false));
      await tester.pumpAndSettle();

      expect(_Glyph.seen, ambient);
      expect(_drawn(tester), _to);
    });

    testWidgets('changes the colour and nothing else about the words', (WidgetTester tester) async {
      Widget styled(Color color) {
        return host(
          DefaultTextStyle(
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, height: 1.5),
            child: PlassInk(color: color, child: const Text('Label')),
          ),
        );
      }

      await tester.pumpWidget(styled(_from));
      await tester.pumpWidget(styled(_to));
      await tester.pump(tokens.motionDuration ~/ 2);

      final TextStyle style = styleOf(tester, 'Label');

      expect(style.fontSize, 21);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.height, 1.5);
      expect(style.color, along(0.5));
    });

    testWidgets('keeps what it holds, and builds again only what reads the colour', (
      WidgetTester tester,
    ) async {
      Widget held(Color color) {
        return host(
          PlassInk(
            color: color,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[_Probe(), _Still()],
            ),
          ),
        );
      }

      _Still.builds = 0;

      await tester.pumpWidget(held(_from));

      final State<_Probe> content = tester.state(find.byType(_Probe));

      await tester.pumpWidget(held(_to));
      await tester.pump(tokens.motionDuration ~/ 2);
      await tester.pumpAndSettle();

      expect(tester.state(find.byType(_Probe)), same(content));
      expect(_drawn(tester), _to);
      // Built for the first frame and never again: not for the new colour, and
      // not for any frame of the change, because it reads nothing that eases.
      expect(_Still.builds, 1);
    });
  });
}
