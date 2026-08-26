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

export 'src/components/alert/pl_alert.dart';
export 'src/components/avatar/pl_avatar.dart';
export 'src/components/badge/pl_badge.dart';
export 'src/components/blockquote/pl_blockquote.dart';
export 'src/components/breadcrumb/pl_breadcrumb.dart';
export 'src/components/button/pl_button.dart';
export 'src/components/card/pl_card.dart';
export 'src/components/checkbox/pl_checkbox.dart';
export 'src/components/chip/pl_chip.dart';
export 'src/components/divider/pl_divider.dart';
export 'src/components/highlight/pl_highlight.dart';
export 'src/components/hot_keys/pl_hot_keys.dart';
export 'src/components/icon/pl_icon.dart';
export 'src/components/list/pl_list.dart';
export 'src/components/pagination/pl_pagination.dart';
export 'src/components/radio_group/pl_radio_group.dart';
export 'src/components/segmented_button/pl_segmented_button.dart';
export 'src/components/skeleton/pl_skeleton.dart';
export 'src/components/slider/pl_slider.dart';
export 'src/components/switch/pl_switch.dart';
export 'src/components/text_field/pl_text_field.dart';
export 'src/components/text_link/pl_text_link.dart';
export 'src/components/timeline/pl_timeline.dart';
export 'src/components/typography/pl_typography.dart';
export 'src/theme/theme.dart';
export 'src/theme/tokens.dart' show PlassColorFamily, PlassTokens;
export 'src/types.dart';
