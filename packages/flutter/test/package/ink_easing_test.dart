// That every control whose words or glyphs change colour with its state eases
// that colour as its fill eases, and that the fill under them eases where the
// React build eases it.
//
// The React build's house transition eases `color` with the fill, so a label
// changes colour as its surface does. A Flutter control that hands its label a
// new colour changes it in one frame instead, and over a fill that is still
// easing, the label takes its new colour on the old surface for the length of
// the transition; a fill that changes in one frame leaves an eased label
// arriving after it. What is checked here is the colour actually drawn: part of
// the way along halfway through the change, exactly the new colour once it has
// settled, and the new colour at once under reduced motion. A control added
// later with an ink or a fill of its own belongs in this list.
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/internal/window.dart';

import '../support/host.dart';

/// A glyph a caller hands a control, recording the colour it is drawn in.
class _Glyph extends StatelessWidget {
  const _Glyph();

  static Color? seen;

  @override
  Widget build(BuildContext context) {
    seen = IconTheme.of(context).color;

    return const SizedBox.square(dimension: 16);
  }
}

/// How the colour is read off the control.
typedef _Read = Color Function(WidgetTester tester);

/// How the state is changed, in a frame of its own. `null` changes it by
/// building the control again with `on`.
typedef _Change = Future<void> Function(WidgetTester tester, bool on);

/// One control, how to put it in the state that changes its ink, and where the
/// ink is read.
class _Case {
  const _Case(this.build, {this.read = _label, this.change, this.endless = false});

  /// The control, with the state that changes its ink on or off.
  final Widget Function(bool on) build;

  final _Read read;

  final _Change? change;

  /// Whether something in it moves for as long as it is on screen, such as a
  /// spinner, so it never settles and is given time instead.
  final bool endless;
}

/// The colour the words `Label` are drawn in.
Color _label(WidgetTester tester) => _words('Label')(tester);

_Read _words(String text) {
  return (WidgetTester tester) =>
      tester.renderObject<RenderParagraph>(find.text(text).last).text.style!.color!;
}

/// The colour the glyph a caller handed the control is drawn in.
Color _glyph(WidgetTester tester) => _Glyph.seen!;

/// The colour one of the library's own glyphs is drawn in: the one it is
/// handed, or else the one it takes from the icon theme around it.
_Read _ownGlyph(PlassGlyphShape shape) {
  return (WidgetTester tester) {
    final Finder glyph = find.byWidgetPredicate(
      (Widget widget) => widget is PlassGlyph && widget.shape == shape,
    );

    return tester.widget<PlassGlyph>(glyph.first).color ??
        IconTheme.of(tester.element(glyph.first)).color!;
  };
}

/// The fill of the nearest box painted round what [target] finds, and a clear
/// colour while it paints none.
_Read _fill(Finder Function() target) {
  return (WidgetTester tester) {
    final DecoratedBox box = tester.widget<DecoratedBox>(
      find.ancestor(of: target(), matching: find.byType(DecoratedBox)).first,
    );

    return (box.decoration as BoxDecoration).color ?? const Color(0x00000000);
  };
}

/// The fill of the nearest `PlassSurfaceBox` round what [target] finds, which
/// is painted beside what the box holds rather than round it: the box's own
/// shadows are its first decoration, and its fill the second.
_Read _surfaceFill(Finder Function() target) {
  return (WidgetTester tester) {
    final Finder box = find.ancestor(of: target(), matching: find.byType(PlassSurfaceBox)).first;
    final DecoratedBox fill = tester
        .widgetList<DecoratedBox>(find.descendant(of: box, matching: find.byType(DecoratedBox)))
        .elementAt(1);

    return (fill.decoration as BoxDecoration).color ?? const Color(0x00000000);
  };
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

/// The track between two regions that the pointer resizes them with.
Finder _resizeHandle() {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is MouseRegion &&
        (widget.cursor == SystemMouseCursors.resizeColumn ||
            widget.cursor == SystemMouseCursors.resizeRow),
  );
}

/// The wash a resize handle paints across its whole track, and a clear colour
/// while it paints none.
Color _handleWash(WidgetTester tester) {
  final Size track = tester.getSize(_resizeHandle());

  for (final Element box
      in find.descendant(of: _resizeHandle(), matching: find.byType(DecoratedBox)).evaluate()) {
    if (box.size == track) {
      return ((box.widget as DecoratedBox).decoration as BoxDecoration).color ??
          const Color(0x00000000);
    }
  }

  return const Color(0x00000000);
}

/// The hairline down the middle of a `PlPanes` handle, inside its wash.
Color _handleLine(WidgetTester tester) {
  final DecoratedBox line = tester.widget<DecoratedBox>(
    find.descendant(of: _resizeHandle(), matching: find.byType(DecoratedBox)).last,
  );

  return (line.decoration as BoxDecoration).color!;
}

/// A mouse, put in the corner and then moved onto the control.
_Change _hover(Finder Function() target) {
  return _hoverAt((WidgetTester tester) => tester.getCenter(target()));
}

/// A mouse, put in the corner and then moved onto the point [at] gives.
_Change _hoverAt(Offset Function(WidgetTester tester) at) {
  late TestGesture mouse;

  return (WidgetTester tester, bool on) async {
    if (!on) {
      mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await tester.pump();

      return;
    }

    await mouse.moveTo(at(tester));
    await tester.pump();
  };
}

/// The focus, handed to the control or taken away.
///
/// Two frames: the focus moves in the first, and the control hears of it after
/// that frame has been built, so it draws its new state in the second.
_Change _focus(FocusNode node) {
  return (WidgetTester tester, bool on) async {
    if (on) {
      node.requestFocus();
    } else {
      node.unfocus();
    }

    await tester.pump();
    await tester.pump();
  };
}

/// A press on the control, which opens what it opens.
_Change _press(Finder Function() target) {
  return (WidgetTester tester, bool on) async {
    if (!on) {
      return;
    }

    await tester.tap(target());
    await tester.pump();
  };
}

/// Opens a popup list on its chosen row, then moves the highlight to the next
/// row with the arrow keys.
_Change _highlight(Finder Function() opener) {
  return (WidgetTester tester, bool on) async {
    if (!on) {
      await tester.tap(opener());
      await tester.pumpAndSettle();

      return;
    }

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
  };
}

/// A key pressed at a control that is already in its first state, as an open
/// `PlCommandPalette` is, which hears the keys wherever the focus is.
_Change _pressKey(LogicalKeyboardKey key) {
  return (WidgetTester tester, bool on) async {
    if (on) {
      await tester.sendKeyEvent(key);
      await tester.pump();
    }
  };
}

const List<PlCommandItem> _commands = <PlCommandItem>[
  PlCommandItem(value: 'other', label: 'Other'),
  PlCommandItem(value: 'label', label: 'Label'),
];

/// A toast raised on [message] with `on` false, then changed in place to
/// [message] with `on` true, as `update` and `showFuture` change one.
_Change _toast(PlToast Function(bool on) message) {
  return (WidgetTester tester, bool on) async {
    final PlToastController controller = PlToastProvider.of(_toastHost.currentContext!);

    if (!on) {
      controller.show(message(false));
      await tester.pumpAndSettle();

      return;
    }

    controller.update('toast', message(true));
    await tester.pump();
  };
}

/// The stack a toast is raised on, round a stand-in for the app.
Widget _toastStack(bool _) {
  return PlToastProvider(child: SizedBox(key: _toastHost, height: 300));
}

final GlobalKey _toastHost = GlobalKey();

final GlobalKey _section = GlobalKey();
final PlAnchorItem _heading = PlAnchorItem(target: _section, label: const Text('Label'));
final FocusNode _textFocus = FocusNode();

final Map<String, _Case> _cases = <String, _Case>{
  'glass PlButton, disabled': _Case(
    (bool on) => PlButton(
      variant: PlassVariant.glass,
      disabled: on,
      onPressed: () {},
      child: const Text('Label'),
    ),
  ),
  'loading PlButton, its spinner': _Case(
    (bool on) => PlButton(
      variant: PlassVariant.glass,
      disabled: on,
      loading: true,
      onPressed: () {},
      child: const Text('Label'),
    ),
    read: (WidgetTester tester) => IconTheme.of(tester.element(find.byType(PlassSpinner))).color!,
    endless: true,
  ),
  for (final PlassVariant variant in PlassVariant.values)
    '${variant.name} PlToggle': _Case(
      (bool on) => PlToggle(variant: variant, pressed: on, child: const Text('Label')),
    ),
  'glass PlChip, disabled': _Case(
    (bool on) => PlChip(variant: PlassVariant.glass, disabled: on, child: const Text('Label')),
  ),
  'glass PlChip, disabled, its ×': _Case(
    (bool on) => PlChip(
      variant: PlassVariant.glass,
      disabled: on,
      onDeleted: () {},
      child: const Text('Label'),
    ),
    read: _ownGlyph(PlassGlyphShape.close),
  ),
  'PlTabs': _Case(
    (bool on) => PlTabs<int>(
      value: on ? 1 : 0,
      onChanged: (int _) {},
      tabs: const <PlTab<int>>[
        PlTab<int>(value: 0, label: Text('Other')),
        PlTab<int>(value: 1, label: Text('Label')),
      ],
    ),
  ),
  for (final PlassVariant variant in PlassVariant.values)
    '${variant.name} PlSegmentedButton': _Case(
      (bool on) => PlSegmentedButton<int>(
        variant: variant,
        value: on ? 1 : 0,
        onChanged: (int _) {},
        segments: const <PlSegment<int>>[
          PlSegment<int>(value: 0, label: Text('Other')),
          PlSegment<int>(value: 1, label: Text('Label')),
        ],
      ),
    ),
  'PlBottomNavigation': _Case(
    (bool on) => PlBottomNavigation<int>(
      value: on ? 1 : 0,
      onChanged: (int _) {},
      safeArea: false,
      items: const <PlBottomNavigationItem<int>>[
        PlBottomNavigationItem<int>(value: 0, label: 'Other'),
        PlBottomNavigationItem<int>(value: 1, label: 'Label', icon: _Glyph()),
      ],
    ),
  ),
  'PlBottomNavigation, its glyph': _Case(
    (bool on) => PlBottomNavigation<int>(
      value: on ? 1 : 0,
      onChanged: (int _) {},
      safeArea: false,
      items: const <PlBottomNavigationItem<int>>[
        PlBottomNavigationItem<int>(value: 0, label: 'Other'),
        PlBottomNavigationItem<int>(value: 1, label: 'Label', icon: _Glyph()),
      ],
    ),
    read: _glyph,
  ),
  'PlFloatingBottomNavigation': _Case(
    (bool on) => PlFloatingBottomNavigation<int>(
      value: on ? 1 : 0,
      onChanged: (int _) {},
      items: const <PlFloatingBottomNavigationItem<int>>[
        PlFloatingBottomNavigationItem<int>(value: 0, label: 'Other'),
        PlFloatingBottomNavigationItem<int>(value: 1, label: 'Label', icon: _Glyph()),
      ],
    ),
    read: _glyph,
  ),
  'PlNavigationMenu': _Case(
    (bool on) => PlNavigationMenu(
      items: <PlNavigationMenuItem>[
        PlNavigationMenuItem(label: 'Label', selected: on, onPressed: () {}),
      ],
    ),
  ),
  'PlAccordion': _Case(
    (bool on) => PlAccordion<int>(
      value: on ? const <int>{1} : const <int>{},
      onChanged: (Set<int> _) {},
      items: const <PlAccordionItem<int>>[
        PlAccordionItem<int>(value: 1, title: Text('Label'), child: Text('Body')),
      ],
    ),
  ),
  'PlCollapsible': _Case(
    (bool on) => PlCollapsible(
      open: on,
      onOpenChanged: (bool _) {},
      title: const Text('Label'),
      child: const Text('Body'),
    ),
  ),
  'PlList': _Case(
    (bool on) => PlList(
      children: <Widget>[PlListItem(selected: on, onPressed: () {}, child: const Text('Label'))],
    ),
  ),
  'PlTree': _Case(
    (bool on) => PlTree(
      items: const <PlTreeNode>[PlTreeNode(id: 'a', label: Text('Label'))],
      selected: on ? const <String>{'a'} : const <String>{},
      onSelectedChanged: (Set<String> _) {},
    ),
  ),
  'PlStepper, its bullet': _Case(
    (bool on) => PlStepper(
      active: on ? 1 : 0,
      onActiveChanged: (int _) {},
      linear: false,
      steps: const <PlStep>[
        PlStep(label: Text('One')),
        PlStep(label: Text('Two')),
      ],
    ),
    read: _words('2'),
  ),
  'PlCalendar': _Case(
    (bool on) => PlCalendar(
      value: on ? DateTime(2026, 3, 18) : null,
      month: DateTime(2026, 3),
      onChanged: (DateTime? _) {},
    ),
    read: _words('18'),
  ),
  'PlAnchor': _Case(
    (bool on) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlAnchor(items: <PlAnchorItem>[_heading], active: on ? _heading : null),
        SizedBox(key: _section, height: 10),
      ],
    ),
  ),
  'PlBreadcrumb, under the pointer': _Case(
    (bool on) => PlBreadcrumb(
      items: <PlBreadcrumbItem>[
        PlBreadcrumbItem(label: const Text('Label'), onPressed: () {}),
        const PlBreadcrumbItem(label: Text('Here')),
      ],
    ),
    change: _hover(() => find.text('Label')),
  ),
  'PlNumberField, a stepper under the pointer': _Case(
    (bool on) => PlNumberField(value: 4, onChanged: (num? _) {}),
    read: _ownGlyph(PlassGlyphShape.plus),
    change: _hover(
      () => find.byWidgetPredicate(
        (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.plus,
      ),
    ),
  ),
  'PlCodeBlock, its copy button under the pointer': _Case(
    (bool on) => const PlCodeBlock(code: 'print(1);'),
    read: _words('Copy'),
    change: _hover(() => find.text('Copy')),
  ),
  'PlCombobox, its chevron under the pointer': _Case(
    (bool on) => PlCombobox<int>(
      value: 0,
      onChanged: (int? _) {},
      options: const <PlComboboxOption<int>>[PlComboboxOption<int>(value: 0, label: 'Other')],
    ),
    read: _ownGlyph(PlassGlyphShape.chevron),
    change: _hover(
      () => find.byWidgetPredicate(
        (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.chevron,
      ),
    ),
  ),
  'PlCombobox, its × under the pointer': _Case(
    (bool on) => PlCombobox<int>(
      value: 0,
      onChanged: (int? _) {},
      clearable: true,
      options: const <PlComboboxOption<int>>[PlComboboxOption<int>(value: 0, label: 'Other')],
    ),
    read: _ownGlyph(PlassGlyphShape.close),
    change: _hover(
      () => find.byWidgetPredicate(
        (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.close,
      ),
    ),
  ),
  'PlAnchor, a row under the pointer': _Case(
    (bool on) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlAnchor(items: <PlAnchorItem>[_heading]),
        SizedBox(key: _section, height: 10),
      ],
    ),
    change: _hover(() => find.text('Label')),
  ),
  'PlTextLink, its underline under the pointer': _Case(
    (bool on) => PlTextLink(onPressed: () {}, child: const Text('Label')),
    read: (WidgetTester tester) =>
        tester.renderObject<RenderParagraph>(find.text('Label')).text.style!.decorationColor!,
    change: _hover(() => find.text('Label')),
  ),
  'PlMenubar, its startIcon as the menu opens': _Case(
    (bool on) => const PlMenubar(
      menus: <PlMenubarMenu>[
        PlMenubarMenu(
          label: 'Label',
          startIcon: _Glyph(),
          items: <PlMenuEntry>[PlMenuItem(label: 'Row')],
        ),
      ],
    ),
    read: _glyph,
    change: _press(() => find.text('Label')),
  ),
  'PlNavigationMenu, its startIcon': _Case(
    (bool on) => PlNavigationMenu(
      items: <PlNavigationMenuItem>[
        PlNavigationMenuItem(
          label: 'Label',
          startIcon: const _Glyph(),
          selected: on,
          onPressed: () {},
        ),
      ],
    ),
    read: _glyph,
  ),
  // A mark changes its ink only with its variant or its colour, and its fill
  // eases between the two as a control's does.
  'PlBadge, its variant': _Case(
    (bool on) => PlBadge(
      variant: on ? PlassVariant.solid : PlassVariant.glass,
      content: const Text('Label'),
    ),
  ),
  'PlAvatar, its variant': _Case(
    (bool on) =>
        PlAvatar(variant: on ? PlassVariant.solid : PlassVariant.glass, child: const Text('Label')),
  ),
  'PlAvatar, its silhouette': _Case(
    (bool on) => PlAvatar(variant: on ? PlassVariant.solid : PlassVariant.glass),
    read: (WidgetTester tester) {
      final CustomPaint silhouette = tester.widget<CustomPaint>(
        find.descendant(of: find.byType(PlAvatar), matching: find.byType(CustomPaint)).last,
      );

      return IconTheme.of(tester.element(find.byWidget(silhouette))).color!;
    },
  ),
  'PlPill, its variant': _Case(
    (bool on) =>
        PlPill(variant: on ? PlassVariant.solid : PlassVariant.glass, title: const Text('Label')),
  ),
  'PlPill, its description': _Case(
    (bool on) => PlPill(
      variant: on ? PlassVariant.solid : PlassVariant.glass,
      title: const Text('Title'),
      description: const Text('Label'),
    ),
  ),
  'PlPill, its leading glyph': _Case(
    (bool on) => PlPill(
      variant: on ? PlassVariant.solid : PlassVariant.glass,
      title: const Text('Title'),
      startIcon: const _Glyph(),
    ),
    read: _glyph,
  ),
  'PlAppLogo, the mark on its plate': _Case(
    (bool on) => PlAppLogo(
      shape: PlAppLogoShape.plate,
      variant: on ? PlassVariant.solid : PlassVariant.glass,
      child: const _Glyph(),
    ),
    read: _glyph,
  ),
  'PlKbd, its variant': _Case(
    (bool on) =>
        PlKbd(variant: on ? PlassVariant.solid : PlassVariant.glass, child: const Text('Label')),
  ),
  'PlAlert, its variant': _Case(
    (bool on) =>
        PlAlert(variant: on ? PlassVariant.solid : PlassVariant.glass, child: const Text('Label')),
  ),
  'PlAlert, its ×': _Case(
    (bool on) => PlAlert(
      variant: on ? PlassVariant.solid : PlassVariant.glass,
      onClose: () {},
      child: const Text('Body'),
    ),
    read: _ownGlyph(PlassGlyphShape.close),
  ),
  'PlAlert, a glyph in its action': _Case(
    (bool on) => PlAlert(
      variant: on ? PlassVariant.solid : PlassVariant.glass,
      action: const _Glyph(),
      child: const Text('Body'),
    ),
    read: _glyph,
  ),
  // On `solid` the title and the glyph ride on the alert's own ink, so they
  // ease with it as the colour changes it.
  'solid PlAlert, its title': _Case(
    (bool on) => PlAlert(
      color: on ? PlassColor.warning : PlassColor.info,
      variant: PlassVariant.solid,
      title: const Text('Label'),
      child: const Text('Body'),
    ),
  ),
  'solid PlAlert, its glyph': _Case(
    (bool on) => PlAlert(
      color: on ? PlassColor.warning : PlassColor.info,
      variant: PlassVariant.solid,
      icon: const _Glyph(),
      child: const Text('Body'),
    ),
    read: _glyph,
  ),
  // A toast changes its colour or its variant when `update` or `showFuture`
  // hands it a new message. On `solid` its glyph, its title and its action ride
  // on its own ink.
  'solid PlToast, its colour': _Case(
    _toastStack,
    change: _toast(
      (bool on) => PlToast(
        id: 'toast',
        timeout: Duration.zero,
        variant: PlassVariant.solid,
        color: on ? PlassColor.warning : PlassColor.info,
        description: const Text('Label'),
      ),
    ),
  ),
  'PlToast, its variant': _Case(
    _toastStack,
    change: _toast(
      (bool on) => PlToast(
        id: 'toast',
        timeout: Duration.zero,
        variant: on ? PlassVariant.solid : PlassVariant.glass,
        description: const Text('Label'),
      ),
    ),
  ),
  'solid PlToast, its title': _Case(
    _toastStack,
    change: _toast(
      (bool on) => PlToast(
        id: 'toast',
        timeout: Duration.zero,
        variant: PlassVariant.solid,
        color: on ? PlassColor.warning : PlassColor.info,
        title: const Text('Label'),
        description: const Text('Body'),
      ),
    ),
  ),
  'solid PlToast, its glyph': _Case(
    _toastStack,
    read: _glyph,
    change: _toast(
      (bool on) => PlToast(
        id: 'toast',
        timeout: Duration.zero,
        variant: PlassVariant.solid,
        color: on ? PlassColor.warning : PlassColor.info,
        icon: const _Glyph(),
        description: const Text('Body'),
      ),
    ),
  ),
  'solid PlToast, its action': _Case(
    _toastStack,
    change: _toast(
      (bool on) => PlToast(
        id: 'toast',
        timeout: Duration.zero,
        variant: PlassVariant.solid,
        color: on ? PlassColor.warning : PlassColor.info,
        description: const Text('Body'),
        actionLabel: const Text('Label'),
      ),
    ),
  ),
  'solid PlToast, its ×': _Case(
    _toastStack,
    read: _ownGlyph(PlassGlyphShape.close),
    change: _toast(
      (bool on) => PlToast(
        id: 'toast',
        timeout: Duration.zero,
        variant: PlassVariant.solid,
        color: on ? PlassColor.warning : PlassColor.info,
        description: const Text('Body'),
      ),
    ),
  ),
  'PlChatBubble, its variant': _Case(
    (bool on) => PlChatBubble(
      variant: on ? PlassVariant.solid : PlassVariant.glass,
      child: const Text('Label'),
    ),
  ),
  'PlChatBubble, its typing dots': _Case(
    (bool on) => PlChatBubble(variant: on ? PlassVariant.solid : PlassVariant.glass, typing: true),
    // Their light comes and goes in a loop, so only the ink under it is read.
    read: (WidgetTester tester) {
      final DecoratedBox dot = tester.widget<DecoratedBox>(
        find
            .byWidgetPredicate(
              (Widget widget) =>
                  widget is DecoratedBox &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration as BoxDecoration).shape == BoxShape.circle,
            )
            .first,
      );

      return (dot.decoration as BoxDecoration).color!.withValues(alpha: 1);
    },
    endless: true,
  ),
  'PlChatBubble, its link card': _Case(
    (bool on) => PlChatBubble(
      variant: on ? PlassVariant.solid : PlassVariant.glass,
      preview: const PlChatBubbleLinkPreview(description: Text('Label')),
    ),
    read: (WidgetTester tester) {
      final DecoratedBox card = tester.widget<DecoratedBox>(
        find.ancestor(of: find.text('Label'), matching: find.byType(DecoratedBox)).first,
      );

      return (card.decoration as BoxDecoration).color!;
    },
  ),
  'PlChatBubble, the words on its link card': _Case(
    (bool on) => PlChatBubble(
      variant: on ? PlassVariant.solid : PlassVariant.glass,
      preview: const PlChatBubbleLinkPreview(description: Text('Label')),
    ),
  ),
  'PlHighlight, its variant': _Case(
    (bool on) => PlHighlight(
      'A Label here',
      query: 'Label',
      variant: on ? PlassVariant.solid : PlassVariant.glass,
    ),
  ),
  'PlHighlight, its underline': _Case(
    (bool on) => PlHighlight(
      'A Label here',
      query: 'Label',
      underline: true,
      variant: on ? PlassVariant.solid : PlassVariant.glass,
    ),
    read: (WidgetTester tester) =>
        tester.renderObject<RenderParagraph>(find.text('Label').last).text.style!.decorationColor!,
  ),
  'PlSelect, a row the arrow keys reach': _Case(
    (bool on) => PlSelect<int>(
      value: 0,
      onChanged: (int? _) {},
      options: const <PlSelectOption<int>>[
        PlSelectOption<int>(value: 0, label: Text('Other')),
        PlSelectOption<int>(value: 1, label: Text('Label')),
      ],
    ),
    change: _highlight(
      () => find.byWidgetPredicate(
        (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.chevron,
      ),
    ),
  ),
  'PlCombobox, a row the arrow keys reach': _Case(
    (bool on) => PlCombobox<int>(
      value: 0,
      onChanged: (int? _) {},
      options: const <PlComboboxOption<int>>[
        PlComboboxOption<int>(value: 0, label: 'Other'),
        PlComboboxOption<int>(value: 1, label: 'Label'),
      ],
    ),
    change: _highlight(
      () => find.byWidgetPredicate(
        (Widget widget) => widget is Semantics && widget.properties.label == 'Open',
      ),
    ),
  ),
  'PlCommandPalette, a row the arrow keys reach': _Case(
    (bool on) => const PlCommandPalette(open: true, items: _commands),
    change: _pressKey(LogicalKeyboardKey.arrowDown),
  ),
  // The fills those inks sit on, which the React house transition eases too.
  'PlBottomNavigation, an item\'s fill': _Case(
    (bool on) => PlBottomNavigation<int>(
      value: on ? 1 : 0,
      onChanged: (int _) {},
      safeArea: false,
      items: const <PlBottomNavigationItem<int>>[
        PlBottomNavigationItem<int>(value: 0, label: 'Other'),
        PlBottomNavigationItem<int>(value: 1, label: 'Label'),
      ],
    ),
    read: _fill(() => find.text('Label')),
  ),
  'PlSelect, the fill of a row the arrow keys reach': _Case(
    (bool on) => PlSelect<int>(
      value: 0,
      onChanged: (int? _) {},
      options: const <PlSelectOption<int>>[
        PlSelectOption<int>(value: 0, label: Text('Other')),
        PlSelectOption<int>(value: 1, label: Text('Label')),
      ],
    ),
    read: _fill(() => find.text('Label').last),
    change: _highlight(
      () => find.byWidgetPredicate(
        (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.chevron,
      ),
    ),
  ),
  'PlCombobox, the fill of a row the arrow keys reach': _Case(
    (bool on) => PlCombobox<int>(
      value: 0,
      onChanged: (int? _) {},
      options: const <PlComboboxOption<int>>[
        PlComboboxOption<int>(value: 0, label: 'Other'),
        PlComboboxOption<int>(value: 1, label: 'Label'),
      ],
    ),
    read: _fill(() => find.text('Label').last),
    change: _highlight(
      () => find.byWidgetPredicate(
        (Widget widget) => widget is Semantics && widget.properties.label == 'Open',
      ),
    ),
  ),
  'PlCommandPalette, the fill of a row the arrow keys reach': _Case(
    (bool on) => const PlCommandPalette(open: true, items: _commands),
    read: _surfaceFill(() => find.text('Label')),
    change: _pressKey(LogicalKeyboardKey.arrowDown),
  ),
  'PlChatBubble, the fill of its link card under the pointer': _Case(
    (bool on) => PlChatBubble(
      preview: PlChatBubbleLinkPreview(description: const Text('Label'), onPressed: () {}),
    ),
    read: _fill(() => find.text('Label')),
    change: _hover(() => find.text('Label')),
  ),
  'PlNumberField, the fill of a stepper under the pointer': _Case(
    (bool on) => PlNumberField(value: 4, onChanged: (num? _) {}),
    read: _fill(
      () => find.byWidgetPredicate(
        (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.plus,
      ),
    ),
    change: _hover(
      () => find.byWidgetPredicate(
        (Widget widget) => widget is PlassGlyph && widget.shape == PlassGlyphShape.plus,
      ),
    ),
  ),
  // An adornment keeps the muted ink as the field takes the focus, so what the
  // focus eases there is the glass under it.
  'PlTextField, its fill as it takes the focus': _Case(
    (bool on) => PlTextField(focusNode: _textFocus, startIcon: const Text('Label')),
    read: _surfaceFill(() => find.text('Label')),
    change: _focus(_textFocus),
  ),
  'PlCodeBlock, the fill of its copy button under the pointer': _Case(
    (bool on) => const PlCodeBlock(code: 'print(1);'),
    read: _fill(() => find.text('Copy')),
    change: _hover(() => find.text('Copy')),
  ),
  'PlWindowPane, the fill of a caption button under the pointer': _Case(
    (bool on) => const PlWindowPane(os: PlWindowOs.windows11, title: Text('Notes')),
    read: _fill(() => _caption(PlWindowControl.close)),
    change: _hover(() => _caption(PlWindowControl.close)),
  ),
  'PlWindowPane, the mark of a caption button under the pointer': _Case(
    (bool on) => const PlWindowPane(os: PlWindowOs.windows11, title: Text('Notes')),
    read: (WidgetTester tester) =>
        (tester.widget<CustomPaint>(_caption(PlWindowControl.close)).painter!
                as PlWindowGlyphPainter)
            .ink,
    change: _hover(() => _caption(PlWindowControl.close)),
  ),
  'PlHighlight, the fill of its mark': _Case(
    (bool on) => PlHighlight(
      'A Label here',
      query: 'Label',
      color: on ? PlassColor.danger : PlassColor.warning,
      variant: PlassVariant.glass,
    ),
    read: _fill(() => find.text('Label').last),
  ),
  'PlPanes, the wash of a handle under the pointer': _Case(
    (bool on) => const SizedBox(
      height: 120,
      child: PlPanes(
        panes: <PlPane>[
          PlPane(child: Text('One')),
          PlPane(child: Text('Two')),
        ],
      ),
    ),
    read: _handleWash,
    change: _hover(_resizeHandle),
  ),
  // The line lights with the wash round it, and eases only while the wash
  // keeps the tree above it the same shape.
  'PlPanes, the line in a handle under the pointer': _Case(
    (bool on) => const SizedBox(
      height: 120,
      child: PlPanes(
        panes: <PlPane>[
          PlPane(child: Text('One')),
          PlPane(child: Text('Two')),
        ],
      ),
    ),
    read: _handleLine,
    change: _hover(_resizeHandle),
  ),
  'PlSidebar, the wash of its handle under the pointer': _Case(
    (bool on) => const Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 120,
        child: PlSidebar(resizable: true, width: 200, child: Text('Links')),
      ),
    ),
    read: _handleWash,
    // The handle straddles the sidebar's edge, and only the half inside it is
    // hit.
    change: _hoverAt(
      (WidgetTester tester) => tester.getCenter(_resizeHandle()) - const Offset(2, 0),
    ),
  ),
};

/// Whether every channel of [colour] lies between those of [a] and [b].
bool _between(Color colour, Color a, Color b) {
  bool within(double value, double one, double other) {
    const double slack = 1 / 255;

    return value >= (one < other ? one : other) - slack &&
        value <= (one < other ? other : one) + slack;
  }

  return within(colour.a, a.a, b.a) &&
      within(colour.r, a.r, b.r) &&
      within(colour.g, a.g, b.g) &&
      within(colour.b, a.b, b.b);
}

void main() {
  final Duration half = PlassTokens.light().motionDuration ~/ 2;

  for (final MapEntry<String, _Case> entry in _cases.entries) {
    final _Case control = entry.value;

    Future<void> settle(WidgetTester tester) async {
      if (control.endless) {
        await tester.pump(const Duration(seconds: 1));
      } else {
        await tester.pumpAndSettle();
      }
    }

    Future<void> start(WidgetTester tester, {required bool reduced}) async {
      await tester.pumpWidget(
        host(control.build(false), width: 480, disableAnimations: reduced, overlay: true),
      );
      await settle(tester);
      await control.change?.call(tester, false);
    }

    Future<void> turn(WidgetTester tester, {required bool reduced}) async {
      final _Change? change = control.change;

      if (change != null) {
        await change(tester, true);
      } else {
        await tester.pumpWidget(
          host(control.build(true), width: 480, disableAnimations: reduced, overlay: true),
        );
      }
    }

    testWidgets('${entry.key} eases its ink as its state changes', (WidgetTester tester) async {
      await start(tester, reduced: false);

      final Color from = control.read(tester);

      await turn(tester, reduced: false);
      await tester.pump(half);

      final Color halfway = control.read(tester);

      await settle(tester);

      final Color to = control.read(tester);

      // The state has to change the ink for the question to mean anything.
      expect(to, isNot(from));
      expect(halfway, isNot(from), reason: 'still the old ink halfway through');
      expect(halfway, isNot(to), reason: 'already the new ink halfway through');
      expect(_between(halfway, from, to), isTrue, reason: '$halfway is not between the two');
    });

    testWidgets('${entry.key} changes its ink at once under reduced motion', (
      WidgetTester tester,
    ) async {
      await start(tester, reduced: true);

      final Color from = control.read(tester);

      await turn(tester, reduced: true);

      final Color at = control.read(tester);

      await settle(tester);

      expect(at, isNot(from));
      expect(at, control.read(tester));
    });
  }
}
