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

export 'src/components/accordion/pl_accordion.dart';
export 'src/components/alert/pl_alert.dart';
export 'src/components/aspect_ratio/pl_aspect_ratio.dart';
export 'src/components/avatar/pl_avatar.dart';
export 'src/components/badge/pl_badge.dart';
export 'src/components/blockquote/pl_blockquote.dart';
export 'src/components/bottom_navigation/pl_bottom_navigation.dart';
export 'src/components/box/pl_box.dart';
export 'src/components/breadcrumb/pl_breadcrumb.dart';
export 'src/components/button/pl_button.dart';
export 'src/components/card/pl_card.dart';
export 'src/components/carousel/pl_carousel.dart';
export 'src/components/chat_bubble/pl_chat_bubble.dart';
export 'src/components/checkbox/pl_checkbox.dart';
export 'src/components/chip/pl_chip.dart';
export 'src/components/collapsible/pl_collapsible.dart';
export 'src/components/container/pl_container.dart';
export 'src/components/divider/pl_divider.dart';
export 'src/components/drawer/pl_drawer.dart';
export 'src/components/file_picker/pl_file_picker.dart';
export 'src/components/floating_bottom_navigation/pl_floating_bottom_navigation.dart';
export 'src/components/grid/pl_grid.dart';
export 'src/components/highlight/pl_highlight.dart';
export 'src/components/hot_keys/pl_hot_keys.dart';
export 'src/components/icon/pl_icon.dart';
export 'src/components/icon_button/pl_icon_button.dart';
export 'src/components/list/pl_list.dart';
export 'src/components/menu/pl_menu.dart';
export 'src/components/modal/pl_modal.dart';
export 'src/components/number_field/pl_number_field.dart';
export 'src/components/otp_field/pl_otp_field.dart';
export 'src/components/overlay/pl_overlay.dart';
export 'src/components/pagination/pl_pagination.dart';
export 'src/components/panes/pl_panes.dart';
export 'src/components/pill/pl_pill.dart';
export 'src/components/popover/pl_popover.dart';
export 'src/components/radio_group/pl_radio_group.dart';
export 'src/components/rating/pl_rating.dart';
export 'src/components/scroll_zone/pl_scroll_zone.dart';
export 'src/components/segmented_button/pl_segmented_button.dart';
export 'src/components/select/pl_select.dart';
export 'src/components/skeleton/pl_skeleton.dart';
export 'src/components/slider/pl_slider.dart';
export 'src/components/switch/pl_switch.dart';
export 'src/components/table/pl_table.dart';
export 'src/components/tabs/pl_tabs.dart';
export 'src/components/text_field/pl_text_field.dart';
export 'src/components/text_link/pl_text_link.dart';
export 'src/components/timeline/pl_timeline.dart';
export 'src/components/toast/pl_toast.dart';
export 'src/components/tooltip/pl_tooltip.dart';
export 'src/components/typography/pl_typography.dart';
export 'src/theme/theme.dart';
export 'src/theme/tokens.dart' show PlassColorFamily, PlassTokens;
export 'src/types.dart';
