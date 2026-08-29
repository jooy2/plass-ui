import 'package:flutter/widgets.dart';

import 'package:plass_ui_example/demos/animate_fade/hero.dart';
import 'package:plass_ui_example/demos/animate_fade/mode.dart';
import 'package:plass_ui_example/demos/animate_fade/timing.dart';
import 'package:plass_ui_example/demos/animate_fade/triggers.dart';
import 'package:plass_ui_example/demos/animate_grow/hero.dart';
import 'package:plass_ui_example/demos/animate_grow/origin.dart';
import 'package:plass_ui_example/demos/animate_grow/from.dart';
import 'package:plass_ui_example/demos/animate_grow/panel.dart';
import 'package:plass_ui_example/demos/accordion/controlled.dart';
import 'package:plass_ui_example/demos/accordion/dividers.dart';
import 'package:plass_ui_example/demos/accordion/hero.dart';
import 'package:plass_ui_example/demos/accordion/multiple.dart';
import 'package:plass_ui_example/demos/accordion/sizes.dart';
import 'package:plass_ui_example/demos/accordion/slots.dart';
import 'package:plass_ui_example/demos/accordion/variants.dart';
import 'package:plass_ui_example/demos/alert/colors.dart';
import 'package:plass_ui_example/demos/alert/dismiss.dart';
import 'package:plass_ui_example/demos/alert/hero.dart';
import 'package:plass_ui_example/demos/alert/shapes.dart';
import 'package:plass_ui_example/demos/alert/sizes.dart';
import 'package:plass_ui_example/demos/alert/variants.dart';
import 'package:plass_ui_example/demos/aspect_ratio/embed.dart';
import 'package:plass_ui_example/demos/aspect_ratio/fit.dart';
import 'package:plass_ui_example/demos/aspect_ratio/hero.dart';
import 'package:plass_ui_example/demos/aspect_ratio/ratios.dart';
import 'package:plass_ui_example/demos/avatar/colors.dart';
import 'package:plass_ui_example/demos/avatar/fallback.dart';
import 'package:plass_ui_example/demos/avatar/group.dart';
import 'package:plass_ui_example/demos/avatar/hero.dart';
import 'package:plass_ui_example/demos/avatar/shapes.dart';
import 'package:plass_ui_example/demos/avatar/sizes.dart';
import 'package:plass_ui_example/demos/avatar/variants.dart';
import 'package:plass_ui_example/demos/badge/colors.dart';
import 'package:plass_ui_example/demos/badge/counts.dart';
import 'package:plass_ui_example/demos/badge/dot.dart';
import 'package:plass_ui_example/demos/badge/hero.dart';
import 'package:plass_ui_example/demos/badge/overlap.dart';
import 'package:plass_ui_example/demos/badge/placement.dart';
import 'package:plass_ui_example/demos/badge/sizes.dart';
import 'package:plass_ui_example/demos/badge/variants.dart';
import 'package:plass_ui_example/demos/blockquote/attribution.dart';
import 'package:plass_ui_example/demos/blockquote/colors.dart';
import 'package:plass_ui_example/demos/blockquote/hero.dart';
import 'package:plass_ui_example/demos/blockquote/sizes.dart';
import 'package:plass_ui_example/demos/blockquote/variants.dart';
import 'package:plass_ui_example/demos/bottom_navigation/hero.dart';
import 'package:plass_ui_example/demos/bottom_navigation/labels.dart';
import 'package:plass_ui_example/demos/bottom_navigation/sizes.dart';
import 'package:plass_ui_example/demos/bottom_navigation/variants.dart';
import 'package:plass_ui_example/demos/box/hero.dart';
import 'package:plass_ui_example/demos/box/padded.dart';
import 'package:plass_ui_example/demos/box/sizes.dart';
import 'package:plass_ui_example/demos/box/variants.dart';
import 'package:plass_ui_example/demos/breadcrumb/collapse.dart';
import 'package:plass_ui_example/demos/breadcrumb/current.dart';
import 'package:plass_ui_example/demos/breadcrumb/hero.dart';
import 'package:plass_ui_example/demos/breadcrumb/separators.dart';
import 'package:plass_ui_example/demos/breadcrumb/sizes.dart';
import 'package:plass_ui_example/demos/button/colors.dart';
import 'package:plass_ui_example/demos/button/density.dart';
import 'package:plass_ui_example/demos/button/elevation.dart';
import 'package:plass_ui_example/demos/button/full_width.dart';
import 'package:plass_ui_example/demos/button/hero.dart';
import 'package:plass_ui_example/demos/button/icons.dart';
import 'package:plass_ui_example/demos/button/sizes.dart';
import 'package:plass_ui_example/demos/button/states.dart';
import 'package:plass_ui_example/demos/button/variants.dart';
import 'package:plass_ui_example/demos/button_group/full_width.dart';
import 'package:plass_ui_example/demos/button_group/hero.dart';
import 'package:plass_ui_example/demos/button_group/orientation.dart';
import 'package:plass_ui_example/demos/button_group/sizes.dart';
import 'package:plass_ui_example/demos/button_group/variants.dart';
import 'package:plass_ui_example/demos/carousel/auto_play.dart';
import 'package:plass_ui_example/demos/carousel/hero.dart';
import 'package:plass_ui_example/demos/carousel/loop.dart';
import 'package:plass_ui_example/demos/carousel/variants.dart';
import 'package:plass_ui_example/demos/card/dividers.dart';
import 'package:plass_ui_example/demos/card/hero.dart';
import 'package:plass_ui_example/demos/card/interactive.dart';
import 'package:plass_ui_example/demos/card/padded.dart';
import 'package:plass_ui_example/demos/card/sizes.dart';
import 'package:plass_ui_example/demos/card/slots.dart';
import 'package:plass_ui_example/demos/card/variants.dart';
import 'package:plass_ui_example/demos/chip/colors.dart';
import 'package:plass_ui_example/demos/chip/hero.dart';
import 'package:plass_ui_example/demos/chip/interactive.dart';
import 'package:plass_ui_example/demos/chip/selected.dart';
import 'package:plass_ui_example/demos/chip/sizes.dart';
import 'package:plass_ui_example/demos/chip/slots.dart';
import 'package:plass_ui_example/demos/chip/variants.dart';
import 'package:plass_ui_example/demos/chat_bubble/actions.dart';
import 'package:plass_ui_example/demos/chat_bubble/hero.dart';
import 'package:plass_ui_example/demos/chat_bubble/media.dart';
import 'package:plass_ui_example/demos/chat_bubble/sides.dart';
import 'package:plass_ui_example/demos/chat_bubble/sizes.dart';
import 'package:plass_ui_example/demos/chat_bubble/status.dart';
import 'package:plass_ui_example/demos/chat_bubble/variants.dart';
import 'package:plass_ui_example/demos/checkbox/colors.dart';
import 'package:plass_ui_example/demos/checkbox/hero.dart';
import 'package:plass_ui_example/demos/checkbox/indeterminate.dart';
import 'package:plass_ui_example/demos/checkbox/sizes.dart';
import 'package:plass_ui_example/demos/checkbox/states.dart';
import 'package:plass_ui_example/demos/collapsible/hero.dart';
import 'package:plass_ui_example/demos/collapsible/slots.dart';
import 'package:plass_ui_example/demos/collapsible/trigger.dart';
import 'package:plass_ui_example/demos/collapsible/variants.dart';
import 'package:plass_ui_example/demos/combobox/custom.dart';
import 'package:plass_ui_example/demos/combobox/hero.dart';
import 'package:plass_ui_example/demos/combobox/multiple.dart';
import 'package:plass_ui_example/demos/combobox/sizes.dart';
import 'package:plass_ui_example/demos/combobox/states.dart';
import 'package:plass_ui_example/demos/container/centered.dart';
import 'package:plass_ui_example/demos/container/hero.dart';
import 'package:plass_ui_example/demos/container/padding.dart';
import 'package:plass_ui_example/demos/container/widths.dart';
import 'package:plass_ui_example/demos/date_picker/bounds.dart';
import 'package:plass_ui_example/demos/date_picker/format.dart';
import 'package:plass_ui_example/demos/date_picker/hero.dart';
import 'package:plass_ui_example/demos/date_picker/locales.dart';
import 'package:plass_ui_example/demos/date_picker/states.dart';
import 'package:plass_ui_example/demos/date_range_picker/bounds.dart';
import 'package:plass_ui_example/demos/date_range_picker/controlled.dart';
import 'package:plass_ui_example/demos/date_range_picker/hero.dart';
import 'package:plass_ui_example/demos/date_range_picker/months.dart';
import 'package:plass_ui_example/demos/date_range_picker/presets.dart';
import 'package:plass_ui_example/demos/date_time_picker/hero.dart';
import 'package:plass_ui_example/demos/date_time_picker/precision.dart';
import 'package:plass_ui_example/demos/date_time_picker/states.dart';
import 'package:plass_ui_example/demos/date_time_picker/steps.dart';
import 'package:plass_ui_example/demos/divider/colors.dart';
import 'package:plass_ui_example/demos/divider/hero.dart';
import 'package:plass_ui_example/demos/divider/label.dart';
import 'package:plass_ui_example/demos/divider/length.dart';
import 'package:plass_ui_example/demos/divider/orientation.dart';
import 'package:plass_ui_example/demos/divider/sizes.dart';
import 'package:plass_ui_example/demos/drawer/hero.dart';
import 'package:plass_ui_example/demos/drawer/inline.dart';
import 'package:plass_ui_example/demos/drawer/sides.dart';
import 'package:plass_ui_example/demos/file_picker/hero.dart';
import 'package:plass_ui_example/demos/file_picker/rejections.dart';
import 'package:plass_ui_example/demos/file_picker/single.dart';
import 'package:plass_ui_example/demos/file_picker/sizes.dart';
import 'package:plass_ui_example/demos/file_picker/states.dart';
import 'package:plass_ui_example/demos/file_picker/variants.dart';
import 'package:plass_ui_example/demos/grid/alignment.dart';
import 'package:plass_ui_example/demos/grid/hero.dart';
import 'package:plass_ui_example/demos/grid/offset.dart';
import 'package:plass_ui_example/demos/grid/responsive.dart';
import 'package:plass_ui_example/demos/grid/spacing.dart';
import 'package:plass_ui_example/demos/grid/span.dart';
import 'package:plass_ui_example/demos/floating_bottom_navigation/colors.dart';
import 'package:plass_ui_example/demos/floating_bottom_navigation/hero.dart';
import 'package:plass_ui_example/demos/floating_bottom_navigation/sizes.dart';
import 'package:plass_ui_example/demos/floating_bottom_navigation/variants.dart';
import 'package:plass_ui_example/demos/highlight/colors.dart';
import 'package:plass_ui_example/demos/highlight/hero.dart';
import 'package:plass_ui_example/demos/highlight/matching.dart';
import 'package:plass_ui_example/demos/highlight/variants.dart';
import 'package:plass_ui_example/demos/hot_keys/cluster.dart';
import 'package:plass_ui_example/demos/hot_keys/hero.dart';
import 'package:plass_ui_example/demos/hot_keys/list.dart';
import 'package:plass_ui_example/demos/hot_keys/os.dart';
import 'package:plass_ui_example/demos/hot_keys/sizes.dart';
import 'package:plass_ui_example/demos/hot_keys/variants.dart';
import 'package:plass_ui_example/demos/icon/anything.dart';
import 'package:plass_ui_example/demos/icon/colors.dart';
import 'package:plass_ui_example/demos/icon/hero.dart';
import 'package:plass_ui_example/demos/icon/inside.dart';
import 'package:plass_ui_example/demos/icon/sizes.dart';
import 'package:plass_ui_example/demos/icon_button/colors.dart';
import 'package:plass_ui_example/demos/icon_button/hero.dart';
import 'package:plass_ui_example/demos/icon_button/sizes.dart';
import 'package:plass_ui_example/demos/icon_button/states.dart';
import 'package:plass_ui_example/demos/icon_button/variants.dart';
import 'package:plass_ui_example/demos/list/dividers.dart';
import 'package:plass_ui_example/demos/list/hero.dart';
import 'package:plass_ui_example/demos/list/rows.dart';
import 'package:plass_ui_example/demos/list/sizes.dart';
import 'package:plass_ui_example/demos/list/variants.dart';
import 'package:plass_ui_example/demos/menu/groups.dart';
import 'package:plass_ui_example/demos/menu/hero.dart';
import 'package:plass_ui_example/demos/menu/rows.dart';
import 'package:plass_ui_example/demos/menu/selection.dart';
import 'package:plass_ui_example/demos/menu/sizes.dart';
import 'package:plass_ui_example/demos/menu/submenu.dart';
import 'package:plass_ui_example/demos/modal/controlled.dart';
import 'package:plass_ui_example/demos/modal/dismissible.dart';
import 'package:plass_ui_example/demos/modal/dividers.dart';
import 'package:plass_ui_example/demos/modal/hero.dart';
import 'package:plass_ui_example/demos/modal/sizes.dart';
import 'package:plass_ui_example/demos/number_field/format.dart';
import 'package:plass_ui_example/demos/number_field/hero.dart';
import 'package:plass_ui_example/demos/number_field/sizes.dart';
import 'package:plass_ui_example/demos/number_field/states.dart';
import 'package:plass_ui_example/demos/number_field/steppers.dart';
import 'package:plass_ui_example/demos/number_field/steps.dart';
import 'package:plass_ui_example/demos/number_field/variants.dart';
import 'package:plass_ui_example/demos/otp_field/charset.dart';
import 'package:plass_ui_example/demos/otp_field/hero.dart';
import 'package:plass_ui_example/demos/otp_field/length.dart';
import 'package:plass_ui_example/demos/otp_field/sizes.dart';
import 'package:plass_ui_example/demos/otp_field/states.dart';
import 'package:plass_ui_example/demos/otp_field/variants.dart';
import 'package:plass_ui_example/demos/overlay/align.dart';
import 'package:plass_ui_example/demos/overlay/dismissible.dart';
import 'package:plass_ui_example/demos/overlay/hero.dart';
import 'package:plass_ui_example/demos/overlay/tones.dart';
import 'package:plass_ui_example/demos/pagination/hero.dart';
import 'package:plass_ui_example/demos/pagination/sizes.dart';
import 'package:plass_ui_example/demos/pagination/steppers.dart';
import 'package:plass_ui_example/demos/pagination/variants.dart';
import 'package:plass_ui_example/demos/pagination/window.dart';
import 'package:plass_ui_example/demos/panes/constraints.dart';
import 'package:plass_ui_example/demos/panes/fixed.dart';
import 'package:plass_ui_example/demos/panes/hero.dart';
import 'package:plass_ui_example/demos/panes/orientation.dart';
import 'package:plass_ui_example/demos/panes/sizes.dart';
import 'package:plass_ui_example/demos/pill/details.dart';
import 'package:plass_ui_example/demos/pill/hero.dart';
import 'package:plass_ui_example/demos/pill/sizes.dart';
import 'package:plass_ui_example/demos/pill/variants.dart';
import 'package:plass_ui_example/demos/popover/form.dart';
import 'package:plass_ui_example/demos/popover/hero.dart';
import 'package:plass_ui_example/demos/popover/sides.dart';
import 'package:plass_ui_example/demos/progress_box/colors.dart';
import 'package:plass_ui_example/demos/progress_box/count.dart';
import 'package:plass_ui_example/demos/progress_box/hero.dart';
import 'package:plass_ui_example/demos/progress_box/indeterminate.dart';
import 'package:plass_ui_example/demos/progress_box/sizes.dart';
import 'package:plass_ui_example/demos/progress_circular/colors.dart';
import 'package:plass_ui_example/demos/progress_circular/hero.dart';
import 'package:plass_ui_example/demos/progress_circular/indeterminate.dart';
import 'package:plass_ui_example/demos/progress_circular/inline.dart';
import 'package:plass_ui_example/demos/progress_circular/sizes.dart';
import 'package:plass_ui_example/demos/progress_linear/colors.dart';
import 'package:plass_ui_example/demos/progress_linear/format.dart';
import 'package:plass_ui_example/demos/progress_linear/hero.dart';
import 'package:plass_ui_example/demos/progress_linear/indeterminate.dart';
import 'package:plass_ui_example/demos/progress_linear/sizes.dart';
import 'package:plass_ui_example/demos/radio_group/colors.dart';
import 'package:plass_ui_example/demos/radio_group/controlled.dart';
import 'package:plass_ui_example/demos/radio_group/hero.dart';
import 'package:plass_ui_example/demos/radio_group/orientation.dart';
import 'package:plass_ui_example/demos/radio_group/sizes.dart';
import 'package:plass_ui_example/demos/radio_group/states.dart';
import 'package:plass_ui_example/demos/rating/average.dart';
import 'package:plass_ui_example/demos/rating/colors.dart';
import 'package:plass_ui_example/demos/rating/hero.dart';
import 'package:plass_ui_example/demos/rating/icons.dart';
import 'package:plass_ui_example/demos/rating/precision.dart';
import 'package:plass_ui_example/demos/rating/sizes.dart';
import 'package:plass_ui_example/demos/rating/states.dart';
import 'package:plass_ui_example/demos/scroll_zone/buttons.dart';
import 'package:plass_ui_example/demos/scroll_zone/hero.dart';
import 'package:plass_ui_example/demos/scroll_zone/lines.dart';
import 'package:plass_ui_example/demos/scroll_zone/placement.dart';
import 'package:plass_ui_example/demos/segmented_button/colors.dart';
import 'package:plass_ui_example/demos/segmented_button/full_width.dart';
import 'package:plass_ui_example/demos/segmented_button/hero.dart';
import 'package:plass_ui_example/demos/segmented_button/icons.dart';
import 'package:plass_ui_example/demos/segmented_button/sizes.dart';
import 'package:plass_ui_example/demos/segmented_button/variants.dart';
import 'package:plass_ui_example/demos/select/controlled.dart';
import 'package:plass_ui_example/demos/select/hero.dart';
import 'package:plass_ui_example/demos/select/icons.dart';
import 'package:plass_ui_example/demos/select/sizes.dart';
import 'package:plass_ui_example/demos/select/states.dart';
import 'package:plass_ui_example/demos/select/variants.dart';
import 'package:plass_ui_example/demos/skeleton/animated.dart';
import 'package:plass_ui_example/demos/skeleton/hero.dart';
import 'package:plass_ui_example/demos/skeleton/matching.dart';
import 'package:plass_ui_example/demos/skeleton/shapes.dart';
import 'package:plass_ui_example/demos/skeleton/sizes.dart';
import 'package:plass_ui_example/demos/slider/colors.dart';
import 'package:plass_ui_example/demos/slider/hero.dart';
import 'package:plass_ui_example/demos/slider/orientation.dart';
import 'package:plass_ui_example/demos/slider/range.dart';
import 'package:plass_ui_example/demos/slider/sizes.dart';
import 'package:plass_ui_example/demos/slider/states.dart';
import 'package:plass_ui_example/demos/slider/steps.dart';
import 'package:plass_ui_example/demos/spoiler/clamped.dart';
import 'package:plass_ui_example/demos/spoiler/hero.dart';
import 'package:plass_ui_example/demos/spoiler/media.dart';
import 'package:plass_ui_example/demos/spoiler/variants.dart';
import 'package:plass_ui_example/demos/switch/colors.dart';
import 'package:plass_ui_example/demos/switch/hero.dart';
import 'package:plass_ui_example/demos/switch/placement.dart';
import 'package:plass_ui_example/demos/switch/sizes.dart';
import 'package:plass_ui_example/demos/switch/states.dart';
import 'package:plass_ui_example/demos/table/columns.dart';
import 'package:plass_ui_example/demos/table/density.dart';
import 'package:plass_ui_example/demos/table/empty.dart';
import 'package:plass_ui_example/demos/table/hero.dart';
import 'package:plass_ui_example/demos/table/rows.dart';
import 'package:plass_ui_example/demos/table/scroll.dart';
import 'package:plass_ui_example/demos/table/striped.dart';
import 'package:plass_ui_example/demos/table/variants.dart';
import 'package:plass_ui_example/demos/tabs/controlled.dart';
import 'package:plass_ui_example/demos/tabs/full_width.dart';
import 'package:plass_ui_example/demos/tabs/hero.dart';
import 'package:plass_ui_example/demos/tabs/orientation.dart';
import 'package:plass_ui_example/demos/tabs/sizes.dart';
import 'package:plass_ui_example/demos/tabs/variants.dart';
import 'package:plass_ui_example/demos/text_field/controlled.dart';
import 'package:plass_ui_example/demos/text_field/hero.dart';
import 'package:plass_ui_example/demos/text_field/icons.dart';
import 'package:plass_ui_example/demos/text_field/multiline.dart';
import 'package:plass_ui_example/demos/text_field/sizes.dart';
import 'package:plass_ui_example/demos/text_field/states.dart';
import 'package:plass_ui_example/demos/text_field/validation.dart';
import 'package:plass_ui_example/demos/text_field/variants.dart';
import 'package:plass_ui_example/demos/text_link/colors.dart';
import 'package:plass_ui_example/demos/text_link/hero.dart';
import 'package:plass_ui_example/demos/text_link/icons.dart';
import 'package:plass_ui_example/demos/text_link/sizes.dart';
import 'package:plass_ui_example/demos/text_link/underline.dart';
import 'package:plass_ui_example/demos/time_picker/bounds.dart';
import 'package:plass_ui_example/demos/time_picker/dials.dart';
import 'package:plass_ui_example/demos/time_picker/hero.dart';
import 'package:plass_ui_example/demos/time_picker/states.dart';
import 'package:plass_ui_example/demos/time_picker/steps.dart';
import 'package:plass_ui_example/demos/timeline/active.dart';
import 'package:plass_ui_example/demos/timeline/connectors.dart';
import 'package:plass_ui_example/demos/timeline/hero.dart';
import 'package:plass_ui_example/demos/timeline/orientation.dart';
import 'package:plass_ui_example/demos/timeline/sizes.dart';
import 'package:plass_ui_example/demos/timeline/status.dart';
import 'package:plass_ui_example/demos/toast/colors.dart';
import 'package:plass_ui_example/demos/toast/future.dart';
import 'package:plass_ui_example/demos/toast/hero.dart';
import 'package:plass_ui_example/demos/toast/positions.dart';
import 'package:plass_ui_example/demos/toast/update.dart';
import 'package:plass_ui_example/demos/toast/variants.dart';
import 'package:plass_ui_example/demos/toolbar/density.dart';
import 'package:plass_ui_example/demos/toolbar/hero.dart';
import 'package:plass_ui_example/demos/toolbar/slots.dart';
import 'package:plass_ui_example/demos/toolbar/variants.dart';
import 'package:plass_ui_example/demos/tooltip/align.dart';
import 'package:plass_ui_example/demos/tooltip/delay.dart';
import 'package:plass_ui_example/demos/tooltip/hero.dart';
import 'package:plass_ui_example/demos/tooltip/provider.dart';
import 'package:plass_ui_example/demos/tooltip/sides.dart';
import 'package:plass_ui_example/demos/tooltip/sizes.dart';
import 'package:plass_ui_example/demos/typography/colors.dart';
import 'package:plass_ui_example/demos/typography/hero.dart';
import 'package:plass_ui_example/demos/typography/levels.dart';
import 'package:plass_ui_example/demos/typography/lines.dart';
import 'package:plass_ui_example/demos/typography/weight.dart';

/// Every demo, under the key the documentation asks for it by.
///
/// The keys are the same strings the React demos live at — `<Demo
/// src="button/variants" />` in the Markdown resolves to
/// `.vitepress/demos/button/variants.tsx` on one side and to this map on the
/// other — so a preview that exists in both packages needs no second list
/// anywhere to say so.
///
/// A React demo with no entry here is one the Flutter package has not reached
/// yet, and the gallery says exactly that rather than rendering an empty box.
const Map<String, WidgetBuilder> demos = <String, WidgetBuilder>{
  'button/hero': _hero,
  'button/variants': _variants,
  'button/colors': _colors,
  'button/sizes': _sizes,
  'button/density': _density,
  'button/icons': _icons,
  'button/states': _states,
  'button/elevation': _elevation,
  'button/full-width': _fullWidth,
  'date-range-picker/hero': _dateRangePickerHero,
  'date-range-picker/months': _dateRangePickerMonths,
  'date-range-picker/presets': _dateRangePickerPresets,
  'date-range-picker/bounds': _dateRangePickerBounds,
  'date-range-picker/controlled': _dateRangePickerControlled,
  'time-picker/hero': _timePickerHero,
  'time-picker/dials': _timePickerDials,
  'time-picker/steps': _timePickerSteps,
  'time-picker/bounds': _timePickerBounds,
  'time-picker/states': _timePickerStates,
  'date-time-picker/hero': _dateTimePickerHero,
  'date-time-picker/precision': _dateTimePickerPrecision,
  'date-time-picker/steps': _dateTimePickerSteps,
  'date-time-picker/states': _dateTimePickerStates,
  'date-picker/hero': _datePickerHero,
  'date-picker/locales': _datePickerLocales,
  'date-picker/bounds': _datePickerBounds,
  'date-picker/format': _datePickerFormat,
  'date-picker/states': _datePickerStates,
  'combobox/hero': _comboboxHero,
  'combobox/custom': _comboboxCustom,
  'combobox/multiple': _comboboxMultiple,
  'combobox/sizes': _comboboxSizes,
  'combobox/states': _comboboxStates,
  'progress-box/hero': _progressBoxHero,
  'progress-box/indeterminate': _progressBoxIndeterminate,
  'progress-box/count': _progressBoxCount,
  'progress-box/sizes': _progressBoxSizes,
  'progress-box/colors': _progressBoxColors,
  'progress-circular/hero': _progressCircularHero,
  'progress-circular/indeterminate': _progressCircularIndeterminate,
  'progress-circular/sizes': _progressCircularSizes,
  'progress-circular/colors': _progressCircularColors,
  'progress-circular/inline': _progressCircularInline,
  'progress-linear/hero': _progressLinearHero,
  'progress-linear/indeterminate': _progressLinearIndeterminate,
  'progress-linear/sizes': _progressLinearSizes,
  'progress-linear/colors': _progressLinearColors,
  'progress-linear/format': _progressLinearFormat,
  'button-group/hero': _buttonGroupHero,
  'button-group/variants': _buttonGroupVariants,
  'button-group/sizes': _buttonGroupSizes,
  'button-group/orientation': _buttonGroupOrientation,
  'button-group/full-width': _buttonGroupFullWidth,
  'typography/hero': _typographyHero,
  'typography/levels': _typographyLevels,
  'typography/weight': _typographyWeight,
  'typography/colors': _typographyColors,
  'typography/lines': _typographyLines,
  'icon/hero': _iconHero,
  'icon/sizes': _iconSizes,
  'icon/colors': _iconColors,
  'icon/inside': _iconInside,
  'icon/anything': _iconAnything,
  'divider/hero': _dividerHero,
  'divider/orientation': _dividerOrientation,
  'divider/label': _dividerLabel,
  'divider/colors': _dividerColors,
  'divider/sizes': _dividerSizes,
  'divider/length': _dividerLength,
  'skeleton/shapes': _skeletonShapes,
  'skeleton/sizes': _skeletonSizes,
  'skeleton/animated': _skeletonAnimated,
  'aspect-ratio/hero': _aspectRatioHero,
  'aspect-ratio/ratios': _aspectRatioRatios,
  'aspect-ratio/fit': _aspectRatioFit,
  'aspect-ratio/embed': _aspectRatioEmbed,
  'floating-bottom-navigation/hero': _floatingBottomNavigationHero,
  'floating-bottom-navigation/variants': _floatingBottomNavigationVariants,
  'floating-bottom-navigation/colors': _floatingBottomNavigationColors,
  'floating-bottom-navigation/sizes': _floatingBottomNavigationSizes,
  'menu/hero': _menuHero,
  'menu/rows': _menuRows,
  'menu/groups': _menuGroups,
  'menu/selection': _menuSelection,
  'menu/submenu': _menuSubmenu,
  'menu/sizes': _menuSizes,
  'bottom-navigation/hero': _bottomNavigationHero,
  'bottom-navigation/labels': _bottomNavigationLabels,
  'bottom-navigation/variants': _bottomNavigationVariants,
  'bottom-navigation/sizes': _bottomNavigationSizes,
  'otp-field/hero': _otpFieldHero,
  'otp-field/length': _otpFieldLength,
  'otp-field/charset': _otpFieldCharset,
  'otp-field/variants': _otpFieldVariants,
  'otp-field/sizes': _otpFieldSizes,
  'otp-field/states': _otpFieldStates,
  'rating/hero': _ratingHero,
  'rating/precision': _ratingPrecision,
  'rating/average': _ratingAverage,
  'rating/icons': _ratingIcons,
  'rating/sizes': _ratingSizes,
  'rating/colors': _ratingColors,
  'rating/states': _ratingStates,
  'icon-button/hero': _iconButtonHero,
  'icon-button/variants': _iconButtonVariants,
  'icon-button/sizes': _iconButtonSizes,
  'icon-button/colors': _iconButtonColors,
  'icon-button/states': _iconButtonStates,
  'panes/hero': _panesHero,
  'panes/orientation': _panesOrientation,
  'panes/constraints': _panesConstraints,
  'panes/fixed': _panesFixed,
  'panes/sizes': _panesSizes,
  'grid/hero': _gridHero,
  'grid/span': _gridSpan,
  'grid/responsive': _gridResponsive,
  'grid/offset': _gridOffset,
  'grid/spacing': _gridSpacing,
  'grid/alignment': _gridAlignment,
  'container/hero': _containerHero,
  'container/widths': _containerWidths,
  'container/padding': _containerPadding,
  'container/centered': _containerCentered,
  'blockquote/hero': _blockquoteHero,
  'blockquote/variants': _blockquoteVariants,
  'blockquote/sizes': _blockquoteSizes,
  'blockquote/colors': _blockquoteColors,
  'blockquote/attribution': _blockquoteAttribution,
  'highlight/variants': _highlightVariants,
  'highlight/colors': _highlightColors,
  'highlight/matching': _highlightMatching,
  'select/hero': _selectHero,
  'select/variants': _selectVariants,
  'select/sizes': _selectSizes,
  'select/states': _selectStates,
  'select/controlled': _selectControlled,
  'select/icons': _selectIcons,
  'skeleton/hero': _skeletonHero,
  'skeleton/matching': _skeletonMatching,
  'avatar/hero': _avatarHero,
  'avatar/variants': _avatarVariants,
  'avatar/sizes': _avatarSizes,
  'avatar/shapes': _avatarShapes,
  'avatar/colors': _avatarColors,
  'avatar/fallback': _avatarFallback,
  'avatar/group': _avatarGroup,
  'badge/hero': _badgeHero,
  'badge/variants': _badgeVariants,
  'badge/sizes': _badgeSizes,
  'badge/colors': _badgeColors,
  'badge/dot': _badgeDot,
  'badge/counts': _badgeCounts,
  'badge/placement': _badgePlacement,
  'badge/overlap': _badgeOverlap,
  'chip/hero': _chipHero,
  'chip/variants': _chipVariants,
  'chip/sizes': _chipSizes,
  'chip/colors': _chipColors,
  'chip/selected': _chipSelected,
  'chip/interactive': _chipInteractive,
  'chip/slots': _chipSlots,
  'card/hero': _cardHero,
  'card/variants': _cardVariants,
  'card/sizes': _cardSizes,
  'card/slots': _cardSlots,
  'card/dividers': _cardDividers,
  'card/padded': _cardPadded,
  'card/interactive': _cardInteractive,
  'alert/hero': _alertHero,
  'alert/variants': _alertVariants,
  'alert/sizes': _alertSizes,
  'alert/colors': _alertColors,
  'alert/shapes': _alertShapes,
  'alert/dismiss': _alertDismiss,
  'text-link/hero': _textLinkHero,
  'text-link/underline': _textLinkUnderline,
  'text-link/colors': _textLinkColors,
  'text-link/sizes': _textLinkSizes,
  'text-link/icons': _textLinkIcons,
  'hot-keys/hero': _hotKeysHero,
  'hot-keys/variants': _hotKeysVariants,
  'hot-keys/sizes': _hotKeysSizes,
  'hot-keys/os': _hotKeysOs,
  'hot-keys/cluster': _hotKeysCluster,
  'hot-keys/list': _hotKeysList,
  'list/rows': _listRows,
  'list/variants': _listVariants,
  'list/sizes': _listSizes,
  'list/dividers': _listDividers,
  'breadcrumb/hero': _breadcrumbHero,
  'breadcrumb/separators': _breadcrumbSeparators,
  'breadcrumb/collapse': _breadcrumbCollapse,
  'breadcrumb/current': _breadcrumbCurrent,
  'breadcrumb/sizes': _breadcrumbSizes,
  'timeline/hero': _timelineHero,
  'timeline/status': _timelineStatus,
  'timeline/active': _timelineActive,
  'timeline/connectors': _timelineConnectors,
  'timeline/orientation': _timelineOrientation,
  'timeline/sizes': _timelineSizes,
  'list/hero': _listHero,
  'chat-bubble/hero': _chatBubbleHero,
  'chat-bubble/sides': _chatBubbleSides,
  'chat-bubble/variants': _chatBubbleVariants,
  'chat-bubble/status': _chatBubbleStatus,
  'chat-bubble/media': _chatBubbleMedia,
  'chat-bubble/actions': _chatBubbleActions,
  'chat-bubble/sizes': _chatBubbleSizes,
  'checkbox/hero': _checkboxHero,
  'checkbox/sizes': _checkboxSizes,
  'checkbox/colors': _checkboxColors,
  'checkbox/states': _checkboxStates,
  'checkbox/indeterminate': _checkboxIndeterminate,
  'radio-group/hero': _radioGroupHero,
  'radio-group/orientation': _radioGroupOrientation,
  'radio-group/sizes': _radioGroupSizes,
  'radio-group/colors': _radioGroupColors,
  'radio-group/states': _radioGroupStates,
  'radio-group/controlled': _radioGroupControlled,
  'switch/hero': _switchHero,
  'switch/sizes': _switchSizes,
  'switch/colors': _switchColors,
  'switch/states': _switchStates,
  'switch/placement': _switchPlacement,
  'file-picker/hero': _filePickerHero,
  'file-picker/variants': _filePickerVariants,
  'file-picker/rejections': _filePickerRejections,
  'file-picker/single': _filePickerSingle,
  'file-picker/sizes': _filePickerSizes,
  'file-picker/states': _filePickerStates,
  'highlight/hero': _highlightHero,
  'text-field/hero': _textFieldHero,
  'text-field/variants': _textFieldVariants,
  'text-field/sizes': _textFieldSizes,
  'text-field/states': _textFieldStates,
  'text-field/icons': _textFieldIcons,
  'text-field/multiline': _textFieldMultiline,
  'text-field/validation': _textFieldValidation,
  'text-field/controlled': _textFieldControlled,
  'slider/hero': _sliderHero,
  'slider/sizes': _sliderSizes,
  'slider/colors': _sliderColors,
  'slider/orientation': _sliderOrientation,
  'slider/range': _sliderRange,
  'slider/states': _sliderStates,
  'slider/steps': _sliderSteps,
  'toolbar/hero': _toolbarHero,
  'toolbar/slots': _toolbarSlots,
  'toolbar/variants': _toolbarVariants,
  'toolbar/density': _toolbarDensity,
  'spoiler/hero': _spoilerHero,
  'spoiler/variants': _spoilerVariants,
  'spoiler/clamped': _spoilerClamped,
  'spoiler/media': _spoilerMedia,
  'popover/hero': _popoverHero,
  'popover/sides': _popoverSides,
  'popover/form': _popoverForm,
  'pill/hero': _pillHero,
  'pill/variants': _pillVariants,
  'pill/details': _pillDetails,
  'pill/sizes': _pillSizes,
  'drawer/hero': _drawerHero,
  'drawer/sides': _drawerSides,
  'drawer/inline': _drawerInline,
  'collapsible/hero': _collapsibleHero,
  'collapsible/variants': _collapsibleVariants,
  'collapsible/slots': _collapsibleSlots,
  'collapsible/trigger': _collapsibleTrigger,
  'carousel/hero': _carouselHero,
  'carousel/variants': _carouselVariants,
  'carousel/loop': _carouselLoop,
  'carousel/auto-play': _carouselAutoPlay,
  'box/hero': _boxHero,
  'box/variants': _boxVariants,
  'box/sizes': _boxSizes,
  'box/padded': _boxPadded,
  'scroll-zone/hero': _scrollZoneHero,
  'scroll-zone/lines': _scrollZoneLines,
  'scroll-zone/buttons': _scrollZoneButtons,
  'scroll-zone/placement': _scrollZonePlacement,
  'segmented-button/hero': _segmentedButtonHero,
  'segmented-button/variants': _segmentedButtonVariants,
  'segmented-button/sizes': _segmentedButtonSizes,
  'segmented-button/colors': _segmentedButtonColors,
  'segmented-button/icons': _segmentedButtonIcons,
  'segmented-button/full-width': _segmentedButtonFullWidth,
  'modal/hero': _modalHero,
  'modal/sizes': _modalSizes,
  'modal/dividers': _modalDividers,
  'modal/controlled': _modalControlled,
  'modal/dismissible': _modalDismissible,
  'overlay/hero': _overlayHero,
  'overlay/tones': _overlayTones,
  'overlay/dismissible': _overlayDismissible,
  'overlay/align': _overlayAlign,
  'number-field/hero': _numberFieldHero,
  'number-field/steppers': _numberFieldSteppers,
  'number-field/format': _numberFieldFormat,
  'number-field/steps': _numberFieldSteps,
  'number-field/variants': _numberFieldVariants,
  'number-field/states': _numberFieldStates,
  'number-field/sizes': _numberFieldSizes,
  'pagination/hero': _paginationHero,
  'pagination/variants': _paginationVariants,
  'pagination/sizes': _paginationSizes,
  'pagination/window': _paginationWindow,
  'pagination/steppers': _paginationSteppers,
  'accordion/hero': _accordionHero,
  'accordion/variants': _accordionVariants,
  'accordion/sizes': _accordionSizes,
  'accordion/multiple': _accordionMultiple,
  'accordion/dividers': _accordionDividers,
  'accordion/slots': _accordionSlots,
  'accordion/controlled': _accordionControlled,
  'table/hero': _tableHero,
  'table/variants': _tableVariants,
  'table/columns': _tableColumns,
  'table/striped': _tableStriped,
  'table/scroll': _tableScroll,
  'table/rows': _tableRows,
  'table/empty': _tableEmpty,
  'table/density': _tableDensity,
  'toast/hero': _toastHero,
  'toast/positions': _toastPositions,
  'toast/variants': _toastVariants,
  'toast/colors': _toastColors,
  'toast/update': _toastUpdate,
  'toast/promise': _toastFuture,
  'tooltip/hero': _tooltipHero,
  'tooltip/sides': _tooltipSides,
  'tooltip/align': _tooltipAlign,
  'tooltip/provider': _tooltipProvider,
  'tooltip/delay': _tooltipDelay,
  'tooltip/sizes': _tooltipSizes,
  'tabs/hero': _tabsHero,
  'tabs/variants': _tabsVariants,
  'tabs/sizes': _tabsSizes,
  'tabs/orientation': _tabsOrientation,
  'tabs/full-width': _tabsFullWidth,
  'tabs/controlled': _tabsControlled,
  'animate-fade/hero': _animateFadeHero,
  'animate-fade/mode': _animateFadeMode,
  'animate-fade/timing': _animateFadeTiming,
  'animate-fade/triggers': _animateFadeTriggers,
  'animate-grow/hero': _animateGrowHero,
  'animate-grow/origin': _animateGrowOrigin,
  'animate-grow/from': _animateGrowFrom,
  'animate-grow/panel': _animateGrowPanel,
};

Widget _hero(BuildContext context) => const ButtonHero();
Widget _variants(BuildContext context) => const ButtonVariants();
Widget _dateRangePickerHero(BuildContext context) => const DateRangePickerHero();
Widget _dateRangePickerMonths(BuildContext context) => const DateRangePickerMonths();
Widget _dateRangePickerPresets(BuildContext context) => const DateRangePickerPresets();
Widget _dateRangePickerBounds(BuildContext context) => const DateRangePickerBounds();
Widget _dateRangePickerControlled(BuildContext context) => const DateRangePickerControlled();
Widget _timePickerHero(BuildContext context) => const TimePickerHero();
Widget _timePickerDials(BuildContext context) => const TimePickerDials();
Widget _timePickerSteps(BuildContext context) => const TimePickerSteps();
Widget _timePickerBounds(BuildContext context) => const TimePickerBounds();
Widget _timePickerStates(BuildContext context) => const TimePickerStates();
Widget _dateTimePickerHero(BuildContext context) => const DateTimePickerHero();
Widget _dateTimePickerPrecision(BuildContext context) => const DateTimePickerPrecision();
Widget _dateTimePickerSteps(BuildContext context) => const DateTimePickerSteps();
Widget _dateTimePickerStates(BuildContext context) => const DateTimePickerStates();
Widget _datePickerHero(BuildContext context) => const DatePickerHero();
Widget _datePickerLocales(BuildContext context) => const DatePickerLocales();
Widget _datePickerBounds(BuildContext context) => const DatePickerBounds();
Widget _datePickerFormat(BuildContext context) => const DatePickerFormat();
Widget _datePickerStates(BuildContext context) => const DatePickerStates();
Widget _comboboxHero(BuildContext context) => const ComboboxHero();
Widget _comboboxCustom(BuildContext context) => const ComboboxCustom();
Widget _comboboxMultiple(BuildContext context) => const ComboboxMultiple();
Widget _comboboxSizes(BuildContext context) => const ComboboxSizes();
Widget _comboboxStates(BuildContext context) => const ComboboxStates();
Widget _progressBoxHero(BuildContext context) => const ProgressBoxHero();
Widget _progressBoxIndeterminate(BuildContext context) => const ProgressBoxIndeterminate();
Widget _progressBoxCount(BuildContext context) => const ProgressBoxCount();
Widget _progressBoxSizes(BuildContext context) => const ProgressBoxSizes();
Widget _progressBoxColors(BuildContext context) => const ProgressBoxColors();
Widget _progressCircularHero(BuildContext context) => const ProgressCircularHero();
Widget _progressCircularIndeterminate(BuildContext context) =>
    const ProgressCircularIndeterminate();
Widget _progressCircularSizes(BuildContext context) => const ProgressCircularSizes();
Widget _progressCircularColors(BuildContext context) => const ProgressCircularColors();
Widget _progressCircularInline(BuildContext context) => const ProgressCircularInline();
Widget _progressLinearHero(BuildContext context) => const ProgressLinearHero();
Widget _progressLinearIndeterminate(BuildContext context) => const ProgressLinearIndeterminate();
Widget _progressLinearSizes(BuildContext context) => const ProgressLinearSizes();
Widget _progressLinearColors(BuildContext context) => const ProgressLinearColors();
Widget _progressLinearFormat(BuildContext context) => const ProgressLinearFormat();
Widget _buttonGroupHero(BuildContext context) => const ButtonGroupHero();
Widget _buttonGroupVariants(BuildContext context) => const ButtonGroupVariants();
Widget _buttonGroupSizes(BuildContext context) => const ButtonGroupSizes();
Widget _buttonGroupOrientation(BuildContext context) => const ButtonGroupOrientation();
Widget _buttonGroupFullWidth(BuildContext context) => const ButtonGroupFullWidth();
Widget _colors(BuildContext context) => const ButtonColors();
Widget _sizes(BuildContext context) => const ButtonSizes();
Widget _density(BuildContext context) => const ButtonDensity();
Widget _icons(BuildContext context) => const ButtonIcons();
Widget _states(BuildContext context) => const ButtonStates();
Widget _elevation(BuildContext context) => const ButtonElevation();
Widget _fullWidth(BuildContext context) => const ButtonFullWidth();

Widget _typographyHero(BuildContext context) => const TypographyHero();
Widget _typographyLevels(BuildContext context) => const TypographyLevels();
Widget _typographyWeight(BuildContext context) => const TypographyWeight();
Widget _typographyColors(BuildContext context) => const TypographyColors();
Widget _typographyLines(BuildContext context) => const TypographyLines();

Widget _iconHero(BuildContext context) => const IconHero();
Widget _iconSizes(BuildContext context) => const IconSizes();
Widget _iconColors(BuildContext context) => const IconColors();
Widget _iconInside(BuildContext context) => const IconInside();
Widget _iconAnything(BuildContext context) => const IconAnything();

Widget _dividerHero(BuildContext context) => const DividerHero();
Widget _dividerOrientation(BuildContext context) => const DividerOrientation();
Widget _dividerLabel(BuildContext context) => const DividerLabel();
Widget _dividerColors(BuildContext context) => const DividerColors();
Widget _dividerSizes(BuildContext context) => const DividerSizes();
Widget _dividerLength(BuildContext context) => const DividerLength();

Widget _skeletonShapes(BuildContext context) => const SkeletonShapes();
Widget _skeletonSizes(BuildContext context) => const SkeletonSizes();
Widget _skeletonAnimated(BuildContext context) => const SkeletonAnimated();

Widget _aspectRatioHero(BuildContext context) => const AspectRatioHero();
Widget _aspectRatioRatios(BuildContext context) => const AspectRatioRatios();
Widget _aspectRatioFit(BuildContext context) => const AspectRatioFit();
Widget _aspectRatioEmbed(BuildContext context) => const AspectRatioEmbed();

Widget _floatingBottomNavigationHero(BuildContext context) => const FloatingBottomNavigationHero();
Widget _floatingBottomNavigationVariants(BuildContext context) =>
    const FloatingBottomNavigationVariants();
Widget _floatingBottomNavigationColors(BuildContext context) =>
    const FloatingBottomNavigationColors();
Widget _floatingBottomNavigationSizes(BuildContext context) =>
    const FloatingBottomNavigationSizes();

Widget _menuHero(BuildContext context) => const MenuHero();
Widget _menuRows(BuildContext context) => const MenuRows();
Widget _menuGroups(BuildContext context) => const MenuGroups();
Widget _menuSelection(BuildContext context) => const MenuSelection();
Widget _menuSubmenu(BuildContext context) => const MenuSubmenus();
Widget _menuSizes(BuildContext context) => const MenuSizes();

Widget _bottomNavigationHero(BuildContext context) => const BottomNavigationHero();
Widget _bottomNavigationLabels(BuildContext context) => const BottomNavigationLabels();
Widget _bottomNavigationVariants(BuildContext context) => const BottomNavigationVariants();
Widget _bottomNavigationSizes(BuildContext context) => const BottomNavigationSizes();

Widget _otpFieldHero(BuildContext context) => const OtpFieldHero();
Widget _otpFieldLength(BuildContext context) => const OtpFieldLength();
Widget _otpFieldCharset(BuildContext context) => const OtpFieldCharset();
Widget _otpFieldVariants(BuildContext context) => const OtpFieldVariants();
Widget _otpFieldSizes(BuildContext context) => const OtpFieldSizes();
Widget _otpFieldStates(BuildContext context) => const OtpFieldStates();

Widget _ratingHero(BuildContext context) => const RatingHero();
Widget _ratingPrecision(BuildContext context) => const RatingPrecision();
Widget _ratingAverage(BuildContext context) => const RatingAverage();
Widget _ratingIcons(BuildContext context) => const RatingIcons();
Widget _ratingSizes(BuildContext context) => const RatingSizes();
Widget _ratingColors(BuildContext context) => const RatingColors();
Widget _ratingStates(BuildContext context) => const RatingStates();

Widget _iconButtonHero(BuildContext context) => const IconButtonHero();
Widget _iconButtonVariants(BuildContext context) => const IconButtonVariants();
Widget _iconButtonSizes(BuildContext context) => const IconButtonSizes();
Widget _iconButtonColors(BuildContext context) => const IconButtonColors();
Widget _iconButtonStates(BuildContext context) => const IconButtonStates();

Widget _panesHero(BuildContext context) => const PanesHero();
Widget _panesOrientation(BuildContext context) => const PanesOrientation();
Widget _panesConstraints(BuildContext context) => const PanesConstraints();
Widget _panesFixed(BuildContext context) => const PanesFixed();
Widget _panesSizes(BuildContext context) => const PanesSizes();

Widget _gridHero(BuildContext context) => const GridHero();
Widget _gridSpan(BuildContext context) => const GridSpan();
Widget _gridResponsive(BuildContext context) => const GridResponsive();
Widget _gridOffset(BuildContext context) => const GridOffset();
Widget _gridSpacing(BuildContext context) => const GridSpacing();
Widget _gridAlignment(BuildContext context) => const GridAlignment();

Widget _containerHero(BuildContext context) => const ContainerHero();
Widget _containerWidths(BuildContext context) => const ContainerWidths();
Widget _containerPadding(BuildContext context) => const ContainerPadding();
Widget _containerCentered(BuildContext context) => const ContainerCentered();

Widget _blockquoteHero(BuildContext context) => const BlockquoteHero();
Widget _blockquoteVariants(BuildContext context) => const BlockquoteVariants();
Widget _blockquoteSizes(BuildContext context) => const BlockquoteSizes();
Widget _blockquoteColors(BuildContext context) => const BlockquoteColors();
Widget _blockquoteAttribution(BuildContext context) => const BlockquoteAttribution();

Widget _highlightVariants(BuildContext context) => const HighlightVariants();
Widget _highlightColors(BuildContext context) => const HighlightColors();
Widget _highlightMatching(BuildContext context) => const HighlightMatching();

Widget _skeletonHero(BuildContext context) => const SkeletonHero();
Widget _skeletonMatching(BuildContext context) => const SkeletonMatching();

Widget _avatarHero(BuildContext context) => const AvatarHero();
Widget _avatarVariants(BuildContext context) => const AvatarVariants();
Widget _avatarSizes(BuildContext context) => const AvatarSizes();
Widget _avatarShapes(BuildContext context) => const AvatarShapes();
Widget _avatarColors(BuildContext context) => const AvatarColors();
Widget _avatarFallback(BuildContext context) => const AvatarFallback();
Widget _avatarGroup(BuildContext context) => const AvatarGroup();

Widget _badgeHero(BuildContext context) => const BadgeHero();
Widget _badgeVariants(BuildContext context) => const BadgeVariants();
Widget _badgeSizes(BuildContext context) => const BadgeSizes();
Widget _badgeColors(BuildContext context) => const BadgeColors();
Widget _badgeDot(BuildContext context) => const BadgeDot();
Widget _badgeCounts(BuildContext context) => const BadgeCounts();
Widget _badgePlacement(BuildContext context) => const BadgePlacement();
Widget _badgeOverlap(BuildContext context) => const BadgeOverlap();

Widget _chipHero(BuildContext context) => const ChipHero();
Widget _chipVariants(BuildContext context) => const ChipVariants();
Widget _chipSizes(BuildContext context) => const ChipSizes();
Widget _chipColors(BuildContext context) => const ChipColors();
Widget _chipSelected(BuildContext context) => const ChipSelected();
Widget _chipInteractive(BuildContext context) => const ChipInteractive();
Widget _chipSlots(BuildContext context) => const ChipSlots();

Widget _cardHero(BuildContext context) => const CardHero();
Widget _cardVariants(BuildContext context) => const CardVariants();
Widget _cardSizes(BuildContext context) => const CardSizes();
Widget _cardSlots(BuildContext context) => const CardSlots();
Widget _cardDividers(BuildContext context) => const CardDividers();
Widget _cardPadded(BuildContext context) => const CardPadded();
Widget _cardInteractive(BuildContext context) => const CardInteractive();

Widget _alertHero(BuildContext context) => const AlertHero();
Widget _alertVariants(BuildContext context) => const AlertVariants();
Widget _alertSizes(BuildContext context) => const AlertSizes();
Widget _alertColors(BuildContext context) => const AlertColors();
Widget _alertShapes(BuildContext context) => const AlertShapes();
Widget _alertDismiss(BuildContext context) => const AlertDismiss();

Widget _textLinkHero(BuildContext context) => const TextLinkHero();
Widget _textLinkUnderline(BuildContext context) => const TextLinkUnderline();
Widget _textLinkColors(BuildContext context) => const TextLinkColors();
Widget _textLinkSizes(BuildContext context) => const TextLinkSizes();
Widget _textLinkIcons(BuildContext context) => const TextLinkIcons();

Widget _hotKeysHero(BuildContext context) => const HotKeysHero();
Widget _hotKeysVariants(BuildContext context) => const HotKeysVariants();
Widget _hotKeysSizes(BuildContext context) => const HotKeysSizes();
Widget _hotKeysOs(BuildContext context) => const HotKeysOs();
Widget _hotKeysCluster(BuildContext context) => const HotKeysCluster();
Widget _hotKeysList(BuildContext context) => const HotKeysList();

Widget _listRows(BuildContext context) => const ListRows();
Widget _listVariants(BuildContext context) => const ListVariants();
Widget _listSizes(BuildContext context) => const ListSizes();
Widget _listDividers(BuildContext context) => const ListDividers();

Widget _breadcrumbHero(BuildContext context) => const BreadcrumbHero();
Widget _breadcrumbSeparators(BuildContext context) => const BreadcrumbSeparators();
Widget _breadcrumbCollapse(BuildContext context) => const BreadcrumbCollapse();
Widget _breadcrumbCurrent(BuildContext context) => const BreadcrumbCurrent();
Widget _breadcrumbSizes(BuildContext context) => const BreadcrumbSizes();

Widget _timelineHero(BuildContext context) => const TimelineHero();
Widget _timelineStatus(BuildContext context) => const TimelineStatus();
Widget _timelineActive(BuildContext context) => const TimelineActive();
Widget _timelineConnectors(BuildContext context) => const TimelineConnectors();
Widget _timelineOrientation(BuildContext context) => const TimelineOrientation();
Widget _timelineSizes(BuildContext context) => const TimelineSizes();

Widget _listHero(BuildContext context) => const ListHero();

Widget _checkboxHero(BuildContext context) => const CheckboxHero();
Widget _checkboxSizes(BuildContext context) => const CheckboxSizes();
Widget _checkboxColors(BuildContext context) => const CheckboxColors();
Widget _checkboxStates(BuildContext context) => const CheckboxStates();
Widget _checkboxIndeterminate(BuildContext context) => const CheckboxIndeterminate();

Widget _radioGroupHero(BuildContext context) => const RadioGroupHero();
Widget _radioGroupOrientation(BuildContext context) => const RadioGroupOrientation();
Widget _radioGroupSizes(BuildContext context) => const RadioGroupSizes();
Widget _radioGroupColors(BuildContext context) => const RadioGroupColors();
Widget _radioGroupStates(BuildContext context) => const RadioGroupStates();
Widget _radioGroupControlled(BuildContext context) => const RadioGroupControlled();

Widget _switchHero(BuildContext context) => const SwitchHero();
Widget _switchSizes(BuildContext context) => const SwitchSizes();
Widget _switchColors(BuildContext context) => const SwitchColors();
Widget _switchStates(BuildContext context) => const SwitchStates();
Widget _switchPlacement(BuildContext context) => const SwitchPlacement();

Widget _highlightHero(BuildContext context) => const HighlightHero();

Widget _textFieldHero(BuildContext context) => const TextFieldHero();
Widget _textFieldVariants(BuildContext context) => const TextFieldVariants();
Widget _textFieldSizes(BuildContext context) => const TextFieldSizes();
Widget _textFieldStates(BuildContext context) => const TextFieldStates();
Widget _textFieldIcons(BuildContext context) => const TextFieldIcons();
Widget _textFieldMultiline(BuildContext context) => const TextFieldMultiline();
Widget _textFieldValidation(BuildContext context) => const TextFieldValidation();
Widget _textFieldControlled(BuildContext context) => const TextFieldControlled();

Widget _sliderHero(BuildContext context) => const SliderHero();
Widget _sliderSizes(BuildContext context) => const SliderSizes();
Widget _sliderColors(BuildContext context) => const SliderColors();
Widget _sliderOrientation(BuildContext context) => const SliderOrientation();
Widget _sliderRange(BuildContext context) => const SliderRange();
Widget _sliderStates(BuildContext context) => const SliderStates();
Widget _sliderSteps(BuildContext context) => const SliderSteps();

Widget _toolbarHero(BuildContext context) => const ToolbarHero();
Widget _toolbarSlots(BuildContext context) => const ToolbarSlots();
Widget _toolbarVariants(BuildContext context) => const ToolbarVariants();
Widget _toolbarDensity(BuildContext context) => const ToolbarDensity();

Widget _spoilerHero(BuildContext context) => const SpoilerHero();
Widget _spoilerVariants(BuildContext context) => const SpoilerVariants();
Widget _spoilerClamped(BuildContext context) => const SpoilerClamped();
Widget _spoilerMedia(BuildContext context) => const SpoilerMedia();
Widget _popoverHero(BuildContext context) => const PopoverHero();
Widget _popoverSides(BuildContext context) => const PopoverSides();
Widget _popoverForm(BuildContext context) => const PopoverForm();
Widget _pillHero(BuildContext context) => const PillHero();
Widget _pillVariants(BuildContext context) => const PillVariants();
Widget _pillDetails(BuildContext context) => const PillDetails();
Widget _pillSizes(BuildContext context) => const PillSizes();
Widget _drawerHero(BuildContext context) => const DrawerHero();
Widget _drawerSides(BuildContext context) => const DrawerSides();
Widget _drawerInline(BuildContext context) => const DrawerInline();
Widget _collapsibleHero(BuildContext context) => const CollapsibleHero();
Widget _collapsibleVariants(BuildContext context) => const CollapsibleVariants();
Widget _collapsibleSlots(BuildContext context) => const CollapsibleSlots();
Widget _collapsibleTrigger(BuildContext context) => const CollapsibleTrigger();
Widget _carouselHero(BuildContext context) => const CarouselHero();
Widget _carouselVariants(BuildContext context) => const CarouselVariants();
Widget _carouselLoop(BuildContext context) => const CarouselLoop();
Widget _carouselAutoPlay(BuildContext context) => const CarouselAutoPlay();
Widget _boxHero(BuildContext context) => const BoxHero();
Widget _boxVariants(BuildContext context) => const BoxVariants();
Widget _boxSizes(BuildContext context) => const BoxSizes();
Widget _boxPadded(BuildContext context) => const BoxPadded();
Widget _scrollZoneHero(BuildContext context) => const ScrollZoneHero();
Widget _scrollZoneLines(BuildContext context) => const ScrollZoneLines();
Widget _scrollZoneButtons(BuildContext context) => const ScrollZoneButtons();
Widget _scrollZonePlacement(BuildContext context) => const ScrollZonePlacement();
Widget _segmentedButtonHero(BuildContext context) => const SegmentedButtonHero();
Widget _segmentedButtonVariants(BuildContext context) => const SegmentedButtonVariants();
Widget _segmentedButtonSizes(BuildContext context) => const SegmentedButtonSizes();
Widget _segmentedButtonColors(BuildContext context) => const SegmentedButtonColors();
Widget _segmentedButtonIcons(BuildContext context) => const SegmentedButtonIcons();
Widget _segmentedButtonFullWidth(BuildContext context) => const SegmentedButtonFullWidth();

Widget _paginationHero(BuildContext context) => const PaginationHero();
Widget _paginationVariants(BuildContext context) => const PaginationVariants();
Widget _paginationSizes(BuildContext context) => const PaginationSizes();
Widget _paginationWindow(BuildContext context) => const PaginationWindow();
Widget _paginationSteppers(BuildContext context) => const PaginationSteppers();

Widget _accordionHero(BuildContext context) => const AccordionHero();
Widget _accordionVariants(BuildContext context) => const AccordionVariants();
Widget _accordionSizes(BuildContext context) => const AccordionSizes();
Widget _accordionMultiple(BuildContext context) => const AccordionMultiple();
Widget _accordionDividers(BuildContext context) => const AccordionDividers();
Widget _accordionSlots(BuildContext context) => const AccordionSlots();
Widget _accordionControlled(BuildContext context) => const AccordionControlled();

Widget _tabsHero(BuildContext context) => const TabsHero();
Widget _tabsVariants(BuildContext context) => const TabsVariants();
Widget _tabsSizes(BuildContext context) => const TabsSizes();
Widget _tabsOrientation(BuildContext context) => const TabsOrientation();
Widget _tabsFullWidth(BuildContext context) => const TabsFullWidth();
Widget _tabsControlled(BuildContext context) => const TabsControlled();

Widget _tableHero(BuildContext context) => const TableHero();
Widget _tableVariants(BuildContext context) => const TableVariants();
Widget _tableColumns(BuildContext context) => const TableColumns();
Widget _tableStriped(BuildContext context) => const TableStriped();
Widget _tableScroll(BuildContext context) => const TableScroll();
Widget _tableRows(BuildContext context) => const TableRows();
Widget _tableEmpty(BuildContext context) => const TableEmpty();
Widget _tableDensity(BuildContext context) => const TableDensity();

Widget _numberFieldHero(BuildContext context) => const NumberFieldHero();
Widget _numberFieldSteppers(BuildContext context) => const NumberFieldSteppers();
Widget _numberFieldFormat(BuildContext context) => const NumberFieldFormat();
Widget _numberFieldSteps(BuildContext context) => const NumberFieldSteps();
Widget _numberFieldVariants(BuildContext context) => const NumberFieldVariants();
Widget _numberFieldStates(BuildContext context) => const NumberFieldStates();
Widget _numberFieldSizes(BuildContext context) => const NumberFieldSizes();

Widget _modalHero(BuildContext context) => const ModalHero();
Widget _modalSizes(BuildContext context) => const ModalSizes();
Widget _modalDividers(BuildContext context) => const ModalDividers();
Widget _modalControlled(BuildContext context) => const ModalControlled();
Widget _modalDismissible(BuildContext context) => const ModalDismissible();

Widget _overlayHero(BuildContext context) => const OverlayHero();
Widget _overlayTones(BuildContext context) => const OverlayTones();
Widget _overlayDismissible(BuildContext context) => const OverlayDismissible();
Widget _overlayAlign(BuildContext context) => const OverlayAlign();

Widget _tooltipHero(BuildContext context) => const TooltipHero();
Widget _tooltipSides(BuildContext context) => const TooltipSides();
Widget _tooltipAlign(BuildContext context) => const TooltipAlign();
Widget _tooltipProvider(BuildContext context) => const TooltipProvider();
Widget _tooltipDelay(BuildContext context) => const TooltipDelay();
Widget _tooltipSizes(BuildContext context) => const TooltipSizes();

Widget _selectHero(BuildContext context) => const SelectHero();
Widget _selectVariants(BuildContext context) => const SelectVariants();
Widget _selectSizes(BuildContext context) => const SelectSizes();
Widget _selectStates(BuildContext context) => const SelectStates();
Widget _selectControlled(BuildContext context) => const SelectControlled();
Widget _selectIcons(BuildContext context) => const SelectIcons();

Widget _toastHero(BuildContext context) => const ToastHero();
Widget _toastPositions(BuildContext context) => const ToastPositions();
Widget _toastVariants(BuildContext context) => const ToastVariants();
Widget _toastColors(BuildContext context) => const ToastColors();
Widget _toastUpdate(BuildContext context) => const ToastUpdate();
Widget _toastFuture(BuildContext context) => const ToastFuture();

Widget _chatBubbleHero(BuildContext context) => const ChatBubbleHero();
Widget _chatBubbleSides(BuildContext context) => const ChatBubbleSides();
Widget _chatBubbleVariants(BuildContext context) => const ChatBubbleVariants();
Widget _chatBubbleStatus(BuildContext context) => const ChatBubbleStatus();
Widget _chatBubbleMedia(BuildContext context) => const ChatBubbleMedia();
Widget _chatBubbleActions(BuildContext context) => const ChatBubbleActions();
Widget _chatBubbleSizes(BuildContext context) => const ChatBubbleSizes();

Widget _filePickerHero(BuildContext context) => const FilePickerHero();
Widget _filePickerVariants(BuildContext context) => const FilePickerVariants();
Widget _filePickerRejections(BuildContext context) => const FilePickerRejections();
Widget _filePickerSingle(BuildContext context) => const FilePickerSingle();
Widget _filePickerSizes(BuildContext context) => const FilePickerSizes();
Widget _filePickerStates(BuildContext context) => const FilePickerStates();
Widget _animateFadeHero(BuildContext context) => const AnimateFadeHero();
Widget _animateFadeMode(BuildContext context) => const AnimateFadeMode();
Widget _animateFadeTiming(BuildContext context) => const AnimateFadeTiming();
Widget _animateFadeTriggers(BuildContext context) => const AnimateFadeTriggers();
Widget _animateGrowHero(BuildContext context) => const AnimateGrowHero();
Widget _animateGrowOrigin(BuildContext context) => const AnimateGrowOrigin();
Widget _animateGrowFrom(BuildContext context) => const AnimateGrowFrom();
Widget _animateGrowPanel(BuildContext context) => const AnimateGrowPanel();
