import 'package:flutter/widgets.dart';

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
import 'package:plass_ui_example/demos/checkbox/colors.dart';
import 'package:plass_ui_example/demos/checkbox/hero.dart';
import 'package:plass_ui_example/demos/checkbox/indeterminate.dart';
import 'package:plass_ui_example/demos/checkbox/sizes.dart';
import 'package:plass_ui_example/demos/checkbox/states.dart';
import 'package:plass_ui_example/demos/divider/colors.dart';
import 'package:plass_ui_example/demos/divider/hero.dart';
import 'package:plass_ui_example/demos/divider/label.dart';
import 'package:plass_ui_example/demos/divider/length.dart';
import 'package:plass_ui_example/demos/divider/orientation.dart';
import 'package:plass_ui_example/demos/divider/sizes.dart';
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
import 'package:plass_ui_example/demos/list/dividers.dart';
import 'package:plass_ui_example/demos/list/hero.dart';
import 'package:plass_ui_example/demos/list/rows.dart';
import 'package:plass_ui_example/demos/list/sizes.dart';
import 'package:plass_ui_example/demos/list/variants.dart';
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
import 'package:plass_ui_example/demos/overlay/align.dart';
import 'package:plass_ui_example/demos/overlay/dismissible.dart';
import 'package:plass_ui_example/demos/overlay/hero.dart';
import 'package:plass_ui_example/demos/overlay/tones.dart';
import 'package:plass_ui_example/demos/pagination/hero.dart';
import 'package:plass_ui_example/demos/pagination/sizes.dart';
import 'package:plass_ui_example/demos/pagination/steppers.dart';
import 'package:plass_ui_example/demos/pagination/variants.dart';
import 'package:plass_ui_example/demos/pagination/window.dart';
import 'package:plass_ui_example/demos/radio_group/colors.dart';
import 'package:plass_ui_example/demos/radio_group/controlled.dart';
import 'package:plass_ui_example/demos/radio_group/hero.dart';
import 'package:plass_ui_example/demos/radio_group/orientation.dart';
import 'package:plass_ui_example/demos/radio_group/sizes.dart';
import 'package:plass_ui_example/demos/radio_group/states.dart';
import 'package:plass_ui_example/demos/segmented_button/colors.dart';
import 'package:plass_ui_example/demos/segmented_button/full_width.dart';
import 'package:plass_ui_example/demos/segmented_button/hero.dart';
import 'package:plass_ui_example/demos/segmented_button/icons.dart';
import 'package:plass_ui_example/demos/segmented_button/sizes.dart';
import 'package:plass_ui_example/demos/segmented_button/variants.dart';
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
import 'package:plass_ui_example/demos/timeline/active.dart';
import 'package:plass_ui_example/demos/timeline/connectors.dart';
import 'package:plass_ui_example/demos/timeline/hero.dart';
import 'package:plass_ui_example/demos/timeline/orientation.dart';
import 'package:plass_ui_example/demos/timeline/sizes.dart';
import 'package:plass_ui_example/demos/timeline/status.dart';
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
  'blockquote/hero': _blockquoteHero,
  'blockquote/variants': _blockquoteVariants,
  'blockquote/sizes': _blockquoteSizes,
  'blockquote/colors': _blockquoteColors,
  'blockquote/attribution': _blockquoteAttribution,
  'highlight/variants': _highlightVariants,
  'highlight/colors': _highlightColors,
  'highlight/matching': _highlightMatching,
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
  'table/rows': _tableRows,
  'table/empty': _tableEmpty,
  'table/density': _tableDensity,
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
};

Widget _hero(BuildContext context) => const ButtonHero();
Widget _variants(BuildContext context) => const ButtonVariants();
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
