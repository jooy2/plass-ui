/// Plass — a UI component library made of glass and gradients.
///
/// Smooth tinted surfaces, shadows in their own colour, and light that follows
/// the pointer. Accessible and themeable, with dark mode built in.
///
/// Nothing here imports `package:flutter/material.dart` or
/// `package:flutter/cupertino.dart`. Every component is built on
/// `package:flutter/widgets.dart` alone, which is what lets it sit inside a
/// Material app, a Cupertino app or a bare [WidgetsApp] without dragging a
/// second design system in behind it — and what makes it indifferent to those
/// two libraries moving out of the framework.
///
/// A component works with no setup: [PlassTheme] is an override rather than a
/// requirement, and without one the tokens follow the platform's own
/// brightness.
///
/// ```dart
/// import 'package:plass_ui/plass_ui.dart';
///
/// PlButton(onPressed: save, child: const Text('Save'))
/// ```
library;

export 'src/components/button/pl_button.dart';
export 'src/theme/theme.dart';
export 'src/theme/tokens.dart' show PlassColorFamily, PlassTokens;
export 'src/types.dart';
