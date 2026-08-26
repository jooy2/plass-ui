import 'package:flutter/widgets.dart';

import 'package:plass_ui_example/demos/blockquote/attribution.dart';
import 'package:plass_ui_example/demos/blockquote/colors.dart';
import 'package:plass_ui_example/demos/blockquote/hero.dart';
import 'package:plass_ui_example/demos/blockquote/sizes.dart';
import 'package:plass_ui_example/demos/blockquote/variants.dart';
import 'package:plass_ui_example/demos/button/colors.dart';
import 'package:plass_ui_example/demos/button/density.dart';
import 'package:plass_ui_example/demos/button/elevation.dart';
import 'package:plass_ui_example/demos/button/full_width.dart';
import 'package:plass_ui_example/demos/button/hero.dart';
import 'package:plass_ui_example/demos/button/icons.dart';
import 'package:plass_ui_example/demos/button/sizes.dart';
import 'package:plass_ui_example/demos/button/states.dart';
import 'package:plass_ui_example/demos/button/variants.dart';
import 'package:plass_ui_example/demos/divider/colors.dart';
import 'package:plass_ui_example/demos/divider/hero.dart';
import 'package:plass_ui_example/demos/divider/label.dart';
import 'package:plass_ui_example/demos/divider/length.dart';
import 'package:plass_ui_example/demos/divider/orientation.dart';
import 'package:plass_ui_example/demos/divider/sizes.dart';
import 'package:plass_ui_example/demos/highlight/colors.dart';
import 'package:plass_ui_example/demos/highlight/matching.dart';
import 'package:plass_ui_example/demos/highlight/variants.dart';
import 'package:plass_ui_example/demos/icon/anything.dart';
import 'package:plass_ui_example/demos/icon/colors.dart';
import 'package:plass_ui_example/demos/icon/hero.dart';
import 'package:plass_ui_example/demos/icon/inside.dart';
import 'package:plass_ui_example/demos/icon/sizes.dart';
import 'package:plass_ui_example/demos/skeleton/animated.dart';
import 'package:plass_ui_example/demos/skeleton/shapes.dart';
import 'package:plass_ui_example/demos/skeleton/sizes.dart';
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
