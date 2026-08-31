/// The shortcut vocabulary, read rather than written.
///
/// [PlHotKeys] turns `Mod+Enter` into a pair of key caps; this turns the same
/// string into a predicate over a real key event. They share this file because a
/// shortcut a widget **displays** and a shortcut it **binds** have to be spelled
/// the same way — otherwise the cap on the screen is a claim nobody checked.
/// `PlCommandPalette` made that argument first and carried a private copy of the
/// matcher to make it; the fields that take a `hotKeys` map are the reason it
/// lives here instead.
///
/// Nothing here is exported from `plass_ui.dart` except [PlassHotKeys], which is
/// the map a caller writes, and which `types.dart` names.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/types.dart';

/// Whether this host spells `Mod` as ⌘.
///
/// Read from [defaultTargetPlatform], which is also where `PlHotKeys.platform`
/// reads it, so a `debugDefaultTargetPlatformOverride` in a test or a preview
/// moves the cap and the binding together rather than one of them.
bool get plassModIsMeta {
  return defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

/// The spellings that mean the same key, folded onto one name.
///
/// A caller writes what is printed on their own keyboard — `Cmd`, `Option`,
/// `Return`, `Esc` — and every one of those has to reach the same cap and the
/// same binding.
const Map<String, String> plassKeyAliases = <String, String>{
  'cmdorctrl': 'mod',
  'commandorcontrol': 'mod',
  'cmd': 'meta',
  'command': 'meta',
  'super': 'meta',
  'win': 'meta',
  'windows': 'meta',
  'control': 'ctrl',
  'option': 'alt',
  'opt': 'alt',
  'return': 'enter',
  // A numpad Enter is an Enter. The framework labels it apart; a key cap does
  // not, and neither does anyone reaching for it.
  'numpadenter': 'enter',
  'esc': 'escape',
  'del': 'delete',
  'caps': 'capslock',
};

/// One token of a chord, folded: case, spacing and the aliases above.
String plassCanonicalKey(String token) {
  final normalized = token.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');

  return plassKeyAliases[normalized] ?? normalized;
}

/// The handful of keys whose `keyLabel` is not what is printed on the cap.
///
/// A cap says `↑` and the framework says `Arrow Up`, which folds to `arrowup`;
/// a cap says `Space` and the framework says a literal space. Everything else —
/// `Enter`, `Escape`, `Tab`, a letter — matches once both sides are folded.
const Map<String, String> _labelKeys = <String, String>{
  'up': 'arrowup',
  'down': 'arrowdown',
  'left': 'arrowleft',
  'right': 'arrowright',
  'space': ' ',
  'plus': '+',
};

/// Is this the chord?
///
/// Every modifier is checked in **both** directions, which is the difference
/// between binding a shortcut and binding a key: `'Enter'` must not fire on
/// `Mod+Enter`, or a field that saves on Enter also saves on every chord that
/// happens to end in one.
bool plassMatchesHotKey(String chord, KeyEvent event) {
  final List<String> parts = chord.split('+').map(plassCanonicalKey).toList(growable: false);
  final Set<String> wanted = parts.sublist(0, parts.length - 1).toSet();
  final String last = parts.last;
  final String key = _labelKeys[last] ?? last;

  final HardwareKeyboard keyboard = HardwareKeyboard.instance;
  final bool mod = plassModIsMeta ? keyboard.isMetaPressed : keyboard.isControlPressed;

  if (wanted.contains('mod') != mod) {
    return false;
  }

  if (wanted.contains('shift') != keyboard.isShiftPressed ||
      wanted.contains('alt') != keyboard.isAltPressed) {
    return false;
  }

  // Only when `Mod` was not asked for. It *is* one of these two, and checking
  // both would make `Mod+K` require a Ctrl that a Mac never sends.
  if (!wanted.contains('mod')) {
    if (wanted.contains('ctrl') != keyboard.isControlPressed ||
        wanted.contains('meta') != keyboard.isMetaPressed) {
      return false;
    }
  }

  return _foldLabel(event.logicalKey.keyLabel) == key;
}

/// What the framework calls a key, folded onto the name a cap is written with.
///
/// A one-character label is lower-cased and left alone — anything else would
/// turn the space bar's own label, which is a space, into an empty string. The
/// rest goes through the full fold, so `Arrow Up` reaches `arrowup` and
/// `Numpad Enter` reaches `enter` by way of the alias table.
String _foldLabel(String label) {
  return label.length == 1 ? label.toLowerCase() : plassCanonicalKey(label);
}

/// Does [hotKeys] claim [key] with no modifiers on it?
///
/// A control that binds its own activation keys through a `Shortcuts` asks this
/// so it can **stand down**. Of two handlers the one nearer the focused node
/// answers first, and a `FocusableActionDetector`'s is nearer than anything a
/// field can wrap around it — so the only way a caller's bare `Enter` can be
/// theirs is for the control to stop claiming it while they are asking for it.
///
/// [key] is a canonical name, so `'enter'` and never `'Enter'`.
bool plassClaimsBareKey(PlassHotKeys? hotKeys, String key) {
  if (hotKeys == null) {
    return false;
  }

  return hotKeys.keys.any((String chord) {
    final List<String> parts = chord.split('+');

    return parts.length == 1 && plassCanonicalKey(parts.single) == key;
  });
}

/// Runs whichever chord this key event is, and says whether one was.
///
/// [KeyEventResult.handled] on a match, which is what consuming it means: the
/// key reaches neither the control's own key handling nor the route above it, so
/// `Escape` bound on a field does not also close the dialog around it.
///
/// Repeats are answered as well as presses — holding a chord down that steps a
/// value should step it — and key *ups* never are.
KeyEventResult plassHandleHotKeys(PlassHotKeys? hotKeys, KeyEvent event) {
  if (hotKeys == null || hotKeys.isEmpty) {
    return KeyEventResult.ignored;
  }

  if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
    return KeyEventResult.ignored;
  }

  for (final MapEntry<String, VoidCallback> entry in hotKeys.entries) {
    if (plassMatchesHotKey(entry.key, event)) {
      entry.value();

      return KeyEventResult.handled;
    }
  }

  return KeyEventResult.ignored;
}

/// The [Focus] a control carrying a `hotKeys` map wears.
///
/// Wrapped **inside** the field rather than around it, for the reason
/// `PlNumberField`'s `Shortcuts` is: of two handlers, the one nearer the focused
/// node answers first — so a chord bound here beats the app's own text-editing
/// shortcuts and the route's `Escape`, which is what consuming a key means.
///
/// It never takes the focus itself and never appears in the traversal order.
/// The control below it is the thing a reader is typing into, and a second stop
/// in front of it would be a Tab that goes nowhere.
///
/// Returns the child untouched when there is nothing to bind, so a field with no
/// `hotKeys` gains no node at all.
Widget plassHotKeyScope({required PlassHotKeys? hotKeys, required Widget child}) {
  if (hotKeys == null || hotKeys.isEmpty) {
    return child;
  }

  return Focus(
    canRequestFocus: false,
    skipTraversal: true,
    onKeyEvent: (FocusNode node, KeyEvent event) => plassHandleHotKeys(hotKeys, event),
    child: child,
  );
}
